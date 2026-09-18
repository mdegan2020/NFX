function bytes = pixelBlockBytes(pixels, rows, cols, frame, band, width, height) %#codegen
    %pixelBlockBytes - Encode one padded native block in row-major byte order
    block = zeros(width, height, 'like', pixels);
    block(1:numel(cols), 1:numel(rows)) = pixels(rows, cols, band, frame).';
    if isa(block, 'uint16')
        buffer = zeros(2, numel(block), 'uint8');
        buffer(1,:) = uint8(bitshift(block(:), -8));
        buffer(2,:) = uint8(bitand(block(:), uint16(255)));
        bytes = reshape(buffer, 1, []);
    else
        bytes = reshape(block, 1, []);
    end
end
