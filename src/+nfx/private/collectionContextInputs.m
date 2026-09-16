function inputs = collectionContextInputs(files) %#codegen
    %collectionContextInputs - Snapshot global catalogs and cross-file contexts
    emptyNodes = contextNodes(struct('owner',{},'offset',{},'data',{}));
    item = struct('nodes',emptyNodes,'catalog',contextCatalog(emptyNodes,nfx.ImageSegment.empty(1,0)),'required',false);
    inputs = repmat(item,1,numel(files)); blocks = zeros(0,4); sources = zeros(numel(files),2);
    for k = 1:numel(files)
        [nodes,catalog] = contextState(files(k).file);
        inputs(k).nodes = foreignNodes(nodes,k); inputs(k).catalog = catalog;
        inputs(k).required = ~isempty(inputs(k).nodes);
        blocks = [blocks;catalog.blocks]; %#ok<AGROW>
        sources(k,:) = [files(k).camera_set_index files(k).time_interval_index];
    end
    blocks = unique(blocks,'rows'); local = inputs;
    for target = 1:numel(files)
        inputs(target).nodes = emptyNodes;
        inputs(target).catalog.blocks = blocks; inputs(target).catalog.sources = sources;
        inputs(target).catalog.set = sources(target,1); inputs(target).catalog.interval = sources(target,2);
        for source = 1:numel(files)
            if source == target, continue; end
            nodes = local(source).nodes; count = numel(inputs(target).nodes);
            for n = 1:numel(nodes)
                node = nodes(n);
                if node.parent > 0, node.parent = node.parent+count; end
                inputs(target).nodes(end+1) = node;
            end
        end
        inputs(target).required = inputs(target).required || ~isempty(inputs(target).nodes);
    end
end

function selected = foreignNodes(nodes,source) %#codegen
    %foreignNodes - Retain complete root scopes that may address another file
    selected = nodes([]); include = false(1,numel(nodes)); map = zeros(1,numel(nodes));
    for n = 1:numel(nodes)
        node = nodes(n);
        if node.parent > 0
            include(n) = include(node.parent);
        else
            include(n) = node.owner == 0 && strcmp(node.tag,'CONTXA') && ...
                any(strcmp(char(node.payload(1:2)),{'CS','TI','CM'}));
        end
        if ~include(n), continue; end
        node.source = source;
        if node.parent > 0, node.parent = map(node.parent); end
        selected(end+1) = node; map(n) = numel(selected);
    end
end
