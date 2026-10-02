function valid = knownPreciseDate(value, precision) %#codegen
    %knownPreciseDate - Check a complete UTC timestamp and fractional seconds
    text = char(value);
    valid = numel(text) == 15 + precision;
    if valid
        valid = knownDate(text(1:14), 14) && text(15) == '.' && ...
            all(text(16:end) >= '0' & text(16:end) <= '9');
    end
end
