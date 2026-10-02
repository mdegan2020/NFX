function [bytes, valid] = variableDecimalNumber(value, width, optional) %#codegen
    %variableDecimalNumber - Select a fitting non-exponential decimal field
    arguments
        value
        width
        optional = false
    end
    bytes = repmat(uint8(32), 1, width);
    valid = optional && isnan(value);
    if valid || ~isfinite(value)
        return
    end
    bestError = Inf;
    for places = 0:width - 1
        word = sprintf('%.*f', places, value);
        if numel(word) > width && places > 0
            if startsWith(word, '0.')
                word = word(2:end);
            elseif startsWith(word, '-0.')
                word = ['-' word(3:end)];
            end
        end
        if numel(word) <= width
            difference = abs(str2double(word) - value);
            if difference < bestError
                bestError = difference;
                padding = repmat('0', 1, width - numel(word));
                if word(1) == '-'
                    word = ['-' padding word(2:end)];
                else
                    word = [padding word]; %#ok<AGROW>
                end
                bytes = uint8(word);
                valid = true;
            end
        end
    end
    % A nonzero spacing or scale must not silently become zero on the wire.
    valid = valid && (value == 0 || str2double(char(bytes)) ~= 0);
end
