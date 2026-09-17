function [obj, reader] = readFiducialTransform(reader) %#codegen
    %readFiducialTransform - Decode bounded supplied sensor metadata
    obj = nfx.FiducialTransform();
    [rows, reader] = reader.count(3, 168, 999);
    [cols, reader] = reader.count(3, 168, 999);
    [values, reader] = reader.numbers(rows * cols * 8, 21, -9.99999999999999e99, 9.99999999999999e99);
    if reader.ok
        obj.ls_fid_trans_t0 = reshape(values(1:8:end), cols, rows).';
        obj.ls_fid_trans_t1 = reshape(values(2:8:end), cols, rows).';
        obj.ls_fid_trans_t2 = reshape(values(3:8:end), cols, rows).';
        obj.ls_fid_trans_t3 = reshape(values(4:8:end), cols, rows).';
        obj.ls_fid_trans_t4 = reshape(values(5:8:end), cols, rows).';
        obj.ls_fid_trans_t5 = reshape(values(6:8:end), cols, rows).';
        obj.ls_fid_trans_t6 = reshape(values(7:8:end), cols, rows).';
        obj.ls_fid_trans_t7 = reshape(values(8:8:end), cols, rows).';
    end
end
