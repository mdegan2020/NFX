function [value, ok, status] = indexNITF(data) %#codegen
    %indexNITF - Index the NFX-supported NITF 2.1 container without pixels
    %   Offsets in the index are zero-based source offsets. Metadata areas
    %   retain physical provenance; their TRE envelopes are decoded later.
    value = emptyIndex();
    reader = nfx.internal.NITFReader(data);
    reader = reader.expect('NITF02.10', 'file version');
    [value.clevel, reader] = reader.integer(2);
    reader = reader.expect('BF01', 'STYPE');
    [text, reader] = reader.text(10);
    if reader.ok, value.header.ostaid = text; end
    [text, reader] = reader.text(14);
    if reader.ok, value.header.fdt = text; end
    [text, reader] = reader.text(80);
    if reader.ok, value.header.ftitle = text; end
    reader = security(reader);
    value.header.fsclas = 'U';
    [number, reader] = reader.integer(5);
    if reader.ok, value.header.fscop = number; end
    [number, reader] = reader.integer(5);
    if reader.ok, value.header.fscpys = number; end
    reader = reader.expect('0', 'ENCRYP');
    [raw, reader] = reader.take(3);
    if reader.ok, value.header.fbkgc = double(raw); end
    [text, reader] = reader.text(24);
    if reader.ok, value.header.oname = text; end
    [text, reader] = reader.text(18);
    if reader.ok, value.header.ophone = text; end
    [value.fl, reader] = reader.integer(12, 388, 999999999998);
    [value.hl, reader] = reader.integer(6, 388, 999999);
    if reader.ok && (value.fl ~= numel(data) || value.hl > value.fl)
        reader = reader.fail('MalformedFile', ...
            'FL or HL disagrees with the supplied file length.', 343);
    end
    if reader.ok
        reader = nfx.internal.NITFReader(data, 361, value.hl);
    end
    [images, reader] = lengthTable(reader, 6, 10, 439, 999998, 9999999998);
    reader = reader.expect('000', 'NUMS graphics count');
    reader = reader.expect('000', 'NUMX reserved count');
    [texts, reader] = lengthTable(reader, 4, 5, 282, 9998, 99998);
    [des, reader] = lengthTable(reader, 4, 9, 200, 9998, 999999998);
    reader = reader.expect('000', 'NUMRES reserved-extension count');
    [value.user, reader] = readArea(reader, 99985);
    [value.extended, reader] = readArea(reader, 99985);
    reader = reader.finish();
    if reader.ok
        report = value.header.validate();
        if ~report.valid
            reader = reader.fail('MalformedFile', 'Invalid file metadata.', 1);
        end
    end
    if ~reader.ok
        ok = false; status = reader.status; value = emptyIndex(); return
    end
    at = value.hl;
    [images, at, reader] = locate(images, at, reader);
    [texts, at, reader] = locate(texts, at, reader);
    [des, at, reader] = locate(des, at, reader);
    if reader.ok && at ~= value.fl
        reader = reader.fail('MalformedFile', ...
            'Segment lengths do not cover the complete file.', 343);
    end
    if ~reader.ok
        ok = false; status = reader.status; value = emptyIndex(); return
    end
    value.images = repmat(imageEntry(), 1, numel(images));
    value.texts = repmat(textEntry(), 1, numel(texts));
    value.des = repmat(desEntry(), 1, numel(des));
    for k = 1:numel(images)
        [entry, reader] = imageHeader(data, images(k), k);
        if ~reader.ok, break; end
        value.images(k) = entry;
    end
    if reader.ok
        for k = 1:numel(texts)
            [entry, reader] = textHeader(data, texts(k), k);
            if ~reader.ok, break; end
            value.texts(k) = entry;
        end
    end
    if reader.ok
        for k = 1:numel(des)
            [entry, reader] = desHeader(data, des(k), k);
            if ~reader.ok, break; end
            value.des(k) = entry;
        end
    end
    ok = reader.ok; status = reader.status;
    if ~ok, value = emptyIndex();
    else, status = nfx.internal.readStatus();
    end
