function report = unknownTREReport(records) %#codegen
    %unknownTREReport - Mark preserved metadata with unavailable semantics
    report = newReport('TRE schema coverage');
    queue = nfx.internal.emptyTRERecords();
    for k = 1:numel(records)
        queue(end + 1) = struct('tag', records(k).tag, ...
            'payload', records(k).payload, 'id', k);
    end
    at = 1;
    while at <= numel(queue)
        entry = queue(at); at = at + 1;
        if any(strcmp(entry.tag, {'FSYNWA', 'FASYWA', 'CONTXA'}))
            [children, reader] = readWrapperChildren(entry.tag, entry.payload);
            if reader.ok, queue = [queue children]; end %#ok<AGROW>
        elseif ~knownTRE(entry.tag)
            report.complete = false;
            report.issues(end + 1) = struct('severity', 'warning', ...
                'id', 'UnknownTRE', 'field', entry.tag, ...
                'message', ['Preserved opaque TRE ' entry.tag ...
                    '; schema and affected model relationships are unverified.'], ...
                'reference', 'NFX supported TRE schemas');
        end
    end
end
