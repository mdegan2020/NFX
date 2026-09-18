function [kind, width] = engineeringPrototype(value) %#codegen
    %engineeringPrototype - Map a native class to a fixed wire descriptor
    kind = 'B';
    width = 0;
    if ischar(value)
        kind = 'A'; width = 1;
    elseif isa(value, 'uint8')
        kind = 'I'; width = 1;
    elseif isa(value, 'uint16')
        kind = 'I'; width = 2;
    elseif isa(value, 'uint32')
        kind = 'I'; width = 4;
    elseif isa(value, 'uint64')
        kind = 'I'; width = 8;
    elseif isa(value, 'int8')
        kind = 'S'; width = 1;
    elseif isa(value, 'int16')
        kind = 'S'; width = 2;
    elseif isa(value, 'int32')
        kind = 'S'; width = 4;
    elseif isa(value, 'int64')
        kind = 'S'; width = 8;
    elseif isa(value, 'single')
        kind = 'R'; width = 4;
        if ~isreal(value), kind = 'C'; width = 8; end
    elseif isa(value, 'double') && isreal(value)
        kind = 'R'; width = 8;
    end
end
