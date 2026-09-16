function [report,model] = rsmSetReport(records,header,position) %#codegen
    %rsmSetReport - Validate complete model relationships from value snapshots
    report = newReport('RSM complete set');
    if nargin < 3
        position = header.iloc;
        if header.ialvl ~= 0, position = [NaN NaN]; end
    end
    model = struct('present',false,'iid',repmat(' ',1,80),'edition',repmat(' ',1,40), ...
        'tid',repmat(' ',1,40),'npar',0,'definition',zeros(1,0,'uint8'), ...
        'blocks',struct('iidi',{},'crscov',{}));
    tags = {records.tag};
    selected = ismember(tags,{'RSMIDA','RSMPCA','RSMPIA','RSMGGA','RSMGIA','RSMAPB','RSMECB','RSMDCB'});
    if ~any(selected), return; end
    selectedRecords = records(selected); names = {selectedRecords.tag};
    model.present = true;
    id = find(strcmp(names,'RSMIDA')); polynomials = find(strcmp(names,'RSMPCA'));
    grids = find(strcmp(names,'RSMGGA')); polynomialID = find(strcmp(names,'RSMPIA'));
    gridID = find(strcmp(names,'RSMGIA')); adjustments = find(strcmp(names,'RSMAPB'));
    indirect = find(strcmp(names,'RSMECB')); direct = find(strcmp(names,'RSMDCB'));
    report = rsmIssue(report,numel(id) ~= 1 || (isempty(polynomials) && isempty(grids)), ...
        'RSMCompanions','tre_ids','An RSM set requires exactly one RSMIDA and at least one polynomial or grid section.');
    report = rsmIssue(report,numel(polynomialID) > 1 || numel(gridID) > 1 || ...
        numel(adjustments) > 1 || numel(indirect) > 1,'RSMMultiplicity','tre_ids', ...
        'RSMPIA, RSMGIA, RSMAPB and RSMECB each occur at most once per model set.');
    if ~report.valid, return; end
    identification = selectedRecords(id).payload;
    model.iid = char(identification(1:80)); model.edition = char(identification(81:120));
    for k = 1:numel(selectedRecords)
        report = rsmIssue(report,~isequal(selectedRecords(k).payload(1:120),identification(1:120)), ...
            'RSMIdentity','iid/edition','Every record in a model set must identify the same original image and support-data edition.');
    end
    processRecords = [adjustments indirect direct];
    if ~isempty(processRecords)
        model.tid = char(selectedRecords(processRecords(1)).payload(121:160));
        for k = processRecords
            report = rsmIssue(report,~strcmp(model.tid,char(selectedRecords(k).payload(121:160))), ...
                'RSMProcessIdentity','RSMAPB/RSMECB/RSMDCB', ...
                'Adjustment and covariance records in one edition must share the most recent process ID.');
        end
    end
    minimumRow = number(identification,1156,8); maximumRow = number(identification,1164,8);
    minimumCol = number(identification,1172,8); maximumCol = number(identification,1180,8);
    domain = [minimumRow maximumRow minimumCol maximumCol];
    report = sectionReport(report,selectedRecords,polynomials,polynomialID,domain);
    report = sectionReport(report,selectedRecords,grids,gridID,domain);
    for k = grids
        data = selectedRecords(k).payload;
        x = number(data,257,21); y = number(data,278,21); form = char(identification(320));
        angular = (form == 'G' && (x < -pi-1e-14 || x > pi+1e-14)) || ...
            (form == 'H' && (x < 0 || x > 2*pi+1e-14)) || ...
            (form ~= 'R' && abs(y) > pi/2+1e-14);
        report = rsmIssue(report,angular,'RSMGridCoordinates','xipln1/yipln1', ...
            'The initial grid coordinates must use the ground-coordinate system declared by RSMIDA.');
    end
    report = imageDomainReport(report,records,identification,domain,header,position);
    adjustmentDefinition = zeros(1,0,'uint8'); adjustmentTID = repmat(' ',1,40);
    if ~isempty(adjustments)
        data = selectedRecords(adjustments).payload;
        adjustmentDefinition = data(161:rsmParameterEnd(data,161)); adjustmentTID = char(data(121:160));
    end
    indirectDefinition = zeros(1,0,'uint8');
    if ~isempty(indirect)
        data = selectedRecords(indirect).payload;
        if data(161) == uint8('Y'), indirectDefinition = data(175:rsmParameterEnd(data,175)); end
    end
    for k = direct
        data = selectedRecords(k).payload;
        rows = number(data,161,2); count = number(data,163,3); at = 166;
        if model.npar == 0
            model.npar = rows; model.tid = char(data(121:160));
        else
            report = rsmIssue(report,model.npar ~= rows || ~strcmp(model.tid,char(data(121:160))), ...
                'RSMDirectIdentity','nrowcb/tid','All direct covariance instances must share the active row count and covariance process identifier.');
        end
        blockNames = repmat(' ',count,80); columns = zeros(1,count);
        for b = 1:count
            blockNames(b,:) = char(data(at:at+79)); columns(b) = number(data,at+80,2); at = at+82;
        end
        included = data(at) == uint8('Y'); at = at+1;
        if included
            last = rsmParameterEnd(data,at); definition = data(at:last); at = last+1;
            if isempty(model.definition), model.definition = definition;
            else
                report = rsmIssue(report,~isequal(model.definition,definition),'RSMParameterDefinition','parameters', ...
                    'Repeated direct-covariance parameter definitions must agree in order, frame, normalization and basis.');
            end
        end
        for b = 1:count
            covariance = zeros(rows,columns(b));
            for row = 1:rows
                for col = 1:columns(b), covariance(row,col) = number(data,at,21); at = at+21; end
            end
            model.blocks(end+1) = struct('iidi',blockNames(b,:),'crscov',covariance);
        end
    end
    if ~isempty(direct)
        blockNames = {model.blocks.iidi};
        report = rsmIssue(report,isempty(model.definition) || sum(strcmp(blockNames,model.iid)) ~= 1, ...
            'RSMDirectCompanions','RSMDCB','Direct covariance requires parameter definitions and exactly one associated-image auto-covariance block.');
        report = rsmIssue(report,numel(unique(blockNames)) ~= numel(blockNames),'RSMDuplicateCovariance','RSMDCB', ...
            'Covariance blocks cannot repeat across direct-covariance instances for one image.');
        if ~isempty(adjustments)
            report = rsmIssue(report,~isequal(model.definition,adjustmentDefinition) || ~strcmp(model.tid,adjustmentTID), ...
                'RSMAdjustmentDefinition','RSMAPB/RSMDCB', ...
                'Current adjustments and direct covariance must share parameter definitions and process identity.');
        end
    elseif ~isempty(adjustments) && ~isempty(indirectDefinition)
        report = rsmIssue(report,~isequal(adjustmentDefinition,indirectDefinition), ...
            'RSMAdjustmentDefinition','RSMAPB/RSMECB','Adjustments and the applicable indirect covariance must use the same active parameter definitions.');
    end
