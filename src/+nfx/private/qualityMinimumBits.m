function value = qualityMinimumBits(records) %#codegen
    %qualityMinimumBits - Retain bits defined by local quality metadata
    value = 1;
    queue = records;
    while ~isempty(queue)
        record = queue(1); queue(1) = [];
        if strcmp(record.tag, 'PIXQLA')
            [tre, ok] = nfx.PIXQLA.deserialize(record.payload);
            if ok, value = max(value, tre.npixqual); end
        elseif any(strcmp(record.tag, {'CONTXA','FSYNWA','FASYWA'}))
            [children, reader] = readWrapperChildren(record.tag, record.payload);
            if reader.ok, queue = [queue children]; end %#ok<AGROW>
        end
    end
end
