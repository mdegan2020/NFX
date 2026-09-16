function areas = contextAreas(header,plan) %#codegen
    %contextAreas - Locate metadata within headers and overflow DES payloads
    item = struct('owner',0,'offset',0,'data',zeros(1,0,'uint8'));
    areas = repmat(item,1,0);
    extended = numel(plan.fileExtended); user = numel(plan.fileUser);
    hasExtended = plan.fileExtendedPresent;
    if user > 0
        areas(end+1) = struct('owner',0,'offset',header.hl-5-3*hasExtended-extended-user,'data',plan.fileUser);
    end
    if extended > 0, areas(end+1) = struct('owner',0,'offset',header.hl-extended,'data',plan.fileExtended); end
    offset = header.hl;
    for k = 1:numel(plan.images)
        extended = numel(plan.imageAreas(k).data); user = numel(plan.imageUserAreas(k).data);
        hasExtended = extended > 0 || plan.imageOverflow(k) ~= 0;
        finish = offset+header.lish(k);
        if user > 0
            areas(end+1) = struct('owner',k,'offset',finish-5-3*hasExtended-extended-user,'data',plan.imageUserAreas(k).data);
        end
        if extended > 0
            areas(end+1) = struct('owner',k,'offset',finish-extended,'data',plan.imageAreas(k).data);
        end
        offset = finish+header.li(k);
    end
    offset = offset+sum(header.ltsh)+sum(header.lt);
    for k = 1:numel(plan.des)
        h = plan.des(k).header;
        if strcmp(h.desid,'TRE_OVERFLOW') && ~strcmp(h.desoflw,'TXSHD')
            areas(end+1) = struct('owner',h.desitem,'offset',offset+header.ldsh(k),'data',plan.des(k).data);
        end
        offset = offset+header.ldsh(k)+header.ld(k);
    end
end
