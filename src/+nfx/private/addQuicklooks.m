function [file,report] = addQuicklooks(file,collection,definitions,blockCamera,report) %#codegen
    %addQuicklooks - Preserve supplied still pixels and bind manifest references
    keys = zeros(numel(collection.quicklooks),84,'uint8'); ids = cell(1,numel(definitions.cameras));
    for k = 1:numel(ids), ids{k} = char(definitions.cameras(k).definition.camera_id); end
    for k = 1:numel(collection.quicklooks)
        image = collection.quicklooks(k); records = image.tre_records; index = find(strcmp({records.tag},'MTIMSA'));
        ready = isscalar(index) && image.number_frames == 1 && ~isempty(image.data);
        report = mieIssue(report,~ready,'QuicklookTiming','quicklooks','Each quick look requires one stored frame and one MTIMSA.');
        report = mieIssue(report,image.header.nicom == 0 || isempty(strtrim(reshape(image.header.icom,1,[]))), ...
            'QuicklookComments','quicklooks.header.icom','Describe why and how the supplied quick look was selected.');
        if ~ready, continue; end
        timing = mieTimingInfo(records(index).payload);
        report = mieIssue(report,timing.number_frames ~= 1,'QuicklookTiming','quicklooks.MTIMSA','Quick-look timing must describe exactly one frame.');
        if timing.number_frames ~= 1, continue; end
        key = records(index).payload(6:89);
        key(40:75) = uint8(lower(char(key(40:75))));
        duplicate = any(all(keys(1:k-1,:) == key,2)); keys(k,:) = key;
        report = mieIssue(report,duplicate,'DuplicateQuicklook','quicklooks', ...
            'Quick looks must differ in a layer, set, camera, interval, or block association.');
        camera = find(strcmpi(ids,char(timing.camera_id))); set = timing.camera_set_index; interval = timing.time_interval_index;
        layer = char(textField(timing.layer_id,36)); layerKnown = isempty(strtrim(layer));
        for j = 1:numel(collection.layers), layerKnown = layerKnown || strcmp(layer,char(textField(collection.layers(j).layer_id,36))); end
        valid = layerKnown && set <= definitions.sets && interval <= numel(definitions.intervals);
        if ~isempty(strtrim(char(timing.camera_id)))
            valid = valid && isscalar(camera);
            if isscalar(camera)
                valid = valid && set == definitions.cameras(camera).set && ...
                    strcmp(layer,char(textField(definitions.cameras(camera).definition.layer_id,36)));
            end
        end
        if timing.temp_block_index > 0
            selected = zeros(1,0);
            if isscalar(camera) && interval > 0
                for j = 1:numel(collection.blocks)
                    if blockCamera(j) == camera && collection.blocks(j).timing.time_interval_index == interval, selected(end+1) = j; end
                end
            end
            valid = valid && timing.temp_block_index <= numel(selected);
        else
            selected = zeros(1,0);
        end
        report = mieIssue(report,~valid,'QuicklookReference','quicklooks.MTIMSA','Quick-look associations must resolve within the collection.');
        [time,timeValid] = mieFrameTime(timing,1);
        report = mieIssue(report,~timeValid,'TimeRange','quicklooks.MTIMSA','The quick-look timestamp exceeds the UTC year range.');
        if valid && timeValid && interval > 0
            start = char(definitions.intervals(interval).start_timestamp);
            finish = char(definitions.intervals(interval).end_timestamp);
            if timing.temp_block_index > 0
                block = collection.blocks(selected(timing.temp_block_index));
                start = char(block.start_timestamp); finish = char(block.end_timestamp);
            end
            known = validMieTimestamp(start);
            inside = known;
            if known
                inside = mieTimeCompare(time,mieTimeValue(start)) >= 0 && mieTimeCompare(time,mieTimeValue(finish)) <= 0;
            end
            report = mieIssue(report,~inside,'QuicklookBounds','quicklooks.MTIMSA','The quick-look timestamp must lie in its referenced interval or block.');
        elseif valid && timeValid
            inside = false;
            for j = 1:numel(definitions.intervals)
                window = definitions.intervals(j);
                if ~validMieTimestamp(window.start_timestamp), continue; end
                inside = inside || (mieTimeCompare(time,mieTimeValue(window.start_timestamp)) >= 0 && ...
                    mieTimeCompare(time,mieTimeValue(window.end_timestamp)) <= 0);
            end
            report = mieIssue(report,~inside,'QuicklookBounds','quicklooks.MTIMSA','The quick-look timestamp must lie within the collection timeline.');
        end
        timing.image_seg_index = numel(file.images)+1; timing.number_frames = 1; timing.nominal_frame_rate = 0;
        image.header.idlvl = timing.image_seg_index;
        category = char(image.header.icat); if endsWith(category,'.M'), image.header.icat = category(1:end-2); end
        image = image.removeTRE(records(index).id)+timing; file = file+image;
    end
end
