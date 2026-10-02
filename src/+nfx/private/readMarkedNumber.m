function [value, reader] = readMarkedNumber(reader, width, marker, ...
        lower, upper, integral) %#codegen
    [raw, reader] = reader.take(width);
    value = NaN;
    if ~reader.ok || isequal(raw, uint8(marker)), return; end
    field = nfx.internal.TREReader(raw);
    [value, field] = field.number(width, lower, upper, integral);
    if ~field.ok
        reader = reader.fail(field.code, field.message);
    end
end
