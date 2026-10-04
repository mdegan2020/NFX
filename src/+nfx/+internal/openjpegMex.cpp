// In-memory OpenJPEG adapter. Profile normalization remains in MATLAB.
// Build with buildOpenJPEGMex; OpenJPEG notices are in THIRD_PARTY_NOTICES.md.
#include "mex.h"
#include "openjpeg.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <memory>
#include <mutex>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
using Codec = std::unique_ptr<opj_codec_t, decltype(&opj_destroy_codec)>;
using Image = std::unique_ptr<opj_image_t, decltype(&opj_image_destroy)>;
using Stream = std::unique_ptr<opj_stream_t, decltype(&opj_stream_destroy)>;
using Array = std::unique_ptr<mxArray, decltype(&mxDestroyArray)>;

struct Failure : std::runtime_error {
    const char* id;
    Failure(const char* id_, const std::string& message)
        : std::runtime_error(message), id(id_) {}
};
void require(bool condition, const char* message) {
    if (!condition) throw Failure("nfx:OpenJPEGMexInput", message);
}

// MATLAB allocation failure may terminate a C MEX without native unwinding.
// Create the small arguments before owning codec buffers, and trap the large
// result allocation so OpenJPEG/STL owners are released on allocation failure.
struct Allocator {
    Array name{mxCreateString("zeros"), mxDestroyArray};
    Array dimensions{mxCreateDoubleMatrix(1, 3, mxREAL), mxDestroyArray};
    Array uint8Name{mxCreateString("uint8"), mxDestroyArray};
    Array uint16Name{mxCreateString("uint16"), mxDestroyArray};

    Array create(size_t rows, size_t cols, size_t bands, unsigned precision) {
        auto* dims = mxGetDoubles(dimensions.get());
        dims[0] = static_cast<double>(rows);
        dims[1] = static_cast<double>(cols);
        dims[2] = static_cast<double>(bands);
        mxArray* arguments[] = {name.get(), dimensions.get(),
            precision == 8 ? uint8Name.get() : uint16Name.get()};
        mxArray* output = nullptr;
        Array error(mexCallMATLABWithTrap(1, &output, 3, arguments, "builtin"),
            mxDestroyArray);
        Array result(output, mxDestroyArray);
        if (error || !result)
            throw Failure("nfx:OpenJPEGResourceLimit",
                "MATLAB could not allocate the codec result array.");
        return result;
    }
};

// Never invoke MATLAB, allocate, or let an exception escape a C callback.
struct Messages {
    std::mutex mutex;
    bool failed = false;
    char text[2048] = {};
};
void message(const char* text, void* context) noexcept {
    auto& messages = *static_cast<Messages*>(context);
    try {
        std::lock_guard<std::mutex> lock(messages.mutex);
        messages.failed = true;
        if (!messages.text[0] && text) {
            std::strncpy(messages.text, text, sizeof(messages.text) - 1);
        }
    } catch (...) {}
}
void check(bool success, Messages& messages) {
    std::lock_guard<std::mutex> lock(messages.mutex);
    if (!success || messages.failed) {
        throw Failure("nfx:OpenJPEGCodec", messages.text[0] ?
            messages.text : "OpenJPEG could not complete the operation.");
    }
}
void handlers(opj_codec_t* codec, Messages& messages) {
    if (!codec) throw std::bad_alloc();
    opj_set_error_handler(codec, message, &messages);
    opj_set_warning_handler(codec, message, &messages);
    opj_set_info_handler(codec, nullptr, nullptr);
}

