function [value,valid,resolution] = sensNumber(number,width,format) %#codegen
    %sensNumber - Encode a SENSRB number within its decimal character set
    value = repmat(uint8('-'),1,width);
    resolution = 0;
    valid = isfinite(number);
    if ~valid, return; end
    if format == 'I'
        word = sprintf('%0*.0f',width,number);
        valid = number >= 0 && fix(number) == number && numel(word) == width;
        if valid, value = uint8(word); end
        return
    end
    if format == 'L' || format == 'O'
        integralWidth = 2+double(format == 'O');
        word = sprintf('%+0*.*f',width,width-integralWidth-2,number);
        valid = numel(word) == width;
        if valid, value = uint8(word); end
        return
    end
    if format == 'E'
        for places = width-4:-1:0
            word = sprintf('%.*E',places,number);
            word = strrep(word,'E+','E');
            marker = find(word == 'E',1);
            digits = word(marker+1:end);
            if startsWith(digits,'-'), digits = digits(2:end); end
            if numel(word) <= width && numel(digits) <= 2
                value = uint8([repmat(' ',1,width-numel(word)) word]);
                return
            end
        end
        valid = false;
        return
    end
    % BCS-N has no exponent. Keep the finest representable decimal value,
    % then remove redundant fraction zeros before left padding the field.
    for places = width-1:-1:0
        word = sprintf('%.*f',places,abs(number));
        if numel(word)+double(number < 0) > width && startsWith(word,'0.')
            word = word(2:end);
        end
        if numel(word)+double(number < 0) <= width
            resolution = 10^(-places);
            if contains(word,'.')
                while word(end) == '0', word(end) = []; end
                if word(end) == '.', word(end) = []; end
            end
            word = [repmat('0',1,width-numel(word)-double(number < 0)) word]; %#ok<AGROW>
            if number < 0, word = ['-' word]; end %#ok<AGROW>
            valid = number == 0 || str2double(word) ~= 0;
            if valid, value = uint8(word); end
            return
        end
    end
    valid = false;
end
