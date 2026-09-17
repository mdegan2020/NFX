function [obj, reader] = readTimeSyncError(reader) %#codegen
    %readTimeSyncError - Decode bounded supplied sensor error metadata
    obj = nfx.TimeSyncError();
    [value, reader] = reader.number(1, 1, 5, true);
    if reader.ok, obj.num_ts_grp = value; end
    if reader.ok && any(obj.num_ts_grp == [1 3])
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.corr_ref_date_ts = value; end
        [value, reader] = reader.text(16, false);
        if reader.ok, obj.corr_ref_time_ts = value; end
        if obj.num_ts_grp == 1
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.tsrr = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.tsrc = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.tscc = value; end
        else
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_pos_cov = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_pos_att_cov = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_pos_fl_cov = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_att_cov = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_att_fl_cov = value; end
            [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
            if reader.ok, obj.ts_fl_cov = value; end
        end
        [value, reader] = reader.number(2, 1, 99, true);
        if reader.ok, obj.ts_spdcf = value; end
    end
    if reader.ok && any(obj.num_ts_grp == [2 5])
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.corr_ref_date_tsp = value; end
        [value, reader] = reader.text(16, false);
        if reader.ok, obj.corr_ref_time_tsp = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_pos_cov = value; end
        [value, reader] = reader.number(2, 1, 99, true);
        if reader.ok, obj.ts_pos_spdcf = value; end
    end
    if reader.ok && any(obj.num_ts_grp == [2 5])
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.corr_ref_date_tsa = value; end
        [value, reader] = reader.text(16, false);
        if reader.ok, obj.corr_ref_time_tsa = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_att_cov = value; end
        [value, reader] = reader.number(2, 1, 99, true);
        if reader.ok, obj.ts_att_spdcf = value; end
    end
    if reader.ok && obj.num_ts_grp == 4
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.corr_ref_date_tspa = value; end
        [value, reader] = reader.text(16, false);
        if reader.ok, obj.corr_ref_time_tspa = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_pos_cov = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_pos_att_cov = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_att_cov = value; end
        [value, reader] = reader.number(2, 1, 99, true);
        if reader.ok, obj.ts_pa_spdcf = value; end
    end
    if reader.ok && any(obj.num_ts_grp == [4 5])
        [value, reader] = reader.text(8, false);
        if reader.ok, obj.corr_ref_date_tsfl = value; end
        [value, reader] = reader.text(16, false);
        if reader.ok, obj.corr_ref_time_tsfl = value; end
        [value, reader] = reader.number(21, -9.99999999999999e99, 9.99999999999999e99, false);
        if reader.ok, obj.ts_fl_cov = value; end
        [value, reader] = reader.number(2, 1, 99, true);
        if reader.ok, obj.ts_fl_spdcf = value; end
    end
end
