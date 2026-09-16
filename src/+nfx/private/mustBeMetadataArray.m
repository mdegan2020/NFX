function mustBeMetadataArray(value,lower,upper,integral) %#codegen
    %mustBeMetadataArray - Require full real double metadata without coercion
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            any(isinf(value(:)) | value(:) < lower | value(:) > upper) || ...
            (integral && any(~isnan(value(:)) & fix(value(:)) ~= value(:)))
        error('nfx:MetadataArray','Supply real full double values within the field range, or NaN when unknown.');
    end
end
