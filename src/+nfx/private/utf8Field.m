function [data, valid] = utf8Field(value, countWidth) %#codegen
    [raw, valid] = encodeUTF8(value);
    valid = valid && numel(raw) < 10^countWidth && ...
        (isempty(raw) || ~isequal(raw(1:min(3, end)), uint8([239 187 191])));
    data = zeros(1, 0, 'uint8');
    if valid
        data = [decimalField(numel(raw), countWidth, 0, false) raw];
    end
end
