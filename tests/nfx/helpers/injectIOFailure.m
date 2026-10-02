function injectIOFailure(testCase, name, body)
    %injectIOFailure - Shadow one I/O boundary in an isolated test folder
    folder = fullfile(testCase.folder, 'io-fault');
    mkdir(folder);
    putBytes(fullfile(folder,[name '.m']),uint8(body));
    previous = warning('off', 'MATLAB:dispatcher:nameConflict');
    testCase.addTeardown(@() warning(previous));
    testCase.applyFixture(matlab.unittest.fixtures.PathFixture(folder));
end