end

function value = emptyIndex() %#codegen
    value = struct('header', nfx.FileHeader(), 'clevel', 0, 'fl', 0, ...
        'hl', 0, 'user', areaEntry(), 'extended', areaEntry(), ...
        'images', repmat(imageEntry(), 1, 0), ...
        'texts', repmat(textEntry(), 1, 0), ...
        'des', repmat(desEntry(), 1, 0));
end

function value = locationEntry() %#codegen
    value = struct('headerOffset', 0, 'headerLength', 0, ...
        'dataOffset', 0, 'dataLength', 0);
end

function value = areaEntry() %#codegen
    value = struct('offset', 0, 'length', 0, 'overflow', 0);
end

function value = imageEntry() %#codegen
    layout = struct('nrows', 0, 'ncols', 0, 'bands', 0, 'nbpp', 0, ...
        'nbpr', 0, 'nbpc', 0, 'imode', ' ', 'ic', '  ', 'comrat', '');
    value = struct('location', locationEntry(), ...
        'header', nfx.ImageHeader(), 'layout', layout, ...
        'user', areaEntry(), 'extended', areaEntry());
end

function value = textEntry() %#codegen
    value = struct('location', locationEntry(), ...
        'header', nfx.TextHeader(), 'extended', areaEntry());
end

function value = desEntry() %#codegen
    value = struct('location', locationEntry(), ...
        'header', nfx.DESHeader(), 'owner', '', 'item', 0);
end

function reader = security(reader) %#codegen
    reader = reader.expect('U', 'classification');
    reader = reader.expect(repmat(' ', 1, 166), 'security fields');
end

function [entries, reader] = lengthTable(reader, hw, dw, minimum, hm, dm) %#codegen
    [count, reader] = reader.integer(3);
    entries = repmat(locationEntry(), 1, 0);
    if reader.ok && count > floor((reader.last - reader.position + 1) / (hw + dw))
        reader = reader.fail('MalformedFile', 'Segment table exceeds HL.');
    end
    if ~reader.ok, return; end
    entries = repmat(locationEntry(), 1, count);
    for k = 1:count
        [entries(k).headerLength, reader] = reader.integer(hw, minimum, hm);
        [entries(k).dataLength, reader] = reader.integer(dw, 1, dm);
        if ~reader.ok, return; end
    end
end

function [entries, at, reader] = locate(entries, at, reader) %#codegen
    for k = 1:numel(entries)
        count = entries(k).headerLength + entries(k).dataLength;
        if reader.ok && count > numel(reader.data) - at
            reader = reader.fail('MalformedFile', ...
                'A segment exceeds the file length.', at + 1);
        end
        if ~reader.ok, return; end
        entries(k).headerOffset = at;
        entries(k).dataOffset = at + entries(k).headerLength;
        at = at + count;
    end
end

function [area, reader] = readArea(reader, capacity) %#codegen
    area = areaEntry();
    [count, reader] = reader.integer(5, 0, capacity + 3);
    if ~reader.ok || count == 0, return; end
    if count < 3
        reader = reader.fail('MalformedFile', 'A metadata area is shorter than its overflow pointer.');
        return
    end
    [area.overflow, reader] = reader.integer(3);
    area.offset = reader.position - 1;
    area.length = count - 3;
    [~, reader] = reader.take(area.length);
end

