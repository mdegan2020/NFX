function results = runTests(options)
    %runTests - Run the complete NFX suite with optional implementation coverage
    %   RESULTS = runTests runs class-based unit, byte-oracle, and reader tests.
    %   Image Processing Toolbox is required for the reader round trips.
    %   TWD gesture tests briefly open their own graphics windows.
    %
    %   RESULTS = runTests(Coverage=true) also creates Cobertura and HTML reports
    %   under the ignored coverage directory. Any failed or incomplete test errors.
    %
    %   RESULTS = runTests(OpenJPEG=ENCODER) includes the optional Windows
    %   OpenJPEG 2.5.4 tests. NFX_OPENJPEG supplies the default executable path.
    %
    %   See also runtests, matlab.unittest.TestRunner
    arguments
        options.Coverage (1,1) logical = false
        options.OpenJPEG {mustBeTextScalar} = getenv('NFX_OPENJPEG')
    end
    root = fileparts(mfilename('fullpath'));
    runner = matlab.unittest.TestRunner.withTextOutput;
    suite = matlab.unittest.TestSuite.fromFolder(fullfile(root,'tests'),InvalidFileFoundAction='error');
    previous = getenv('NFX_OPENJPEG');
    restoreEnvironment = onCleanup(@() setenv('NFX_OPENJPEG',previous));
    setenv('NFX_OPENJPEG',char(options.OpenJPEG));
    if strlength(options.OpenJPEG) == 0
        suite = suite.selectIf(~matlab.unittest.selectors.HasTag('OpenJPEG'));
        fprintf('Optional OpenJPEG tests excluded; supply OpenJPEG=ENCODER to include them.\n');
    end
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
