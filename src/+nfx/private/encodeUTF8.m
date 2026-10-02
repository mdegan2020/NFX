function [bytes, ok] = encodeUTF8(value) %#codegen
    %encodeUTF8 - Encode Unicode scalar values without replacing bad surrogates
    bytes = zeros(1, 0, 'uint8');
    ok = (ischar(value) && (isrow(value) || isempty(value))) || ...
        (isstring(value) && isscalar(value) && ~ismissing(value));
    if ~ok
        return
    end
    units = double(char(value));
    bytes = zeros(1, 3 * numel(units), 'uint8');
    used = 0;
    k = 1;
    while k <= numel(units)
        point = units(k);
        if point >= 55296 && point <= 56319
            if k == numel(units) || ...
                    units(k + 1) < 56320 || units(k + 1) > 57343
                ok = false;
                bytes = zeros(1, 0, 'uint8');
                return
            end
            point = 65536 + (point - 55296) * 1024 + units(k + 1) - 56320;
            k = k + 1;
        elseif point >= 56320 && point <= 57343
            ok = false;
            bytes = zeros(1, 0, 'uint8');
            return
        end
        if point < 128
            encoded = uint8(point);
        elseif point < 2048
            encoded = uint8([192 + floor(point / 64), ...
                128 + mod(point, 64)]);
        elseif point < 65536
            encoded = uint8([224 + floor(point / 4096), ...
                128 + mod(floor(point / 64), 64), 128 + mod(point, 64)]);
        else
            encoded = uint8([240 + floor(point / 262144), ...
                128 + mod(floor(point / 4096), 64), ...
                128 + mod(floor(point / 64), 64), 128 + mod(point, 64)]);
        end
        bytes(used + (1:numel(encoded))) = encoded;
        used = used + numel(encoded);
        k = k + 1;
    end
    bytes = bytes(1:used);
end