function [entry, reader] = imageHeader(data, location, index) %#codegen
    entry = imageEntry(); entry.location = location;
    reader = nfx.internal.NITFReader(data, location.headerOffset + 1, ...
        location.dataOffset, 'image', index);
    reader = reader.expect('IM', 'image marker');
    [text, reader] = reader.text(10);
    if reader.ok, entry.header.iid1 = text; end
    [text, reader] = reader.text(14);
    if reader.ok, entry.header.idatim = text; end
    [text, reader] = reader.text(17);
    if reader.ok, entry.header.tgtid = text; end
    [text, reader] = reader.text(80);
    if reader.ok, entry.header.iid2 = text; end
    reader = security(reader); entry.header.isclas = 'U';
    reader = reader.expect('0', 'image encryption');
    [text, reader] = reader.text(42);
    if reader.ok, entry.header.isorce = text; end
    [entry.layout.nrows, reader] = reader.integer(8, 1, 99999999);
    [entry.layout.ncols, reader] = reader.integer(8, 1, 99999999);
    reader = reader.expect('INT', 'PVTYPE');
    [text, reader] = reader.text(8);
    if reader.ok, entry.header.irep = text; end
    [text, reader] = reader.text(8);
    if reader.ok, entry.header.icat = text; end
    [number, reader] = reader.integer(2, 1, 64);
    if reader.ok, entry.header.abpp = number; end
    [text, reader] = reader.text(1, false);
    if reader.ok, entry.header.pjust = text; end
    [text, reader] = reader.text(1, false);
    if reader.ok, entry.header.icords = text; end
    if reader.ok && ~any(strcmp(text, {' ', 'D', 'G'}))
        reader = reader.fail('UnsupportedFeature', 'Unsupported ICORDS.', reader.position - 1);
    end
    if reader.ok && ~strcmp(text, ' ')
        [text, reader] = reader.text(60, false);
        if reader.ok, entry.header.igeolo = text; end
    end
    [count, reader] = reader.integer(1);
    [text, reader] = reader.text(80 * count, false);
    if reader.ok, entry.header.icom = reshape(text, 80, count).'; end
    [entry.layout.ic, reader] = reader.text(2, false);
    if reader.ok && ~any(strcmp(entry.layout.ic, {'NC', 'C8'}))
        reader = reader.fail('UnsupportedFeature', 'Unsupported IC compression.');
    end
    if reader.ok && strcmp(entry.layout.ic, 'C8')
        [entry.layout.comrat, reader] = reader.text(4, false);
    end
    [bands, reader] = reader.integer(1);
    if reader.ok && bands == 0
        [bands, reader] = reader.integer(5, 10, 99999);
    end
    entry.layout.bands = bands;
    if reader.ok && bands > floor((reader.last - reader.position + 1) / 13)
        reader = reader.fail('MalformedFile', 'Band definitions exceed the subheader.');
    end
    if ~reader.ok, return; end
    labels = repmat({''}, 1, bands); wavelengths = NaN(1, bands);
    categories = repmat(' ', bands, 6);
    for k = 1:bands
        [labels{k}, reader] = reader.text(2);
        [text, reader] = reader.text(6, false);
        if reader.ok && strcmp(text, 'CLDPCT')
            categories(k, :) = text;
        elseif reader.ok && ~all(text == ' ')
            number = str2double(text);
            if ~isreal(number) || ~isfinite(number) || number < 0 || number > 999999
                reader = reader.fail('MalformedFile', 'Invalid ISUBCAT wavelength.');
            else
                wavelengths(k) = number;
            end
        end
        reader = reader.expect('N   0', 'band filters or LUTs');
        if ~reader.ok, return; end
    end
    entry.header.irepband = labels; entry.header.isubcat = wavelengths;
    entry.header.isubcat_text = categories;
    reader = reader.expect('0', 'ISYNC');
    [entry.layout.imode, reader] = reader.text(1, false);
    if reader.ok && ~any(strcmp(entry.layout.imode, {'B', 'F', 'T'}))
        reader = reader.fail('UnsupportedFeature', 'Unsupported IMODE.');
    end
    [entry.layout.nbpr, reader] = reader.integer(4, 1, 9999);
    [entry.layout.nbpc, reader] = reader.integer(4, 1, 9999);
    [number, reader] = reader.integer(4, 1, 8192);
    if reader.ok, entry.header.nppbh = number; end
    [number, reader] = reader.integer(4, 1, 8192);
    if reader.ok, entry.header.nppbv = number; end
    [entry.layout.nbpp, reader] = reader.integer(2, 1, 64);
    if reader.ok && ~any(entry.layout.nbpp == [8 16])
        reader = reader.fail('UnsupportedFeature', 'Only uint8/uint16 storage is supported.');
    end
    [number, reader] = reader.integer(3, 1, 999);
    if reader.ok, entry.header.idlvl = number; end
    [number, reader] = reader.integer(3, 0, 998);
    if reader.ok, entry.header.ialvl = number; end
    [row, reader] = reader.integer(5, -9999, 99999);
    [column, reader] = reader.integer(5, -9999, 99999);
    if reader.ok, entry.header.iloc = [row column]; end
    reader = reader.expect('1.0 ', 'IMAG');
    [entry.user, reader] = readArea(reader, 99985);
    [entry.extended, reader] = readArea(reader, 99985);
    reader = reader.finish();
    if reader.ok && (entry.layout.nbpr ~= ceil(entry.layout.ncols / entry.header.nppbh) || ...
            entry.layout.nbpc ~= ceil(entry.layout.nrows / entry.header.nppbv))
        reader = reader.fail('MalformedFile', 'Block counts disagree with image dimensions.');
    end
