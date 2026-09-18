function valid = validXMLDate(value) %#codegen
    %validXMLDate - Validate the XMLDCA date precision forms
    value = char(value);
    valid = false;
    if ~any(numel(value) == [10 17 20]) || ...
            value(5) ~= '-' || value(8) ~= '-'
        return
    end
    date = value([1:4 6:7 9:10]);
    if numel(value) == 10
        valid = knownDate(date, 8);
        return
    end
    if value(11) ~= 'T' || value(14) ~= ':' || value(end) ~= 'Z'
        return
    end
    date = [date value([12:13 15:16])];
    if numel(value) == 20
        if value(17) ~= ':', return; end
        date = [date value(18:19)];
    end
    valid = knownDate(date, numel(date));
end
