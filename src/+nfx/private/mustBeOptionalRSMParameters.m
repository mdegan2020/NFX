function mustBeOptionalRSMParameters(value) %#codegen
    %mustBeOptionalRSMParameters - Accept a scalar or empty value descriptor
    if ~isa(value,'nfx.RSMParameters') || numel(value) > 1
        error('nfx:RSMParameters','Supply a scalar or empty nfx.RSMParameters value.');
    end
end
