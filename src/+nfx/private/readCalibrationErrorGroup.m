function [obj, reader] = readCalibrationErrorGroup(reader, pages) %#codegen
    %readCalibrationErrorGroup - Decode bounded supplied sensor error metadata
    obj = nfx.CalibrationErrorGroup();
    [value, reader] = reader.text(8, false);
    if reader.ok, obj.corr_ref_date_io = value; end
    [value, reader] = reader.text(16, false);
    if reader.ok, obj.corr_ref_time_io = value; end
    [count, reader] = reader.count(2, 2, 11);
    [ids, reader] = reader.numbers(count, 2, 1, 11, true);
    if reader.ok, obj.cal_ap_id = ids; end
    [matrix, reader] = readGLASCovariance(reader, count, pages);
    if reader.ok, obj.errcov_c3 = matrix; end
    [value, reader] = reader.number(1, 0, 1, true);
    if reader.ok, obj.cal_interp = value; end
    [value, reader] = reader.number(2, 1, 99, true);
    if reader.ok, obj.spdcf_id_time = value; end
    [value, reader] = reader.number(2, 1, 99, true);
    if reader.ok, obj.spdcf_id_fl = value; end
end
