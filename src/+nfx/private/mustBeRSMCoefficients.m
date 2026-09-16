function mustBeRSMCoefficients(value) %#codegen
    %mustBeRSMCoefficients - Require at most six terms along each ground axis
    mustBeMetadataArray(value,-9.99999999999999e99,9.99999999999999e99,false);
    if ndims(value) > 3 || any(size(value) > 6)
        error('nfx:RSMCoefficients','Supply a double X-by-Y-by-Z coefficient array, at most 6-by-6-by-6.');
    end
end
