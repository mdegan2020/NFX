function report = snipReport(header,images,texts,records,des) %#codegen
    %snipReport - Enforce the supplied airborne nonrectified MSI metadata case
    report = newReport('SNIP 1.2 CN1 airborne nonrectified MSI');
    spectral = false(1,numel(images)); quick = spectral;
    for k = 1:numel(images)
        id = strtrim(char(images(k).header.iid1));
        spectral(k) = strcmp(id,'MULTISPECT') || (startsWith(id,'MSI') && numel(id) > 3);
        quick(k) = strcmp(id,'QUICK_LOOK') || (startsWith(id,'QL') && numel(id) > 2);
        report = snipIssue(report,~spectral(k) && ~quick(k),'SNIPImageScope',sprintf('images(%d).iid1',k), ...
            'The selected profile supports complete MSI images and supplied quick looks.','6.4');
        h = images(k).header;
        report = snipIssue(report,~strcmp(h.ic,'NC') || images(k).number_frames ~= 1 || ~strcmp(h.pjust,'R') || ...
            ~any(h.nbpp == [8 16]) || ~any(strcmp(h.icords,{'G','D','N','S','U'})), ...
            'SNIPImageEncoding',sprintf('images(%d).header',k), ...
            'This selected SNIP profile requires NC still unsigned 8/16-bit imagery, right justification and geographic corners.','Tables 9-1 and 10-5');
    end
    report = snipIssue(report,~any(spectral),'SNIPSpectralImage','images','At least one spectral image is required.','6.4.4.2');
    if ~any(spectral), return; end
    first = find(spectral,1);
    report = snipIssue(report,any(quick(first:end)) || images(first).header.idlvl ~= 1, ...
        'SNIPImageOrder','images','Place quick looks first and give the first spectral image display level one.','6.4.4 and 10.7.6');
    report = snipIssue(report,isempty(strtrim(char(header.ftitle))) || isempty(strtrim(char(header.oname))) || ...
        isempty(strtrim(char(header.ophone))),'SNIPFileIdentity','header.ftitle/oname/ophone', ...
        'Supply the filename prefix and originator contact fields.','8');
    for k = 1:numel(des)
        report = snipIssue(report,~any(strcmp(des(k).header.desid,{'TRE_OVERFLOW','CSATTB','CSEPHB','CSSFAB','CSCSDB'})), ...
            'SNIPDESScope',sprintf('des(%d)',k),'This profile supports TRE overflow and typed sensor-model DESs.','6.4');
    end
    report = mergeReport(report,snipCitationReport(texts,header,images(first).header.idlvl),'');
    ids = find(strcmp({records.tag},'CSDIDA'));
    report = snipIssue(report,numel(ids) ~= 1,'SNIPDatasetIdentification','CSDIDA', ...
        'Include exactly one file-header CSDIDA.','6.4.3');
    times = repmat(' ',sum(spectral),14); names = repmat(' ',sum(spectral),80); count = 0;
    for k = find(spectral)
        count = count+1; h = images(k).header; times(count,:) = char(h.idatim); names(count,:) = textField(h.iid2,80);
        report = snipIssue(report,h.ialvl ~= 0 || isempty(strtrim(char(h.iid2))) || isempty(strtrim(char(h.isorce))) || ...
            (sum(spectral) == 1 && ~strcmp(char(h.iid1),'MULTISPECT')), ...
            'SNIPSpectralIdentity',sprintf('images(%d).header',k), ...
            'Supply an unattached base image, unique IID2 and sensor source; a sole MSI image uses MULTISPECT.','10.7');
        report = snipIssue(report,~any(strcmp(h.icat,{'MS','EO','EOVIS','VNIR','NIR','SWIR','MWIR','LWIR','IR','UV','FL','TI','OP','CAVIS','DTV'})) || ...
            any(~ismember(h.irepband,{'',' ','M','R','G','B'})), ...
            'SNIPSpectralDisplay',sprintf('images(%d).header',k), ...
            'Use a spectral category and M/R/G/B or blank band labels.','Tables 10-3 and 10-4');
        item = images(k).tre_records; tags = {item.tag};
        required = {'BANDSB','CSCRNA','HISTOA','ACFTB ','AIMIDB'};
        for r = 1:numel(required)
            report = snipIssue(report,sum(strcmp(tags,required{r})) ~= 1,'SNIPRequiredTRE', ...
                sprintf('images(%d).%s',k,required{r}),'Supply one complete instance of this required spectral TRE.','Table 6-5');
        end
        report = snipIssue(report,~any(strcmp(tags,'ILLUMB')),'SNIPRequiredTRE',sprintf('images(%d).ILLUMB',k), ...
            'Supply image-level illumination metadata.','17.7');
        report = snipIssue(report,any(ismember(tags,{'CONTXA','FSYNWA','FASYWA','MTIMSA'})), ...
            'SNIPMetadataScope',sprintf('images(%d)',k),'Motion/frame contexts are outside the selected still-image profile.','6.4');
        selected = find(strcmp(tags,'BANDSB'));
        if isscalar(selected), report = mergeReport(report,snipBandReport(item(selected).payload,h),sprintf('images(%d).',k)); end
        selected = find(strcmp(tags,'AIMIDB'));
        if isscalar(selected)
            report = snipIssue(report,~strcmp(char(item(selected).payload(1:14)),char(h.idatim)), ...
                'SNIPAcquisitionTime',sprintf('images(%d).AIMIDB',k),'Acquisition dates must agree.','15.2');
        end
        illuminationTime = false; illuminationGeometry = false;
        for r = find(strcmp(tags,'ILLUMB'))
            [child,matched,geometry] = snipIlluminationReport(item(r).payload,h);
            report = mergeReport(report,child,sprintf('images(%d).',k));
            illuminationTime = illuminationTime || matched; illuminationGeometry = illuminationGeometry || geometry;
        end
        report = snipIssue(report,~illuminationTime,'SNIPIlluminationTime',sprintf('images(%d).ILLUMB.datetime',k), ...
            'Include an illumination set at the image acquisition time.','17.7');
        report = snipIssue(report,~illuminationGeometry,'SNIPIlluminationGeometry',sprintf('images(%d).ILLUMB',k), ...
            'Supply known sensor azimuth and elevation in the acquisition-time set.','17.7');
        cropped = false; selected = find(strcmp(tags,'HISTOA'));
        if isscalar(selected)
            [child,cropped] = snipHistoryReport(item(selected).payload,h,header);
            report = mergeReport(report,child,sprintf('images(%d).',k));
        end
        chips = find(strcmp(tags,'ICHIPB'));
        report = snipIssue(report,numel(chips) > 1 || (cropped && isempty(chips)), ...
            'SNIPChipMapping',sprintf('images(%d).ICHIPB',k),'A declared spatial crop needs one original-image mapping.','20.1');
        if isscalar(chips)
            report = mergeReport(report,snipChipReport(item(chips).payload,records,h,header,cropped),sprintf('images(%d).',k));
        end
        report = mergeReport(report,snipModelReport(item,h,header,des),sprintf('images(%d).',k));
    end
    report = snipIssue(report,size(unique(names,'rows'),1) ~= sum(spectral),'SNIPImageIdentity','images.iid2', ...
        'Distinct complete spectral images must have distinct IID2 values.','10.7.1.2');
    report = mergeReport(report,sortedIdentifiers(images(spectral)),'');
    if isscalar(ids)
        data = records(ids).payload; times = sortrows(times);
        report = snipIssue(report,~strcmp(char(data(10:11)),'9I'),'SNIPPlatformScope','CSDIDA.platform_code', ...
            'Use the pinned airborne WAMI platform code 9I; other catalog entries describe spaceborne systems.','21.2.1.3; Appendix AS Table AS.5-1');
        report = snipIssue(report,~strcmp(char(data(14:15)),'00') || ~strcmp(char(data(19:22)),'GAP2'), ...
            'SNIPDatasetScope','CSDIDA.pass/sensor_id/product_id','Use airborne PASS 0, MSI sensor GA and nonrectified product P2.','21.2.1.3');
        report = snipIssue(report,~strcmp(char(data(27:40)),times(1,:)) || ~strcmp(char(data(41:54)),char(header.fdt)), ...
            'SNIPDatasetTime','CSDIDA.time/process_time','Match the earliest spectral acquisition and the file creation time.','21.2.1.3');
    end
    for k = find(quick)
        report = mergeReport(report,snipQuicklookReport(images(k),images(spectral),sum(quick)),sprintf('images(%d).',k));
    end
    quickNames = repmat(' ',sum(quick),10); count = 0;
    for k = find(quick), count = count+1; quickNames(count,:) = textField(images(k).header.iid1,10); end
    report = snipIssue(report,size(unique(quickNames,'rows'),1) ~= sum(quick),'SNIPQuicklookID','images.iid1', ...
        'Multiple quick looks must have distinct QL-prefixed IDs.','9.2');
