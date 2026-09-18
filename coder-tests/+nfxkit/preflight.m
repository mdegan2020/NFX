function info = preflight()
    %preflight - Record generation prerequisites without configuring tools
    info = struct('version', version, 'release', version('-release'), ...
        'architecture', computer('arch'), 'mexExtension', mexext, ...
        'products', ver, 'releaseSupported', ~isMATLABReleaseOlderThan('R2023b'), ...
        'coderInstalled', ~isempty(ver('coder')), ...
        'coderLicensed', logical(license('test', 'MATLAB_Coder')), ...
        'codegenAvailable', exist('codegen', 'file') ~= 0, ...
        'compilers', repmat(compilerRecord(), 1, 0), ...
        'messages', {cell(1, 0)});
    for language = {'C', 'C++'}
        item = compilerRecord(); item.language = language{1};
        try
            selected = mex.getCompilerConfigurations(language{1}, 'Selected');
            if ~isempty(selected)
                item.selected = true; item.name = selected(1).Name;
                item.version = selected(1).Version;
                item.location = selected(1).Location;
            end
        catch exception
            item.diagnostic = exception.message;
        end
        info.compilers(end + 1) = item;
    end
    if ~info.releaseSupported
        info.messages{end + 1} = 'MATLAB R2023b or later is required.';
    end
    if ~info.coderInstalled || ~info.coderLicensed || ~info.codegenAvailable
        info.messages{end + 1} = 'MATLAB Coder product/license is unavailable.';
    end
    if ~info.compilers(1).selected
        info.messages{end + 1} = 'Configure a supported C compiler using mex -setup C.';
    end
end

function item = compilerRecord()
    item = struct('language', '', 'selected', false, 'name', '', ...
        'version', '', 'location', '', 'diagnostic', '');
end
