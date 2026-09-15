function bytes = decimalField(value, width, places, signed) %#codegen
    %decimalField - Format a numeric field and reject width growth
    if signed
        text = sprintf('%+0*.*f', width, places, value);
    else
        text = sprintf('%0*.*f', width, places, value);
    end
    if ~isfinite(value) || numel(text) ~= width
        error('nfx:Width', 'Numeric value does not fit its %d-byte field.', width);
    end
    bytes = uint8(text);
end
