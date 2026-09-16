function report = contextImageReport(contexts,images) %#codegen
    %contextImageReport - Validate model companions in every selected frame set
    report = newReport('Effective image metadata');
    for k = 1:numel(contexts)
        records = contexts(k).records; header = images(contexts(k).image).header;
        prefix = sprintf('contexts(%.0f:%.0f).',contexts(k).first,contexts(k).last);
        report = mergeReport(report,rsmSetReport(records,header),[prefix 'rsm.']);
        report = mergeReport(report,glasImageReport(records,header),[prefix 'glas.']);
    end
end
