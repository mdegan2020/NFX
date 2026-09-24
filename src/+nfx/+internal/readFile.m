function [file, ok, status] = readFile(filename, maxBytes, maxPixels, readAll, selected)
    %readFile - Validate host options, load bounded bytes, and restore a File
    if nargin < 4, readAll = false; end
    if nargin < 5, selected = []; end
    file = nfx.File(); ok = false; status = nfx.internal.readStatus();
    validName = (ischar(filename) && isrow(filename)) || ...
        (isstring(filename) && isscalar(filename) && ~ismissing(filename));
    if ~validName || strlength(filename) == 0 || any(char(filename) == 0) || ...
            ~nfx.internal.validReadLimit(maxBytes) || ...
            ~nfx.internal.validReadLimit(maxPixels) || ...
            ~islogical(readAll) || ~isscalar(readAll) || ...
            ~nfx.internal.validImageSelection(selected) || ...
            (readAll && ~isempty(selected))
        status.code = 'InvalidInput';
        status.message = ['Supply a filename, finite positive limits, a logical readAll, ' ...
            'and distinct image indices. Use either readAll or readSegment.'];
        return
    end
    filename = char(filename);
    [data, identity, ok, status] = nfx.internal.loadMetadata(filename, maxBytes);
    status.path = filename;
    if ~ok, return; end
    [file, ok, status] = nfx.internal.FileReader.readMetadata( ...
        data, identity, maxPixels, maxBytes);
    if ~ok, file = nfx.File(); status.path = filename; return; end
    if readAll, selected = 1:numel(file.images); end
    if ~isempty(selected)
        encoded = numel(data.bytes);
        if any(selected > numel(file.images))
            ok = false; status.code = 'InvalidInput';
            status.message = 'Select existing one-based image segment indices.';
        else
            for k = selected, encoded = encoded + file.images(k).li; end
            if encoded > maxBytes
                ok = false; status.code = 'ResourceLimit';
                status.message = sprintf('Selected content requires %.0f bytes; MaxBytes is %.0f.', ...
                    encoded, maxBytes);
            else
                [file, ok, status] = file.readSegment(selected, ...
                    MaxPixels=maxPixels, MaxBytes=maxBytes);
            end
        end
    end
    status.path = filename;
    if ~ok, file = nfx.File(); end
end
