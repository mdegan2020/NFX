function [bytes, ok, status] = loadImageSource(source, maxBytes)
    %loadImageSource - Read one deferred payload after checking its source
    bytes = zeros(1, 0, 'uint8'); ok = false;
    status = nfx.internal.readStatus(); status.path = source.path;
    status.scope = 'image'; status.index = source.index;
    status.offset = source.entry.location.dataOffset;
    if source.entry.location.dataLength > maxBytes
        status.code = 'ResourceLimit';
        status.message = 'The selected image payload exceeds MaxBytes.'; return
    end
    try
        info = dir(source.path);
        if isempty(info)
            status.code = 'IOError';
            status.message = 'The deferred image source is no longer available.'; return
        end
        if info.bytes ~= source.length || info.datenum ~= source.modified
            status.code = 'SourceChanged';
            status.message = 'The deferred image source has changed; read the file again.';
            return
        end
        [fid, message] = fopen(source.path, 'rb');
        if fid < 0
            status.code = 'IOError'; status.message = message; return
        end
        cleanup = onCleanup(@() fclose(fid));
        fileHeader = readRange(fid, 0, numel(source.fileHeader));
        imageHeader = readRange(fid, source.entry.location.headerOffset, ...
            numel(source.imageHeader));
        if ~isequal(fileHeader, source.fileHeader) || ...
                ~isequal(imageHeader, source.imageHeader)
            status.code = 'SourceChanged';
            status.message = 'The deferred source headers have changed.'; return
        end
        bytes = readRange(fid, source.entry.location.dataOffset, ...
            source.entry.location.dataLength);
        after = dir(source.path);
        if isempty(after) || after.bytes ~= source.length || ...
                after.datenum ~= source.modified
            bytes = zeros(1, 0, 'uint8'); status.code = 'SourceChanged';
            status.message = 'The deferred image source changed while reading.'; return
        end
        ok = true;
        clear cleanup
    catch exception
        bytes = zeros(1, 0, 'uint8');
        status.code = 'IOError'; status.message = exception.message;
    end
end

function bytes = readRange(fid, offset, count)
    if fseek(fid, offset, 'bof') ~= 0
        error('nfx:ReadSeek', 'Cannot seek to the deferred source range.');
    end
    [bytes, actual] = fread(fid, count, '*uint8');
    if actual ~= count
        error('nfx:ReadShort', 'The source ended within the selected range.');
    end
    bytes = reshape(bytes, 1, []);
end
