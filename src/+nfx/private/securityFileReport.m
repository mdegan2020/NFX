function report = securityFileReport(records, images, texts, header) %#codegen
    %securityFileReport - Check copied dates and the file-header prerequisite
    report = securityDocumentReport(records, header.fdt);
    anySegment = false;
    for k = 1:numel(images)
        child = securityDocumentReport(images(k).tre_records, header.fdt);
        anySegment = anySegment || ~child.complete;
        report = mergeReport(report, child, sprintf('images(%d).', k));
    end
    for k = 1:numel(texts)
        child = securityDocumentReport(texts(k).tre_records, header.fdt);
        anySegment = anySegment || ~child.complete;
        report = mergeReport(report, child, sprintf('texts(%d).', k));
    end
    coverage = unknownTREReport(records);
    report = addIssue(report, anySegment && coverage.complete && ...
        ~any(strcmp({records.tag}, 'SECURA')), 'MissingFileSecurity', ...
        'tre_records', 'A segment SECURA requires a file-header SECURA.', ...
        'STDI-0002-1 Appendix AI');
end
