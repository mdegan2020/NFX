classdef (Abstract) NfxTest < matlab.unittest.TestCase
    %NfxTest - Isolated paths and temporary files for NFX tests
    properties
        folder
    end
    methods (TestClassSetup)
        function configurePaths(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'src')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'tests', 'helpers')));
        end
    end
    methods (TestMethodSetup)
        function temporaryFolder(testCase)
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.folder = fixture.Folder;
        end
    end
end
