function [bytes, valid] = treNumber(number, width, places, ...
        signed, optional, exponential) %#codegen
    %treNumber - Format a bounded scalar without throwing on unset metadata
    bytes = repmat(uint8(32), 1, width);
    valid = optional && isnan(number);
    if valid || ~isfinite(number)
        return
    end
    if exponential
        if signed
            word = sprintf('%+.*E', places, number);
        else
            word = sprintf('%.*E', places, number);
        end
    elseif signed
        word = sprintf('%+0*.*f', width, places, number);
    else
        word = sprintf('%0*.*f', width, places, number);
    end
    valid = numel(word) == width;
    if valid
        bytes = uint8(word);
    end
end
