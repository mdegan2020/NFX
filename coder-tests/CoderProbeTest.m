classdef CoderProbeTest < matlab.unittest.TestCase
    %CoderProbeTest - Concrete entry points with independently checked fixtures
    %   Invoke through runCoderTests to supply the portable result session.
    properties (TestParameter)
        probe = {'storage', 'rpc', 'timing', 'groups', 'native8', ...
            'native16', 'file8', 'file16', 'mixed'}
        phase = {'reference', 'mex', 'standalone_c', 'standalone_cpp', ...
            'noheap_c', 'noheap_cpp'}
    end
    properties
        config
    end
    methods (TestClassSetup)
        function session(testCase)
            filename = getenv('NFX_CODER_RUN');
            testCase.assertTrue(isfile(filename), ...
                'Use runCoderTests to configure and archive this suite.');
            saved = load(filename, 'config'); testCase.config = saved.config;
        end
    end
    methods (Test)
        function check(testCase, probe, phase)
            probes = nfxkit.probes(); selected = probes(strcmp({probes.name}, probe));
            result = nfxkit.runPhase(testCase.config, selected, phase);
            testCase.assumeFalse(ismember(result.outcome, ...
                {'unmet_prerequisites', 'not_requested'}), result.diagnostic);
            testCase.verifyEqual(result.outcome, 'pass', ...
                sprintf('%s\n%s', result.diagnostic, jsonencode(result.cases)));
        end
    end
end
