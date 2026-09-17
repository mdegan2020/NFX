function [obj, reader] = readFieldAlignmentGrid(reader) %#codegen
    %readFieldAlignmentGrid - Decode bounded supplied sensor metadata
    obj = nfx.FieldAlignmentGrid();
    [value, reader] = reader.number(11, 0, 99.99999999, false);
    if reader.ok, obj.fl_cal = value; end
    [value, reader] = reader.number(12, -99999.99999, 99999.99999, false);
    if reader.ok, obj.num_fir_line = value; end
    [value, reader] = reader.number(11, 0, 99999.99999, false);
    if reader.ok, obj.delta_line = value; end
    [rows, reader] = reader.count(3, 88, 999);
    [value, reader] = reader.number(12, -99999.99999, 99999.99999, false);
    if reader.ok, obj.num_fir_samp = value; end
    [value, reader] = reader.number(11, 0, 99999.99999, false);
    if reader.ok, obj.delta_samp = value; end
    [cols, reader] = reader.count(3, 88, 999);
    [values, reader] = reader.numbers(rows * cols * 8, 11, -99.9999999, 99.9999999);
    if reader.ok
        obj.fa_x1 = reshape(values(1:8:end), cols, rows).';
        obj.fa_y1 = reshape(values(2:8:end), cols, rows).';
        obj.fa_x2 = reshape(values(3:8:end), cols, rows).';
        obj.fa_y2 = reshape(values(4:8:end), cols, rows).';
        obj.fa_x3 = reshape(values(5:8:end), cols, rows).';
        obj.fa_y3 = reshape(values(6:8:end), cols, rows).';
        obj.fa_x4 = reshape(values(7:8:end), cols, rows).';
        obj.fa_y4 = reshape(values(8:8:end), cols, rows).';
    end
end
