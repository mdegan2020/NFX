function valid = validXMLLocation(value, count) %#codegen
    %validXMLLocation - Check explicit latitude/longitude decimal pairs
    value = char(value);
    valid = isempty(strtrim(value));
    if valid, return; end
    if numel(value) ~= 25 * count, return; end
    for k = 1:count
        pair = value((k - 1) * 25 + (1:25));
        if ~any(pair(1) == '+-') || ~any(pair(13) == '+-') || ...
                pair(4) ~= '.' || pair(17) ~= '.' || ...
                any(pair([2:3 5:12 14:16 18:25]) < '0' | ...
                    pair([2:3 5:12 14:16 18:25]) > '9')
            return
        end
        latitude = str2double(pair(1:12));
        longitude = str2double(pair(13:25));
        if abs(latitude) > 90 || longitude < -180 || longitude > 360
            return
        end
    end
    valid = count == 1 || strcmp(value(1:25), value(end - 24:end));
end
