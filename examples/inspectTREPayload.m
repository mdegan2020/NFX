function view = inspectTREPayload(filename, imageIndex, treIndex)
    %inspectTREPayload - Inspect known or opaque image metadata
    %   VIEW = inspectTREPayload(FILENAME, IMAGEINDEX, TREINDEX) reads a
    %   file and displays an independent snapshot of one attachment.
    %   Image and attachment indices both default to one.
    %
    %   VIEW.RECORDS contains raw tag/payload/id structures. Changing a
    %   copied structure never changes the source image or file.
    %
    %   See also nfx.File.read, nfx.TRERecord
    arguments
        filename
        imageIndex (1,1) double {mustBeInteger, mustBePositive} = 1
        treIndex (1,1) double {mustBeInteger, mustBePositive} = 1
    end
    view = nfx.TRERecord();
    [file, ok, status] = nfx.File.read(filename);
    if ~ok
        fprintf('%s: %s\n', status.code, status.message);
        return
    end
    if imageIndex > numel(file.images)
        fprintf('The requested image is absent.\n');
        return
    end
    [view, found, status] = file.images(imageIndex).tre(treIndex);
    if ~found
        fprintf('%s: %s\n', status.code, status.message);
        return
    end
    disp(view);
    fprintf('Metadata schemas complete: %d\n', ...
            file.validate().complete);
end
