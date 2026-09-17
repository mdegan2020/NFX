function [pixels, ok, status] = readPixels(data, entry, maxPixels, prototype) %#codegen
    %readPixels - Decode checked NC B/F/T blocks with a fixed output class
    %   PROTOTYPE is an empty uint8 or uint16 array. It keeps each generated
    %   entry point's primitive pixel class explicit. Samples retain their
    %   stored justification; only zero block padding is removed.
    pixels = zeros(0, 0, 'like', prototype);
    status = nfx.internal.readStatus(); ok = false;
    h = entry.header; layout = entry.layout; location = entry.location;
    status.scope = 'image'; status.offset = location.dataOffset;
    if ~strcmp(layout.ic, 'NC')
        status.code = 'UnsupportedFeature';
        status.message = 'This pixel decoder requires uncompressed NC data.';
        return
    end
    width = 1 + isa(prototype, 'uint16');
    if ~(isa(prototype, 'uint8') || isa(prototype, 'uint16')) || layout.nbpp ~= 8 * width
        status.code = 'InvalidInput';
        status.message = 'Pixel prototype must agree with the stored NBPP.';
        return
    end
    blockSamples = h.nppbh * h.nppbv;
    frameBytes = blockSamples * layout.nbpr * layout.nbpc * layout.bands * width;
    frames = location.dataLength / frameBytes;
    validMode = (strcmp(layout.imode, 'B') && frames == 1) || ...
        (strcmp(layout.imode, 'F') && frames > 1 && layout.bands == 1) || ...
        (strcmp(layout.imode, 'T') && frames > 1 && layout.bands > 1);
    if ~isfinite(frames) || frames < 1 || fix(frames) ~= frames || ~validMode
        status.code = 'MalformedFile';
        status.message = 'Stored image length disagrees with its block/frame layout.';
        return
    end
    samples = layout.nrows * layout.ncols * layout.bands * frames;
    if samples > maxPixels
        status.code = 'ResourceLimit';
        status.message = 'Decoded image samples exceed MaxPixels.';
        return
    end
    pixels = zeros(layout.nrows, layout.ncols, layout.bands, frames, 'like', prototype);
    at = location.dataOffset;
    for blockRow = 1:layout.nbpc
        firstRow = (blockRow - 1) * h.nppbv + 1;
        rows = firstRow:min(firstRow + h.nppbv - 1, layout.nrows);
        for blockColumn = 1:layout.nbpr
            firstColumn = (blockColumn - 1) * h.nppbh + 1;
            columns = firstColumn:min(firstColumn + h.nppbh - 1, layout.ncols);
            for frame = 1:frames
                for band = 1:layout.bands
                    % Decode one row-major block, independent of host endian.
                    raw = data(at + (1:width * blockSamples));
                    values = cast(raw, 'like', prototype);
                    if isa(prototype, 'uint16')
                        values = bitshift(values(1:2:end), 8) + values(2:2:end);
                    end
                    block = reshape(values, h.nppbh, h.nppbv).';
                    if any(block(numel(rows) + 1:end, :) ~= 0, 'all') || ...
                            any(block(1:numel(rows), numel(columns) + 1:end) ~= 0, 'all')
                        pixels = zeros(0, 0, 'like', prototype);
                        status.code = 'UnsupportedFeature';
                        status.message = 'Nonzero edge padding is outside the NFX encoding.';
                        status.offset = at;
                        return
                    end
                    pixels(rows, columns, band, frame) = block(1:numel(rows), 1:numel(columns));
                    at = at + width * blockSamples;
                end
            end
        end
    end
    ok = true; status = nfx.internal.readStatus();
end
