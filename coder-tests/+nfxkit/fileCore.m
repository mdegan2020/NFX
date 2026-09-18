function result = fileCore(raw, prototype) %#codegen
    %fileCore - Expose complete-file inference separately from pixel decoding
    result = struct('ok', false, 'code', '', 'samples', reshape(prototype, 1, []), ...
        'header', zeros(1, 0, 'uint8'));
    [file, ok, status] = nfx.internal.FileReader.readBytes(raw, 10000);
    result.ok = ok; result.code = status.code;
    if ~ok, return, end
    result.header = file.header.bytes();
    for k = 1:numel(file.images)
        assert(isa(file.images(k).data, class(prototype)));
        result.samples = [result.samples reshape(file.images(k).data, 1, [])];
    end
end
