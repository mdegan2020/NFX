function [state,report] = collectionSelection(state,type,ranges,catalog,report) %#codegen
    %collectionSelection - Resolve collection hierarchy against declared indices
    switch type
        case 'CS'
            available = unique([catalog.cameras.set]);
            [state.sets,report] = choose(available,ranges,report);
            state.setSpecified = true;
            if ~state.intervalSpecified, state.intervals = catalog.intervals; end
        case 'TI'
            [state.intervals,report] = choose(catalog.intervals,ranges,report);
            state.intervalSpecified = true;
            if ~state.setSpecified && ~state.cameraSpecified, state.sets = unique([catalog.cameras.set]); end
        case 'CM'
            cameras = zeros(0,2);
            for set = state.sets
                available = [catalog.cameras([catalog.cameras.set] == set).index];
                [selected,report] = choose(available,ranges,report);
                cameras = [cameras; repmat(set,numel(selected),1) selected']; %#ok<AGROW>
            end
            state.cameras = cameras;
            state.cameraSpecified = true;
        case 'TB'
            cameras = state.cameras;
            if ~state.cameraSpecified
                cameras = zeros(numel(catalog.cameras),2); count = 0;
                for k = 1:numel(catalog.cameras)
                    if any(state.sets == catalog.cameras(k).set)
                        count = count+1; cameras(count,:) = [catalog.cameras(k).set catalog.cameras(k).index];
                    end
                end
                cameras = cameras(1:count,:);
            end
            blocks = zeros(0,4);
            report = problem(report,isempty(cameras) || isempty(state.intervals) || any(state.intervals == 0), ...
                'ContextHierarchy','Temporal-block context requires a camera set and a time interval.');
            for c = 1:size(cameras,1)
                for interval = state.intervals
                    known = catalog.blocks(catalog.blocks(:,1) == cameras(c,1) & ...
                        catalog.blocks(:,2) == interval & catalog.blocks(:,3) == cameras(c,2),4)';
                    [selected,report] = choose(known,ranges,report);
                    blocks = [blocks; repmat([cameras(c,1) interval cameras(c,2)],numel(selected),1) selected']; %#ok<AGROW>
                end
            end
            state.blocks = blocks; state.scope = 2; state.blockSpecified = true;
    end
    state.collection = true;
end

function [selected,report] = choose(available,ranges,report) %#codegen
    %choose - Validate explicit ranges and clip only the final open endpoint
    selected = zeros(1,0);
    for r = 1:size(ranges,1)
        members = available(available >= ranges(r,1) & available <= ranges(r,2));
        valid = ~isempty(members) && min(members) == ranges(r,1);
        if isfinite(ranges(r,2)), valid = valid && numel(unique(members)) == ranges(r,2)-ranges(r,1)+1; end
        report = problem(report,~valid,'CollectionContextBounds','Collection context indices must identify declared entities.');
        selected = [selected members]; %#ok<AGROW>
    end
    selected = unique(selected);
end

function report = problem(report,condition,id,message) %#codegen
    %problem - Identify a collection association failure
    report = addIssue(report,condition,id,'wrappers',message,'STDI-0002 Appendix AF, AF5.11-AF5.13');
end
