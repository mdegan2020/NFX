function valid = validAttributeCoordinate(value) %#codegen
    value = char(value);
    valid = numel(value) == 8 && ...
        all((value >= '0' & value <= '9') | value == '-');
end
