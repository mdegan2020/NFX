function [data, valid] = pointValues(values, definitions) %#codegen
    data = zeros(1, 0, 'uint8');
    valid = numel(values) == numel(definitions) && ...
        sum([definitions.att_len]) <= 99988;
    if ~valid, return; end
    for k = 1:numel(values)
        width = definitions(k).att_len;
        valid = isfinite(width) && width >= 1 && width <= 9999 && ...
            fix(width) == width && numel(char(values(k).value)) <= width;
        if ~valid, return; end
        data = [data textField(values(k).value, width)]; %#ok<AGROW>
    end
end
