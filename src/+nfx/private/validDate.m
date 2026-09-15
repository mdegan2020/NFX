function valid = validDate(value) %#codegen
    %validDate - Check a NITF UTC timestamp including unknown digit pairs
    text = char(value);
    valid = numel(text) == 14;
    if ~valid
        return
    end
    parts = nan(1, 7);
    for k = 1:7
        pair = text(2*k-1:2*k);
        if all(pair >= '0' & pair <= '9')
            parts(k) = 10 * (double(pair(1)) - 48) + double(pair(2)) - 48;
        elseif ~strcmp(pair, '--')
            valid = false;
        end
    end
    valid = valid && ~(parts(3) < 1 || parts(3) > 12 || ...
        parts(4) < 1 || parts(4) > 31 || parts(5) > 23 || ...
        parts(6) > 59 || parts(7) > 59);
    if ~isnan(parts(3)) && ~isnan(parts(4)) && valid
        days = [31 29 31 30 31 30 31 31 30 31 30 31];
        if all(~isnan(parts(1:2)))
            year = 100 * parts(1) + parts(2);
            days(2) = 28 + (mod(year, 4) == 0 && ...
                (mod(year, 100) ~= 0 || mod(year, 400) == 0));
        end
        valid = parts(4) <= days(parts(3));
    end
end
