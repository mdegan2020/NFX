function [source, identity, ok, status] = loadMetadata(filename, maxBytes)
    %loadMetadata - Seek over imagery and retain headers and support data
    source = struct('bytes', zeros(1, 0, 'uint8'), ...
        'ranges', zeros(0, 3), 'length', 0);
    identity = struct('path', '', 'length', 0, 'modified', 0);
    ok = false; status = nfx.internal.readStatus(); status.path = filename;
    try
        [fid, message] = fopen(filename, 'rb');
        if fid < 0
            status.code = 'IOError'; status.message = message; return
        end
        cleanup = onCleanup(@() fclose(fid));
        % Keep R2023b compatibility; filePermissions was added later.
        [~, attributes] = fileattrib(filename); %#ok<FILEATTRIB>
        identity.path = attributes.Name;
        before = dir(identity.path);
        identity.modified = before.datenum;
        if fseek(fid, 0, 'eof') ~= 0
            error('nfx:ReadSeek', 'Cannot determine source length.');
        end
        source.length = ftell(fid); identity.length = source.length;
        if source.length < 388
            status.code = 'MalformedFile';
            status.message = 'The source is shorter than a NITF file header.';
            status.offset = 0; return
        end
        if maxBytes < 360
            status.code = 'ResourceLimit';
            status.message = 'File header bytes exceed MaxBytes.'; return
        end
        fixed = readRange(fid, 0, 360);
        cursor = nfx.internal.NITFReader(fixed, 355, 360);
        [hl, cursor] = cursor.integer(6, 388, min(source.length, 999999));
        if ~cursor.ok, status = cursor.status; return; end
        if hl > maxBytes
            status.code = 'ResourceLimit';
            status.message = 'File header bytes exceed MaxBytes.'; return
        end
        header = [fixed readRange(fid, 360, hl - 360)];
        source.bytes = header; source.ranges = [0 hl 0];
        [directory, valid, status] = nfx.internal.indexNITF(source, false);
        if ~valid, return; end
        entries = [directory.images.location directory.texts.location ...
            directory.des.location];
        ranges = zeros(1 + numel(entries), 3); ranges(1, :) = [0 hl 0];
        total = hl;
        for k = 1:numel(entries)
            count = entries(k).headerLength;
            if k > numel(directory.images)
                count = count + entries(k).dataLength;
            end
            ranges(k + 1, :) = [entries(k).headerOffset count total];
            total = total + count;
        end
        if total > maxBytes
            status.code = 'ResourceLimit';
            status.message = sprintf( ...
                'Metadata requires %.0f bytes; MaxBytes is %.0f.', total, maxBytes);
            return
        end
        bytes = zeros(1, total, 'uint8'); bytes(1:hl) = header;
        for k = 2:size(ranges, 1)
            bytes(ranges(k, 3) + (1:ranges(k, 2))) = ...
                readRange(fid, ranges(k, 1), ranges(k, 2));
        end
        after = dir(identity.path);
        if isempty(after) || after.bytes ~= identity.length || ...
                after.datenum ~= identity.modified
            status.code = 'SourceChanged';
            status.message = 'The source changed while reading metadata.'; return
        end
        source.bytes = bytes; source.ranges = ranges;
        ok = true; status = nfx.internal.readStatus();
        status.path = filename;
        clear cleanup
    catch exception
        status.code = 'IOError'; status.message = exception.message;
    end
end

function bytes = readRange(fid, offset, count)
    if fseek(fid, offset, 'bof') ~= 0
        error('nfx:ReadSeek', 'Cannot seek to a metadata range.');
    end
    [bytes, actual] = fread(fid, count, '*uint8');
    if actual ~= count
        error('nfx:ReadShort', 'The source ended within a metadata range.');
    end
    bytes = reshape(bytes, 1, []);
end
