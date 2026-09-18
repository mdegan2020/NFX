function [pixels, ok, status] = decodeJPEG2000(data)
    %decodeJPEG2000 - Isolate MATLAB codec and temporary-file host services
    pixels = zeros(0, 0, 'uint8'); ok = false;
    status = nfx.internal.readStatus(); status.scope = 'image';
    if exist('imread', 'file') == 0 && exist('imread', 'builtin') == 0
        status.code = 'MissingDependency';
        status.message = 'The MATLAB imread JPEG2000 decoder is unavailable.';
        return
    end
    stage = 'IOError';
    try
        filename = [tempname '.j2c'];
        removeTemporary = onCleanup(@() removeFile(filename));
        [fid, message] = fopen(filename, 'wb');
        if fid < 0
            status.code = stage; status.message = message; return
        end
        closeTemporary = onCleanup(@() fclose(fid));
        count = fwrite(fid, data, 'uint8');
        [message, errorNumber] = ferror(fid);
        if count ~= numel(data) || errorNumber ~= 0
            status.code = stage;
            status.message = ['Cannot stage JPEG2000 bytes. ' message];
            clear closeTemporary
            clear removeTemporary
            return
        end
        clear closeTemporary
        stage = 'MalformedFile';
        warningID = 'MATLAB:imagesci:jp2adapter:libraryWarning';
        previousWarning = warning('query', warningID);
        restoreWarning = onCleanup(@() warning(previousWarning));
        warning('error', warningID);
        pixels = imread(filename);
        clear restoreWarning
        clear removeTemporary
        ok = true;
    catch exception
        clear closeTemporary
        clear removeTemporary
        pixels = zeros(0, 0, 'uint8'); status.code = stage;
        if contains(lower(exception.identifier), 'license') || ...
                strcmp(exception.identifier, 'MATLAB:UndefinedFunction')
            status.code = 'MissingDependency';
        end
        status.message = ['JPEG2000 decode failed: ' exception.message];
    end
end

function removeFile(filename)
    %removeFile - Clean up only the temporary file owned by this adapter
    if isfile(filename), delete(filename); end
end
