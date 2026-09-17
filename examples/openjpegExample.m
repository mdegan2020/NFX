function [file, metrics] = openjpegExample(encoder)
    %openjpegExample - Build NPJE and EPJE segments from synthetic pixels
    %   [FILE, METRICS] = openjpegExample(ENCODER) encodes the same
    %   five-band uint16 pixels into two still image segments. ENCODER is
    %   the path to opj_compress.exe 2.5.4 on Windows. FILE is ready for
    %   FILE.write.
    %   METRICS contains individual encoding timings, not benchmark
    %   averages.
    %
    %   See also nfx.JPEG2000, nfx.ImageSegment, nfx.File

    arguments
        encoder {mustBeTextScalar, mustBeNonzeroLengthText}
    end

    pixels = reshape( ...
        uint16(mod((0:1030 * 1032 * 5 - 1) * 251 + 17, 4096)), ...
        1030, 1032, 5);
    image = nfx.ImageSegment(pixels, header=nfx.ImageHeader( ...
        iid1='NPJE', idatim='20260916000000', ...
        isclas='U', irep='MULTI', icat='MS'));

    first = image.compress(encoder, Profile='NPJE');
    image.header.iid1 = 'EPJE';
    second = image.compress(encoder, Profile='EPJE');

    file = nfx.File(header=nfx.FileHeader(ostaid='NFXDEMO', ...
        fdt='20260916000000', fsclas='U', ...
        ftitle='Synthetic OpenJPEG prototype')) + first + second;
    metrics = struct2table([ ...
        first.compression.metrics second.compression.metrics]);
    metrics.profile = ["NPJE"; "EPJE"];
end
