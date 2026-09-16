function mustBeRSMVector(value) %#codegen
    %mustBeRSMVector - Accept a real double parameter vector without coercion
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 36 || any(isinf(value))
        error('nfx:RSMVector','Supply a full real double row vector with at most 36 values.');
    end
end
