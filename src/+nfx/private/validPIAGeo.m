function valid = validPIAGeo(value) %#codegen
    %validPIAGeo - Check integer-second latitude and longitude identifiers
    text = char(value);
    valid = isempty(strtrim(text));
    if valid || numel(text) ~= 15
        return
    end
    precise = [text(1:6) '.0000' text(7:14) '.0000' text(15)];
    valid = validAcquisitionLocation(precise, 'precise');
end
