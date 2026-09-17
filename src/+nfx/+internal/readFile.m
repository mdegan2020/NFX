function [file, ok, status] = readFile(filename, maxBytes, maxPixels)
    %readFile - Validate host options, load bounded bytes, and restore a File
    file = nfx.File(); ok = false; status = nfx.internal.readStatus();
    validName = (ischar(filename) && isrow(filename)) || ...
        (isstring(filename) && isscalar(filename) && ~ismissing(filename));
    if ~validName || strlength(filename) == 0 || any(char(filename) == 0) || ...
            ~validLimit(maxBytes) || ~validLimit(maxPixels)
        status.code = 'InvalidInput';
        status.message = 'Supply a filename and positive finite double integer limits.';
        return
    end
    filename = char(filename);
    [data, ok, status] = nfx.internal.loadReadFile(filename, maxBytes);
    if ~ok, return; end
    [file, ok, status] = nfx.internal.FileReader.readBytes(data, maxPixels);
    status.path = filename;
end

function valid = validLimit(value)
    valid = isa(value, 'double') && isscalar(value) && isreal(value) && ...
        ~issparse(value) && isfinite(value) && value >= 1 && ...
        value <= flintmax && fix(value) == value;
end
