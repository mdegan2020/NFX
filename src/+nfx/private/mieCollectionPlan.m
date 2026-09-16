function [files,report] = mieCollectionPlan(collection) %#codegen
    %mieCollectionPlan - Derive all collection files without publishing bytes
    item = struct('filename','','file',nfx.File(),'camera_set_index',0,'time_interval_index',0,'manifest',false);
    files = repmat(item,1,0); [definitions,report] = mieCollectionDefinitions(collection);
    if ~report.valid, return; end
    [blockCamera,report] = checkBlocks(collection,definitions,report);
    [report,templates] = checkTemplates(collection,definitions,report);
    if ~report.valid, return; end
    groups = zeros(numel(collection.blocks),2);
    for k = 1:numel(collection.blocks)
        groups(k,:) = [collection.blocks(k).timing.time_interval_index definitions.cameras(blockCamera(k)).set];
    end
    groups = unique(groups,'rows'); allMappings = nfx.MTIMFA.empty(1,0);
    for g = 1:size(groups,1)
        interval = groups(g,1); set = groups(g,2);
        selected = false(1,numel(collection.blocks));
        for k = 1:numel(selected)
            selected(k) = collection.blocks(k).timing.time_interval_index == interval && definitions.cameras(blockCamera(k)).set == set;
        end
        indices = find(selected); available = [collection.blocks(indices).available];
        report = mieIssue(report,sum(available) > 999,'CollectionImageCount','blocks', ...
            'Each camera-set/time-interval file permits at most 999 available image segments.');
        if sum(available) > 999, continue; end
        template = find(templates(:,1) == set & templates(:,2) == interval);
        if isempty(template), file = nfx.File(header=collection.header); else, file = collection.file_templates(template).file; end
        file = addDefinitions(file,collection,definitions);
        segmentIndices = NaN(1,numel(collection.blocks)); positions = zeros(sum(available),2);
        for k = indices(available)
            block = collection.blocks(k); camera = definitions.cameras(blockCamera(k));
            image = block.image; imageIndex = numel(file.images)+1; segmentIndices(k) = imageIndex;
            image.header.idlvl = imageIndex;
            [parent,location,valid] = imageLocation(camera.position,positions(1:imageIndex-1,:));
            report = mieIssue(report,~valid,'CameraPlacement','blocks.image.header.iloc', ...
                'Camera CCS placement must fit ILOC or attach to an earlier image in the same file.');
            if ~valid, continue; end
            image.header.ialvl = parent; image.header.iloc = location; positions(imageIndex,:) = camera.position;
            category = char(image.header.icat); if endsWith(category,'.M'), category = category(1:end-2); end
            if block.timing.nominal_frame_rate ~= 0, category = [category(1:min(6,numel(category))) '.M']; end
            image.header.icat = category;
            timing = block.timing; timing.image_seg_index = imageIndex; timing.layer_id = camera.definition.layer_id;
            timing.camera_set_index = set; timing.number_frames = image.number_frames;
            prior = indices(indices <= k); timing.temp_block_index = sum(blockCamera(prior) == blockCamera(k));
            file = file+(image+timing);
        end
        mappings = blockMappings(collection,definitions,indices,blockCamera,segmentIndices,set,interval);
        for k = 1:numel(mappings)
            child = mappings(k).validate(); report = mergeReport(report,child,'MTIMFA.');
            if child.valid && any(available), file = file+mappings(k); end
        end
        allMappings = [allMappings mappings]; %#ok<AGROW>
        if ~any(available)
            report = mieIssue(report,~collection.manifest || ~collection.manifest_mtimfa, ...
                'MissingBlockManifest','manifest_mtimfa','Unavailable-only groups require their mappings in a manifest.');
            report = mieIssue(report,~isempty(template),'UnusedFileTemplate','file_templates', ...
                'An unavailable-only group has no imagery file for a file template.');
            continue
        end
        current = item; current.file = file; current.camera_set_index = set; current.time_interval_index = interval;
        current.filename = collectionFilename(collection.base_name,set,interval,definitions.sets);
        files(end+1) = current;
    end
    if collection.manifest
        if isempty(collection.manifest_template), manifest = nfx.File(header=collection.header); else, manifest = collection.manifest_template; end
        manifest = addDefinitions(manifest,collection,definitions);
        if collection.manifest_mtimfa
            for k = 1:numel(allMappings)
                if allMappings(k).validate().valid, manifest = manifest+allMappings(k); end
            end
        end
        [manifest,report] = addQuicklooks(manifest,collection,definitions,blockCamera,report);
        current = item; current.manifest = true;
        current.filename = collectionFilename(collection.base_name,0,0,definitions.sets);
        files = [current files];
        [manifest,report] = addFileList(manifest,{files.filename},report);
        files(1).file = manifest;
    end
    report = mieIssue(report,isempty(files),'EmptyCollection','blocks','The collection must produce at least one file.');
    for k = 1:numel(files)
        report = mieIssue(report,numel(files(k).filename) > 255,'FilenameLength','base_name','Derived filenames must fit 255 characters.');
    end
