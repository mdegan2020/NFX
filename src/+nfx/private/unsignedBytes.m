function value = unsignedBytes(numbers, width) %#codegen
    %unsignedBytes - Encode exact unsigned integers most significant byte first
    value = zeros(width,numel(numbers),'uint8');
    for k = 1:width
        value(k,:) = uint8(bitand(bitshift(numbers,-8*(width-k)),uint64(255)));
    end
    value = reshape(value,1,[]);
end
