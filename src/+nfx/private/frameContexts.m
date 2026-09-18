function [contexts,report] = frameContexts(nodes,images,catalog) %#codegen
    %frameContexts - Partition image frames at effective metadata boundaries
    record = struct('tag','      ','payload',zeros(1,0,'uint8'),'byte_offset',0,'file_index',0);
    context = struct('image',0,'first',0,'last',0,'records',repmat(record,1,0),'file_records',repmat(record,1,0));
    contexts = repmat(context,1,0); report = newReport('MIE metadata contexts');
    if nargin < 3, catalog = contextCatalog(nodes,images); end
    state = struct('selection',zeros(0,3),'scope',1,'sync',false,'async',false, ...
        'asyncStart','','aggregate',false,'sets',catalog.set,'intervals',catalog.interval, ...
        'cameras',zeros(0,2),'blocks',zeros(0,4),'collection',false, ...
        'setSpecified',false,'intervalSpecified',false,'cameraSpecified',false,'blockSpecified',false);
    states = repmat(state,1,numel(nodes)); frames = zeros(1,numel(images));
    for k = 1:numel(images), frames(k) = images(k).number_frames; end
    sources = max([0 nodes.source])+1;
    lastSync = zeros(sources,numel(images)); lastAsync = cell(sources,numel(images)+1);
    for n = 1:numel(nodes)
        node = nodes(n);
        if node.parent > 0
            current = states(node.parent);
        else
            current = state;
            if node.source > 0
                current.sets = catalog.sources(node.source,1); current.intervals = catalog.sources(node.source,2);
            end
            if node.owner == 0
                current.selection = [(1:numel(images))' ones(numel(images),1) frames'];
            else
                current.selection = [node.owner 1 frames(node.owner)]; current.scope = 2;
                current.sets = catalog.images(node.owner,1); current.intervals = catalog.images(node.owner,2);
            end
        end
        data = node.payload;
        if strcmp(node.tag,'FSYNWA')
            if current.collection, current.selection = filterCollection(current,catalog); end
            first = number(data,1,9); last = number(data,10,9);
            [current.selection,report] = frameSelection(current.selection,[first last],frames,report,last == 0);
            owners = unique(current.selection(:,1))';
            report = issue(report,any(lastSync(node.source+1,owners) > first),'SynchronousOrder', ...
                'FSYNWA starts must be nondecreasing in physical byte order for each image.');
            lastSync(node.source+1,owners) = first; current.sync = true;
        elseif strcmp(node.tag,'FASYWA')
            first = char(data(1:24)); last = char(data(25:48)); owner = node.owner+1;
            if ~isempty(lastAsync{node.source+1,owner})
                report = issue(report,mieTimeCompare(mieTimeValue(first),mieTimeValue(lastAsync{node.source+1,owner})) < 0, ...
                    'AsynchronousOrder','FASYWA starts must be nondecreasing in physical owner order.');
            end
            lastAsync{node.source+1,owner} = first;
            if current.collection, current.selection = filterCollection(current,catalog); end
            [current.selection,report] = timeSelection(current.selection,first,last,images,report);
            current.async = true; current.asyncStart = first; current.scope = 2;
        elseif strcmp(node.tag,'CONTXA')
            type = char(data(1:2)); [~,ranges] = contextIndices(char(data(8:end)),type);
            current.aggregate = current.aggregate || (data(3) == uint8('A') && ...
                (size(ranges,1) > 1 || any(ranges(:,1) ~= ranges(:,2))));
            if any(strcmp(type,{'IS','FH'}))
                report = indexBounds(report,ranges,numel(images));
                selected = false(size(current.selection,1),1);
                for r = 1:size(ranges,1)
                    selected = selected | (current.selection(:,1) >= ranges(r,1) & current.selection(:,1) <= ranges(r,2));
                end
                current.selection = current.selection(selected,:);
                if strcmp(type,'IS'), current.scope = 2; end
            elseif strcmp(type,'FR')
                if current.collection, current.selection = filterCollection(current,catalog); end
                [current.selection,report] = frameSelection(current.selection,ranges,frames,report,false);
            else
                [current,report] = collectionSelection(current,type,ranges,catalog,report);
            end
        end
        if ~node.wrapper && current.collection
            current.selection = filterCollection(current,catalog);
        end
        states(n) = current;
    end
    if ~report.valid, return; end
    for image = 1:numel(images)
        boundaries = [1 frames(image)+1];
        for n = 1:numel(nodes)
            if nodes(n).wrapper, continue; end
            selected = states(n).selection(states(n).selection(:,1) == image,2:3);
            boundaries = [boundaries selected(:,1)' selected(:,2)'+1]; %#ok<AGROW>
        end
        boundaries = unique(boundaries);
        for b = 1:numel(boundaries)-1
            active = false(1,numel(nodes));
            for n = 1:numel(nodes)
                selected = states(n).selection;
                active(n) = ~nodes(n).wrapper && ...
                    any(selected(:,1) == image & selected(:,2) <= boundaries(b) & selected(:,3) >= boundaries(b));
            end
            current = context; current.image = image; current.first = boundaries(b); current.last = boundaries(b+1)-1;
            selected = precedence(nodes,states,find(active & [states.scope] == 2));
            [selected,report] = crossFileSelection(nodes,selected,report);
            for n = selected
                current.records(end+1) = struct('tag',nodes(n).tag,'payload',nodes(n).payload,'byte_offset',nodes(n).offset,'file_index',nodes(n).source);
            end
            selected = precedence(nodes,states,find(active & [states.scope] == 1));
            [selected,report] = crossFileSelection(nodes,selected,report);
            for n = selected
                current.file_records(end+1) = struct('tag',nodes(n).tag,'payload',nodes(n).payload,'byte_offset',nodes(n).offset,'file_index',nodes(n).source);
            end
            contexts(end+1) = current;
        end
    end