struct Buffer {
    const uint8_t* input = nullptr;
    size_t length = 0;
    size_t position = 0;
    bool writing = false;
    std::vector<uint8_t> output;
};
OPJ_SIZE_T read(void* target, OPJ_SIZE_T count, void* context) noexcept {
    auto& buffer = *static_cast<Buffer*>(context);
    count = std::min(count, buffer.length - buffer.position);
    if (!count) return static_cast<OPJ_SIZE_T>(-1);
    std::memcpy(target, buffer.input + buffer.position, count);
    buffer.position += count;
    return count;
}
OPJ_SIZE_T write(void* source, OPJ_SIZE_T count, void* context) noexcept {
    auto& buffer = *static_cast<Buffer*>(context);
    if (count > buffer.output.max_size() - buffer.position)
        return static_cast<OPJ_SIZE_T>(-1);
    try {
        const size_t end = buffer.position + count;
        if (end > buffer.output.size()) buffer.output.resize(end);
        std::memcpy(buffer.output.data() + buffer.position, source, count);
        buffer.position = end;
        return count;
    } catch (...) { return static_cast<OPJ_SIZE_T>(-1); }
}
OPJ_BOOL seek(OPJ_OFF_T offset, void* context) noexcept {
    auto& buffer = *static_cast<Buffer*>(context);
    if (offset < 0) return OPJ_FALSE;
    const uint64_t end = static_cast<uint64_t>(offset);
    if (!buffer.writing && end > buffer.length) return OPJ_FALSE;
    if (buffer.writing) {
        if (end > buffer.output.max_size()) return OPJ_FALSE;
        try {
            if (end > buffer.output.size())
                buffer.output.resize(static_cast<size_t>(end));
        } catch (...) { return OPJ_FALSE; }
    }
    buffer.position = static_cast<size_t>(end);
    return OPJ_TRUE;
}
OPJ_OFF_T skip(OPJ_OFF_T offset, void* context) noexcept {
    const auto& buffer = *static_cast<Buffer*>(context);
    if (buffer.position > static_cast<size_t>(INT64_MAX)) return -1;
    const auto position = static_cast<OPJ_OFF_T>(buffer.position);
    if (offset > 0 && offset > INT64_MAX - position) return -1;
    if (offset < -position) return -1;
    return seek(position + offset, context) ? offset : -1;
}
Stream streamFor(Buffer& buffer) {
    Stream stream(opj_stream_create(65536, !buffer.writing), opj_stream_destroy);
    if (!stream) throw std::bad_alloc();
    opj_stream_set_user_data(stream.get(), &buffer, nullptr);
    opj_stream_set_user_data_length(stream.get(), buffer.length);
    opj_stream_set_seek_function(stream.get(), seek);
    opj_stream_set_skip_function(stream.get(), skip);
    if (buffer.writing) opj_stream_set_write_function(stream.get(), write);
    else opj_stream_set_read_function(stream.get(), read);
    return stream;
}
std::string text(const mxArray* array) {
    require(mxIsChar(array) && mxGetM(array) == 1, "Expected row character text.");
    std::string value(mxGetNumberOfElements(array), '\0');
    const auto* chars = mxGetChars(array);
    for (size_t k = 0; k < value.size(); ++k) {
        require(chars[k] > 0 && chars[k] < 128, "Expected ASCII text.");
        value[k] = static_cast<char>(chars[k]);
    }
    return value;
}
double integer(const mxArray* array, double maximum) {
    require(mxIsDouble(array) && !mxIsComplex(array) && !mxIsSparse(array) &&
        mxGetNumberOfElements(array) == 1, "Expected a scalar double integer.");
    const double value = mxGetScalar(array);
    require(std::isfinite(value) && value >= 1 && value <= maximum &&
        value == std::floor(value), "Integer option is out of range.");
    return value;
}
size_t product(size_t a, size_t b) {
    require(b == 0 || a <= std::numeric_limits<size_t>::max() / b,
        "Image size exceeds addressable memory.");
    return a * b;
}
template<class T>
void fromMatlab(const T* source, opj_image_t* image, size_t rows, size_t cols) {
    const size_t plane = product(rows, cols);
    for (size_t band = 0; band < image->numcomps; ++band)
        for (size_t col = 0; col < cols; ++col)
            for (size_t row = 0; row < rows; ++row)
                image->comps[band].data[row * cols + col] =
                    source[band * plane + col * rows + row];
}
template<class T>
void toMatlab(T* target, const opj_image_t* image, size_t rows, size_t cols) {
    const size_t plane = product(rows, cols);
    for (size_t band = 0; band < image->numcomps; ++band)
        for (size_t col = 0; col < cols; ++col)
            for (size_t row = 0; row < rows; ++row) {
                const auto value = image->comps[band].data[row * cols + col];
                if (value < 0 || value > std::numeric_limits<T>::max())
                    throw Failure("nfx:OpenJPEGCodec", "Decoded sample out of range.");
                target[band * plane + col * rows + row] = static_cast<T>(value);
            }
}
mxArray* encode(const mxArray* data, const std::string& profile, int threads,
    Allocator& allocator) {
    require(!mxIsSparse(data) && !mxIsComplex(data) &&
        (mxIsUint8(data) || mxIsUint16(data)) && mxGetNumberOfDimensions(data) <= 3,
        "Expected a full uint8 or uint16 image array.");
    require(profile == "NPJE" || profile == "EPJE", "Unknown profile.");
    const auto* dims = mxGetDimensions(data);
    const size_t rows = dims[0], cols = dims[1];
    const size_t bands = mxGetNumberOfDimensions(data) == 3 ? dims[2] : 1;
    const bool epje = profile == "EPJE";
    require(rows >= 32 && cols >= 32 && rows <= INT32_MAX && cols <= INT32_MAX &&
        bands >= 1 && bands <= (epje ? 3276u : 16384u), "Unsupported image geometry.");
    const size_t tiles = product((rows + 1023) / 1024, (cols + 1023) / 1024);
    require(tiles <= (epje ? 65535u : 16382u), "Too many tiles for the profile.");
    product(product(rows, cols), product(bands, sizeof(OPJ_INT32)));
    const unsigned precision = mxIsUint16(data) ? 16 : 8;
    std::vector<opj_image_cmptparm_t> components(bands);
    for (auto& c : components) {
        c.dx = c.dy = 1; c.w = static_cast<OPJ_UINT32>(cols);
        c.h = static_cast<OPJ_UINT32>(rows); c.prec = precision;
    }
    Image image(opj_image_create(static_cast<OPJ_UINT32>(bands), components.data(),
        bands == 1 ? OPJ_CLRSPC_GRAY : OPJ_CLRSPC_UNSPECIFIED), opj_image_destroy);
    if (!image) throw std::bad_alloc();
    image->x1 = static_cast<OPJ_UINT32>(cols);
    image->y1 = static_cast<OPJ_UINT32>(rows);
    if (precision == 8) fromMatlab(mxGetUint8s(data), image.get(), rows, cols);
    else fromMatlab(mxGetUint16s(data), image.get(), rows, cols);
    opj_cparameters_t p;
    opj_set_default_encoder_parameters(&p);
    p.tile_size_on = OPJ_TRUE; p.cp_tdx = p.cp_tdy = 1024;
    p.numresolution = 6; p.cblockw_init = p.cblockh_init = 64;
    p.prog_order = epje ? OPJ_RLCP : OPJ_LRCP;
    p.tcp_mct = 0; p.irreversible = 0; p.cp_disto_alloc = 1;
    p.tcp_numlayers = 20;
    const double targets[] = {.03125, .0625, .125, .25, .5, .6, .7, .8, .9,
        1, 1.1, 1.2, 1.3, 1.5, 1.7, 2, 2.3, 2.8, 3.5};
    for (int k = 0; k < 19; ++k)
        p.tcp_rates[k] = static_cast<float>(precision / targets[k]);
    p.tcp_rates[19] = 1;
    char comment[] = "NFX_OpenJPEG_2.5.4"; p.cp_comment = comment;
    if (epje) { p.tp_on = 1; p.tp_flag = 'R'; }
    Messages messages;
    Codec codec(opj_create_compress(OPJ_CODEC_J2K), opj_destroy_codec);
    handlers(codec.get(), messages);
    check(opj_setup_encoder(codec.get(), &p, image.get()), messages);
    const char* options[] = {"PLT=YES", "TLM=YES", "GUARD_BITS=2", nullptr};
    check(opj_encoder_set_extra_options(codec.get(), options), messages);
    check(opj_codec_set_threads(codec.get(), threads), messages);
    Buffer buffer; buffer.writing = true;
    auto stream = streamFor(buffer);
    check(opj_start_compress(codec.get(), image.get(), stream.get()), messages);
    check(opj_encode(codec.get(), stream.get()), messages);
    check(opj_end_compress(codec.get(), stream.get()), messages);
    stream.reset(); codec.reset(); image.reset();
    auto result = allocator.create(1, buffer.output.size(), 1, 8);
    std::memcpy(mxGetUint8s(result.get()), buffer.output.data(), buffer.output.size());
    return result.release();
}
mxArray* decode(const mxArray* data, double maximum, int threads, Allocator& allocator) {
    require(mxIsUint8(data) && !mxIsComplex(data) && !mxIsSparse(data) &&
        mxGetNumberOfDimensions(data) == 2 && mxGetM(data) == 1 &&
        mxGetNumberOfElements(data) >= 4, "Expected a uint8 row codestream.");
    Buffer buffer; buffer.input = mxGetUint8s(data);
    buffer.length = mxGetNumberOfElements(data);
    require(buffer.input[0] == 255 && buffer.input[1] == 79,
        "Expected a raw JPEG2000 codestream.");
    Messages messages;
    Codec codec(opj_create_decompress(OPJ_CODEC_J2K), opj_destroy_codec);
    handlers(codec.get(), messages);
    opj_dparameters_t p; opj_set_default_decoder_parameters(&p);
    check(opj_setup_decoder(codec.get(), &p), messages);
    check(opj_decoder_set_strict_mode(codec.get(), OPJ_TRUE), messages);
    check(opj_codec_set_threads(codec.get(), threads), messages);
    auto stream = streamFor(buffer);
    opj_image_t* raw = nullptr;
    const bool headerRead = opj_read_header(stream.get(), codec.get(), &raw);
    Image image(raw, opj_image_destroy);
    check(headerRead && image != nullptr, messages);
    require(image->x0 == 0 && image->y0 == 0 && image->x1 >= 32 &&
        image->y1 >= 32 && image->numcomps >= 1 && image->numcomps <= 16384,
        "Unsupported image geometry.");
    const size_t rows = image->y1, cols = image->x1, bands = image->numcomps;
    const size_t samples = product(product(rows, cols), bands);
    if (samples > static_cast<size_t>(maximum))
        throw Failure("nfx:OpenJPEGResourceLimit", "Decoded samples exceed MaxPixels.");
    product(samples, sizeof(OPJ_INT32));
    const auto precision = image->comps[0].prec;
    require(precision == 8 || precision == 16, "Expected 8/16-bit components.");
    for (size_t band = 0; band < bands; ++band) {
        const auto& c = image->comps[band];
        require(c.dx == 1 && c.dy == 1 && c.x0 == 0 && c.y0 == 0 &&
            c.w == cols && c.h == rows && c.prec == precision && c.sgnd == 0,
            "Expected unsigned components with matching geometry.");
    }
    check(opj_decode(codec.get(), stream.get(), image.get()), messages);
    check(opj_end_decompress(codec.get(), stream.get()), messages);
    for (size_t band = 0; band < bands; ++band)
        check(image->comps[band].data != nullptr, messages);
    stream.reset(); codec.reset();
    auto result = allocator.create(rows, cols, bands, precision);
    if (precision == 8) toMatlab(mxGetUint8s(result.get()), image.get(), rows, cols);
    else toMatlab(mxGetUint16s(result.get()), image.get(), rows, cols);
    return result.release();
}
mxArray* dispatch(int inputs, const mxArray* arguments[], Allocator& allocator) {
    require(inputs >= 1, "Supply info, encode, or decode.");
    const auto operation = text(arguments[0]);
    if (operation == "info") {
        require(inputs == 1, "info takes no additional inputs.");
        return mxCreateString(opj_version());
    }
    require(inputs == 4, "encode/decode require data, profile/MaxPixels, Threads.");
    const int threads = static_cast<int>(integer(arguments[3], INT32_MAX));
    if (operation == "encode")
        return encode(arguments[1], text(arguments[2]), threads, allocator);
    if (operation == "decode")
        return decode(arguments[1], integer(arguments[2], 9007199254740992.0),
            threads, allocator);
    throw Failure("nfx:OpenJPEGMexInput", "Unknown operation.");
}
} // namespace

