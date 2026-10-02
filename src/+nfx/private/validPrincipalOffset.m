function valid = validPrincipalOffset(value) %#codegen
    %validPrincipalOffset - Preserve the published seven-byte decimal field
    %   The current range example exceeds the printed field width. Keep
    %   its signed decimal spelling instead of guessing a fixed precision.
    word = char(value);
    valid = numel(word) == 7;
    if ~valid
        return
    end
    dots = find(word == '.');
    valid = any(word(1) == '+-') && isscalar(dots) && ...
        dots > 2 && dots < 7;
    if ~valid
        return
    end
    digits = word(2:end);
    digits(digits == '.') = [];
    valid = all(digits >= '0' & digits <= '9') && ...
        abs(str2double(word)) <= 99.999999;
end
