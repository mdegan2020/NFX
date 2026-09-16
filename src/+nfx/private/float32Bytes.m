function value = float32Bytes(number) %#codegen
    %float32Bytes - Encode supplied numeric metadata as big-endian IEEE binary32
    bits = typecast(single(number),'uint32');
    value = unsignedBytes(uint64(bits),4);
end
