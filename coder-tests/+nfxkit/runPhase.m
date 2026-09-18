function result = runPhase(config, probe, phase)
    %runPhase - Keep failures and prerequisite gaps visible in a portable record
    timer = tic;
    result = struct('probe', probe.name, 'entry', probe.entry, 'scope', probe.scope, ...
        'phase', phase, 'outcome', '', 'diagnostic', '', 'seconds', 0, ...
        'configuration', struct(), 'cases', struct([]));
    folder = fullfile(config.folder, [probe.name '_' phase]); mkdir(folder);
    [result.outcome, result.diagnostic] = nfxkit.prerequisite(config, phase);
    if isempty(result.outcome)
        try
            result = execute(result, folder, probe, phase);
        catch exception
            result.outcome = 'harness_failure';
            result.diagnostic = getReport(exception, 'extended', 'hyperlinks', 'off');
        end
    end
    result.seconds = toc(timer);
    nfxkit.writeJSON(fullfile(folder, 'result.json'), result);
end

function result = execute(result, folder, probe, phase)
    try
        cases = nfxkit.cases(probe.name, folder);
        [records, reference] = nfxkit.compareCases(str2func(probe.entry), cases);
        result.cases = records;
        if ~all([records.passed])
            result.outcome = 'reference_failure';
            result.diagnostic = 'MATLAB reference failed independent expectations.';
            return
        end
    catch exception
        result.outcome = 'reference_failure';
        result.diagnostic = getReport(exception, 'extended', 'hyperlinks', 'off');
        return
    end
    if strcmp(phase, 'reference'), result.outcome = 'pass'; return, end
    buildFolder = fullfile(folder, 'build'); mkdir(buildFolder);
    % Unique output name plus explicit output directory prevents a stale MEX
    % elsewhere on the user's path from masquerading as this compilation.
    [~, unique] = fileparts(tempname); mexName = ['nfx_' unique];
    try
        [cfg, result.configuration] = nfxkit.generationConfig(phase);
        types = nfxkit.inputTypes(probe.name);
        save(fullfile(folder, 'configuration.mat'), 'cfg', 'types');
        args = {'-config', cfg, probe.entry, '-args', types, '-d', buildFolder, '-report'};
        if strcmp(phase, 'mex')
            args = [args {'-o', fullfile(buildFolder, mexName)}]; %#ok<NASGU>
        else
            args = [args {'-c'}]; %#ok<NASGU>
        end
        % Constant source captures compiler output even on exceptions. No
        % caller-provided text is ever interpreted as MATLAB code here.
        log = evalc('[generated, diagnostic] = invokeCodegen(args);');
        writeText(fullfile(folder, 'generation.log'), [log newline diagnostic]);
        if ~generated
            result.outcome = 'compile_failure'; result.diagnostic = diagnostic; return
        end
    catch exception
        result.outcome = 'compile_failure';
        result.diagnostic = getReport(exception, 'extended', 'hyperlinks', 'off');
        writeText(fullfile(folder, 'generation.log'), result.diagnostic);
        return
    end
    if ~strcmp(phase, 'mex')
        result.outcome = 'pass';
        result.diagnostic = 'Source generated only; no library build or generated execution.';
        return
    end
    previousPath = path; restorePath = onCleanup(@() path(previousPath));
    addpath(buildFolder);
    unload = onCleanup(@() clear(mexName));
    actualPath = which(mexName);
    if ~strcmpi(actualPath, fullfile(buildFolder, [mexName '.' mexext]))
        result.outcome = 'runtime_failure';
        result.diagnostic = 'The newly generated MEX cannot be resolved from its output directory.';
        return
    end
    [result.cases, ~] = nfxkit.compareCases(str2func(mexName), cases, reference);
    if all([result.cases.passed])
        result.outcome = 'pass';
    else
        result.outcome = 'runtime_failure';
        result.diagnostic = 'MEX execution failed or disagreed with reference/independent values.';
    end
end

function [ok, diagnostic] = invokeCodegen(args)
    ok = false; diagnostic = '';
    try
        codegen(args{:}); ok = true;
    catch exception
        diagnostic = getReport(exception, 'extended', 'hyperlinks', 'off');
    end
end

function writeText(filename, value)
    [fid, message] = fopen(filename, 'w', 'n', 'UTF-8');
    if fid < 0, error('nfxkit:LogWrite', '%s', message); end
    cleanup = onCleanup(@() fclose(fid)); fprintf(fid, '%s', value);
end
