function [bytes, kind, width] = engineeringBytes(data) %#codegen
    %engineeringBytes - Preserve scalar bit patterns in row-major order
    [kind, width] = engineeringPrototype(data);
    if width == 0
        error('nfx:EngineeringType', ...
            'Use native integer, real float, complex single or char data.');
    end
    sequence = reshape(data.', 1, []);
    if ischar(data)
        if ~validBCSData(data)
            error('nfx:EngineeringText', 'Type A requires BCS characters.');
        end
        bytes = uint8(sequence);
        return
    end
    if kind == 'C'
        paired = zeros(1, 2 * numel(sequence), 'single');
        paired(1:2:end) = real(sequence);
        paired(2:2:end) = imag(sequence);
        bits = uint64(typecast(paired, 'uint32'));
        scalarWidth = 4;
    else
        scalarWidth = width;
        switch width
            case 1, bits = uint64(typecast(sequence, 'uint8'));
            case 2, bits = uint64(typecast(sequence, 'uint16'));
            case 4, bits = uint64(typecast(sequence, 'uint32'));
            otherwise, bits = typecast(sequence, 'uint64');
        end
    end
    bytes = zeros(1, numel(bits) * scalarWidth, 'uint8');
    for k = 1:numel(bits)
        for j = 1:scalarWidth
            bytes((k - 1) * scalarWidth + j) = ...
                uint8(bitand(bitshift(bits(k), -8 * (scalarWidth - j)), ...
                uint64(255)));
        end
    end
end