void mexFunction(int outputs, mxArray* result[], int inputs, const mxArray* arguments[]) {
    // Unwind all native resources before entering MATLAB's error mechanism.
    char id[128] = {}, messageText[4096] = {};
    try {
        Allocator allocator;
        require(outputs <= 1, "At most one output is supported.");
        Array value(dispatch(inputs, arguments, allocator), mxDestroyArray);
        if (outputs == 1) result[0] = value.release();
        return;
    } catch (const Failure& error) {
        std::strncpy(id, error.id, sizeof(id) - 1);
        std::strncpy(messageText, error.what(), sizeof(messageText) - 1);
    } catch (const std::bad_alloc&) {
        std::strncpy(id, "nfx:OpenJPEGResourceLimit", sizeof(id) - 1);
        std::strncpy(messageText, "OpenJPEG could not allocate native buffers.",
            sizeof(messageText) - 1);
    } catch (const std::exception& error) {
        std::strncpy(id, "nfx:OpenJPEGNative", sizeof(id) - 1);
        std::strncpy(messageText, error.what(), sizeof(messageText) - 1);
    } catch (...) {
        std::strncpy(id, "nfx:OpenJPEGNative", sizeof(id) - 1);
        std::strncpy(messageText, "Unexpected native codec failure.", sizeof(messageText) - 1);
    }
    mexErrMsgIdAndTxt(id, "%s", messageText);
}
