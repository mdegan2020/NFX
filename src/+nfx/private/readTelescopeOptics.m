function [obj, reader] = readTelescopeOptics(reader, flag) %#codegen
    %readTelescopeOptics - Decode bounded supplied sensor metadata
    obj = nfx.TelescopeOptics();
    obj.telescope_optics_flag = flag;
    [lensCount, reader] = reader.count(1, 263, 1);
    [count, reader] = reader.unsigned(4);
    if ~reader.ok, return, end
    count = double(count); varyingCount = 0;
    if flag == 2
        [varyingCount, reader] = reader.count(2, 2, 11);
        [ids, reader] = reader.numbers(varyingCount, 2, 1, 11, true);
        if reader.ok, obj.time_varying_io_parm_id = ids; end
        [date, reader] = reader.text(8, false);
        if reader.ok, obj.tele_date = date; end
    end
    rowBytes = 168 + double(flag == 2) * (15 + 21 * varyingCount);
    if ~reader.ok, return, end
    if count > floor((numel(reader.data) - reader.position + 1) / rowBytes)
        reader = reader.fail('TruncatedPayload', 'Telescope frame count exceeds available bytes.');
        return
    end
    terms = zeros(8, count); times = zeros(1, count);
    varying = zeros(varyingCount, count);
    for k = 1:count
        if flag == 2
            [times(k), reader] = reader.number(15, 0, 99999.999999999);
        end
        [values, reader] = reader.numbers(8, 21, -9.99999999999999e99, 9.99999999999999e99);
        if ~reader.ok, return, end
        terms(:, k) = values.';
        if flag == 2
            [values, reader] = reader.numbers(varyingCount, 21, -9.99999999999999e99, 9.99999999999999e99);
            if ~reader.ok, return, end
            varying(:, k) = values.';
        end
    end
    obj.tele_trans_t0 = terms(1, :);
    obj.tele_trans_t1 = terms(2, :);
    obj.tele_trans_t2 = terms(3, :);
    obj.tele_trans_t3 = terms(4, :);
    obj.tele_trans_t4 = terms(5, :);
    obj.tele_trans_t5 = terms(6, :);
    obj.tele_trans_t6 = terms(7, :);
    obj.tele_trans_t7 = terms(8, :);
    if flag == 2
        obj.tele_time = times; obj.time_varying_io_m = varying;
    end
    if lensCount == 1
        [lens, reader] = readInteriorOrientation(reader);
        if reader.ok, obj.tele_iop = lens; end
    end
end
