function report = contextImageReport(contexts,images) %#codegen
    %contextImageReport - Validate model companions in every selected frame set
    report = newReport('Effective image metadata');
    for k = 1:numel(contexts)
        records = contexts(k).records; header = images(contexts(k).image).header;
        coverage = unknownTREReport(records);
        inherited = unknownTREReport(contexts(k).file_records);
        report = mergeReport(report, coverage, '');
        report = mergeReport(report, inherited, '');
        if ~coverage.complete || ~inherited.complete, continue; end
        prefix = sprintf('contexts(%.0f:%.0f).',contexts(k).first,contexts(k).last);
        report = mergeReport(report,rsmSetReport(records,header),[prefix 'rsm.']);
        report = mergeReport(report,glasImageReport(records,header),[prefix 'glas.']);
    end
end
