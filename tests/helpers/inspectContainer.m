function result = inspectContainer(filename)
    %inspectContainer - Independently walk NITF tables, segments and TRE owners
    bytes = readBytes(filename);
    assert(strcmp(char(bytes(1:9)), 'NITF02.10'), 'oracle:Magic', 'Invalid magic.');
    result.fl = number(bytes, 343, 12);
    result.hl = number(bytes, 355, 6);
    result.clevel = number(bytes, 10, 2);
    cursor = 361;
    [images, cursor] = table(bytes, cursor, 6, 10);
    assert(number(bytes, cursor, 3) == 0, 'oracle:Graphics', 'Unexpected graphics.');
    assert(number(bytes, cursor+3, 3) == 0, 'oracle:Reserved', 'NUMX must be zero.');
    [texts, cursor] = table(bytes, cursor+6, 4, 5);
    [des, cursor] = table(bytes, cursor, 4, 9);
    assert(number(bytes, cursor, 3) == 0, 'oracle:Reserved', 'Unexpected reserved segment.');
    [result.userTRE, result.userOverflow, cursor] = area(bytes, cursor+3);
    [result.tres, result.overflow, cursor] = area(bytes, cursor);
    assert(cursor == result.hl+1, 'oracle:HeaderLength', 'HL disagrees with header fields.');
    [result.images, cursor] = segments(bytes, cursor, images, 'IM');
    [result.texts, cursor] = segments(bytes, cursor, texts, 'TE');
    [result.des, cursor] = segments(bytes, cursor, des, 'DE');
    assert(cursor == result.fl+1 && result.fl == numel(bytes), 'oracle:Length', 'File length mismatch.');
    for k = 1:numel(result.images)
        h = result.images(k).header;
        f = struct('nrows', number(h,334,8), 'ncols', number(h,342,8), ...
            'abpp', number(h,369,2), 'pjust', char(h(371)), 'icords', char(h(372)), ...
            'igeolo', '', 'icom', repmat(' ',0,80));
        at = 373;
        if h(372) ~= uint8(' '), f.igeolo = char(h(at:at+59)); at = at+60; end
        comments = number(h,at,1);
        at = at+1;
        f.icom = reshape(char(h(at:at+80*comments-1)),80,comments).';
        at = at+80*comments;
        f.ic = char(h(at:at+1)); at = at+2; f.comrat = '';
        assert(any(strcmp(f.ic,{'NC','C8'})), 'oracle:Compression', 'Unsupported compression.');
        if strcmp(f.ic,'C8'), f.comrat = char(h(at:at+3)); at = at+4; end
        bands = number(h,at,1);
        at = at+1;
        if bands == 0, bands = number(h,at,5); at = at+5; end
        f.bands = bands;
        at = at+13*bands;
        assert(h(at) == uint8('0'), 'oracle:Sync', 'Unexpected synchronization.');
        f.imode = char(h(at+1));
        f.nbpr = number(h,at+2,4); f.nbpc = number(h,at+6,4);
        f.nppbh = number(h,at+10,4); f.nppbv = number(h,at+14,4);
        f.nbpp = number(h,at+18,2);
        f.idlvl = number(h,at+20,3); f.ialvl = number(h,at+23,3);
        f.iloc = [number(h,at+26,5), number(h,at+31,5)];
        assert(strcmp(char(h(at+36:at+39)), '1.0 '), 'oracle:Image', 'Unexpected IMAG.');
        [result.images(k).userTRE, result.images(k).userOverflow, at] = area(h, at+40);
        [result.images(k).tres, result.images(k).overflow, at] = area(h, at);
        assert(at == numel(h)+1, 'oracle:ImageLength', 'Image subheader size mismatch.');
        result.images(k).fields = f;
    end
    for k = 1:numel(result.texts)
        h = result.texts(k).header;
        assert(strcmp(char(h(274:277)), '0STA'), 'oracle:Text', 'Unexpected text format.');
        result.texts(k).fields = struct('textid', char(h(3:9)), ...
            'txtalvl', number(h,10,3), 'txtdt', char(h(13:26)), 'txtitl', char(h(27:106)));
        [result.texts(k).tres, result.texts(k).overflow, at] = area(h, 278);
        assert(at == numel(h)+1, 'oracle:TextLength', 'Text subheader size mismatch.');
    end
    for k = 1:numel(result.des)
        h = result.des(k).header;
        f = struct('desid', strtrim(char(h(3:27))), 'desver', number(h,28,2), ...
            'desoflw', '', 'desitem', 0, 'desshf', zeros(1,0,'uint8'));
        at = 197;
        if strcmp(f.desid, 'TRE_OVERFLOW')
            f.desoflw = strtrim(char(h(at:at+5)));
            f.desitem = number(h,at+6,3);
            at = at+9;
            result.des(k).tres = records(result.des(k).data);
        end
        size = number(h,at,4);
        f.desshf = h(at+4:end);
        assert(size == numel(f.desshf), 'oracle:DESLength', 'DES subheader size mismatch.');
        result.des(k).fields = f;
    end
    result.allTRE = [resolve(result.tres, result.overflow, result.des, 'XHD', 0) ...
        resolve(result.userTRE, result.userOverflow, result.des, 'UDHD', 0)];
    pointers = [result.overflow result.userOverflow];
    for k = 1:numel(result.images)
        segment = result.images(k);
        result.images(k).allTRE = [resolve(segment.tres, segment.overflow, result.des, 'IXSHD', k) ...
            resolve(segment.userTRE, segment.userOverflow, result.des, 'UDID', k)];
        pointers = [pointers segment.overflow segment.userOverflow]; %#ok<AGROW>
    end
    for k = 1:numel(result.texts)
        segment = result.texts(k);
        result.texts(k).allTRE = resolve(segment.tres, segment.overflow, result.des, 'TXSHD', k);
        pointers(end+1) = segment.overflow;
    end
    for k = 1:numel(result.des)
        if strcmp(result.des(k).fields.desid, 'TRE_OVERFLOW')
            assert(sum(pointers == k) == 1, 'oracle:OverflowOwner', 'Overflow must have exactly one owner.');
        end
    end
