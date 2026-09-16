function value = miisCheckValue(digits) %#codegen
    %miisCheckValue - Apply the two MISB ST 1204.3 hexadecimal permutations
    p = zeros(15,16,'uint8'); q = p;
    p(1,:) = uint8(0:15); q(1,:) = p(1,:);
    for k = 2:15
        previous = p(k-1,:);
        p(k,:) = bitshift(bitxor(bitget(previous,4),bitget(previous,3)),3)+ ...
            bitshift(bitand(previous,3),1)+bitget(previous,4);
        previous = q(k-1,:);
        q(k,:) = bitshift(bitand(previous,1),3)+ ...
            bitshift(bitxor(bitget(previous,4),bitget(previous,1)),2)+bitshift(bitand(previous,6),-1);
    end
    pCheck = uint8(0); qCheck = uint8(0);
    for k = 1:numel(digits)
        digit = double(digits(k))-double('0');
        if digits(k) >= 'A', digit = double(digits(k))-double('A')+10; end
        pCheck = bitxor(pCheck,p(mod(k,15)+1,digit+1));
        qCheck = bitxor(qCheck,q(mod(k,15)+1,digit+1));
    end
    hexadecimal = '0123456789ABCDEF'; value = hexadecimal([double(pCheck)+1 double(qCheck)+1]);
end
