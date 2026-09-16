function report = rsmFileReport(images,positions) %#codegen
    %rsmFileReport - Check shared sets and available direct-covariance blocks
    report = newReport('RSM relationships across images');
    template = struct('present',false,'iid',repmat(' ',1,80),'edition',repmat(' ',1,40), ...
        'tid',repmat(' ',1,40),'npar',0,'definition',zeros(1,0,'uint8'), ...
        'blocks',struct('iidi',{},'crscov',{}));
    models = repmat(template,1,0); owners = zeros(1,0);
    for k = 1:numel(images)
        [child,model] = rsmSetReport(images(k).tre_records,images(k).header,positions(k,:));
        if ~child.valid
            report = mergeReport(report,child,sprintf('images(%.0f).',k)); continue
        end
        if ~model.present, continue; end
        same = zeros(1,0);
        if ~isempty(strtrim(model.iid))
            known = false(1,numel(models));
            for j = 1:numel(models), known(j) = ~isempty(strtrim(models(j).iid)); end
            report = rsmIssue(report,any(known & ~strcmp({models.iid},model.iid) & ...
                strcmp({models.edition},model.edition)),'RSMEditionIdentity','images', ...
                'Different known original images must have different support-data editions.');
            same = find(strcmp({models.iid},model.iid) & strcmp({models.edition},model.edition));
        end
        if isempty(same)
            models(end+1) = model; owners(end+1) = k;
        else
            source = images(owners(same)).tre_records;
            report = rsmIssue(report,~sameSnapshots(source,images(k).tre_records), ...
                'RSMSharedImageSet','images', ...
                'Images sharing a known original image ID and edition must share the same RSM support-data set.');
        end
    end
    if ~report.valid, return; end
    [report,models] = covarianceModels(report,models);
    if ~report.valid, return; end
    count = numel(models); blockIndex = zeros(count); connected = false(count);
    for k = 1:count
        for b = 1:numel(models(k).blocks)
            targets = find(strcmp({models.iid},models(k).blocks(b).iidi) & strcmp({models.tid},models(k).tid));
            % The referenced process edition may live in another NITF file.
            if isempty(targets), continue; end
            covariance = models(k).blocks(b).crscov;
            for target = targets
                report = rsmIssue(report,models(target).npar == 0 || size(covariance,2) ~= models(target).npar, ...
                    'RSMCrossCovarianceIdentity','RSMDCB', ...
                    'Referenced image sets with the same process ID must supply direct covariance with matching dimensions.');
                blockIndex(k,target) = b;
                if any(covariance(:) ~= 0), connected(k,target) = true; connected(target,k) = true; end
            end
        end
    end
    if ~report.valid, return; end
    for row = 1:count
        for col = row+1:count
            if blockIndex(row,col) == 0 || blockIndex(col,row) == 0, continue; end
            a = models(row).blocks(blockIndex(row,col)).crscov;
            b = models(col).blocks(blockIndex(col,row)).crscov';
            report = rsmIssue(report,any(abs(a(:)-b(:)) > 1e-12*max(abs(a(:)),abs(b(:)))), ...
                'RSMCrossCovarianceTranspose','RSMDCB','Opposite image-pair blocks must be transposes of each other.');
        end
    end
    if ~report.valid, return; end
    visited = false(1,count);
    for root = 1:count
        if visited(root) || models(root).npar == 0, continue; end
        members = root; visited(root) = true; cursor = 1;
        while cursor <= numel(members)
            neighbours = find(connected(members(cursor),:) & ~visited);
            members = [members neighbours]; visited(neighbours) = true; cursor = cursor+1; %#ok<AGROW>
        end
        dimensions = [models(members).npar]; starts = [0 cumsum(dimensions)];
        covariance = zeros(starts(end));
        for i = 1:numel(members)
            for j = i:numel(members)
                source = members(i); target = members(j); block = zeros(dimensions(i),dimensions(j));
                if blockIndex(source,target) > 0
                    block = models(source).blocks(blockIndex(source,target)).crscov;
                elseif blockIndex(target,source) > 0
                    block = models(target).blocks(blockIndex(target,source)).crscov';
                end
                rows = starts(i)+(1:dimensions(i)); cols = starts(j)+(1:dimensions(j));
                covariance(rows,cols) = block; covariance(cols,rows) = block';
            end
        end
        report = rsmIssue(report,~rsmCovariance(covariance),'RSMJointCovariance','RSMDCB', ...
            'Available direct-covariance blocks must assemble into a positive semidefinite matrix.');
    end
end

function [report,combined] = covarianceModels(report,models) %#codegen
    %covarianceModels - Unite supplied blocks for one image and process
    combined = models([]);
    for k = 1:numel(models)
        same = zeros(1,0);
        if ~isempty(strtrim(models(k).iid))
            same = find(strcmp({combined.iid},models(k).iid) & strcmp({combined.tid},models(k).tid));
        end
        if isempty(same), combined(end+1) = models(k); continue; end
        if models(k).npar == 0, continue; end
        if combined(same).npar == 0, combined(same) = models(k); continue; end
        report = rsmIssue(report,combined(same).npar ~= models(k).npar || ...
            ~isequal(combined(same).definition,models(k).definition), ...
            'RSMCovarianceParameterIdentity','RSMDCB', ...
            'Editions sharing original image and covariance process IDs must use the same active parameter definitions.');
        for b = 1:numel(models(k).blocks)
            block = models(k).blocks(b); duplicate = find(strcmp({combined(same).blocks.iidi},block.iidi));
            if isempty(duplicate)
                combined(same).blocks(end+1) = block;
            else
                existing = combined(same).blocks(duplicate).crscov; supplied = block.crscov;
                mismatch = ~isequal(size(existing),size(supplied)) || ...
                    any(abs(existing(:)-supplied(:)) > 1e-12*max(abs(existing(:)),abs(supplied(:))));
                report = rsmIssue(report,mismatch,'RSMCovarianceBlockIdentity','RSMDCB', ...
                    'Repeated covariance blocks for the same image and process must agree.');
            end
        end
    end
end

function valid = sameSnapshots(first,second) %#codegen
    %sameSnapshots - Compare RSM set content independently of attachment order
    types = {'RSMIDA','RSMPCA','RSMPIA','RSMGGA','RSMGIA','RSMAPB','RSMECB','RSMDCB'};
    first = first(ismember({first.tag},types)); second = second(ismember({second.tag},types));
    valid = numel(first) == numel(second); if ~valid, return; end
    used = false(1,numel(second));
    for k = 1:numel(first)
        found = false;
        for j = 1:numel(second)
            if ~used(j) && strcmp(first(k).tag,second(j).tag) && isequal(first(k).payload,second(j).payload)
                used(j) = true; found = true; break
            end
        end
        if ~found, valid = false; return; end
    end
end
