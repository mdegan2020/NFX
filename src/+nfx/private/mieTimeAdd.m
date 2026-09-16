function [value,valid] = mieTimeAdd(value,delta,multiplier,count) %#codegen
    %mieTimeAdd - Add a UINT64 product and frame count with bounded limbs
    %   Base-65536 products fit exact double integers. Long-division
    %   remainders fit UINT64; the complete product need not fit UINT64.
    a = limbs(delta,4); b = limbs(multiplier,4); c = limbs(uint64(count),2);
    product = zeros(1,10);
    for i = 1:4
        for j = 1:4
            product(i+j-1) = product(i+j-1)+a(i)*b(j);
        end
    end
    product = normalize(product); expanded = zeros(1,10);
    for i = 1:8
        for j = 1:2
            expanded(i+j-1) = expanded(i+j-1)+product(i)*c(j);
        end
    end
    expanded = normalize(expanded); unit = uint64(86400000000000);
    remainder = uint64(0); days = 0;
    for i = 10:-1:1
        current = remainder*uint64(65536)+uint64(expanded(i));
        digit = idivide(current,unit); remainder = rem(current,unit);
        days = days*65536+double(digit);
        if days > 3652424, valid = false; return; end
    end
    nanos = value.nanos+remainder;
    carry = double(nanos >= unit);
    value.day = value.day+days+carry; value.nanos = rem(nanos,unit);
    valid = value.day <= 3652424;
end

function value = limbs(number,count) %#codegen
    %limbs - Extract exact small integers without converting a whole UINT64
    value = zeros(1,count);
    for k = 1:count
        value(k) = double(bitand(number,uint64(65535))); number = bitshift(number,-16);
    end
end

function value = normalize(value) %#codegen
    %normalize - Carry exact integer coefficients into bounded radix digits
    for k = 1:numel(value)-1
        carry = floor(value(k)/65536); value(k) = rem(value(k),65536);
        value(k+1) = value(k+1)+carry;
    end
end
