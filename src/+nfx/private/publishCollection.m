function published = publishCollection(files,paths,order,overwrite)
    %publishCollection - Report completed files when host publication fails
    %   Filesystem exception reporting is isolated from collection planning
    %   and byte construction. This host boundary requires MATLAB; TRY/CATCH
    %   is not supported by MATLAB Coder. No compiled support is claimed.
    published = cell(1,numel(order)); count = 0;
    for k = order
        try
            files(k).file.write(paths{k},Overwrite=overwrite);
        catch exception
            error('nfx:CollectionWrite','Failed to publish %s. Already published (%d): %s. Cause: %s', ...
                paths{k},count,strjoin(published(1:count),'; '),exception.message);
        end
        count = count+1; published{count} = paths{k};
    end
end
