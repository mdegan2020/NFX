function results = runTests(options)
    %runTests - Run the complete NFX suite with optional implementation coverage
    %   RESULTS = runTests runs class-based unit, byte-oracle, and reader tests.
    %   Image Processing Toolbox is required for the reader round trips.
    %
    %   RESULTS = runTests(Coverage=true) also creates Cobertura and HTML reports
    %   under the ignored coverage directory. Any failed or incomplete test errors.
    %
    %   See also runtests, matlab.unittest.TestRunner
    arguments
        options.Coverage (1,1) logical = false
    end
    root = fileparts(mfilename('fullpath'));
    runner = matlab.unittest.TestRunner.withTextOutput;
    suite = matlab.unittest.TestSuite.fromFolder(fullfile(root,'tests'));
    if options.Coverage
        output = fullfile(root,'coverage');
        if ~isfolder(output), mkdir(output); end
        formats = [matlab.unittest.plugins.codecoverage.CoberturaFormat(fullfile(output,'cobertura.xml')) ...
            matlab.unittest.plugins.codecoverage.CoverageReport(fullfile(output,'html'))];
        runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
            fullfile(root,'src'),IncludingSubfolders=true,Producing=formats));
    end
    results = runner.run(suite);
    fprintf('\nNFX: %d passed, %d failed, %d incomplete.\n', ...
        nnz([results.Passed]),nnz([results.Failed]),nnz([results.Incomplete]));
    assertSuccess(results);
end