end

function report = sectionReport(report,records,sections,identifiers,domain) %#codegen
    %sectionReport - Verify a complete rectangular section index grid
    if isempty(sections)
        report = rsmIssue(report,~isempty(identifiers),'RSMOrphanSectionID','RSMPIA/RSMGIA', ...
            'A section-identification record requires its polynomial or grid sections.');
        return
    end
    if isempty(identifiers)
        rowCount = 1; columnCount = 1;
        report = rsmIssue(report,numel(sections) ~= 1,'RSMSectionIDRequired','RSMPIA/RSMGIA', ...
            'Multiple sections require their section-identification record.');
    else
        data = records(identifiers).payload; rowCount = number(data,541,3); columnCount = number(data,544,3);
        expected = [(domain(2)-domain(1)+1)/rowCount (domain(4)-domain(3)+1)/columnCount];
        actual = [number(data,550,21) number(data,571,21)];
        report = rsmIssue(report,any(abs(actual-expected) > 1e-12*expected), ...
            'RSMSectionSize','rssiz/cssiz','Section sizes must divide the inclusive RSM image domain by the row and column section counts.');
    end
    pairs = zeros(numel(sections),2);
    for k = 1:numel(sections)
        data = records(sections(k)).payload; pairs(k,:) = [number(data,121,3) number(data,124,3)];
    end
    valid = size(pairs,1) == rowCount*columnCount && size(unique(pairs,'rows'),1) == size(pairs,1) && ...
        all(pairs(:,1) <= rowCount) && all(pairs(:,2) <= columnCount);
    report = rsmIssue(report,~valid,'RSMSectionCoverage','sections', ...
        'Supply exactly one section for every row/column index in the declared section grid.');