end

function value = number(bytes, first, count)
    value = str2double(char(bytes(first:first+count-1)));
    assert(isfinite(value) && fix(value) == value, 'oracle:Number', 'Invalid integer field.');
end

function [value, cursor] = table(bytes, cursor, headerWidth, dataWidth)
    count = number(bytes,cursor,3);
    cursor = cursor+3;
    value = zeros(count,2);
    for k = 1:count
        value(k,:) = [number(bytes,cursor,headerWidth), number(bytes,cursor+headerWidth,dataWidth)];
        cursor = cursor+headerWidth+dataWidth;
    end
end

function [value, cursor] = segments(bytes, cursor, lengths, marker)
    value = repmat(struct('header', zeros(1,0,'uint8'), 'data', zeros(1,0,'uint8'), ...
        'offset', 0, 'fields', struct(), 'tres', emptyRecords(), 'overflow', 0, ...
        'userTRE',emptyRecords(),'userOverflow',0,'allTRE', emptyRecords()), 1, size(lengths,1));
    for k = 1:size(lengths,1)
        value(k).offset = cursor-1;
        value(k).header = bytes(cursor:cursor+lengths(k,1)-1);
        cursor = cursor+lengths(k,1);
        value(k).data = bytes(cursor:cursor+lengths(k,2)-1);
        cursor = cursor+lengths(k,2);
        assert(strcmp(char(value(k).header(1:2)),marker), 'oracle:Segment', 'Invalid segment order.');
    end
end

function [value, overflow, cursor] = area(bytes, cursor)
    size = number(bytes,cursor,5);
    cursor = cursor+5;
    overflow = 0;
    value = emptyRecords();
    if size > 0
        assert(size >= 3, 'oracle:Area', 'Missing overflow pointer.');
        overflow = number(bytes,cursor,3);
        value = records(bytes(cursor+3:cursor+size-1));
        cursor = cursor+size;
    end
end

function value = records(bytes)
    value = emptyRecords();
    cursor = 1;
    while cursor <= numel(bytes)
        assert(cursor+10 <= numel(bytes), 'oracle:TRE', 'Truncated TRE envelope.');
        size = number(bytes,cursor+6,5);
        assert(size >= 1 && size <= 99985 && cursor+10+size <= numel(bytes), 'oracle:TRE', 'Truncated or oversized TRE.');
        value(end+1) = struct('tag', char(bytes(cursor:cursor+5)), 'payload', bytes(cursor+11:cursor+10+size));
        cursor = cursor+11+size;
    end
end

function value = emptyRecords()
    value = repmat(struct('tag', '', 'payload', zeros(1,0,'uint8')), 1, 0);
end

function value = resolve(inline, pointer, des, owner, item)
    value = inline;
    if pointer == 0, return; end
    assert(pointer <= numel(des), 'oracle:OverflowOwner', 'Dangling DES pointer.');
    h = des(pointer).fields;
    assert(strcmp(h.desid,'TRE_OVERFLOW') && strcmp(h.desoflw,owner) && h.desitem == item, ...
        'oracle:OverflowOwner', 'Overflow ownership mismatch.');
    value = [value des(pointer).tres];
end
