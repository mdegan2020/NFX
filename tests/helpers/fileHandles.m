function value = fileHandles()
    %fileHandles - Query open descriptors on both supported MATLAB API versions
    if exist('openedFiles','builtin') || exist('openedFiles','file')
        value = openedFiles();
    else
        value = fopen('all');
    end
end
