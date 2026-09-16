function mustBeGLASCovariance(value,dimension,pages) %#codegen
    %mustBeGLASCovariance - Preserve bounded double covariance page arrays
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ndims(value) > 3 || ...
            size(value,1) > dimension || size(value,2) > dimension || size(value,3) > pages || ...
            any(isinf(value(:))) || any(abs(value(:)) > 9.99999999999999e99)
        error('nfx:GLASCovariance','Supply full real double covariance matrices within the field dimensions and range.');
    end
end
