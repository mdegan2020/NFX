function available = hasOpenJPEGMex()
    %hasOpenJPEGMex - Resolve the optional package binary on the MATLAB path
    location = which('nfx.internal.openjpegMex');
    available = ~isempty(location) && exist(location, 'file') == 3;
end
