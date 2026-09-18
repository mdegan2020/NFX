function report = supportFileReport(contexts, images, positions) %#codegen
    %supportFileReport - Check references that need the complete image set
    report = newReport('STDI-0002-1 Appendices AA and AV');
    levels = zeros(1, numel(images));
    quality = false(1, numel(images));
    for k = 1:numel(images)
        levels(k) = images(k).header.idlvl;
        quality(k) = strcmp(images(k).header.icat, 'PIXQUAL');
    end
    for c = 1:numel(contexts)
        index = contexts(c).image;
        records = contexts(c).records;
        h = images(index).header;
        for r = find(strcmp({records.tag}, 'PIXQLA'))
            tre = nfx.PIXQLA.deserialize(records(r).payload);
            selected = find(ismember(levels, tre.aisdlvl));
            if tre.all_images, selected = find(~quality); end
            valid = ~isempty(selected) && ~any(quality(selected)) && ...
                (tre.all_images || numel(selected) == numel(tre.aisdlvl));
            report = issue(report, ~valid, 'QualityAssociation', ...
                'PIXQLA must identify existing non-PIXQUAL image display levels.');
            if ~valid, continue; end
            first = images(selected(1)).header;
            sameBands = true; sameWavelengths = true;
            bands = size(images(index).data, 3);
            for k = selected
                other = images(k).header;
                otherBands = size(images(k).data, 3);
                dimensions = (h.nrows == other.nrows && h.ncols == other.ncols) || ...
                    (h.nrows == 1 && h.ncols == other.ncols) || ...
                    (h.ncols == 1 && h.nrows == other.nrows);
                report = issue(report, ~dimensions || ...
                    (bands ~= 1 && bands ~= otherBands), ...
                    'QualityDimensions', ...
                    'Use matching image dimensions or one compact row/column, and matching bands or one band.');
                sameBands = sameBands && bands == otherBands;
                sameWavelengths = sameWavelengths && ...
                    isequaln(first.isubcat, other.isubcat);
                aligned = isequal(positions(index, :), positions(k, :)) && ...
                    strcmp(h.idatim, other.idatim) && ...
                    strcmp(h.tgtid, other.tgtid) && ...
                    strcmp(h.isorce, other.isorce) && ...
                    strcmp(h.icords, other.icords) && ...
                    strcmp(h.igeolo, other.igeolo) && ...
                    h.nppbh == other.nppbh && h.nppbv == other.nppbv;
                report = issue(report, ~aligned, 'QualityAlignment', ...
                    'Quality images must preserve acquisition, coordinates, block sizes and pixel origin.');
            end
            expected = NaN(1, bands);
            if sameBands && sameWavelengths, expected = first.isubcat; end
            report = issue(report, ~isequaln(h.isubcat, expected), ...
                'QualityWavelengths', ...
                'Use corresponding wavelengths only when all associated bands match; otherwise use blanks.');
        end
        for r = find(strcmp({records.tag}, 'CSCCGA'))
            tre = nfx.CSCCGA.deserialize(records(r).payload);
            code = strtrim(char(tre.reg_sensor));
            if numel(code) ~= 3 || any(code < '0' | code > '9'), continue; end
            selected = find(levels == str2double(code));
            valid = isscalar(selected) && selected ~= index;
            report = issue(report, ~valid, 'CloudReference', ...
                'A numeric cloud reference must identify another image in this file.');
            if ~valid, continue; end
            other = images(selected).header;
            report = issue(report, other.ialvl ~= 0, 'CloudReferenceBase', ...
                'A local cloud reference must identify a base image (IALVL=0).');
            count = 0;
            for k = 1:numel(images)
                count = count + strcmp(images(k).header.icat, other.icat);
            end
            report = issue(report, count == 1 && ~endsWith(other.icat, '.M'), ...
                'CloudReferenceCode', ...
                'A unique still-image category uses its sensor code (PAN for VIS), not a display level.');
        end
    end
end

function report = issue(report, condition, id, message) %#codegen
    report = addIssue(report, condition, id, 'tre_records', message, report.scope);
end
