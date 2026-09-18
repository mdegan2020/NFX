function report = glasFileReport(fileRecords,images,des,positions,complete) %#codegen
    %glasFileReport - Bind verified sensor DESs to current image contexts
    arguments
        fileRecords
        images
        des
        positions
        complete = true
    end
    report = newReport('GLAS/GFM file associations');
    report = glasIssue(report,sum(strcmp({fileRecords.tag},'CSEXRB')) > 1, ...
        'GLASMultiplicity','CSEXRB','The file header permits at most one CSEXRB record.');
    info = repmat(glasDESInfo(nfx.DESSegment()),1,numel(des));
    levels = zeros(1,numel(images));
    for k = 1:numel(images), levels(k) = images(k).header.idlvl; end
    for k = 1:numel(des)
        info(k) = glasDESInfo(des(k));
        if ~info(k).verified, continue; end
        report = glasIssue(report,any(~ismember(info(k).levels,levels)) || (info(k).all && isempty(images)), ...
            'GLASDisplayAssociation',sprintf('des(%.0f).aisdlvl',k),'DES display associations must identify images in this file.');
        for j = 1:k-1
            report = glasIssue(report,info(j).verified && strcmpi(info(k).uuid,info(j).uuid), ...
                'GLASDuplicateDES','des.uuid','Every typed sensor DES in the file must have a distinct UUID.');
        end
    end
    % These DES invariants do not depend on unknown TRE semantics.
    if ~complete, return; end
    for k = 1:numel(fileRecords)
        if strcmp(fileRecords(k).tag,'CSEXRB')
            plane = glasImageInfo(fileRecords(k).payload);
            [report,~] = associations(report,plane,info,NaN);
        end
    end
    allPlanes = repmat(struct('owner',0,'data',zeros(1,0,'uint8'),'uuid',repmat(' ',1,36)),1,0);
    for image = 1:numel(images)
        records = images(image).tre_records;
        for k = find(strcmp({records.tag},'CSEXRB'))
            allPlanes(end+1) = struct('owner',image,'data',records(k).payload,'uuid',char(records(k).payload(1:36)));
        end
    end
    for k = 1:numel(allPlanes)
        entry = allPlanes(k); image = images(entry.owner); h = image.header; records = image.tre_records;
        plane = glasImageInfo(entry.data);
        [report,linked] = associations(report,plane,info,h.idlvl);
        same = strcmpi({allPlanes.uuid},entry.uuid);
        for j = find(same)
            report = glasIssue(report,~isequal(allPlanes(j).data,entry.data),'GLASPlaneIdentity','CSEXRB.image_uuid', ...
                'Repeated image-plane UUIDs must preserve their original exploitation metadata.');
        end
        % A shared plane has its own origin, independent of CCS placement.
        owners = [allPlanes(same).owner];
        unchipped = false(size(owners));
        for j = 1:numel(owners)
            unchipped(j) = ~any(strcmp({images(owners(j)).tre_records.tag},'ICHIPB'));
        end
        owners = owners(unchipped);
        % Frame contexts from the same stored segment have one raster origin.
        [~,distinct] = unique(levels(owners),'stable'); owners = owners(distinct);
        planePosition = [0 0];
        if ~isempty(owners), planePosition = positions(entry.owner,:)-min(positions(owners,:),[],1); end
        report = geometry(report,plane,records,h,positions(entry.owner,:),planePosition,numel(owners) > 1);
        frames = plane.frames; timing = find(strcmp({records.tag},'MTIMSA'));
        if plane.timeLocation == 1 && isscalar(timing), frames = integer4(records(timing).payload(145:148)); end
        if plane.sensor == 'F' && isfinite(frames)
            report = glasIssue(report,frames ~= image.number_frames,'GLASFrameCount','CSEXRB/MTIMSA.number_frames', ...
                'The effective model frame count must match the stored frame array.');
        end
        for d = linked
            if ~strcmp(des(d).header.desid,'CSSFAB'), continue; end
            sensor = info(d);
            report = glasIssue(report,sensor.sensor ~= plane.sensor,'GLASSensorType','CSEXRB/CSSFAB', ...
                'Associated exploitation and field alignment must identify the same sensor type.');
            report = bandAssociations(report,sensor,h);
            hasWarp = any(strcmp({records.tag},'CSWRPB'));
            report = glasIssue(report,hasWarp && sensor.sensor == 'F' && ...
                (sensor.fieldAngle ~= 1 || any(sensor.fiducialSize ~= 1)), ...
                'GLASWarpingAlignment','CSWRPB/CSSFAB','Framer warping requires calibration field angles with a 1-by-1 fiducial array.');
            report = glasIssue(report,sensor.telescope == 1 && (~isfinite(frames) || sensor.frames ~= frames), ...
                'GLASTelescopeFrames','CSSFAB/CSEXRB','Frame-based telescope transforms must match the effective frame count.');
        end
    end
end

