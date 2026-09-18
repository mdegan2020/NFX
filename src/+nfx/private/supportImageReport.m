function report = supportImageReport(records, image) %#codegen
    %supportImageReport - Check local quality, cloud, block and target metadata
    report = newReport('STDI-0002-1 Appendices E, AA and AV');
    h = image.header;
    tags = {records.tag};
    coverage = unknownTREReport(records);
    q = find(strcmp(tags, 'PIXQLA'));
    c = find(strcmp(tags, 'CSCCGA'));
    if strcmp(h.icat, 'PIXQUAL') || ~isempty(q)
        valid = strcmp(h.icat, 'PIXQUAL') && ...
            strcmp(h.irep, 'NODISPLY') && ...
            (isscalar(q) || (isempty(q) && ~coverage.complete)) && ...
            strcmp(h.imode, 'B') && strcmp(h.pjust, 'R') && ...
            h.abpp >= 2 + 7 * (h.nbpp == 16);
        report = issue(report, ~valid, 'PixelQualityImage', ...
            'PIXQUAL requires one PIXQLA, NODISPLY, and supported unsigned bit storage.');
        if isscalar(q)
            tre = nfx.PIXQLA.deserialize(records(q).payload);
            report = issue(report, tre.npixqual > h.abpp, ...
                'QualityPrecision', 'ABPP must cover every defined quality bit.');
        end
    end
    if strcmp(h.icat, 'CLOUD') || ~isempty(c)
        valid = strcmp(h.icat, 'CLOUD') && strcmp(h.irep, 'MONO') && ...
            (isscalar(c) || (isempty(c) && ~coverage.complete)) && ...
            h.nbands == 1 && h.nbpp == 8 && ...
            h.abpp == 8 && strcmp(h.imode, 'B') && ...
            strcmp(h.pjust, 'R') && ...
            (strcmp(h.iid1, 'CLOUDCOVER') || startsWith(h.iid1, 'CC'));
        labels = h.irepband;
        for k = 1:numel(labels), valid = valid && isempty(strtrim(labels{k})); end
        report = issue(report, ~valid, 'CloudImage', ...
            'CLOUD requires one CSCCGA, one unsigned 8-bit band, and a cloud image identifier.');
        category = h.isubcat_text;
        percent = size(category, 1) == 1 && strcmp(category, 'CLDPCT');
        pixels = image.data;
        if percent
            validValues = pixels <= 100 | pixels == 253 | pixels == 254;
        else
            validValues = pixels == 0 | pixels == 253 | ...
                pixels == 254 | pixels == 255;
        end
        report = issue(report, any(~validValues(:)) || ...
            any(~isnan(h.isubcat)), 'CloudPixels', ...
            'Use binary or percentage cloud values, with 253 fill and 254 unknown.');
        if isscalar(c)
            tre = nfx.CSCCGA.deserialize(records(c).payload);
            report = issue(report, tre.ccg_max_line ~= h.nrows || ...
                tre.ccg_max_sample ~= h.ncols, 'CloudDimensions', ...
                'Cloud grid dimensions must match the image dimensions.');
            report = issue(report, ~isequal(h.iloc, ...
                [tre.origin_line tre.origin_sample] - 1), ...
                'CloudOrigin', 'ILOC must express the zero-based cloud grid origin.');
        end
    end
    targets = find(strcmp(tags, 'MSTGTA'));
    active = zeros(1, 0);
    report = issue(report, numel(targets) > 256, 'TargetCount', ...
        'An image may contain at most 256 mission target records.');
    for k = targets
        tre = nfx.MSTGTA.deserialize(records(k).payload);
        if tre.tgt_num ~= 0, active(end + 1) = tre.tgt_num; end
    end
    report = issue(report, numel(unique(active)) ~= numel(active), ...
        'TargetNumber', 'Nonempty mission target numbers must be unique.');
    blocks = find(strcmp(tags, 'BLOCKA'));
    numbers = zeros(1, numel(blocks));
    for k = 1:numel(blocks)
        tre = nfx.BLOCKA.deserialize(records(blocks(k)).payload);
        numbers(k) = tre.block_instance;
        if ~any(strcmp(h.icat, {'SAR','ISAR','SAR.M','ISAR.M'}))
            report = issue(report, tre.n_gray ~= 0 || ...
                ~isnan(tre.layover_angle) || ~isnan(tre.shadow_angle), ...
                'BlockRadarFields', 'Non-radar BLOCKA requires zero gray fill and blank radar angles.');
        end
    end
    report = issue(report, numel(unique(numbers)) ~= numel(numbers), ...
        'BlockNumber', 'Block instance numbers must be distinct.');
end

function report = issue(report, condition, id, message) %#codegen
    report = addIssue(report, condition, id, 'tre_records', message, report.scope);
end
