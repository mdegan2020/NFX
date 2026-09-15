function mustBeLocation(value) %#codegen
    %mustBeLocation - Require two exact double-valued display offsets
    if ~isa(value, 'double') || ~isreal(value) || issparse(value) || ...
            ~isvector(value) || numel(value) ~= 2 || ...
            any(~isfinite(value) | value < -9999 | value > 99999 | fix(value) ~= value)
        error('nfx:Location', 'Expected two integer doubles in [-9999, 99999].');
    end
end
