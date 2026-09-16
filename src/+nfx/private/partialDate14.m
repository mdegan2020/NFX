function valid = partialDate14(value) %#codegen
    %partialDate14 - Check a UTC date with a numeric prefix and trailing dashes
    value = char(value);
    valid = false;
    if numel(value) ~= 14, return; end
    unknown = find(value == '-',1);
    if isempty(unknown), unknown = 15; end
    if any(value(1:unknown-1) < '0' | value(1:unknown-1) > '9') || ...
            any(value(unknown:end) ~= '-'), return; end
    widths = [4 2 2 2 2 2];
    lower = [0 1 1 0 0 0]; upper = [9999 12 31 23 59 59];
    decoded = zeros(1,6);
    at = 1;
    for k = 1:6
        if k == 3
            days = [31 29 31 30 31 30 31 31 30 31 30 31];
            if unknown > 4
                year = decoded(1);
                days(2) = 28+(mod(year,4) == 0 && (mod(year,100) ~= 0 || mod(year,400) == 0));
            end
            upper(3) = days(decoded(2));
        end
        known = max(0,min(widths(k),unknown-at));
        prefix = 0;
        for m = 0:known-1, prefix = prefix*10+double(value(at+m))-48; end
        scale = 10^(widths(k)-known);
        minimum = prefix*scale; maximum = minimum+scale-1;
        if maximum < lower(k) || minimum > upper(k), return; end
        decoded(k) = max(minimum,lower(k));
        at = at+widths(k);
    end
    valid = true;
end
