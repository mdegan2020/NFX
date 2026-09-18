classdef CoderKitTest < NfxTest
    %CoderKitTest - Verify the portable harness without requiring a Coder license
    properties (TestParameter)
        probe = {'storage', 'rpc', 'timing', 'groups', 'native8', ...
            'native16', 'file8', 'file16', 'mixed'}
    end
    methods (TestClassSetup)
        function kitPath(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'coder-tests')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'coder-tests', 'entries')));
        end
    end
    methods (Test)
        function referenceCases(testCase, probe)
            probes = nfxkit.probes(); selected = probes(strcmp({probes.name}, probe));
            config = syntheticConfig(testCase.folder);
            result = nfxkit.runPhase(config, selected, 'reference');
            testCase.verifyEqual(result.outcome, 'pass', jsonencode(result));
            testCase.verifyTrue(all([result.cases.passed]));
        end
        function failuresAreRecordedAndLaterCasesRun(testCase)
            cases = repmat(struct('name', '', 'args', {{0}}, ...
                'expected', struct('value', 0)), 1, 3);
            cases(1).name = 'wrong'; cases(1).expected.value = 1;
            cases(2).name = 'throws'; cases(2).args = {-1};
            cases(3).name = 'later'; cases(3).args = {2};
            cases(3).expected.value = 2;
            [results, values] = nfxkit.compareCases(@syntheticCallable, cases);
            testCase.verifyEqual([results.passed], [false false true]);
            testCase.verifySubstring(results(1).diagnostic, 'Independent expectation');
            testCase.verifySubstring(results(2).diagnostic, 'synthetic exception');
            testCase.verifyEqual(values{3}.value, 2);
            [results, ~] = nfxkit.compareCases(@syntheticCallable, cases(3), ...
                {struct('value', 2, 'unlistedField', 10)});
            testCase.verifyFalse(results.passed);
            testCase.verifySubstring(results.diagnostic, 'differs from MATLAB');
        end
        function prerequisitesAreNotPasses(testCase)
            config = syntheticConfig(testCase.folder);
            config.environment.coderInstalled = false;
            probes = nfxkit.probes(); result = nfxkit.runPhase(config, probes(1), 'mex');
            testCase.verifyEqual(result.outcome, 'unmet_prerequisites');
            testCase.verifyEmpty(result.cases);
            config.referenceOnly = true;
            [outcome, ~] = nfxkit.prerequisite(config, 'mex');
            testCase.verifyEqual(outcome, 'not_requested');
            config = syntheticConfig(testCase.folder);
            config.environment.compilers(1).selected = false;
            [outcome, ~] = nfxkit.prerequisite(config, 'mex');
            testCase.verifyEqual(outcome, 'unmet_prerequisites');
            config.standalone = true;
            [outcome, ~] = nfxkit.prerequisite(config, 'standalone_cpp');
            testCase.verifyEmpty(outcome); % -c does not require a compiler.
            config.environment.releaseSupported = false;
            [outcome, ~] = nfxkit.prerequisite(config, 'reference');
            testCase.verifyEqual(outcome, 'unmet_prerequisites');
        end
        function preflightRecordsEnvironment(testCase)
            info = nfxkit.preflight();
            testCase.verifyEqual(info.version, version);
            testCase.verifyEqual(info.architecture, computer('arch'));
            testCase.verifyEqual({info.compilers.language}, {'C', 'C++'});
            testCase.verifyClass(info.coderLicensed, 'logical');
            testCase.verifyNotEmpty(info.products);
        end
        function frameworkFailuresCannotReportSuccess(testCase)
            config = syntheticConfig(testCase.folder);
            config.environment.version = 'synthetic';
            config.environment.release = 'synthetic';
            config.environment.architecture = 'synthetic';
            folder = fullfile(testCase.folder, 'one_reference'); mkdir(folder);
            record = struct('probe', 'one', 'phase', 'reference', 'outcome', 'pass');
            nfxkit.writeJSON(fullfile(folder, 'result.json'), record);
            failed = struct('Name', 'synthetic', 'Passed', false, 'Failed', true, ...
                'Incomplete', true, 'Duration', 0);
            report = nfxkit.summarize(config, failed);
            testCase.verifyFalse(report.allRequestedPassed);
            config.folder = fullfile(testCase.folder, 'no-phase-records');
            mkdir(config.folder);
            report = nfxkit.summarize(config, failed);
            testCase.verifyFalse(report.allRequestedPassed);
            testCase.verifyEmpty(report.phaseResults);
            testCase.verifyTrue(report.tests.failed);
            testCase.verifyTrue(isfile(fullfile(config.folder, 'SUMMARY.md')));
            report = nfxkit.summarize(config, repmat(failed, 1, 0));
            testCase.verifyFalse(report.allRequestedPassed);
            testCase.verifyError(@() nfxkit.cases('unknown', testCase.folder), 'nfxkit:Probe');
        end
        function copiedBundleRunsAndArchives(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            archive = exportCoderTests(OutputFolder=testCase.folder);
            extracted = fullfile(testCase.folder, 'copied'); mkdir(extracted);
            files = unzip(archive, extracted);
            testCase.verifyFalse(any(contains(files, [filesep 'docs' filesep])));
            testCase.verifyFalse(any(contains(files, [filesep 'artifacts' filesep])));
            hashes = nfxkit.sourceHashes(root);
            testCase.verifyEqual(nfxkit.sourceHashes(extracted), hashes);
            previous = pwd; restoreFolder = onCleanup(@() cd(previous));
            cd(extracted);
            testCase.verifyEqual(which('runCoderTests'), fullfile(extracted, 'runCoderTests.m'));
            oldPath = path; oldEnvironment = getenv('NFX_CODER_RUN');
            output = evalc('report = runCoderTests(ReferenceOnly=true);');
            testCase.verifySubstring(output, 'MEX execution passes: 0');
            testCase.verifyEqual(path, oldPath);
            testCase.verifyEqual(getenv('NFX_CODER_RUN'), oldEnvironment);
            testCase.verifyTrue(report.allRequestedPassed);
            testCase.verifyEqual(report.referencePasses, 9);
            testCase.verifyEqual(report.mexPasses, 0);
            testCase.verifyEqual(nnz(strcmp({report.phaseResults.outcome}, 'not_requested')), 45);
            testCase.verifyEqual(numel(report.tests), 54);
            contents = fullfile(testCase.folder, 'results'); mkdir(contents);
            unzip(report.archive, contents);
            testCase.verifyTrue(isfile(fullfile(contents, 'SUMMARY.md')));
            testCase.verifyTrue(isfile(fullfile(contents, 'test-results.mat')));
            result = jsondecode(fileread(fullfile(contents, 'results.json')));
            testCase.verifyEqual(result.mexPasses, 0);
            session = jsondecode(fileread(fullfile(contents, 'session.json')));
            testCase.verifyEqual(session.root, extracted);
            testCase.verifyEqual(session.environment.version, version);
            copiedHashes = jsondecode(fileread(fullfile(contents, 'source-hashes.json')));
            testCase.verifyEqual(copiedHashes(:), hashes(:));
        end
    end
end

function config = syntheticConfig(folder)
    config = struct('folder', folder, 'referenceOnly', false, ...
        'standalone', false, 'noHeap', false, 'environment', struct( ...
        'releaseSupported', true, 'coderInstalled', true, ...
        'coderLicensed', true, 'codegenAvailable', true, ...
        'compilers', struct('selected', true)));
end

function value = syntheticCallable(number)
    assert(number >= 0, 'nfxkit:Synthetic', 'synthetic exception');
    value = struct('value', number);
end
