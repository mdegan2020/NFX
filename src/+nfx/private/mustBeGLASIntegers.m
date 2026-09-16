function mustBeGLASIntegers(value) %#codegen
    %mustBeGLASIntegers - Preserve exact native uint64 values without coercion
    if ~isa(value,'uint64') || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:GLASIntegers','Expected a uint64 row vector.');
    end
end