end

function [cameraIndices,report] = checkBlocks(collection,definitions,report) %#codegen
    %checkBlocks - Bind blocks to fixed collection definitions and boundaries
    cameraIndices = zeros(1,numel(collection.blocks));
    ids = cell(1,numel(definitions.cameras));
    for k = 1:numel(ids), ids{k} = char(definitions.cameras(k).definition.camera_id); end
    for k = 1:numel(collection.blocks)
        block = collection.blocks(k); child = validate(block);
        report = mergeReport(report,child,sprintf('blocks(%.0f).',k));
        camera = find(strcmpi(ids,char(block.timing.camera_id)));
        interval = block.timing.time_interval_index;
        known = isscalar(camera) && isfinite(interval) && interval >= 1 && interval <= numel(definitions.intervals);
        report = mieIssue(report,~known,'BlockReference','blocks.timing','Every block must reference a declared camera and interval.');
        if ~known || ~child.valid, continue; end
        cameraIndices(k) = camera; window = definitions.intervals(interval);
        hasTime = validMieTimestamp(window.start_timestamp);
        report = mieIssue(report,~hasTime,'EmptyIntervalBlock','blocks','An empty scheduled interval cannot contain temporal blocks.');
        if hasTime
            report = mieIssue(report,mieTimeCompare(mieTimeValue(block.start_timestamp),mieTimeValue(window.start_timestamp)) < 0 || ...
                mieTimeCompare(mieTimeValue(block.end_timestamp),mieTimeValue(window.end_timestamp)) > 0, ...
                'BlockIntervalBounds','blocks','Every temporal block must fit its collection interval.');
        end
        if block.available
            definition = definitions.cameras(camera).definition; h = block.image.header;
            report = mieIssue(report,any([h.nrows h.ncols] ~= [definition.nrows definition.ncols]), ...
                'CameraDimensions','blocks.image','Original-resolution frames must match their camera dimensions.');
            for layer = 1:numel(collection.layers)
                item = collection.layers(layer);
                if ~strcmp(char(textField(item.layer_id,36)),char(textField(definition.layer_id,36))), continue; end
                report = mieIssue(report,isnan(block.timing.nominal_frame_rate) || ...
                    block.timing.nominal_frame_rate < item.min_frame_rate || block.timing.nominal_frame_rate > item.max_frame_rate, ...
                    'BlockFrameRate','blocks.timing.nominal_frame_rate','Supply a nominal rate within the layer summary bounds.');
            end
        end
        prior = zeros(1,0);
        for j = 1:k-1
            if cameraIndices(j) == camera && collection.blocks(j).timing.time_interval_index == interval, prior(end+1) = j; end
        end
        report = mieIssue(report,numel(prior) >= 999,'TemporalBlockCount','blocks','Each camera interval permits at most 999 temporal blocks.');
        if ~isempty(prior)
            previous = collection.blocks(prior(end));
            report = mieIssue(report,mieTimeCompare(mieTimeValue(block.start_timestamp),mieTimeValue(previous.start_timestamp)) <= 0 || ...
                mieTimeCompare(mieTimeValue(block.start_timestamp),mieTimeValue(previous.end_timestamp)) < 0, ...
                'BlockOrder','blocks','Append each camera interval in chronological nonoverlapping block order.');
        end
    end
end

function [report,indices] = checkTemplates(collection,definitions,report) %#codegen
    %checkTemplates - Prevent duplicate generated metadata and unused templates
    indices = zeros(numel(collection.file_templates),2);
    for k = 1:numel(collection.file_templates)
        template = collection.file_templates(k); indices(k,:) = [template.camera_set_index template.time_interval_index];
        valid = all(isfinite(indices(k,:))) && indices(k,1) <= definitions.sets && indices(k,2) <= numel(definitions.intervals);
        report = mieIssue(report,~valid,'TemplateReference','file_templates','Template indices must identify a collection file group.');
        used = false;
        for b = 1:numel(collection.blocks)
            for c = 1:numel(definitions.cameras)
                used = used || (template.time_interval_index == collection.blocks(b).timing.time_interval_index && ...
                    template.camera_set_index == definitions.cameras(c).set && ...
                    strcmpi(char(collection.blocks(b).timing.camera_id),char(definitions.cameras(c).definition.camera_id)));
            end
        end
        report = mieIssue(report,~used,'UnusedFileTemplate','file_templates','Every file template must belong to a supplied block group.');
        report = templateReport(report,template.file);
    end
    report = mieIssue(report,size(unique(indices,'rows'),1) ~= size(indices,1),'DuplicateFileTemplate','file_templates','Supply one template per file group.');
    if isscalar(collection.manifest_template), report = templateReport(report,collection.manifest_template); end
