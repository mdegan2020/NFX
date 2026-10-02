function results = runTwdTests(options)
    %runTwdTests - Run TWD tests with optional implementation coverage
    %   RESULTS = runTwdTests runs the independent viewer suite. Gesture
    %   tests briefly open their own graphics windows in MATLAB desktop.
    %
    %   RESULTS = runTwdTests(Coverage=true) also creates Cobertura and HTML
    %   reports under coverage/twd. Any failed or incomplete test errors.
    %
    %   See also runTests, runtests, matlab.unittest.TestRunner
    arguments
        options.Coverage (1,1) logical = false
    end
    root = fileparts(mfilename('fullpath'));
    runner = matlab.unittest.TestRunner.withTextOutput;
    suite = matlab.unittest.TestSuite.fromFolder( ...
        fullfile(root, 'tests', 'twd'), InvalidFileFoundAction='error');
    if options.Coverage
        output = fullfile(root, 'coverage', 'twd');
        if ~isfolder(output), mkdir(output); end
        formats = [ ...
            matlab.unittest.plugins.codecoverage.CoberturaFormat( ...
                fullfile(output, 'cobertura.xml')) ...
            matlab.unittest.plugins.codecoverage.CoverageReport( ...
                fullfile(output, 'html'))];
        plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
            fullfile(root, 'src', '+twd'), IncludingSubfolders=true, ...
            Producing=formats);
        runner.addPlugin(plugin);
    end
    results = runner.run(suite);
    fprintf('\nTWD: %d passed, %d failed, %d incomplete.\n', ...
        nnz([results.Passed]), nnz([results.Failed]), ...
        nnz([results.Incomplete]));
    assertSuccess(results);
end
