function mustBeRSMParameters(value) %#codegen
    %mustBeRSMParameters - Accept one concrete value descriptor
    if ~isa(value,'nfx.RSMParameters') || ~isscalar(value)
        error('nfx:RSMParameters','Supply a scalar nfx.RSMParameters value.');
    end
end
