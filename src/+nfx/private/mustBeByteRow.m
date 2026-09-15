function mustBeByteRow(value) %#codegen
    %mustBeByteRow - Reject conversions of encoded payload bytes
    if ~isa(value, 'uint8') || ~ismatrix(value) || ~(isrow(value) || isempty(value))
        error('nfx:Bytes', 'Expected a uint8 row of encoded bytes.');
    end
end
