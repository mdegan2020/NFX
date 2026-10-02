function [text, ok] = decodeUTF8(bytes) %#codegen
    %decodeUTF8 - Reject truncated, overlong and non-scalar UTF-8 sequences
    text = '';
    ok = isa(bytes, 'uint8') && (isrow(bytes) || isempty(bytes));
    if ~ok
        return
    end
    units = zeros(1, numel(bytes), 'uint16');
    used = 0;
    k = 1;
    while k <= numel(bytes)
        first = double(bytes(k));
        if first < 128
            count = 1; point = first; minimum = 0;
        elseif first >= 194 && first <= 223
            count = 2; point = first - 192; minimum = 128;
        elseif first >= 224 && first <= 239
            count = 3; point = first - 224; minimum = 2048;
        elseif first >= 240 && first <= 244
            count = 4; point = first - 240; minimum = 65536;
        else
            ok = false;
            return
        end
        if k + count - 1 > numel(bytes)
            ok = false;
            return
        end
        for j = 1:count - 1
            next = double(bytes(k + j));
            if next < 128 || next > 191
                ok = false;
                return
            end
            point = point * 64 + next - 128;
        end
        if point < minimum || point > 1114111 || ...
                (point >= 55296 && point <= 57343)
            ok = false;
            return
        end
        if point < 65536
            used = used + 1;
            units(used) = uint16(point);
        else
            units(used + 1) = uint16(55296 + floor((point - 65536) / 1024));
            units(used + 2) = uint16(56320 + mod(point - 65536, 1024));
            used = used + 2;
        end
        k = k + count;
    end
    text = char(units(1:used));
end
