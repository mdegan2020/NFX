function mustBePointValues(values) %#codegen
    if ~isstruct(values) || ~(isrow(values) || isempty(values)) || ...
            numel(fieldnames(values)) ~= 1 || ~isfield(values, 'value')
        error('nfx:PointValues', 'Supply a row of structs with one value field.');
    end
    for k = 1:numel(values)
        mustBeAscii(values(k).value, 9999);
    end
end
