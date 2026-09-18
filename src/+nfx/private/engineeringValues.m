function value = engineeringValues(bytes, prototype, width) %#codegen
    %engineeringValues - Decode exact integer bits using an explicit type
    if ischar(prototype)
        value = char(bytes);
        return
    end
    scalarWidth = width;
    if ~isreal(prototype), scalarWidth = width / 2; end
    bits = zeros(1, numel(bytes) / scalarWidth, 'uint64');
    for k = 1:numel(bits)
        for j = 1:scalarWidth
            bits(k) = bitor(bitshift(bits(k), 8), ...
                uint64(bytes((k - 1) * scalarWidth + j)));
        end
    end
    if isa(prototype, 'uint8')
        value = uint8(bits);
    elseif isa(prototype, 'uint16')
        value = uint16(bits);
    elseif isa(prototype, 'uint32')
        value = uint32(bits);
    elseif isa(prototype, 'uint64')
        value = bits;
    elseif isa(prototype, 'int8')
        value = typecast(uint8(bits), 'int8');
    elseif isa(prototype, 'int16')
        value = typecast(uint16(bits), 'int16');
    elseif isa(prototype, 'int32')
        value = typecast(uint32(bits), 'int32');
    elseif isa(prototype, 'int64')
        value = typecast(bits, 'int64');
    elseif isa(prototype, 'single')
        parts = typecast(uint32(bits), 'single');
        if isreal(prototype)
            value = parts;
        else
            value = complex(parts(1:2:end), parts(2:2:end));
        end
    else
        value = typecast(bits, 'double');
    end
end
