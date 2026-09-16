function catalog = contextCatalog(nodes,images) %#codegen
    %contextCatalog - Recover collection indices from immutable TRE snapshots
    camera = struct('set',0,'index',0,'id','');
    catalog = struct('cameras',repmat(camera,1,0),'intervals',zeros(1,0), ...
        'blocks',zeros(0,4),'images',zeros(numel(images),4),'set',0,'interval',0,'sources',zeros(0,2));
    for k = 1:numel(nodes)
        node = nodes(k); data = node.payload;
        if node.parent ~= 0 || node.owner ~= 0, continue; end
        if strcmp(node.tag,'CAMSDA')
            count = number(data,4,3); first = number(data,7,3); at = 10;
            for set = first:first+count-1
                cameras = number(data,at,3); at = at+3;
                for c = 1:cameras
                    catalog.cameras(end+1) = struct('set',set,'index',c,'id',char(data(at:at+35))); at = at+184;
                end
            end
        elseif strcmp(node.tag,'TMINTA')
            for at = 5:54:numel(data), catalog.intervals(end+1) = number(data,at,6); end
        end
    end
    catalog.intervals = unique(catalog.intervals(catalog.intervals > 0));
    for k = 1:numel(nodes)
        node = nodes(k); data = node.payload;
        if node.parent ~= 0 || node.owner ~= 0 || ~strcmp(node.tag,'MTIMFA'), continue; end
        set = number(data,37,3); interval = number(data,40,6); count = number(data,46,3); at = 49;
        for c = 1:count
            camera = find(strcmpi({catalog.cameras.id},char(data(at:at+35))) & [catalog.cameras.set] == set);
            blocks = number(data,at+36,3); at = at+39;
            for b = 1:blocks
                if isscalar(camera) && any(data(at:at+47) ~= uint8(' '))
                    catalog.blocks(end+1,:) = [set interval catalog.cameras(camera).index b];
                end
                at = at+51;
            end
        end
    end
    catalog.blocks = unique(catalog.blocks,'rows');
    for k = 1:numel(images)
        records = images(k).tre_records; timing = find(strcmp({records.tag},'MTIMSA'));
        if ~isscalar(timing), continue; end
        data = records(timing).payload; set = number(data,42,3); interval = number(data,81,6);
        camera = find(strcmpi({catalog.cameras.id},char(data(45:80))) & [catalog.cameras.set] == set);
        index = 0; if isscalar(camera), index = catalog.cameras(camera).index; end
        catalog.images(k,:) = [set interval index number(data,87,3)];
    end
    sets = unique(catalog.images(:,1)); intervals = unique(catalog.images(:,2));
    if isscalar(sets), catalog.set = sets; end
    if isscalar(intervals), catalog.interval = intervals; end
end

function value = number(data,first,count) %#codegen
    %number - Read an already validated decimal index
    value = str2double(char(data(first:first+count-1)));
end
