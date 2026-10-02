function valid = validPartialAngle(value, maximum) %#codegen
    %validPartialAngle - Check signed degrees with unspecified fractional digits
    text = char(value);
    valid = isempty(strtrim(text));
    if valid
        return
    end
    whole = 2 + (maximum == 180);
    if numel(text) < whole + 2 || numel(text) > whole + 8 || ...
            ~any(text(1) == '+-') || text(whole + 2) ~= '.'
        return
    end
    prefix = text(2:whole + 1);
    fraction = text(whole + 3:end);
    blank = find(fraction == ' ', 1);
    if isempty(blank)
        blank = numel(fraction) + 1;
    end
    valid = all(prefix >= '0' & prefix <= '9') && ...
        all(fraction(1:blank - 1) >= '0' & fraction(1:blank - 1) <= '9') && ...
        all(fraction(blank:end) == ' ') && ...
        abs(str2double(strtrim(text))) <= maximum;
end
