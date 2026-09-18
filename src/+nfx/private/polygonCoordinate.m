function bytes = polygonCoordinate(value) %#codegen
    %polygonCoordinate - Select the most accurate fitting decimal encoding
    best = '';
    bestError = Inf;
    for places = 0:13
        text = sprintf('%015.*f', places, value);
        if numel(text) == 15
            difference = abs(str2double(text) - value);
            if difference < bestError
                best = text;
                bestError = difference;
            end
        end
    end
    for places = 0:9
        text = sprintf('%015.*E', places, value);
        if numel(text) == 15
            difference = abs(str2double(text) - value);
            if difference < bestError
                best = text;
                bestError = difference;
            end
        end
    end
    if isempty(best)
        error('nfx:PolygonCoordinate', ...
            'The coordinate cannot be represented in fifteen bytes.');
    end
    bytes = uint8(best);
end
