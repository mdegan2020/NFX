classdef (Hidden) FileReader
    %FileReader - Restore supported NITF snapshots through checked boundaries
    methods (Static)
        function [parts, ok, status] = metadata(data, index) %#codegen
            %metadata - Decode owners and payloads after native indexing
            parts = emptyParts();
            used = false(1, numel(index.des));
            pointers = [index.extended.overflow index.user.overflow];
            [parts.fileRecords, used, ok, status] = ownerRecords( ...
                data, index, index.extended, index.user, 'file', 0, used);
            if ~ok, parts = emptyParts(); return; end
            parts.imageRecords = repmat(struct('records', ...
                nfx.internal.emptyTRERecords()), 1, numel(index.images));
            for k = 1:numel(index.images)
                entry = index.images(k);
                pointers = [pointers entry.extended.overflow entry.user.overflow]; %#ok<AGROW>
                [records, used, ok, status] = ownerRecords(data, index, ...
                    entry.extended, entry.user, 'image', k, used);
                if ~ok, parts = emptyParts(); return; end
                parts.imageRecords(k).records = records;
            end
            for k = 1:numel(index.texts)
                entry = index.texts(k);
                pointers(end + 1) = entry.extended.overflow;
                absent = struct('offset', 0, 'length', 0, 'overflow', 0);
                [records, used, ok, status] = ownerRecords(data, index, ...
                    entry.extended, absent, 'text', k, used);
                if ~ok, parts = emptyParts(); return; end
                raw = segmentData(data, entry.location);
                invalid = (raw < 32 | raw > 126) & raw ~= 10 & raw ~= 12 & raw ~= 13;
                if any(invalid)
                    ok = false; status = failure('MalformedFile', ...
                        'STA text contains unsupported characters.', ...
                        entry.location.dataOffset, 'text', k);
                    parts = emptyParts(); return
                end
                text = nfx.TextSegment.restoreRead(char(raw), entry.header, records);
                if ~isequal(uint8(text.data), raw)
                    ok = false; status = failure('UnsupportedFeature', ...
                        'STA line endings are outside the NFX encoding.', ...
                        entry.location.dataOffset, 'text', k);
                    parts = emptyParts(); return
                end
                parts.texts(end + 1) = text;
            end
            for k = 1:numel(index.des)
                entry = index.des(k);
                if strcmp(entry.header.desid, 'TRE_OVERFLOW')
                    if ~used(k)
                        ok = false; status = failure('MalformedFile', ...
                            'TRE_OVERFLOW has no unique referencing owner.', ...
                            entry.location.headerOffset, 'des', k);
                        parts = emptyParts(); return
                    end
                else
                    parts.des(end + 1) = nfx.DESSegment( ...
                        segmentData(data, entry.location), header=entry.header);
                end
            end
            pointers = pointers(pointers ~= 0);
            expected = numel(parts.des) + (1:numel(pointers));
            if ~isequal(pointers, expected)
                parts = emptyParts(); ok = false;
                status = failure('UnsupportedFeature', ...
                    'DES order is outside the supported NFX packing.', 0, 'file', 0);
                return
            end
            status = nfx.internal.readStatus();
        end

        function [file, ok, status] = readBytes(data) %#codegen
            %readBytes - Restore text and support data; pixels follow separately
            file = nfx.File();
            [index, ok, status] = nfx.internal.indexNITF(data);
            if ~ok, return; end
            [parts, ok, status] = nfx.internal.FileReader.metadata(data, index);
            if ~ok, return; end
            if ~isempty(index.images)
                ok = false; status = failure('UnsupportedFeature', ...
                    'Image reconstruction is not yet available.', ...
                    index.images(1).location.headerOffset, 'image', 1);
                return
            end
            file = nfx.File.restoreRead(index.header, ...
                nfx.ImageSegment.empty(1, 0), parts.texts, parts.des, parts.fileRecords);
            report = file.validate();
            if ~report.valid
                file = nfx.File(); ok = false;
                status = failure('MalformedFile', report.issues(1).message, 0, 'file', 0);
            elseif ~isequal(file.header.bytes(), data(1:index.hl))
                file = nfx.File(); ok = false;
                status = failure('MalformedFile', ...
                    'Stored file structure disagrees with reconstructed content.', 0, 'file', 0);
            end
        end
    end
end

function parts = emptyParts() %#codegen
    parts = struct('fileRecords', nfx.internal.emptyTRERecords(), ...
        'imageRecords', repmat(struct('records', nfx.internal.emptyTRERecords()), 1, 0), ...
        'texts', nfx.TextSegment.empty(1, 0), 'des', nfx.DESSegment.empty(1, 0));
end

function bytes = segmentData(data, location) %#codegen
    bytes = data(location.dataOffset + (1:location.dataLength));
end

