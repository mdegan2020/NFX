function [bytes, valid] = sunElevationNumber(value) %#codegen
    %sunElevationNumber - Encode signed elevation or the unknown sentinel
    [bytes, valid] = treNumber(value, 5, 1, value ~= 999.9, false, false);
    valid = valid && (abs(value) <= 90 || value == 999.9);
end
