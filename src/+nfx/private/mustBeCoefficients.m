function mustBeCoefficients(value) %#codegen
    %mustBeCoefficients - Validate an editable RPC coefficient vector
    if ~isa(value, 'double') || ~isreal(value) || issparse(value) || ...
            ~isvector(value) || numel(value) ~= 20 || any(isinf(value))
        error('nfx:Coefficients', ...
            'Expected a real, full double vector with exactly 20 elements.');
    end
end
