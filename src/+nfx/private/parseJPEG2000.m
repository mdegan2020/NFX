function info = parseJPEG2000(data)
    %parseJPEG2000 - Walk marker lengths and SOT boundaries, never scan entropy
    n = numel(data);
    check(n >= 4 && isequal(data(1:2),uint8([255 79])),'Missing raw codestream SOC.');
    info.main = repmat(struct('marker',0,'first',0,'last',0),1,0);
    info.tlm = zeros(0,2); info.tlm_style = zeros(1,0);
    info.dimensions = []; info.precision = []; info.rsiz = [];
    info.cod = []; info.qcd = [];
    p = 3; ntlm = 0;
    while p <= n-1 && be(data,p,2) ~= hex2dec('FF90')
        [marker,body,last] = segment(data,p,n);
        info.main(end+1) = struct('marker',marker,'first',p,'last',last);
        switch marker
            case hex2dec('FF51')
                check(p == 3 && isempty(info.dimensions) && numel(body) >= 39,'Invalid SIZ placement or size.');
                bands = be(body,35,2);
                check(bands >= 1 && bands <= 16384 && numel(body) == 36+3*bands,'Invalid SIZ components.');
                info.rsiz = be(body,1,2);
                info.dimensions = [be(body,7,4) be(body,3,4) bands];
                info.tile_size = [be(body,23,4) be(body,19,4)];
                info.offsets = [be(body,11,4) be(body,15,4) be(body,27,4) be(body,31,4)];
                components = reshape(double(body(37:end)),3,[]);
                check(all(components(1,:) == components(1,1)) && all(components(2:3,:) == 1,'all'), ...
                    'Expected equally sampled components with uniform unsigned precision.');
                info.precision = components(1,1)+1;
            case hex2dec('FF52')
                check(isempty(info.cod) && numel(body) == 10,'Unsupported or repeated COD.');
                info.cod = double(body);
            case hex2dec('FF5C')
                check(isempty(info.qcd),'Repeated QCD.');
                info.qcd = double(body);
            case hex2dec('FF55')
                check(numel(body) >= 2 && double(body(1)) == ntlm,'Invalid TLM sequence.');
                style = double(body(2)); st = bitand(bitshift(style,-4),3); sp = bitand(bitshift(style,-6),1);
                check(any(st == [0 1 2]) && sp == 1 && bitand(style,143) == 0,'Unsupported TLM style.');
                width = st+4;
                check(mod(numel(body)-2,width) == 0,'Truncated TLM entries.');
                entries = zeros((numel(body)-2)/width,2);
                for k = 1:size(entries,1)
                    at = 3+(k-1)*width;
                    if st == 0, entries(k,1) = size(info.tlm,1)+k-1;
                    else, entries(k,1) = be(body,at,st); end
                    entries(k,2) = be(body,at+st,4);
                end
                info.tlm = [info.tlm;entries];
                info.tlm_style(end+1) = style; ntlm = ntlm+1;
            case hex2dec('FF64')
                check(numel(body) >= 2,'Truncated COM.');
            otherwise
                error('nfx:JPEG2000Structure','Unsupported main-header marker 0x%04X.',marker);
        end
        p = last+1;
    end
    check(~isempty(info.dimensions) && ~isempty(info.cod) && ~isempty(info.qcd),'Missing SIZ, COD or QCD.');
    check(all(info.dimensions > 0) && all(info.tile_size > 0),'Invalid image or tile dimensions.');
    info.main_end = p-1;
    part = struct('first',0,'last',0,'tile',0,'index',0,'count',0, ...
        'data_first',0,'packet_lengths',zeros(1,0),'plt_count',0);
    info.parts = repmat(part,1,0);
    while p <= n-1 && be(data,p,2) == hex2dec('FF90')
        check(p+11 <= n && be(data,p+2,2) == 10,'Invalid SOT.');
        part.first = p; part.last = p+be(data,p+6,4)-1;
        check(part.last >= p+13 && part.last <= n-2,'Invalid tile-part length.');
        part.tile = be(data,p+4,2); part.index = double(data(p+10)); part.count = double(data(p+11));
        at = p+12; lengths = zeros(1,0,'uint8'); part.plt_count = 0;
        while at <= part.last-1 && be(data,at,2) ~= hex2dec('FF93')
            [marker,body,last] = segment(data,at,part.last);
            if marker == hex2dec('FF58')
                check(~isempty(body) && double(body(1)) == part.plt_count,'Invalid PLT sequence.');
                lengths = [lengths body(2:end)]; %#ok<AGROW>
                part.plt_count = part.plt_count+1;
            elseif marker == hex2dec('FF64')
                check(numel(body) >= 2,'Truncated tile COM.');
            else
                error('nfx:JPEG2000Structure','Unsupported tile-header marker 0x%04X.',marker);
            end
            at = last+1;
        end
        check(at <= part.last-1 && be(data,at,2) == hex2dec('FF93'),'Missing SOD.');
        part.data_first = at+2;
        part.packet_lengths = packetLengths(lengths);
        check(part.plt_count > 0 && sum(part.packet_lengths) == part.last-at-1,'PLT does not cover the tile-part data.');
        info.parts(end+1) = part;
        p = part.last+1;
    end
    check(p == n-1 && be(data,p,2) == hex2dec('FFD9'),'Missing EOC or trailing codestream data.');
    check(~isempty(info.parts),'No tile-parts.');
    actual = [[info.parts.tile].' ([info.parts.last]-[info.parts.first]+1).'];
    check(isequal(info.tlm,actual),'TLM entries disagree with physical tile-parts.');
end

function [marker,body,last] = segment(data,first,limit)
    check(first+3 <= limit,'Truncated marker segment.');
    marker = be(data,first,2); count = be(data,first+2,2);
    last = first+1+count;
    check(count >= 2 && last <= limit,'Invalid marker length.');
    body = data(first+4:last);
end

function value = be(data,first,count)
    value = double(data(first:first+count-1))*256.^(count-1:-1:0).';
end

function values = packetLengths(bytes)
    values = zeros(1,nnz(bytes < 128)); next = 1; value = 0; width = 0;
    for k = 1:numel(bytes)
        value = value*128+double(bitand(bytes(k),127)); width = width+1;
        check(width <= 5 && value <= 2^32-1,'Oversized PLT packet length.');
        if bytes(k) < 128
            check(value > 0,'Zero-length packet.');
            values(next) = value; next = next+1; value = 0; width = 0;
        end
    end
    check(width == 0,'Truncated PLT packet length.');
end

function check(ok,message)
    if ~ok, error('nfx:JPEG2000Structure','%s',message); end
end
