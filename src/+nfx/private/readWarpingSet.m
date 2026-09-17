function [obj, reader] = readWarpingSet(reader, sensor) %#codegen
    %readWarpingSet - Decode bounded WarpingSet fields without exceptions
    obj = nfx.WarpingSet();
    if strcmp(sensor, 'F')
        [value, reader] = reader.number( ...
            11, 0, 99.99999999, 0, false);
        if reader.ok
            obj.fl_warp = value;
        end
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.offset_line = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.offset_samp = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.scale_line = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.scale_samp = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.offset_line_unwrp = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.offset_samp_unwrp = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.scale_line_unwrp = value;
    end
    [value, reader] = reader.number( ...
        7, 1, 9999999, 1, false);
    if reader.ok
        obj.scale_samp_unwrp = value;
    end
    [orders, reader] = reader.numbers(4, 1, 0, 9, true);
    if reader.ok
        [a, reader] = reader.numbers(prod(orders(1:2) + 1), 21, ...
            -9.99999999999999e99, 9.99999999999999e99);
        [b, reader] = reader.numbers(prod(orders(3:4) + 1), 21, ...
            -9.99999999999999e99, 9.99999999999999e99);
        if reader.ok
            obj.a = reshape(a, orders(1:2) + 1);
            obj.b = reshape(b, orders(3:4) + 1);
        end
    end
end