end

function selection = filterCollection(state,catalog) %#codegen
    %filterCollection - Apply the completed orthogonal hierarchy to local images
    if catalog.set == 0 && catalog.interval == 0, selection = zeros(0,3); return; end
    selected = true(size(state.selection,1),1);
    for k = 1:numel(selected)
        coordinates = catalog.images(state.selection(k,1),:);
        selected(k) = any(state.sets == coordinates(1)) && any(state.intervals == coordinates(2));
        if state.cameraSpecified, selected(k) = selected(k) && ismember(coordinates([1 3]),state.cameras,'rows'); end
        if state.blockSpecified, selected(k) = selected(k) && ismember(coordinates,state.blocks,'rows'); end
    end
    selection = state.selection(selected,:);
end

function selected = precedence(nodes,states,selected) %#codegen
    %precedence - Preserve augment/partial records and resolve scalar overrides
    keep = true(size(selected));
    scalar = {'GEOPSB','BNDPLC','PIXQLA','CSCCGA','RPC00B','CSCRNA','ICHIPB','CSEXRB','CSRLSB','CSWRPB', ...
        'RSMIDA','RSMPIA','RSMGIA','RSMAPB','RSMECB'};
    for a = 1:numel(selected)
        i = selected(a);
        for b = 1:numel(selected)
            j = selected(b);
            if ~knownTRE(nodes(i).tag), continue; end
            if i == j || nodes(i).source ~= nodes(j).source || ~strcmp(nodes(i).tag,nodes(j).tag), continue; end
            if states(i).async && states(j).sync, keep(a) = false; continue; end
            if states(i).async && states(j).async && nodes(j).owner == 0 && ...
                    mieTimeCompare(mieTimeValue(states(i).asyncStart),mieTimeValue(states(j).asyncStart)) <= 0 && ...
                    (nodes(i).owner ~= 0 || nodes(j).offset > nodes(i).offset)
                keep(a) = false; continue
            end
            % Bare duplicate model records remain an error. Wrapping permits
            % an explicit override while retaining each original snapshot.
            section = any(strcmp(nodes(i).tag,{'RSMPCA','RSMGGA'})) && ...
                isequal(nodes(i).payload(1:126),nodes(j).payload(1:126));
            if (any(strcmp(nodes(i).tag,scalar)) || section) && (nodes(i).parent > 0 || nodes(j).parent > 0) && ...
                    (~states(i).sync || ~states(j).async) && nodes(j).offset > nodes(i).offset
                keep(a) = false;
            end
        end
    end
    identification = selected(keep & strcmp({nodes(selected).tag},'RSMIDA'));
    if isscalar(identification)
        model = nodes(identification);
        for a = 1:numel(selected)
            node = nodes(selected(a));
            if node.source == model.source && knownTRE(node.tag) && startsWith(node.tag,'RSM') && node.offset < model.offset && ...
                    (node.parent > 0 || model.parent > 0) && ~isequal(node.payload(1:120),model.payload(1:120))
                keep(a) = false;
            end
        end
    end
    selected = selected(keep);
end

