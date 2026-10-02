function [data, valid] = commercialGSDNumber(value, unknown) %#codegen
    if isnan(value) && unknown
        data = uint8('N/A  '); valid = true;
    elseif value <= 999.9
        [data, valid] = treNumber(value, 5, 1, false, false, false);
    else
        [data, valid] = treNumber(value, 5, 0, false, false, false);
        valid = valid && value >= 1000 && fix(value) == value;
    end
end
