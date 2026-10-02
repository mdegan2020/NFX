function valid = knownClockTime(value, precision) %#codegen
    %knownClockTime - Check a fully specified UTC clock with fractional seconds
    text = char(value);
    valid = numel(text) == 7 + precision;
    if ~valid
        return
    end
    digits = text([1:6 8:end]);
    valid = text(7) == '.' && all(digits >= '0' & digits <= '9') && ...
        str2double(text(1:2)) <= 23 && str2double(text(3:4)) <= 59 && ...
        str2double(text(5:6)) <= 59;
end
