function nodes = contextNodes(areas) %#codegen
    %contextNodes - Read validated wrappers in actual serialized byte order
    item = struct('tag','      ','payload',zeros(1,0,'uint8'), ...
        'owner',0,'offset',0,'parent',0,'wrapper',false,'source',0);
    nodes = repmat(item,1,0);
    for a = 1:numel(areas)
        data = areas(a).data; at = 1; parents = zeros(1,0); ends = zeros(1,0);
        while at <= numel(data)
            while ~isempty(ends) && at > ends(end)
                ends(end) = []; parents(end) = [];
            end
            tag = char(data(at:at+5)); length = str2double(char(data(at+6:at+10)));
            first = at+11; last = at+10+length; prefix = 0;
            if strcmp(tag,'FSYNWA'), prefix = 18;
            elseif strcmp(tag,'FASYWA'), prefix = 48;
            elseif strcmp(tag,'CONTXA'), prefix = 7+str2double(char(data(first+3:first+6)));
            end
            current = item; current.tag = tag; current.owner = areas(a).owner;
            current.offset = areas(a).offset+at-1; current.wrapper = prefix > 0;
            if ~isempty(parents), current.parent = parents(end); end
            if prefix > 0, current.payload = data(first:first+prefix-1);
            else, current.payload = data(first:last);
            end
            nodes(end+1) = current;
            if prefix > 0
                parents(end+1) = numel(nodes); ends(end+1) = last; at = first+prefix;
            else
                at = last+1;
            end
        end
    end
end
