function [pixels, ok, status] = decodeJPEG2000(data, backend, threads, maxPixels)
    %decodeJPEG2000 - Isolate MATLAB codec and temporary-file host services
    if nargin < 2, backend = 'auto'; end
    if nargin < 3, threads = 4; end
    if nargin < 4, maxPixels = flintmax; end
    pixels = zeros(0, 0, 'uint8'); ok = false;
    status = nfx.internal.readStatus(); status.scope = 'image';
    if ~nfx.internal.validJPEG2000Options(backend, threads) || ...
            ~nfx.internal.validReadLimit(maxPixels)
        status.code = 'InvalidInput';
        status.message = 'Invalid JPEG2000 backend, Threads, or MaxPixels.';
        return
    end
    useMex = strcmp(backend, 'mex') || (strcmp(backend, 'auto') && ...
        nfx.internal.hasOpenJPEGMex());
    if useMex
        try
            nfx.internal.requireOpenJPEGMex();
            pixels = nfx.internal.openjpegMex('decode', data, maxPixels, threads);
            ok = true;
        catch exception
            status.code = 'MalformedFile';
            if any(strcmp(exception.identifier, {'nfx:OpenJPEGMexMissing', ...
                    'nfx:OpenJPEGMexVersion', 'MATLAB:invalidMEXFile'}))
                status.code = 'MissingDependency';
            elseif strcmp(exception.identifier, 'nfx:OpenJPEGResourceLimit')
                status.code = 'ResourceLimit';
            end
            status.message = ['JPEG2000 MEX decode failed: ' exception.message];
        end
        return
    end
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
