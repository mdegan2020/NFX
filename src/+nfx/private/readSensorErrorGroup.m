function [obj, reader] = readSensorErrorGroup(reader) %#codegen
    %readSensorErrorGroup - Decode bounded supplied sensor error metadata
    obj = nfx.SensorErrorGroup();
    [value, reader] = reader.text(8, false);
    if reader.ok, obj.corr_ref_date = value; end
    [value, reader] = reader.text(16, false);
    if reader.ok, obj.corr_ref_time = value; end
    [count, reader] = reader.count(1, 1, 7);
    [ids, reader] = reader.numbers(count, 1, 1, 7, true);
    if reader.ok, obj.adj_parm_id = ids; end
    [flag, reader] = reader.number(1, 0, 1, true);
    if reader.ok && flag == 1
        [matrix, reader] = readGLASCovariance(reader, count, 1);
        if reader.ok, obj.errcov_c1 = matrix; end
        [items, reader] = readCorrelationPairings(reader);
        if reader.ok, obj.basic_pf = items; end
        [items, reader] = readCorrelationPairings(reader);
        if reader.ok, obj.basic_pl = items; end
        [flag, reader] = reader.number(1, 0, 1, true);
        if reader.ok && flag == 1
            [value, reader] = reader.number(2, 1, 99, true);
            if reader.ok, obj.basic_sr_spdcf = value; end
        end
    end
    [flag, reader] = reader.number(1, 0, 1, true);
    if reader.ok && flag == 1
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.post_start_date = value; end
        [value, reader] = reader.number(15, 0, 86399.999999999, false);
        if reader.ok, obj.post_start_time = value; end
        [value, reader] = reader.number(13, 0, 999.999999999, false);
        if reader.ok, obj.post_dt = value; end
        [value, reader] = reader.number(3, 2, 999, true);
        if reader.ok, obj.num_posts = value; end
        [common, reader] = reader.number(1, 0, 1, true);
        if ~reader.ok, return, end
        pages = 1;
        if common == 0, pages = obj.num_posts; end
        [matrix, reader] = readGLASCovariance(reader, count, pages);
        if reader.ok, obj.errcov_c2 = matrix; end
        [value, reader] = reader.number(1, 0, 1, true);
        if reader.ok, obj.post_interp = value; end
        [items, reader] = readCorrelationPairings(reader);
        if reader.ok, obj.post_pf = items; end
        [items, reader] = readCorrelationPairings(reader);
        if reader.ok, obj.post_pl = items; end
        [flag, reader] = reader.number(1, 0, 1, true);
        if reader.ok && flag == 1
            [value, reader] = reader.number(2, 1, 99, true);
            if reader.ok, obj.post_sr_spdcf = value; end
            [value, reader] = reader.number(1, 0, 1, true);
            if reader.ok, obj.post_corr = value; end
        end
    end
end
