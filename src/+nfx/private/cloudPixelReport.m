function report = cloudPixelReport(records, image) %#codegen
    %cloudPixelReport - Check cloud samples without resolving model companions
    report = newReport('STDI-0002-1 Appendix AV');
    h = image.header;
    if ~strcmp(h.icat, 'CLOUD') && ~any(strcmp({records.tag}, 'CSCCGA'))
        return
    end
    category = h.isubcat_text;
    percent = size(category, 1) == 1 && strcmp(category, 'CLDPCT');
    pixels = zeros(0, 0, 'uint8');
    if image.pixelsLoaded, pixels = image.data; end
    if percent
        validValues = pixels <= 100 | pixels == 253 | pixels == 254;
    else
        validValues = pixels == 0 | pixels == 253 | ...
            pixels == 254 | pixels == 255;
    end
    report = addIssue(report, any(~validValues(:)) || ...
        any(~isnan(h.isubcat)), 'CloudPixels', 'tre_records', ...
        'Use binary or percentage cloud values, with 253 fill and 254 unknown.', ...
        report.scope);
end
