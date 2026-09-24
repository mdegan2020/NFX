function report = snipQuicklookReport(image,spectral,total) %#codegen
    %snipQuicklookReport - Check supplied overview imagery and source comments
    report = newReport('SNIP quick look'); h = image.header; bands = image.number_bands;
    id = strtrim(char(h.iid1)); validID = strcmp(id,'QUICK_LOOK');
    if total > 1, validID = startsWith(id,'QL') && numel(id) > 2; end
    report = snipIssue(report,~validID,'SNIPQuicklookID','header.iid1','Use QUICK_LOOK, or distinct QL-prefixed IDs for multiple quick looks.','9.2');
    valid = (bands == 1 && strcmp(h.irep,'MONO') && isequal(h.irepband,{'M'})) || ...
        (bands == 3 && any(strcmp(h.irep,{'RGB','MULTI'})) && isequal(h.irepband,{'R','G','B'}));
    report = snipIssue(report,~valid || ~strcmp(h.icat,'VIS') || h.abpp < 8 || ...
        (h.nbpp == 16 && h.abpp == 8),'SNIPQuicklookPixels','header', ...
        'Use VIS, MONO/M or RGB/MULTI with RGB labels and the prescribed 8-16 bit storage.','Table 9-1');
    report = snipIssue(report,h.nbpr ~= 1 || h.nbpc ~= 1 || h.nppbh ~= h.ncols || h.nppbv ~= h.nrows, ...
        'SNIPQuicklookBlock','header.block_size','Store the quick look as one unpadded image-sized block.','Table 9-1');
    candidates = false(1,numel(spectral));
    for k = 1:numel(spectral)
        source = spectral(k).header;
        match = h.ialvl == source.idlvl;
        if h.ialvl == 0
            match = (isempty(strtrim(char(h.iid2))) || strcmp(char(h.iid2),char(source.iid2))) && ...
                strcmp(char(h.isorce),char(source.isorce)) && strcmp(char(h.igeolo),char(source.igeolo));
        end
        candidates(k) = match;
    end
    report = snipIssue(report,sum(candidates) ~= 1,'SNIPQuicklookSource','header.ialvl/iid2', ...
        'Identify one associated spectral image using attachment or matching source metadata.','9');
    if sum(candidates) ~= 1, return; end
    source = spectral(candidates).header;
    report = snipIssue(report,~strcmp(char(h.isorce),char(source.isorce)) || ...
        ~strcmp(char(h.tgtid),char(source.tgtid)) || ~strcmp(char(h.icords),char(source.icords)) || ...
        ~strcmp(char(h.igeolo),char(source.igeolo)) || ...
        (~isempty(strtrim(char(h.iid2))) && ~strcmp(char(h.iid2),char(source.iid2))), ...
        'SNIPQuicklookMetadata','header','Preserve source identity, target and geographic corners.','Table 9-1');
    report = snipIssue(report,h.nrows > source.nrows || h.ncols > source.ncols || ...
        abs(h.nrows*source.ncols-h.ncols*source.nrows) > .5*max(source.nrows,source.ncols), ...
        'SNIPQuicklookDimensions','header.nrows/ncols','Preserve the source aspect ratio at the same or lower resolution.','9.3');
    report = snipIssue(report,h.nicom == 0,'SNIPQuicklookComment','header.icom', ...
        'The first comment must identify the source bands and their wavelengths.','9.4');
    if h.nicom == 0, return; end
    comment = strtrim(h.icom(1,:)); prefix = 'Created from band '; middle = ', wavelength ';
    if bands == 3, prefix = 'RGB created from bands '; middle = ', wavelengths '; end
    marker = strfind(comment,middle); valid = startsWith(comment,prefix) && isscalar(marker);
    subcategoriesMatch = true;
    if valid
        indices = strsplit(comment(numel(prefix)+1:marker-1),',');
        tail = strtrim(comment(marker+numel(middle):end)); blank = find(tail == ' ',1,'last');
        valid = ~isempty(blank);
        if valid
            unit = tail(blank+1:end); values = strsplit(tail(1:blank-1),',');
            factor = NaN;
            if strcmp(unit,'nm'), factor = 1; elseif any(strcmp(unit,{'um',[char(181) 'm']})), factor = 1000; end
            valid = numel(indices) == bands && numel(values) == bands && isfinite(factor);
            if valid
                for k = 1:bands
                    index = str2double(indices{k}); wavelength = str2double(values{k})*factor;
                    inRange = isfinite(index) && fix(index) == index && index >= 1 && index <= numel(source.isubcat);
                    valid = valid && inRange && isfinite(wavelength);
                    if inRange
                        valid = valid && abs(wavelength-source.isubcat(index)) <= max(1e-6,abs(wavelength)*1e-5);
                        if ~isnan(h.isubcat(k))
                            actual = str2double(char(bandDecimal(h.isubcat(k),6)));
                            expected = str2double(char(bandDecimal(source.isubcat(index),6)));
                            subcategoriesMatch = subcategoriesMatch && actual == expected;
                        end
                    end
                end
            end
        end
    end
    report = snipIssue(report,~valid,'SNIPQuicklookComment','header.icom(1)', ...
        'Use the prescribed source-band/wavelength comment in displayed RGB order, with nm or um units.','9.4');
    report = snipIssue(report,~subcategoriesMatch,'SNIPQuicklookWavelength','header.isubcat', ...
        'Each displayed band subcategory must be blank or its source wavelength in nanometers.','Table 9-1');
end