end

function [entry, reader] = textHeader(data, location, index) %#codegen
    entry = textEntry(); entry.location = location;
    reader = nfx.internal.NITFReader(data, location.headerOffset + 1, ...
        location.dataOffset, 'text', index);
    reader = reader.expect('TE', 'text marker');
    [text, reader] = reader.text(7);
    if reader.ok, entry.header.textid = text; end
    [number, reader] = reader.integer(3, 0, 998);
    if reader.ok, entry.header.txtalvl = number; end
    [text, reader] = reader.text(14);
    if reader.ok, entry.header.txtdt = text; end
    [text, reader] = reader.text(80);
    if reader.ok, entry.header.txtitl = text; end
    reader = security(reader); entry.header.tsclas = 'U';
    reader = reader.expect('0STA', 'text encryption/format');
    [entry.extended, reader] = readArea(reader, 9713);
    reader = reader.finish();
    if reader.ok && ~entry.header.validate().valid
        reader = reader.fail('MalformedFile', 'Invalid text metadata.');
    end
end

function [entry, reader] = desHeader(data, location, index) %#codegen
    entry = desEntry(); entry.location = location;
    reader = nfx.internal.NITFReader(data, location.headerOffset + 1, ...
        location.dataOffset, 'des', index);
    reader = reader.expect('DE', 'DES marker');
    [text, reader] = reader.text(25);
    if reader.ok, entry.header.desid = text; end
    [number, reader] = reader.integer(2, 1, 99);
    if reader.ok, entry.header.desver = number; end
    reader = security(reader); entry.header.desclas = 'U';
    overflow = strcmp(entry.header.desid, 'TRE_OVERFLOW');
    if reader.ok && overflow
        [entry.owner, reader] = reader.text(6);
        [entry.item, reader] = reader.integer(3);
    end
    [count, reader] = reader.integer(4, 0, 9798);
    [raw, reader] = reader.take(count);
    if reader.ok, entry.header.desshf = raw; end
    reader = reader.finish();
    if reader.ok && ~overflow && ~entry.header.validate().valid
        reader = reader.fail('MalformedFile', 'Invalid DES metadata.');
    end
    if reader.ok && overflow && (entry.header.desver ~= 1 || count ~= 0 || ...
            ~((any(strcmp(entry.owner, {'XHD', 'UDHD'})) && entry.item == 0) || ...
              (any(strcmp(entry.owner, {'IXSHD', 'UDID', 'TXSHD'})) && entry.item > 0)))
        reader = reader.fail('MalformedFile', 'Invalid TRE_OVERFLOW owner/header.');
    end
end
