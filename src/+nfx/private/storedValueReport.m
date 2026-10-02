function report = storedValueReport(records, header) %#codegen
    %storedValueReport - Check effective stored-to-engineering value metadata
    reference = 'STDI-0002-1 Appendix AT, S2EVPA-007, -008 and -013';
    report = newReport(reference);
    tags = {records.tag};
    selected = find(strcmp(tags, 'S2EVPA'));
    if isempty(selected)
        return
    end
    ranges = zeros(numel(selected), 2);
    for k = 1:numel(selected)
        tre = nfx.S2EVPA.deserialize(records(selected(k)).payload);
        ranges(k, :) = [tre.first_band tre.last_band];
    end
    bands = header.nbands + sum(header.xbands);
    report = addIssue(report, any(ranges(:, 2) > bands), ...
        'EngineeringBandRange', 'S2EVPA.last_band', ...
        'Engineering-value band ranges must fit the associated image.', reference);
    ranges = sortrows(ranges, 1);
    overlap = false;
    last = ranges(1, 2);
    for k = 2:size(ranges, 1)
        overlap = overlap || ranges(k, 1) <= last;
        last = max(last, ranges(k, 2));
    end
    report = addIssue(report, overlap, 'EngineeringBandOverlap', 'S2EVPA', ...
        'Engineering-value band ranges must not overlap.', reference);
    report = addIssue(report, any(ismember(tags, {'BANDSB', 'PIXMTA'})), ...
        'EngineeringTransformConflict', 'S2EVPA', ...
        'Omit S2EVPA when BANDSB or PIXMTA supplies a value transformation.', ...
        reference);
end
