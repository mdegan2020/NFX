function mustBeRSMMatrix(value,maxRows,maxColumns) %#codegen
    %mustBeRSMMatrix - Preserve real double matrices with bounded dimensions
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ~ismatrix(value) || ...
            isempty(value) || size(value,1) > maxRows || size(value,2) > maxColumns || any(isinf(value(:)))
        error('nfx:RSMMatrix','Supply a nonempty full real double matrix within the supported dimensions.');
    end
end
