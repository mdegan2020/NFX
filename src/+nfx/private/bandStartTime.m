function valid = bandStartTime(value) %#codegen
    %bandStartTime - Check YYMMDDhhmmss.sss with unknown component digits
    value = char(value);
    valid = numel(value) == 16;
    if ~valid, return; end
    valid = value(13) == '.' && all((value([1:12 14:16]) >= '0' & ...
        value([1:12 14:16]) <= '9') | value([1:12 14:16]) == '-');
    if ~valid, return; end
    low = [0 1 1 0 0 0]; high = [99 12 31 23 59 59];
    for k = 1:6
        part = value(2*k-1:2*k);
        smallest = part; largest = part;
        smallest(part == '-') = '0'; largest(part == '-') = '9';
        valid = valid && str2double(smallest) <= high(k) && str2double(largest) >= low(k);
    end
    if ~contains(value(1:6),'-')
        % Two-digit year leaves the century unspecified. A possible leap
        % century is accepted; this field cannot identify the full epoch.
        valid = valid && knownDate(['20' value(1:6)],8);
    end
end
