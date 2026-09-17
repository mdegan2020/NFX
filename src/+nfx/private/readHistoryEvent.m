function [obj, reader] = readHistoryEvent(reader) %#codegen
    %readHistoryEvent - Decode conditionals and stored decimal precision
    obj = nfx.HistoryEvent();
    [value, reader] = reader.text(14, true, false);
    if reader.ok
        obj.pdate = value;
    end
    [value, reader] = reader.text(10, true, false);
    if reader.ok
        obj.psite = value;
    end
    [value, reader] = reader.text(10, true, false);
    if reader.ok
        obj.pas = value;
    end
    [count, reader] = reader.count(1, 80, 9);
    [raw, reader] = reader.textRows(80, count, false);
    if reader.ok
        obj.ipcom = raw;
    end
    [value, reader] = reader.number( ...
        2, 1, 64, 1, false);
    if reader.ok
        obj.ibpp = value;
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok
        obj.ipvtype = value;
    end
    [value, reader] = reader.text(10, true, false);
    if reader.ok
        obj.inbwc = value;
    end
    [value, reader] = reader.number( ...
        1, 0, 3, 1, true);
    if reader.ok
        obj.disp_flag = value;
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.rot_flag = value;
    end
    if obj.rot_flag == 1
        [value, places, reader] = reader.decimal( ...
            8, 0, 359.9999, 6);
        if reader.ok
            obj.rot_angle = value;
            obj.decimal_places(1) = places;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, true);
    if reader.ok
        obj.asym_flag = value;
    end
    if obj.asym_flag == 1
        [value, places, reader] = reader.decimal( ...
            7, 0, 99.9999, 5);
        if reader.ok
            obj.zoomrow = value;
            obj.decimal_places(2) = places;
        end
        [value, places, reader] = reader.decimal( ...
            7, 0, 99.9999, 5);
        if reader.ok
            obj.zoomcol = value;
            obj.decimal_places(3) = places;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.proj_flag = value;
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.sharp_flag = value;
    end
    if obj.sharp_flag == 1
        [value, reader] = reader.number( ...
            2, -1, 99, 1, false);
        if reader.ok
            obj.sharpfam = value;
        end
        [value, reader] = reader.number( ...
            2, -1, 99, 1, false);
        if reader.ok
            obj.sharpmem = value;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.mag_flag = value;
    end
    if obj.mag_flag == 1
        [value, places, reader] = reader.decimal( ...
            7, 0, 99.9999, 5);
        if reader.ok
            obj.mag_level = value;
            obj.decimal_places(4) = places;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 2, 1, false);
    if reader.ok
        obj.dra_flag = value;
    end
    if obj.dra_flag == 1
        [value, places, reader] = reader.decimal( ...
            7, 0, 999.999, 5);
        if reader.ok
            obj.dra_mult = value;
            obj.decimal_places(5) = places;
        end
        [value, reader] = reader.number( ...
            5, -9999, 9999, 1, false);
        if reader.ok
            obj.dra_sub = value;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.ttc_flag = value;
    end
    if obj.ttc_flag == 1
        [value, reader] = reader.number( ...
            2, -1, 99, 1, false);
        if reader.ok
            obj.ttcfam = value;
        end
        [value, reader] = reader.number( ...
            2, -1, 99, 1, false);
        if reader.ok
            obj.ttcmem = value;
        end
    end
    [value, reader] = reader.number( ...
        1, 0, 1, 1, false);
    if reader.ok
        obj.devlut_flag = value;
    end
    [value, reader] = reader.number( ...
        2, 1, 64, 1, false);
    if reader.ok
        obj.obpp = value;
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok
        obj.opvtype = value;
    end
    [value, reader] = reader.text(10, true, false);
    if reader.ok
        obj.outbwc = value;
    end
end