function [selected,report] = crossFileSelection(nodes,selected,report) %#codegen
    %crossFileSelection - Reject conflicting overrides without inventing file order
    keep = true(size(selected));
    for a = 1:numel(selected)
        first = nodes(selected(a));
        for b = a+1:numel(selected)
            second = nodes(selected(b));
            if first.source == second.source || ~strcmp(first.tag,second.tag), continue; end
            if ~knownTRE(first.tag), continue; end
            if isequal(first.payload,second.payload), keep(b) = false; continue; end
            augment = any(strcmp(first.tag,{'FREESA','MATESA','ILLUMB','FCRNSA', ...
                'ENGRDA','XMLDCA','SECURA','MSTGTA','BLOCKA'}));
            sections = any(strcmp(first.tag,{'RSMPCA','RSMGGA'})) && ~isequal(first.payload(121:126),second.payload(121:126));
            report = issue(report,~augment && ~sections,'CrossFilePrecedence', ...
                'Overlapping metadata from different files have no defined byte-offset order; supply an unambiguous set.');
        end
    end
    selected = selected(keep);
end

function [selected,report] = frameSelection(parent,ranges,frames,report,openZero) %#codegen
    %frameSelection - Intersect ranges without expanding their frame indices
    selected = zeros(size(parent,1)*size(ranges,1),3); count = 0;
    for p = 1:size(parent,1)
        owner = parent(p,1); limits = ranges;
        if openZero, limits(:,2) = Inf; end
        report = indexBounds(report,limits,frames(owner));
        for r = 1:size(limits,1)
            first = max(parent(p,2),limits(r,1)); last = min(parent(p,3),limits(r,2));
            if first <= last, count = count+1; selected(count,:) = [owner first last]; end
        end
    end
    selected = selected(1:count,:);
end

function [selected,report] = timeSelection(parent,first,last,images,report) %#codegen
    %timeSelection - Locate timestamp limits with exact integer frame timing
    selected = zeros(size(parent,1),3); count = 0; start = mieTimeValue(first); open = all(last == '-');
    finish = start; if ~open, finish = mieTimeValue(last); end
    for p = 1:size(parent,1)
        owner = parent(p,1); records = images(owner).tre_records;
        index = find(strcmp({records.tag},'MTIMSA'));
        if isscalar(index)
            timing = mieTimingInfo(records(index).payload);
            if timing.number_frames ~= images(owner).number_frames
                report = issue(report,true,'AsynchronousTiming','Frame counts must agree before resolving asynchronous metadata.'); continue
            end
        elseif images(owner).number_frames == 1 && validMieTimestamp([char(images(owner).header.idatim) '.---------'])
            timing = nfx.MTIMSA(base_timestamp=[char(images(owner).header.idatim) '.---------'],number_frames=1);
        else
            report = issue(report,true,'AsynchronousTiming','FASYWA requires unambiguous frame timing.'); continue
        end
        [~,ok] = mieFrameTime(timing,images(owner).number_frames);
        report = issue(report,~ok,'AsynchronousTiming','Frame timestamps must fit the supported calendar.');
        if ~ok, continue; end
        left = lowerFrame(timing,start,parent(p,2),parent(p,3)+1);
        right = parent(p,3)+1;
        if ~open, right = lowerFrame(timing,finish,parent(p,2),right); end
        if left < right, count = count+1; selected(count,:) = [owner left right-1]; end
    end
    selected = selected(1:count,:);
end

function value = lowerFrame(timing,time,first,last) %#codegen
    %lowerFrame - Find the first frame at or beyond an exclusive time limit
    while first < last
        middle = floor((first+last)/2); [stamp,~] = mieFrameTime(timing,middle);
        if mieTimeCompare(stamp,time) < 0, first = middle+1; else, last = middle; end
    end
    value = first;
end

function report = indexBounds(report,ranges,count) %#codegen
    %indexBounds - Check finite endpoints and the start of an open range
    report = issue(report,any(ranges(:,1) > count) || any(isfinite(ranges(:,2)) & ranges(:,2) > count), ...
        'ContextBounds','Wrapper indices must identify existing images or frames.');
end

function report = issue(report,condition,id,message) %#codegen
    %issue - Add a context diagnostic with its normative reference
    report = addIssue(report,condition,id,'wrappers',message,'STDI-0002 Appendix AF, AF5.9-AF6');
end

function value = number(data,first,count) %#codegen
    %number - Read an already validated fixed-width decimal
    value = str2double(char(data(first:first+count-1)));
end