function [records, used, ok, status] = ownerRecords( ...
        data, index, extended, user, owner, item, used) %#codegen
    records = nfx.internal.emptyTRERecords(); offsets = zeros(1, 0);
    names = {'XHD', 'UDHD'};
    if strcmp(owner, 'image'), names = {'IXSHD', 'UDID'};
    elseif strcmp(owner, 'text'), names = {'TXSHD', ''};
    end
    areas = [extended user];
    overflow = zeros(1, 0, 'uint8'); overflowArea = 0;
    overflowOffset = 0;
    % NFX packs extended, then user, then overflow. Source offsets remain
    % attached while grouping records; physical precedence is recreated by
    % the same area packing and checked below.
    for a = 1:2
        [records, offsets, ok, status] = appendArea( ...
            data, areas(a).offset, areas(a).length, records, offsets, owner, item);
        if ~ok, return; end
        pointer = areas(a).overflow;
        if pointer == 0, continue; end
        if pointer > numel(index.des) || used(pointer)
            ok = false; status = failure('MalformedFile', ...
                'Overflow pointer is invalid or already owned.', ...
                areas(a).offset - 3, owner, item); return
        end
        target = index.des(pointer);
        if ~strcmp(target.header.desid, 'TRE_OVERFLOW') || ...
                ~strcmp(target.owner, names{a}) || target.item ~= item
            ok = false; status = failure('MalformedFile', ...
                'Overflow pointer disagrees with its DES owner.', ...
                areas(a).offset - 3, owner, item); return
        end
        if overflowArea ~= 0
            ok = false; status = failure('UnsupportedFeature', ...
                'Multiple overflow areas are outside the NFX packing.', ...
                areas(a).offset - 3, owner, item); return
        end
        used(pointer) = true; overflowArea = a;
        overflow = segmentData(data, target.location);
        overflowOffset = target.location.dataOffset;
    end
    [records, offsets, ok, status] = appendArea(data, overflowOffset, ...
        numel(overflow), records, offsets, owner, item);
    if ~ok, return; end
    ids = unique([records.id], 'stable');
    for k = 1:numel(ids)
        selected = find([records.id] == ids(k));
        [ok, child] = nfx.TRERecord.checkReadGroup(records(selected), owner);
        if ~ok
            code = 'MalformedFile';
            if strcmp(child.code, 'UnsupportedTRE'), code = 'UnsupportedFeature'; end
            status = failure(code, child.message, offsets(selected(1)), owner, item);
            return
        end
    end
    store = nfx.internal.TREStore.fromSnapshots(records);
    if strcmp(owner, 'text')
        [expectedExtended, expectedOverflow] = store.areas(9713);
        expectedUser = zeros(1, 0, 'uint8'); overflowUser = false;
    else
        [expectedExtended, expectedUser, expectedOverflow, overflowUser] = store.modelAreas(99985);
    end
    ok = isequal(expectedExtended, data(extended.offset + (1:extended.length))) && ...
        isequal(expectedUser, data(user.offset + (1:user.length))) && ...
        isequal(expectedOverflow, overflow) && ...
        (isempty(overflow) || overflowArea == 1 + overflowUser);
    if ~ok
        status = failure('UnsupportedFeature', ...
            'Metadata areas do not follow supported NFX packing.', ...
            extended.offset, owner, item);
    end
end

function [records, offsets, ok, status] = appendArea( ...
        data, offset, count, records, offsets, owner, item) %#codegen
    reader = nfx.internal.NITFReader(data, offset + 1, offset + count, owner, item);
    identity = 0;
    if ~isempty(records), identity = max([records.id]); end
    while reader.ok && reader.position <= reader.last
        at = reader.position - 1;
        [tag, reader] = reader.text(6, false);
        [count, reader] = reader.integer(5, 1, 99985);
        [payload, reader] = reader.take(count);
        if ~reader.ok, break; end
        continuation = strcmp(tag, 'SENSRB') && payload(1) == 'N';
        if continuation
            if isempty(records) || ~strcmp(records(end).tag, 'SENSRB')
                reader = reader.fail('MalformedFile', ...
                    'SENSRB continuation has no leading instance.', at + 1);
                break
            end
            id = records(end).id;
        elseif strcmp(tag, 'J2KLRA')
            id = 0;
            if any([records.id] == 0)
                reader = reader.fail('MalformedFile', ...
                    'Duplicate original J2KLRA records.', at + 1);
                break
            end
        else
            identity = identity + 1; id = identity;
        end
        records(end + 1) = struct('tag', tag, 'payload', payload, 'id', id);
        offsets(end + 1) = at;
    end
    ok = reader.ok; status = reader.status;
end

function status = failure(code, message, offset, scope, index) %#codegen
    status = nfx.internal.readStatus(); status.code = code;
    status.message = message; status.offset = offset;
    status.scope = scope; status.index = index;
end
