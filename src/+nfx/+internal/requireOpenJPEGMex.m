function requireOpenJPEGMex()
    %requireOpenJPEGMex - Require the pinned optional native backend
    if ~nfx.internal.hasOpenJPEGMex()
        error('nfx:OpenJPEGMexMissing', ...
            'Run buildOpenJPEGMex, or use the existing executable/MATLAB backend.');
    end
    if ~strcmp(nfx.internal.openjpegMex('info'), '2.5.4')
        error('nfx:OpenJPEGMexVersion', ...
            'Rebuild the MEX backend with pinned OpenJPEG 2.5.4.');
    end
end
