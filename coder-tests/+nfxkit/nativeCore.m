function result = nativeCore(raw, prototype) %#codegen
    %nativeCore - Probe fixed-class native reader and actual writer byte paths
    result = struct('ok', false, 'code', '', 'samples', reshape(prototype, 1, []), ...
        'headers', zeros(1, 0, 'uint8'), 'storage', zeros(1, 0, 'uint8'), ...
        'clevel', 0);
    [index, ok, status] = nfx.internal.indexNITF(raw);
    result.code = status.code;
    if ~ok, return, end
    % File owns structural fields; the index exposes them separately. Probe
    % editable metadata here and the derived file header in fileCore.
    headerBytes = index.header.bytes();
    result.headers = headerBytes([1:9 12:342]);
    result.clevel = index.clevel;
    for k = 1:numel(index.images)
        entry = index.images(k);
        [pixels, ok, status] = nfx.internal.readPixels(raw, entry, 10000, prototype);
        if ~ok, result.code = status.code; return, end
        image = nfx.ImageSegment(pixels, header=entry.header); h = image.header;
        extended = raw(entry.extended.offset + (1:entry.extended.length));
        user = raw(entry.user.offset + (1:entry.user.length));
        result.headers = [result.headers h.bytes(extended, entry.extended.overflow, ...
            user, entry.user.overflow)];
        result.samples = [result.samples reshape(pixels, 1, [])];
        for blockRow = 1:h.nbpc
            rows = (blockRow - 1) * h.nppbv + 1:min(blockRow * h.nppbv, h.nrows);
            for blockCol = 1:h.nbpr
                cols = (blockCol - 1) * h.nppbh + 1:min(blockCol * h.nppbh, h.ncols);
                for frame = 1:image.number_frames
                    for band = 1:size(pixels, 3)
                        result.storage = [result.storage nfx.internal.pixelBlockBytes( ...
                            pixels, rows, cols, frame, band, h.nppbh, h.nppbv)];
                    end
                end
            end
        end
    end
    result.ok = true;
end
