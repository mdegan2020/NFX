function [outcome, reason] = prerequisite(config, phase)
    %prerequisite - Separate unrequested checks from unavailable prerequisites
    outcome = ''; reason = '';
    if ~strcmp(phase, 'reference') && (config.referenceOnly || ...
            (startsWith(phase, 'standalone') && ~config.standalone) || ...
            (startsWith(phase, 'noheap') && ~config.noHeap))
        outcome = 'not_requested'; reason = 'This generation phase was not requested.';
        return
    end
    info = config.environment;
    if ~info.releaseSupported
        outcome = 'unmet_prerequisites'; reason = 'MATLAB R2023b or later is required.';
    elseif ~strcmp(phase, 'reference')
        if ~info.coderInstalled || ~info.coderLicensed || ~info.codegenAvailable
            outcome = 'unmet_prerequisites'; reason = 'MATLAB Coder product/license is unavailable.';
        elseif strcmp(phase, 'mex') && ~info.compilers(1).selected
            outcome = 'unmet_prerequisites'; reason = 'Select a supported C compiler using mex -setup C.';
        end
        % Standalone checks generate source only (-c), without invoking a
        % compiler. Both compiler selections remain recorded in preflight.
    end
end
