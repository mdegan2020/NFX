function stats = pixelStatistics(data) %#codegen
    %pixelStatistics - Reduce native samples with bounded temporary storage
    width = 8;
    if isa(data, 'uint16'), width = 16; end
    largest = cast(0, 'like', data);
    trailing = width;
    for first = 1:65536:numel(data)
        block = data(first:min(first+65535, numel(data)));
        largest = max(largest, max(block));
        while trailing > 0 && any(bitand(block, cast(2^trailing-1, 'like', data)) ~= 0)
            trailing = trailing - 1;
        end
    end
    bits = 1;
    while double(largest) >= 2^bits, bits = bits + 1; end
    stats = struct('bits', bits, 'trailing', trailing);
end
