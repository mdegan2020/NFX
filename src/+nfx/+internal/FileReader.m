classdef (Hidden) FileReader
    %FileReader - Restore supported NITF snapshots through checked boundaries
    methods (Static)
        function [file, ok, status] = readMetadata(source, identity, maxPixels, maxBytes)
            %readMetadata - Restore complete metadata with deferred imagery
            file = nfx.File();
            [index, ok, status] = nfx.internal.indexNITF(source);
            if ~ok, return; end
            [parts, ok, status] = nfx.internal.FileReader.metadata(source, index);
            if ~ok, return; end
            images = nfx.ImageSegment.empty(1, 0);
            for k = 1:numel(index.images)
                entry = index.images(k);
                descriptor = nfx.internal.emptyImageSource();
                descriptor.path = identity.path;
                descriptor.length = identity.length;
                descriptor.modified = identity.modified;
                descriptor.entry = entry; descriptor.index = k;
                descriptor.maxPixels = maxPixels; descriptor.maxBytes = maxBytes;
                descriptor.fileHeader = nfx.internal.sourceBytes(source, 0, index.hl);
                descriptor.imageHeader = nfx.internal.sourceBytes(source, ...
                    entry.location.headerOffset, entry.location.headerLength);
                [descriptor.frames, ~, ok, status] = nfx.internal.imageShape(entry);
                if ~ok, status.index = k; return; end
                [image, ok, status] = nfx.ImageSegment.restoreDeferred( ...
                    descriptor, parts.imageRecords(k).records, ...
                    parts.imageRecords(k).packing);
                if ~ok, status.index = k; return; end
                restored = image.header.bytes( ...
                    nfx.internal.sourceBytes(source, entry.extended.offset, entry.extended.length), ...
                    entry.extended.overflow, ...
                    nfx.internal.sourceBytes(source, entry.user.offset, entry.user.length), ...
                    entry.user.overflow);
                if ~isequal(restored, descriptor.imageHeader)
                    ok = false; status = failure('MalformedFile', ...
                        'Stored image fields disagree with reconstructed metadata.', ...
                        entry.location.headerOffset, 'image', k); return
                end
                images(end + 1) = image;
            end
            tags = {parts.fileRecords.tag};
            pending = all(ismember({'MIMCSA','CAMSDA','MICIDA','TMINTA'}, tags));
            file = nfx.File.restoreRead(index.header, images, parts.texts, ...
                parts.des, parts.fileRecords, pending, parts.filePacking);
            file = file.readLimits(maxPixels, maxBytes);
            if pending, report = file.validateReadStructure();
            else, report = file.validate();
            end
            if ~report.valid
                ok = false; status = failure('MalformedFile', ...
                    report.issues(1).message, 0, 'file', 0);
            elseif ~isequal(file.header.bytes(), ...
                    nfx.internal.sourceBytes(source, 0, index.hl))
                ok = false; status = failure('MalformedFile', ...
                    'Stored file structure disagrees with reconstructed content.', 0, 'file', 0);
            else
                status.context_complete = ~pending;
                status.metadata_complete = nfx.internal.metadataComplete(report);
                status.pixels_complete = isempty(images);
            end
            if ~ok, file = nfx.File(); end
        end

        function [parts, ok, status] = metadata(data, index) %#codegen
            %metadata - Decode owners and payloads after native indexing
            parts = emptyParts();
            used = false(1, numel(index.des));
            pointers = [index.extended.overflow index.user.overflow];
            [parts.fileRecords, used, ok, status, parts.filePacking] = ownerRecords( ...
                data, index, index.extended, index.user, 'file', 0, used);
            if ~ok, parts = emptyParts(); return; end
            parts.imageRecords = repmat(struct('records', ...
                nfx.internal.emptyTRERecords(), 'packing', [-1 -1 0]), 1, numel(index.images));
            for k = 1:numel(index.images)
                entry = index.images(k);
                pointers = [pointers entry.extended.overflow entry.user.overflow]; %#ok<AGROW>
                [records, used, ok, status, packing] = ownerRecords(data, index, ...
                    entry.extended, entry.user, 'image', k, used);
                if ~ok, parts = emptyParts(); return; end
                parts.imageRecords(k).records = records;
                parts.imageRecords(k).packing = packing;
            end
            for k = 1:numel(index.texts)
                entry = index.texts(k);
                pointers(end + 1) = entry.extended.overflow;
                absent = struct('offset', 0, 'length', 0, 'overflow', 0);
                [records, used, ok, status, packing] = ownerRecords(data, index, ...
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
                text = nfx.TextSegment.restoreRead(char(raw), entry.header, records, packing);
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
                    parts.des(end + 1) = restoreDES( ...
                        segmentData(data, entry.location), entry.header);
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

        function [file, ok, status] = readBytes(data, maxPixels, resolve) %#codegen
            %readBytes - Restore a complete value from a native byte buffer
            arguments
                data
                maxPixels = 2^28
                resolve = true
            end
            file = nfx.File();
            if ~isa(maxPixels, 'double') || ~isscalar(maxPixels) || ...
                    ~isreal(maxPixels) || ~isfinite(maxPixels) || ...
                    maxPixels < 0 || maxPixels > flintmax || fix(maxPixels) ~= maxPixels
                ok = false; status = failure('InvalidInput', ...
                    'MaxPixels must be a nonnegative finite double integer.', NaN, 'file', 0);
                return
            end
            [index, ok, status] = nfx.internal.indexNITF(data);
            if ~ok, return; end
            [parts, ok, status] = nfx.internal.FileReader.metadata(data, index);
            if ~ok, return; end
            images = nfx.ImageSegment.empty(1, 0); samples = 0;
            for k = 1:numel(index.images)
                entry = index.images(k); records = parts.imageRecords(k).records;
                compression = nfx.JPEG2000.empty(1, 0);
                if ~strcmp(entry.layout.ic, 'NC')
                    if coder.target('MATLAB')
                        [compression, pixels, ok, status] = nfx.JPEG2000.restoreRead( ...
                            segmentData(data, entry.location), entry, records, maxPixels - samples);
                        if ~ok, status.index = k; return; end
                        records(strcmp({records.tag}, 'J2KLRA')) = [];
                    else
                        ok = false; status = failure('UnsupportedFeature', ...
                            'JPEG2000 decoding requires the MATLAB host codec.', ...
                            entry.location.dataOffset, 'image', k); return
                    end
                else
                    if any(strcmp({records.tag}, 'J2KLRA'))
                        ok = false; status = failure('MalformedFile', ...
                            'J2KLRA requires compressed imagery in the NFX subset.', ...
                            entry.location.headerOffset, 'image', k); return
                    end
                    if entry.layout.nbpp == 8
                        [pixels, ok, status] = nfx.internal.readPixels( ...
                            data, entry, maxPixels - samples, zeros(0, 0, 'uint8'));
                    else
                        [pixels, ok, status] = nfx.internal.readPixels( ...
                            data, entry, maxPixels - samples, zeros(0, 0, 'uint16'));
                    end
                end
                if ~ok, status.index = k; return; end
                [image, ok, status] = nfx.ImageSegment.restoreRead( ...
                    pixels, entry.header, records, compression, parts.imageRecords(k).packing);
                if ~ok
                    status.scope = 'image'; status.index = k;
                    status.offset = entry.location.headerOffset; return
                end
                stored = data(entry.location.headerOffset + (1:entry.location.headerLength));
                restored = image.header.bytes( ...
                    data(entry.extended.offset + (1:entry.extended.length)), entry.extended.overflow, ...
                    data(entry.user.offset + (1:entry.user.length)), entry.user.overflow);
                if ~isequal(stored, restored)
                    ok = false; status = failure('MalformedFile', ...
                        'Stored image fields disagree with reconstructed content.', ...
                        entry.location.headerOffset, 'image', k); return
                end
                images(end + 1) = image;
                samples = samples + numel(pixels);
            end
            tags = {parts.fileRecords.tag};
            pending = all(ismember({'MIMCSA','CAMSDA','MICIDA','TMINTA'}, tags));
            file = nfx.File.restoreRead(index.header, ...
                images, parts.texts, parts.des, parts.fileRecords, pending, parts.filePacking);
            if resolve && ~pending
                report = file.validate();
            else
                report = file.validateReadStructure();
            end
            if ~report.valid
                file = nfx.File(); ok = false;
                status = failure('MalformedFile', report.issues(1).message, 0, 'file', 0);
            elseif ~isequal(file.header.bytes(), data(1:index.hl))
                file = nfx.File(); ok = false;
                status = failure('MalformedFile', ...
                    'Stored file structure disagrees with reconstructed content.', 0, 'file', 0);
            else
                status.context_complete = ~pending;
                status.metadata_complete = report.complete;
            end
        end
    end
end

function parts = emptyParts() %#codegen
    parts = struct('fileRecords', nfx.internal.emptyTRERecords(), ...
        'filePacking', [-1 -1 0], ...
        'imageRecords', repmat(struct('records', nfx.internal.emptyTRERecords(), 'packing', [-1 -1 0]), 1, 0), ...
        'texts', nfx.TextSegment.empty(1, 0), 'des', nfx.DESSegment.empty(1, 0));
end

function bytes = segmentData(data, location) %#codegen
    bytes = nfx.internal.sourceBytes(data, location.dataOffset, location.dataLength);
end

function segment = restoreDES(data, header) %#codegen
    % Generic DESs may use any name. Preserve their bytes without granting
    % sensor proof unless the complete typed representation validates.
    % File validation rejects references to unverified sensor support data.
    segment = nfx.DESSegment(data, header=header);
    switch header.desid
        case 'CSATTB'
            [attitude, ok] = nfx.CSATTB.deserialize(data, header);
            if ok, segment = attitude.segment(); end
        case 'CSEPHB'
            [ephemeris, ok] = nfx.CSEPHB.deserialize(data, header);
            if ok, segment = ephemeris.segment(); end
        case 'CSSFAB'
            [alignment, ok] = nfx.CSSFAB.deserialize(data, header);
            if ok, segment = alignment.segment(); end
        case 'CSCSDB'
            [covariance, ok] = nfx.CSCSDB.deserialize(data, header);
            if ok, segment = covariance.segment(); end
    end
end

function [records, used, ok, status, packing] = ownerRecords( ...
        data, index, extended, user, owner, item, used) %#codegen
    records = nfx.internal.emptyTRERecords(); offsets = zeros(1, 0);
    names = {'XHD', 'UDHD'};
    if strcmp(owner, 'image'), names = {'IXSHD', 'UDID'};
    elseif strcmp(owner, 'text'), names = {'TXSHD', ''};
    end
    packing = [0 0 0];
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
        packing(a) = numel(records);
        if a == 2, packing(a) = packing(a) - packing(1); end
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
    packing(3) = double(overflowArea == 2);
    store = nfx.internal.TREStore.fromSnapshots(records, packing);
    if strcmp(owner, 'text')
        [expectedExtended, expectedOverflow] = store.areas(9713);
        expectedUser = zeros(1, 0, 'uint8'); overflowUser = false;
    else
        [expectedExtended, expectedUser, expectedOverflow, overflowUser] = store.modelAreas(99985);
    end
    ok = isequal(expectedExtended, nfx.internal.sourceBytes(data, extended.offset, extended.length)) && ...
        isequal(expectedUser, nfx.internal.sourceBytes(data, user.offset, user.length)) && ...
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
        [count, reader] = reader.integer(5, 1, 99999);
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
