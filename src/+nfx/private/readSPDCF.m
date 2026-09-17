function [obj, reader] = readSPDCF(reader) %#codegen
    %readSPDCF - Decode bounded supplied sensor error metadata
    obj = nfx.SPDCF();
    [value, reader] = reader.number(2, 1, 99, true);
    if reader.ok, obj.spdcf_id = value; end
    [count, reader] = reader.count(2, 52, 99);
    for k = 1:count
        [component, reader] = readGLASCorrelation(reader);
        if ~reader.ok, break, end
        obj.components(end + 1) = component;
    end
end
