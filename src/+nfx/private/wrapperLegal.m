function valid = wrapperLegal(tag,payload,owner) %#codegen
    %wrapperLegal - Inspect nested wrapper scopes using an explicit work stack
    %   The stack retains serialized snapshots rather than recursive object
    %   graphs. Collection indices are resolved separately by the owning file.
    valid = false;
    data = [uint8(tag) decimalField(numel(payload),5,0,false) payload];
    capacity = floor(numel(data)/12)+1;
    starts = zeros(1,capacity);
    scopes = zeros(1,capacity);
    parents = repmat(' ',capacity,2);
    cameraSeen = false(1,capacity);
    aggregate = false(1,capacity);
    asynchronous = false(1,capacity);
    frames = false(1,capacity);
    top = 1;
    starts(1) = 1;
    scopes(1) = 1+strcmp(owner,'image');
    while top > 0
        at = starts(top);
        scope = scopes(top);
        parent = parents(top,:);
        inCamera = cameraSeen(top);
        inAggregate = aggregate(top);
        inAsync = asynchronous(top);
        inFrames = frames(top);
        top = top-1;
        name = char(data(at:at+5));
        length = str2double(char(data(at+6:at+10)));
        first = at+11;
        last = first+length-1;
        switch name
            case 'FASYWA'
                if inAsync || inFrames, return; end
                % An open end refers specifically to a temporal block.
                if scope == 1 && all(data(first+24:first+47) == uint8('-')), return; end
                first = first+48;
                inAsync = true;
            case 'FSYNWA'
                if scope ~= 2 || inAsync, return; end
                first = first+18;
                inFrames = true;
            case 'CONTXA'
                if inAsync, return; end
                context = char(data(first:first+1));
                mode = char(data(first+2));
                listLength = str2double(char(data(first+3:first+6)));
                [ok,ranges] = contextIndices(char(data(first+7:first+6+listLength)),context);
                if ~ok, return; end
                several = size(ranges,1) > 1 || any(ranges(:,1) ~= ranges(:,2));
                inAggregate = inAggregate || (mode == 'A' && several);
                switch context
                    case 'IS'
                        if scope ~= 1 || mode ~= 'I', return; end
                        scope = 2;
                    case 'FR'
                        if scope ~= 2, return; end
                        inFrames = true;
                    case 'FH'
                        if scope ~= 1, return; end
                    case 'CS'
                        if scope ~= 1 || inCamera || ~any(strcmp(parent,{'  ','TI'})), return; end
                    case 'CM'
                        if inFrames, return; end
                        inCamera = true;
                    case 'TI'
                        if scope ~= 1 || ~any(strcmp(parent,{'  ','CS','CM'})), return; end
                    case 'TB'
                        if scope ~= 1, return; end
                        scope = 2;
                    otherwise
                        return
                end
                parent = context;
                first = first+7+listLength;
            otherwise
                if ~leafLegal(name,data(first:last),scope,inAggregate,inAsync), return; end
                continue
        end
        if first > last, return; end
        while first <= last
            if first+10 > last, return; end
            childLength = str2double(char(data(first+6:first+10)));
            if ~isfinite(childLength) || childLength < 1 || first+10+childLength > last, return; end
            top = top+1;
            starts(top) = first;
            scopes(top) = scope;
            parents(top,:) = parent;
            cameraSeen(top) = inCamera;
            aggregate(top) = inAggregate;
            asynchronous(top) = inAsync;
            frames(top) = inFrames;
            first = first+11+childLength;
        end
    end
    valid = true;
end

function valid = leafLegal(tag,payload,scope,aggregate,asynchronous) %#codegen
    %leafLegal - Enforce the supported concrete metadata association paths
    valid = false;
    if asynchronous
        valid = any(strcmp(tag,{'ILLUMB','FREESA'}));
        return
    end
    switch tag
        case {'RPC00B','CSCRNA','ICHIPB','BANDSB','HISTOA','ACFTB ','AIMIDB', ...
                'SENSRB','RSMIDA','RSMPCA','RSMPIA','RSMGGA','RSMGIA','RSMAPB','RSMECB','RSMDCB', ...
                'CSRLSB','CSWRPB'}
            valid = scope == 2 && ~aggregate;
        case 'FCRNSA'
            valid = scope == 2 || any(payload(1) == uint8('YN'));
        case {'MIMCSA','CSDIDA','TMINTA','CAMSDA','MTIMFA','MICIDA'}
            valid = scope == 1;
        case 'CSEXRB'
            count = str2double(char(payload(37:39)));
            valid = ~aggregate || payload(58+36*count) == uint8(' ');
        case {'MATESA','ILLUMB','FREESA'}
            valid = true;
    end
end
