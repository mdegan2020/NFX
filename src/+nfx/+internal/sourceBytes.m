function [value, ok] = sourceBytes(data, offset, count) %#codegen
    %sourceBytes - Extract an available source range without filling gaps
    if isstruct(data)
        [value, ok] = nfx.internal.rangeBytes( ...
            data.bytes, data.ranges, offset, count);
    else
        [value, ok] = nfx.internal.rangeBytes( ...
            data, zeros(0, 3), offset, count);
    end
end