end

function report = imageDomainReport(report,records,data,domain,header,position) %#codegen
    %imageDomainReport - Relate original dimensions and an optional chip map
    original = [number(data,1140,8) number(data,1148,8)];
    chips = find(strcmp({records.tag},'ICHIPB'));
    report = rsmIssue(report,numel(chips) > 1,'RSMChipMultiplicity','ICHIPB','Supply at most one mapping from stored pixels to the original image.');
    if numel(chips) > 1, return; end
    if isempty(chips)
        stored = [header.nrows header.ncols];
        report = rsmIssue(report,any(isfinite(original) & original ~= stored) || ...
            domain(2) >= stored(1) || domain(4) >= stored(2),'RSMOriginalSize','fullr/fullc', ...
            'Without a chip mapping, stored dimensions must equal the original image dimensions and contain the RSM image domain.');
    else
        chip = records(chips).payload;
        report = rsmIssue(report,number(chip,1,2) ~= 0,'RSMChipMapping','ICHIPB', ...
            'RSM use with an explicitly chipped image requires an available original-image mapping.');
        if number(chip,1,2) ~= 0, return; end
        full = [number(chip,209,8) number(chip,217,8)];
        report = rsmIssue(report,any(isfinite(original) & full > 0 & original ~= full), ...
            'RSMChipOriginalSize','ICHIPB/RSMIDA','Known original dimensions in ICHIPB and RSMIDA must agree.');
        original(~isfinite(original) & full > 0) = full(~isfinite(original) & full > 0);
        report = rsmIssue(report,domain(2) >= original(1) || domain(4) >= original(2), ...
            'RSMChipDomain','ICHIPB/RSMIDA','The RSM image domain must fit known original-image dimensions.');
        output = zeros(2,4); fullPoints = zeros(2,4);
        for k = 1:8
            output(k) = number(chip,17+12*(k-1),12); fullPoints(k) = number(chip,113+12*(k-1),12);
        end
        report = rsmIssue(report,~validQuad(output) || ~validQuad(fullPoints), ...
            'RSMChipGeometry','ICHIPB','The four output/original mapping points must form nondegenerate convex quadrilaterals.');
        ordered = max(output(1,1:2)) < min(output(1,3:4)) && ...
            max(output(2,[1 3])) < min(output(2,[2 4]));
        report = rsmIssue(report,~ordered,'RSMChipCornerOrder','ICHIPB', ...
            'Output corners must obey the declared upper/lower and left/right inequalities.');
        extent = [header.nrows;header.ncols];
        local = output-position(:);
        outside = any(max(output,[],2)-min(output,[],2) > extent-1) || ...
            any(local(:) < 0.5) || any(any(local > extent-0.5));
        report = rsmIssue(report,outside,'RSMChipOutputExtent','ICHIPB', ...
            'Output corner pixel centers must fit the stored raster at its resolved CCS position.');
    end
end

function valid = validQuad(points) %#codegen
    %validQuad - Check the four declared corner points without fitting a map
    points = points(:,[1 2 4 3]); extent = max(points,[],2)-min(points,[],2);
    valid = all(extent > 0); if ~valid, return; end
    points = (points-min(points,[],2))./extent; turns = zeros(1,4);
    for k = 1:4
        a = points(:,mod(k,4)+1)-points(:,k);
        b = points(:,mod(k+1,4)+1)-points(:,mod(k,4)+1);
        turns(k) = a(1)*b(2)-a(2)*b(1);
    end
    valid = all(turns > 1e-12) || all(turns < -1e-12);
end

function value = number(data,first,width) %#codegen
    %number - Read one known-width field from an internally validated record
    value = str2double(char(data(first:first+width-1)));
end
