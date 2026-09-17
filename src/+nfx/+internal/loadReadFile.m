function [data, ok, status] = loadReadFile(filename, maxBytes)
    %loadReadFile - Isolate host I/O and bound allocation before reading
    %   The native byte parsers do not catch exceptions. This host adapter
    %   translates filesystem failures into the public reader diagnostic.
    data = zeros(1, 0, 'uint8'); ok = false;
    status = nfx.internal.readStatus(); status.path = filename;
    try
        [fid, message] = fopen(filename, 'rb');
        if fid < 0
            status.code = 'IOError'; status.message = message; return
        end
        cleanup = onCleanup(@() fclose(fid));
        if fseek(fid, 0, 'eof') ~= 0
            status.code = 'IOError'; status.message = 'Cannot determine source length.';
            return
        end
        count = ftell(fid);
        if count < 0 || fseek(fid, 0, 'bof') ~= 0
            status.code = 'IOError'; status.message = 'Cannot seek the source file.';
            return
        end
        if count > maxBytes
            status.code = 'ResourceLimit'; status.message = 'Source bytes exceed MaxBytes.';
            return
        end
        [data, actual] = fread(fid, count, '*uint8');
        data = reshape(data, 1, []);
        [message, errorNumber] = ferror(fid);
        changed = fseek(fid, 0, 'eof') ~= 0 || ftell(fid) ~= count;
        if actual ~= count || changed || errorNumber ~= 0
            data = zeros(1, 0, 'uint8'); status.code = 'IOError';
            status.message = ['Source length changed or reading failed. ' message];
            return
        end
        clear cleanup
        ok = true;
    catch exception
        data = zeros(1, 0, 'uint8'); status.code = 'IOError';
        status.message = exception.message;
    end
end
