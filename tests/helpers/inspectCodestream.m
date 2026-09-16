function result = inspectCodestream(filename)
    %inspectCodestream - Independent file-based JPEG 2000 marker oracle
    fid = fopen(filename,'rb','ieee-be');
    cleanup = onCleanup(@() fclose(fid));
    assert(word(fid) == hex2dec('FF4F'));
    result.tiles = zeros(0,4); result.tlm = zeros(0,2); result.styles = [];
    result.packets = {}; result.payloads = {}; result.cod = []; result.qcd = [];
    marker = word(fid);
    while marker ~= hex2dec('FF90')
        finish = ftell(fid); length = word(fid); finish = finish+length;
        switch marker
            case hex2dec('FF51')
                result.rsiz = word(fid);
                result.grid = fread(fid,8,'uint32').';
                result.bands = word(fid);
                result.components = fread(fid,[3 result.bands],'uint8').';
            case hex2dec('FF52')
                result.cod = fread(fid,length-2,'uint8').';
            case hex2dec('FF5C')
                result.qcd = fread(fid,length-2,'uint8').';
            case hex2dec('FF55')
                z = fread(fid,1,'uint8'); style = fread(fid,1,'uint8');
                assert(z == numel(result.styles)); result.styles(end+1) = style;
                while ftell(fid) < finish
                    tile = size(result.tlm,1);
                    if style == 96, tile = word(fid); else, assert(style == 64); end
                    result.tlm(end+1,:) = [tile fread(fid,1,'uint32')];
                end
            otherwise
                assert(marker == hex2dec('FF64'));
        end
        fseek(fid,finish,'bof'); marker = word(fid);
    end
    while marker == hex2dec('FF90')
        start = ftell(fid)-2; assert(word(fid) == 10);
        tile = word(fid); count = fread(fid,1,'uint32');
        index = fread(fid,1,'uint8'); total = fread(fid,1,'uint8');
        result.tiles(end+1,:) = [tile index total count];
        packets = []; z = 0; marker = word(fid);
        while marker ~= hex2dec('FF93')
            assert(marker == hex2dec('FF58')); length = word(fid);
            assert(fread(fid,1,'uint8') == z); z = z+1;
            raw = fread(fid,length-3,'uint8'); value = 0;
            for k = 1:numel(raw)
                value = 128*value+mod(raw(k),128);
                if raw(k) < 128, packets(end+1) = value; value = 0; end %#ok<AGROW>
            end
            assert(value == 0); marker = word(fid);
        end
        payloadSize = start+count-ftell(fid);
        assert(sum(packets) == payloadSize);
        result.packets{end+1} = packets;
        result.payloads{end+1} = fread(fid,payloadSize,'*uint8').';
        assert(ftell(fid) == start+count); marker = word(fid);
    end
    assert(marker == hex2dec('FFD9') && isempty(fread(fid,1,'uint8')));
    assert(isequal(result.tlm,result.tiles(:,[1 4])));
end

function value = word(fid)
    value = fread(fid,1,'uint16');
    assert(isscalar(value),'oracle:Codestream','Unexpected end of codestream.');
end