end

function report = templateReport(report,file) %#codegen
    %templateReport - Reserve imagery, indexes and manifest list for the planner
    report = mergeReport(report,validate(file.header),'template.header.');
    report = mieIssue(report,~isempty(file.images),'TemplateImages','file_templates','Supply motion blocks and quick looks separately from file templates.');
    tags = {file.tre_records.tag};
    report = mieIssue(report,any(ismember(tags,{'MIMCSA','CAMSDA','MICIDA','TMINTA','MTIMFA'})), ...
        'TemplateDefinitions','file_templates','Collection-definition TREs are derived from the collection catalogs.');
    for k = 1:numel(file.texts)
        id = char(file.texts(k).header.textid);
        report = mieIssue(report,startsWith(id,'FILE'),'TemplateFileList','file_templates','FILE-prefixed text IDs are reserved for the manifest list.');
    end
end

function file = addDefinitions(file,collection,definitions) %#codegen
    %addDefinitions - Keep complete common definitions identical in every file
    for k = 1:numel(collection.layers), file = file+collection.layers(k); end
    for k = 1:numel(collection.camera_sets), file = file+collection.camera_sets(k); end
    for k = 1:numel(collection.camera_ids), file = file+collection.camera_ids(k); end
    for first = 1:1851:numel(definitions.intervals)
        file = file+nfx.TMINTA(definitions.intervals(first:min(first+1850,numel(definitions.intervals))));
    end
end

function [parent,location,valid] = imageLocation(position,previous) %#codegen
    %imageLocation - Preserve collection CCS placement with legal file offsets
    parent = 0; location = position; valid = all(location <= 99999);
    if valid, return; end
    for k = 1:size(previous,1)
        location = position-previous(k,:); valid = all(location >= -9999 & location <= 99999);
        if valid, parent = k; return; end
    end
end

function value = collectionFilename(base,set,interval,sets) %#codegen
    %collectionFilename - Omit zero reduction indices for original imagery
    if sets > 1
        value = sprintf('%s.c%.0fi%.0f.ntf',char(base),set,interval);
    else
        value = sprintf('%s.i%.0f.ntf',char(base),interval);
    end
end

function mappings = blockMappings(collection,definitions,indices,cameraIndices,segments,set,interval) %#codegen
    %blockMappings - Derive available and unavailable image-segment references
    mappings = nfx.MTIMFA.empty(1,0);
    for layer = 1:numel(collection.layers)
        layerID = char(textField(collection.layers(layer).layer_id,36)); cameras = struct('camera_id',{},'temporal_blocks',{});
        for c = 1:numel(definitions.cameras)
            camera = definitions.cameras(c); selected = indices(cameraIndices(indices) == c);
            if camera.set ~= set || isempty(selected) || ~strcmp(char(textField(camera.definition.layer_id,36)),layerID), continue; end
            blocks = struct('start_timestamp',{},'end_timestamp',{},'image_seg_index',{});
            for b = selected
                blocks(end+1) = struct('start_timestamp',collection.blocks(b).start_timestamp, ...
                    'end_timestamp',collection.blocks(b).end_timestamp,'image_seg_index',segments(b));
            end
            cameras(end+1) = struct('camera_id',camera.definition.camera_id,'temporal_blocks',blocks);
        end
        if isempty(cameras), continue; end
        mappings(end+1) = nfx.MTIMFA(layer_id=collection.layers(layer).layer_id,camera_set_index=set, ...
            time_interval_index=interval,cameras=cameras);
    end
end

function [file,report] = addFileList(file,names,report) %#codegen
    %addFileList - Split manifest text at whole CRLF-terminated filenames
    buffer = ''; count = 0;
    for k = 1:numel(names)
        line = [names{k} char([13 10])];
        if numel(buffer)+numel(line) > 99998
            count = count+1; [file,report] = listSegment(file,buffer,count,report); buffer = '';
        end
        buffer = [buffer line]; %#ok<AGROW>
    end
    if ~isempty(buffer), [file,report] = listSegment(file,buffer,count+1,report); end
end

function [file,report] = listSegment(file,buffer,index,report) %#codegen
    %listSegment - Use normative FILEnnn identifiers and the exact list title
    if numel(file.texts) >= 999
        report = mieIssue(report,true,'ManifestTextCount','base_name','The complete manifest exceeds 999 text segments.'); return
    end
    header = nfx.TextHeader(textid=sprintf('FILE%03.0f',index),txtdt=file.header.fdt, ...
        txtitl='MIE4NITF Manifest File List',tsclas='U');
    file = file+nfx.TextSegment(buffer,header=header);
end
