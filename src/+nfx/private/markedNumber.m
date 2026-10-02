function [data, valid] = markedNumber(value, width, places, marker) %#codegen
    if isnan(value)
        data = uint8(marker); valid = numel(data) == width;
    else
        [data, valid] = treNumber(value, width, places, false, false, false);
    end
end
