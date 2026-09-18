function report = runCoderTests(options)
    %runCoderTests - Run and archive the portable NFX Coder probes
    %   REPORT = runCoderTests runs MATLAB references and C MEX checks. It
    %   records unavailable prerequisites without claiming compilation
    %   passed. REPORT.archive names the ZIP to return from that machine.
    %
    %   REPORT = runCoderTests(ReferenceOnly=true) runs MATLAB checks only.
    %   Standalone=true adds C/C++ source generation. NoHeap=true also
    %   generates C/C++ with dynamic allocation disabled. Source-only
    %   generation does not prove a library builds or executes correctly.
    %
    %   OutputFolder=FOLDER selects the parent of a new result directory.
    %   The default is artifacts/coder under this source folder. The runner
    %   returns failed probe results in REPORT without throwing an error.
    %
    %   See also exportCoderTests, matlab.unittest.TestRunner
    arguments
        options.ReferenceOnly (1, 1) logical = false
        options.Standalone (1, 1) logical = false
        options.NoHeap (1, 1) logical = false
        options.OutputFolder {mustBeTextScalar} = ''
    end
    root = fileparts(mfilename('fullpath'));
    previousPath = path; restorePath = onCleanup(@() path(previousPath));
    addpath(fullfile(root, 'src'), fullfile(root, 'coder-tests'), ...
        fullfile(root, 'coder-tests', 'entries'));
    parent = char(options.OutputFolder);
    if isempty(parent), parent = fullfile(root, 'artifacts', 'coder'); end
    if ~isfolder(parent), mkdir(parent); end
    % FILEATTRIB supports R2023b; filePermissions is newer.
    [ok, attributes] = fileattrib(parent); %#ok<FILEATTRIB>
    assert(ok, 'nfxkit:OutputFolder', 'Cannot resolve the output folder.');
    folder = tempname(attributes.Name); mkdir(folder);
    config = struct('root', root, 'folder', folder, ...
        'referenceOnly', options.ReferenceOnly, ...
        'standalone', options.Standalone, 'noHeap', options.NoHeap, ...
        'environment', nfxkit.preflight());
    hashes = nfxkit.sourceHashes(root);
    nfxkit.writeJSON(fullfile(folder, 'source-hashes.json'), hashes);
    nfxkit.writeJSON(fullfile(folder, 'session.json'), config);
    sessionFile = fullfile(folder, 'session.mat');
    save(sessionFile, 'config');
    previous = getenv('NFX_CODER_RUN');
    restoreEnvironment = onCleanup(@() setenv('NFX_CODER_RUN', previous));
    setenv('NFX_CODER_RUN', sessionFile);
    suite = matlab.unittest.TestSuite.fromFile( ...
        fullfile(root, 'coder-tests', 'CoderProbeTest.m'));
    runner = matlab.unittest.TestRunner.withTextOutput;
    runner.addPlugin(matlab.unittest.plugins.DiagnosticsRecordingPlugin);
    testResults = runner.run(suite);
    save(fullfile(folder, 'test-results.mat'), 'testResults');
    report = nfxkit.summarize(config, testResults);
    report.archive = [folder '.zip'];
    nfxkit.writeJSON(fullfile(folder, 'results.json'), report);
    zip(report.archive, {'*'}, folder);
    fprintf('\nNFX Coder results: %s\n', report.archive);
    fprintf('Reference passes: %d; MEX execution passes: %d.\n', ...
        report.referencePasses, report.mexPasses);
    fprintf(['Compilation remains unverified for every ' ...
        'nonpassing MEX probe.\n']);
end
