function mustBeGLASObjects(value,className) %#codegen
    %mustBeGLASObjects - Require an unconverted row of value descriptors
    if ~isa(value,className) || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:GLASObjects','Expected a row of %s values.',className);
    end
end
