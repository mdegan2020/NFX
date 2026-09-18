function result = nfxCoderStorage(commentCounts, payloadLengths) %#codegen
    %nfxCoderStorage - Probe comment rows and variable snapshot dimensions
    assert(numel(commentCounts) <= 4 && numel(payloadLengths) <= 4);
    assert(all(commentCounts >= 0 & commentCounts <= 9));
    assert(all(payloadLengths >= 1 & payloadLengths <= 99985));
    headers = nfx.ImageHeader.empty(1, 0);
    coder.varsize('headers', [1 4], [false true]);
    result = struct('counts', zeros(1, 0), 'comments', zeros(1, 0, 'uint8'), ...
        'lengths', zeros(1, 0), 'payload', zeros(1, 0, 'uint8'), 'missing', false);
    for k = 1:numel(commentCounts)
        header = nfx.ImageHeader();
        header.icom = repmat(char(64 + k), commentCounts(k), 80);
        headers(end + 1) = header;
    end
    for k = 1:numel(headers)
        result.counts(end + 1) = headers(k).nicom;
        result.comments = [result.comments reshape(uint8(headers(k).icom.'), 1, [])];
    end
    image = nfx.ImageSegment(uint8(1));
    for k = 1:numel(payloadLengths), image = image + nfx.FREESA(payloadLengths(k)); end
    records = image.tre_records;
    for k = 1:numel(records)
        result.lengths(end + 1) = numel(records(k).payload);
        result.payload = [result.payload records(k).payload];
    end
    [value, found] = image.FREESA(numel(records) + 1);
    result.missing = ~found && isscalar(value) && value.count == 1;
end
