function result = nfxCoderEngineering(data, count) %#codegen
    %nfxCoderEngineering - Probe homogeneous entries with varying byte sizes
    assert(isa(data, 'uint16') && ismatrix(data) && ~isempty(data));
    assert(all(size(data) <= 8));
    assert(count >= 1 && count <= 3 && fix(count) == count);
    entries = nfx.ENGRDA.entry('A', data);
    if count >= 2, entries(2) = nfx.ENGRDA.entry('Text', 'NFX'); end
    if count == 3
        entries(3) = nfx.ENGRDA.entry('Raw', uint8(1));
        entries(3).engdts = 3;
        entries(3).engdata = uint8([128 0 1]);
    end
    image = nfx.ImageSegment(uint8(1)) + ...
        nfx.ENGRDA(resrc='Sensor', redata=entries);
    [tre, ok] = image.ENGRDA;
    [matrix, converted] = nfx.ENGRDA.values(tre.redata(1), uint16(0));
    counts = tre.engdatc;
    payload = tre.payload();
    tre.resrc = 'Edited';
    [~, found] = image.ENGRDA(2);
    original = image.ENGRDA;
    result = struct('ok', ok && converted, 'matrix', matrix, ...
        'counts', counts, 'payload', payload, 'missing', ~found, ...
        'independent', strcmp(original.resrc, 'Sensor'));
end
