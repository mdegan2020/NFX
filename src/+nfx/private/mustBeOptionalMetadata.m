function mustBeOptionalMetadata(value,lower,upper,integral) %#codegen
    %mustBeOptionalMetadata - Require an absent field or a double scalar
    mustBeMetadataArray(value,lower,upper,integral);
    if ~(isscalar(value) || isequal(size(value),[0 0]))
        error('nfx:OptionalMetadata','Supply a double scalar or [] for an absent field.');
    end
end
