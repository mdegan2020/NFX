function valid = validLocation23(value) %#codegen
    value = char(value);
    valid = numel(value) == 23;
    if ~valid, return; end
    if value(1) == '+' || value(1) == '-'
        expanded = [value(1:11) '0' value(12:23) '0'];
    else
        expanded = [value(1:10) '0' value(11:22) '0' value(23)];
    end
    valid = validAcquisitionLocation(expanded, 'precise');
end
