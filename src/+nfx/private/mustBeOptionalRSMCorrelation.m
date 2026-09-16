function mustBeOptionalRSMCorrelation(value) %#codegen
    %mustBeOptionalRSMCorrelation - Accept a scalar or absent correlation form
    if ~isa(value,'nfx.RSMCorrelation') || numel(value) > 1
        error('nfx:RSMCorrelation','Supply a scalar or empty nfx.RSMCorrelation value.');
    end
end
