function valid = knownDate(value,width) %#codegen
    %knownDate - Check a fully known UTC calendar date with optional time
    value = char(value);
    valid = numel(value) == width && all(value >= '0' & value <= '9');
    if valid, valid = validDate([value repmat('0',1,14-width)]); end
end
