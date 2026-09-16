function order = mieTimeCompare(left,right) %#codegen
    %mieTimeCompare - Compare exact values at their common stated precision
    order = sign(left.day-right.day);
    if order ~= 0, return; end
    quantum = uint64(10^(9-min(left.precision,right.precision)));
    a = idivide(left.nanos,quantum); b = idivide(right.nanos,quantum);
    order = double(a > b)-double(a < b);
end
