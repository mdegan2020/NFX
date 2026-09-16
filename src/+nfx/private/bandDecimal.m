function value = bandDecimal(number,width) %#codegen
    %bandDecimal - Encode a floating decimal with the available precision
    if isnan(number)
        value = repmat(uint8('-'),1,width);
        return
    end
    for places = width-1:-1:0
        candidate = sprintf('%.*f',places,number);
        if numel(candidate) > width && startsWith(candidate,'0.')
            candidate = candidate(2:end);
        end
        if numel(candidate) <= width
            value = uint8([repmat('0',1,width-numel(candidate)) candidate]);
            return
        end
    end
    error('nfx:Width','The value does not fit the spectral numeric field.');
end