end

function report = sortedIdentifiers(images) %#codegen
    %sortedIdentifiers - Validate the optional complete-image sorting schema
    report = newReport('SNIP sorted image identifiers'); count = numel(images);
    selected = false(1,count); types = zeros(1,count); values = zeros(1,count); widths = zeros(1,count);
    for k = 1:count
        id = strtrim(char(images(k).header.iid1)); selected(k) = contains(id,':');
        if ~selected(k), continue; end
        if ~startsWith(id,'MSI:') || numel(id) < 5, continue; end
        suffix = id(5:end); widths(k) = numel(suffix);
        if all(suffix >= '0' & suffix <= '9')
            types(k) = 1; values(k) = str2double(suffix);
        elseif all(suffix >= 'A' & suffix <= 'Z')
            types(k) = 2;
            for c = suffix, values(k) = values(k)*26+double(c)-double('A')+1; end
        end
    end
    if ~any(selected), return; end
    valid = all(selected) && all(types > 0) && all(types == types(1)) && all(diff(values) > 0);
    if valid && types(1) == 1
        digits = floor(log10(max(values,1)))+1;
        valid = all(digits == digits(1)) || all(widths == widths(1));
    end
    report = snipIssue(report,~valid,'SNIPSortedIdentifiers','images.iid1', ...
        'Use MSI: followed by a consistently numeric or uppercase base-26 increasing sequence; pad numeric orders to equal width.','6.4.4.9 and 10.7.1.1.2');
end
