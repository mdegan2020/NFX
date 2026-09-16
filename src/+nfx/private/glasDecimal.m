function [value,valid,resolution] = glasDecimal(number,width) %#codegen
    %glasDecimal - Encode a signed BCS-N field with a floating decimal point
    value = repmat(uint8(' '),1,width); valid = false; resolution = 0;
    if ~isfinite(number), return; end
    for places = width-2:-1:0
        word = sprintf('%+.*f',places,number);
        if ~contains(word,'.'), word = [word '.']; end %#ok<AGROW>
        if numel(word) > width && word(2) == '0' && word(3) == '.'
            word(2) = [];
        end
        if numel(word) <= width
            rounded = str2double(word); valid = number == 0 || rounded ~= 0;
            if ~valid, return; end
            word = [word(1) repmat('0',1,width-numel(word)) word(2:end)];
            value = uint8(word); resolution = 10^(-places); return
        end
    end
end
