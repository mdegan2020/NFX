function valid = validMieTimestamp(value) %#codegen
    %validMieTimestamp - Check exact UTC text and trailing precision markers
    value = char(value);
    valid = false;
    if numel(value) ~= 24 || value(15) ~= '.', return; end
    if any(value(1:14) < '0' | value(1:14) > '9') || ~validDate(value(1:14)), return; end
    fraction = value(16:24);
    firstUnknown = find(fraction == '-', 1);
    if ~isempty(firstUnknown)
        if any(fraction(firstUnknown:end) ~= '-'), return; end
        fraction = fraction(1:firstUnknown-1);
    end
    valid = all(fraction >= '0' & fraction <= '9');
end
