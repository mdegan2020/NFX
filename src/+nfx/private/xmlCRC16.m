function value = xmlCRC16(data) %#codegen
    %xmlCRC16 - STANAG 7023 Annex B CRC used by XMLDCA
    %   Initial register zero, polynomial 0x8005, MSB first, no final XOR.
    value = uint16(0);
    for k = 1:numel(data)
        value = bitxor(value, bitshift(uint16(data(k)), 8));
        for bit = 1:8
            high = bitget(value, 16);
            value = bitshift(value, 1);
            if high
                value = bitxor(value, uint16(32773));
            end
        end
    end
end
