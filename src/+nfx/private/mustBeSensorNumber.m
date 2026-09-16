function mustBeSensorNumber(value) %#codegen
    %mustBeSensorNumber - Accept an optional double scalar without coercion
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isscalar(value) || isequal(size(value),[0 0])) || any(isinf(value))
        error('nfx:SensorNumber','Supply a double scalar, NaN, or [].');
    end
end
