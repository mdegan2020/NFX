function data = normalizeJPEG2000(data,profile)
    %normalizeJPEG2000 - Reorder complete parts and rebuild profile TLMs
    info = parseJPEG2000(data);
    epje = strcmp(profile,'EPJE');
    % The CLI writes Rsiz=0. Check the actual bounded Profile-1 settings
    % before changing the declaration; no coding parameters are changed.
    if ~any(info.rsiz == [0 2])
        error('nfx:JPEG2000Profile','Unexpected encoder capability declaration.');
    end
    parts = info.parts;
    [~,order] = sortrows([[parts.index].' [parts.tile].'],[1 2]);
    parts = parts(order);
    main = data(1:info.main_end);
    main(7:8) = uint8([0 2]);
    keep = true(size(main));
    for k = 1:numel(info.main)
        m = info.main(k);
        if m.marker == hex2dec('FF55'), keep(m.first:m.last) = false; end
    end
    main = main(keep);
    width = 4+2*epje; capacity = floor((65535-4)/width);
    tlm = zeros(1,0,'uint8');
    for first = 1:capacity:numel(parts)
        count = min(capacity,numel(parts)-first+1);
        z = (first-1)/capacity;
        if z > 255, error('nfx:JPEG2000Profile','Too many TLM segments.'); end
        record = [uint8([255 85]) bigEndian(4+count*width,2) uint8([z 64+32*epje])];
        entries = zeros(width,count,'uint8');
        for k = 1:count
            item = parts(first+k-1);
            if epje, entries(1:2,k) = bigEndian(item.tile,2).'; end
            entries(end-3:end,k) = bigEndian(item.last-item.first+1,4).';
        end
        tlm = [tlm record reshape(entries,1,[])]; %#ok<AGROW>
    end
    output = zeros(1,numel(main)+numel(tlm)+sum([parts.last]-[parts.first]+1)+2,'uint8');
    output(1:numel(main)+numel(tlm)) = [main tlm]; at = numel(main)+numel(tlm)+1;
    for k = 1:numel(parts)
        bytes = data(parts(k).first:parts(k).last);
        output(at:at+numel(bytes)-1) = bytes; at = at+numel(bytes);
    end
    output(end-1:end) = uint8([255 217]);
    inspectJPEG2000(output,profile);
    data = output;
end

function bytes = bigEndian(value,width)
    bytes = uint8(mod(floor(value./256.^(width-1:-1:0)),256));
end
