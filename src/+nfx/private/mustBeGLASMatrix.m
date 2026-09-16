function mustBeGLASMatrix(value,maxRows,maxColumns,limit) %#codegen
    %mustBeGLASMatrix - Preserve bounded real double metadata matrices
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ~ismatrix(value) || ...
            size(value,1) > maxRows || size(value,2) > maxColumns || ...
            any(isinf(value(:))) || any(abs(value(:)) > limit)
        error('nfx:GLASMatrix','Supply a full real double matrix within the field dimensions and range.');
    end
end
