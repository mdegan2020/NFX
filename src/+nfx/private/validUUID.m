function valid = validUUID(value) %#codegen
    %validUUID - Recognize the hexadecimal 8-4-4-4-12 UUID text form
    value = char(value);
    valid = false;
    if numel(value) ~= 36, return; end
    if any(value([9 14 19 24]) ~= '-'), return; end
    digits = value([1:8 10:13 15:18 20:23 25:36]);
    valid = all((digits >= '0' & digits <= '9') | ...
        (digits >= 'a' & digits <= 'f') | (digits >= 'A' & digits <= 'F'));
end
