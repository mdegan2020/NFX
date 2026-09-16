function value = illuminationNumber(number,width) %#codegen
    %illuminationNumber - Fit scientific notation without a double conversion
    if isnan(number), value = repmat(uint8(' '),1,width); return; end
    signed = width == 14;
    places = width-6-signed;
    if signed, pattern = '%+.*E'; else, pattern = '%.*E'; end
    text = sprintf(pattern,places,number);
    while numel(text) > width && places > 0
        places = places-1;
        text = sprintf(pattern,places,number);
    end
    if numel(text) ~= width, error('nfx:Width','The scientific value does not fit its field.'); end
    value = uint8(text);
end
