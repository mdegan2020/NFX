function [definitions,report] = mieCollectionDefinitions(collection) %#codegen
    %mieCollectionDefinitions - Resolve complete camera and interval catalogs
    camera = struct('camera_id','','camera_desc','','layer_id','','idlvl',0,'ialvl',0, ...
        'iloc',[0 0],'nrows',0,'ncols',0);
    entry = struct('definition',camera,'set',0,'index',0,'position',[0 0]);
    interval = struct('time_interval_index',0,'start_timestamp','','end_timestamp','');
    definitions = struct('cameras',repmat(entry,1,0),'sets',0,'intervals',repmat(interval,1,0));
    report = newReport('NFX-MIE-NC1 collection definitions');
    name = char(collection.base_name);
    invalidName = isempty(strtrim(name)) || ~strcmp(name,strtrim(name)) || ...
        any(ismember(name,'\/:*?"<>|')) || any(double(name) < 32) || any(strcmp(name,{'.','..'}));
    stem = strtok(upper(name),'.'); reserved = {'CON','PRN','AUX','NUL'};
    for k = 1:9, reserved{end+1} = sprintf('COM%d',k); reserved{end+1} = sprintf('LPT%d',k); end
    report = mieIssue(report,invalidName || any(strcmp(stem,reserved)),'CollectionName','base_name', ...
        'Supply a portable flat filename base without reserved characters or surrounding whitespace.');
    report = mergeReport(report,validate(collection.header),'header.');
    report = mieIssue(report,isempty(collection.layers) || isempty(collection.camera_sets) || ...
        isempty(collection.camera_ids) || isempty(collection.intervals),'CollectionDefinitions','definitions', ...
        'Supply layer summaries, all camera sets, core identifiers, and all time intervals.');
    report = mieIssue(report,numel(collection.manifest_template) > 1,'ManifestTemplate','manifest_template', ...
        'Supply at most one manifest file template.');
    report = mieIssue(report,~collection.manifest && (~isempty(collection.quicklooks) || ...
        ~isempty(collection.manifest_template) || collection.manifest_mtimfa), ...
        'ManifestRequired','manifest','Manifest metadata and quick looks require manifest output.');
    for k = 1:numel(collection.layers)
        item = collection.layers(k); report = mergeReport(report,validate(item),sprintf('layers(%.0f).',k));
        report = mieIssue(report,~strcmp(item.mi_req_decoder,'NC') || item.t_rset ~= 0, ...
            'MIEEncoding','layers','NFX-MIE-NC1 requires original-resolution uncompressed NC layers.');
        rates = [item.nominal_frame_rate item.min_frame_rate item.max_frame_rate];
        report = mieIssue(report,any(isnan(rates)) || rates(1) < rates(2) || rates(1) > rates(3), ...
            'CollectionRates','layers','Supply complete nominal/minimum/maximum rates with nominal inside the bounds.');
    end
    for k = 1:numel(collection.camera_sets)
        report = mergeReport(report,validate(collection.camera_sets(k)),sprintf('camera_sets(%.0f).',k));
    end
    for k = 1:numel(collection.camera_ids)
        report = mergeReport(report,validate(collection.camera_ids(k)),sprintf('camera_ids(%.0f).',k));
    end
    for k = 1:numel(collection.intervals)
        report = mergeReport(report,validate(collection.intervals(k)),sprintf('intervals(%.0f).',k));
    end
    if ~report.valid, return; end
    layers = cell(1,numel(collection.layers));
    for k = 1:numel(layers), layers{k} = char(textField(collection.layers(k).layer_id,36)); end
    report = mieIssue(report,numel(unique(layers)) ~= numel(layers),'DuplicateLayer','layers','Each layer has one collection summary.');
    definitions.sets = collection.camera_sets(1).num_camera_sets; covered = false(1,definitions.sets);
    for k = 1:numel(collection.camera_sets)
        tre = collection.camera_sets(k); first = tre.first_camera_set_in_tre;
        last = first+tre.num_camera_sets_in_tre-1;
        mismatch = tre.num_camera_sets ~= definitions.sets || last > definitions.sets;
        report = mieIssue(report,mismatch,'CameraSetTotal','camera_sets','All CAMSDA totals must describe the same complete collection.');
        if mismatch, continue; end
        report = mieIssue(report,any(covered(first:last)),'DuplicateCameraSet','camera_sets','Define each camera set once.');
        covered(first:last) = true;
        for s = 1:numel(tre.camera_sets)
            cameras = tre.camera_sets(s).cameras;
            for c = 1:numel(cameras)
                current = entry; current.definition = cameras(c); current.set = first+s-1; current.index = c;
                definitions.cameras(end+1) = current;
                report = mieIssue(report,~any(strcmp(layers,char(textField(cameras(c).layer_id,36)))), ...
                    'CameraLayer','camera_sets','Each camera must reference one declared layer.');
            end
        end
    end
    report = mieIssue(report,~all(covered),'MissingCameraSet','camera_sets','Define every set from one through NUM_CAMERA_SETS.');
    [~,order] = sortrows([[definitions.cameras.set].' [definitions.cameras.index].'],[1 2]);
    definitions.cameras = definitions.cameras(order);
    ids = cell(1,numel(definitions.cameras)); levels = zeros(size(ids));
    for k = 1:numel(ids)
        ids{k} = lower(char(definitions.cameras(k).definition.camera_id)); levels(k) = definitions.cameras(k).definition.idlvl;
    end
    report = mieIssue(report,numel(unique(ids)) ~= numel(ids),'DuplicateCamera','camera_sets','Each camera belongs to exactly one set and layer.');
    for k = 1:numel(ids)
        position = definitions.cameras(k).definition.iloc;
        parent = definitions.cameras(k).definition.ialvl;
        for depth = 1:numel(ids)
            if parent == 0, break; end
            matches = find(levels == parent);
            report = mieIssue(report,numel(matches) ~= 1,'CameraAttachment','camera_sets', ...
                'A camera attachment must identify one unambiguous display level in the collection.');
            if numel(matches) ~= 1, break; end
            position = position+definitions.cameras(matches).definition.iloc;
            parent = definitions.cameras(matches).definition.ialvl;
        end
        definitions.cameras(k).position = position;
        report = mieIssue(report,any(position < 0),'CameraLocation','camera_sets','Camera locations must remain in the nonnegative CCS quadrant.');
    end
    coreIDs = cell(1,0); coreCameras = cell(1,0);
    for k = 1:numel(collection.camera_ids)
        for c = 1:numel(collection.camera_ids(k).cameras)
            item = collection.camera_ids(k).cameras(c);
            coreCameras{end+1} = lower(char(item.camera_id)); coreIDs{end+1} = upper(char(item.camera_core_id));
        end
    end
    report = mieIssue(report,numel(unique(coreCameras)) ~= numel(coreCameras) || ...
        numel(unique(coreIDs)) ~= numel(coreIDs),'DuplicateCoreIdentifier','camera_ids', ...
        'Camera and MIIS core identifiers must be unique across all MICIDA instances.');
    report = mieIssue(report,~isequal(sort(ids),sort(coreCameras)),'CoreCameraCoverage','camera_ids', ...
        'MICIDA must identify exactly the cameras in CAMSDA.');
    allIntervals = repmat(interval,1,0);
    for k = 1:numel(collection.intervals), allIntervals = [allIntervals collection.intervals(k).intervals]; end %#ok<AGROW>
    allIntervals = allIntervals([allIntervals.time_interval_index] > 0);
    [~,order] = sort([allIntervals.time_interval_index]); allIntervals = allIntervals(order);
    for k = 1:numel(allIntervals)
        current = allIntervals(k);
        if ~isempty(definitions.intervals) && current.time_interval_index == definitions.intervals(end).time_interval_index
            previousInterval = definitions.intervals(end);
            same = isequal(textField(current.start_timestamp,24),textField(previousInterval.start_timestamp,24)) && ...
                isequal(textField(current.end_timestamp,24),textField(previousInterval.end_timestamp,24));
            report = mieIssue(report,~same,'ConflictingInterval','intervals', ...
                'Repeated interval indices must carry identical definitions.');
        else
            definitions.intervals(end+1) = current;
        end
    end
    report = mieIssue(report,isempty(definitions.intervals) || ...
        ~isequal([definitions.intervals.time_interval_index],1:numel(definitions.intervals)), ...
        'IntervalSequence','intervals','Define consecutive collection interval indices starting at one.');
    previous = 0;
    for k = 1:numel(definitions.intervals)
        current = definitions.intervals(k);
        if isempty(strtrim(char(current.start_timestamp))), continue; end
        if previous > 0
            prior = definitions.intervals(previous);
            report = mieIssue(report,mieTimeCompare(mieTimeValue(current.start_timestamp),mieTimeValue(prior.start_timestamp)) <= 0 || ...
                mieTimeCompare(mieTimeValue(current.start_timestamp),mieTimeValue(prior.end_timestamp)) < 0, ...
                'IntervalOrder','intervals','Intervals must have increasing starts and no temporal overlap at their stated precision.');
        end
        previous = k;
    end
end
