function [obj, reader] = readUnmodeledErrorGrid(reader) %#codegen
    %readUnmodeledErrorGrid - Decode bounded supplied sensor error metadata
    obj = nfx.UnmodeledErrorGrid();
    [rows, reader] = reader.count(3, 63, 999);
    [cols, reader] = reader.count(2, 63, 99);
    [values, reader] = reader.numbers(rows * cols * 3, 21, -9.99999999999999e99, 9.99999999999999e99);
    if reader.ok
        obj.urr = reshape(values(1:3:end), cols, rows).';
        obj.urc = reshape(values(2:3:end), cols, rows).';
        obj.ucc = reshape(values(3:3:end), cols, rows).';
    end
    [value, reader] = reader.number(2, 1, 99, true);
    if reader.ok, obj.line_spdcf = value; end
    [value, reader] = reader.number(2, 1, 99, true);
    if reader.ok, obj.sample_spdcf = value; end
end
