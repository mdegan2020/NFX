function mustBeByteField(value,width,optional) %#codegen
    %mustBeByteField - Require a native byte row with its exact field width
    if ~isa(value,'uint8') || ~(isequal(size(value),[1 width]) || ...
            (optional && isempty(value) && (isrow(value) || isequal(size(value),[0 0]))))
        error('nfx:ByteField','Supply a uint8 row of the specified field width.');
    end
end
