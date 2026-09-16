function earlier = mieTimeEarlier(left, right) %#codegen
    %mieTimeEarlier - Compare timestamps only to their common stated precision
    left = char(left);
    right = char(right);
    earlier = false;
    for k = 1:min(numel(left),numel(right))
        if left(k) == '-' || right(k) == '-', return; end
        if left(k) ~= right(k)
            earlier = left(k) < right(k);
            return
        end
    end
end