function [report,linked] = associations(report,plane,info,level) %#codegen
    %associations - Resolve forward references without constraining reverse IDs
    linked = zeros(1,0);
    for k = 1:size(plane.des,1)
        matches = find([info.verified] & strcmpi({info.uuid},plane.des(k,:)));
        report = glasIssue(report,numel(matches) ~= 1,'GLASMissingDES','CSEXRB.assoc_des_uuid', ...
            'Each forward UUID must resolve to one unchanged typed sensor DES in this file.');
        if numel(matches) ~= 1, continue; end
        d = matches(1); linked(end+1) = d;
        report = glasIssue(report,isfinite(level) && ~info(d).all && ~any(info(d).levels == level), ...
            'GLASForwardDisplay','CSEXRB.assoc_des_uuid/AISDLVL','A referenced DES must include this image display level or ALL.');
    end
end

function report = bandAssociations(report,sensor,header) %#codegen
    %bandAssociations - Match primary band indices with supplemental identities
    labels = header.irepband; wavelengths = header.isubcat;
    if numel(labels) ~= numel(wavelengths), return; end
    for k = 1:numel(sensor.bandIndex)
        index = sensor.bandIndex(k); candidates = false(1,numel(labels));
        for j = 1:numel(labels)
            sameLabel = strcmp(char(textField(labels{j},2)),sensor.bandLabels(k,:));
            wavelength = wavelengths(j); representable = true;
            if ~isnan(wavelength)
                % Compare the actual precision of both six-byte wire fields.
                wavelength = str2double(char(bandDecimal(wavelength,6)))/1000;
                rounded = str2double(char(bandDecimal(wavelength,6)));
                representable = wavelength == 0 || rounded ~= 0; wavelength = rounded;
            end
            candidates(j) = sameLabel && representable && isequaln(wavelength,sensor.wavelengths(k));
        end
        primary = index <= numel(labels) && candidates(index);
        report = glasIssue(report,~primary && sum(candidates) ~= 1,'GLASBandAssociation','CSSFAB.bands', ...
            'A band index must agree with image labels/wavelengths, or supplemental identities must identify one retained band.');
    end
end

function report = geometry(report,plane,records,header,position,planePosition,segmented) %#codegen
    %geometry - Preserve original dimensions while validating segment/chip bounds
    chips = find(strcmp({records.tag},'ICHIPB')); original = plane.dimensions;
    report = glasIssue(report,numel(chips) > 1,'GLASChipMultiplicity','ICHIPB','Supply one original-image chip mapping per context.');
    if numel(chips) > 1, return; end
    stored = [header.nrows header.ncols]; known = original > 0;
    if isempty(chips)
        mismatch = any(known & planePosition+stored > original);
        if ~segmented, mismatch = mismatch || any(known & stored ~= original); end
        report = glasIssue(report,mismatch,'GLASImageDimensions','CSEXRB.num_lines/num_samples', ...
            'Stored segments must fit the original plane; an unsegmented image must match its known dimensions.');
        return
    end
    chip = records(chips).payload;
    report = glasIssue(report,number(chip,1,2) ~= 0,'GLASChipMapping','ICHIPB', ...
        'A chipped GLAS/GFM image requires the original-image mapping.');
    if number(chip,1,2) ~= 0, return; end
    full = [number(chip,209,8) number(chip,217,8)];
    report = glasIssue(report,any(known & full > 0 & original ~= full),'GLASChipDimensions','ICHIPB/CSEXRB', ...
        'Known original dimensions in the chip and exploitation metadata must agree.');
    output = zeros(2,4); source = zeros(2,4);
    for k = 1:8, output(k) = number(chip,17+12*(k-1),12); source(k) = number(chip,113+12*(k-1),12); end
    ordered = max(output(1,1:2)) < min(output(1,3:4)) && max(output(2,[1 3])) < min(output(2,[2 4]));
    local = output-position(:); extent = stored(:);
    outside = any(local(:) < 0.5) || any(any(local > extent-0.5));
    original(~known) = inf;
    outside = outside || any(any(source > original(:)-0.5));
    report = glasIssue(report,~ordered || ~validQuad(output) || ~validQuad(source) || outside, ...
        'GLASChipGeometry','ICHIPB','Chip corner geometry must fit the stored raster and known original plane.');
end

function valid = validQuad(points) %#codegen
    %validQuad - Check convexity in the published corner ordering
    points = points(:,[1 2 4 3]); extent = max(points,[],2)-min(points,[],2);
    valid = all(extent > 0); if ~valid, return; end
    points = (points-min(points,[],2))./extent; turns = zeros(1,4);
    for k = 1:4
        a = points(:,mod(k,4)+1)-points(:,k); b = points(:,mod(k+1,4)+1)-points(:,mod(k,4)+1);
        turns(k) = a(1)*b(2)-a(2)*b(1);
    end
    valid = all(turns > 1e-12) || all(turns < -1e-12);
end

function value = number(data,at,width) %#codegen
    %number - Read a numeric field in a validated record
    value = str2double(char(data(at:at+width-1)));
end

function value = integer4(data) %#codegen
    %integer4 - Read an exact native frame count into double
    value = 0;
    for k = 1:4, value = value*256+double(data(k)); end
end
