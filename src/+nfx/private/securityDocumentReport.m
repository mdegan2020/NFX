function report = securityDocumentReport(records, fileDate) %#codegen
    %securityDocumentReport - Check copied dates and expose schema limits
    report = newReport('STDI-0002-1 Appendix AI');
    queue = nfx.internal.emptyTRERecords();
    for k = 1:numel(records)
        queue(end + 1) = struct('tag', records(k).tag, ...
            'payload', records(k).payload, 'id', k);
    end
    at = 1;
    while at <= numel(queue)
        record = queue(at); at = at + 1;
        if any(strcmp(record.tag, {'CONTXA','FSYNWA','FASYWA'}))
            [children, reader] = readWrapperChildren(record.tag, record.payload);
            if reader.ok, queue = [queue children]; end %#ok<AGROW>
        elseif strcmp(record.tag, 'SECURA')
            tre = nfx.SECURA.deserialize(record.payload);
            report = addIssue(report, ~isempty(fileDate) && ...
                ~strcmp(tre.fdattim, fileDate), 'SecurityFileDate', ...
                'SECURA.fdattim', 'SECURA FDATTIM must match the file FDT.', ...
                report.scope);
            report = mergeReport(report, unverifiedSecurityDocument(), '');
        end
    end
end
