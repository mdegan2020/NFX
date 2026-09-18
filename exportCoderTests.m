function archive = exportCoderTests(options)
    %exportCoderTests - Bundle the Coder kit for another machine
    %   ARCHIVE = exportCoderTests creates a ZIP under artifacts/coder.
    %   Extract it there, open the folder in MATLAB, and call
    %   runCoderTests. Git, Codex, connectors, and PDFs are not required.
    %
    %   ARCHIVE = exportCoderTests(OutputFolder=FOLDER) uses another parent
    %   directory. Each export receives its own directory and ZIP filename.
    %
    %   See also runCoderTests
    arguments
        options.OutputFolder {mustBeTextScalar} = ''
    end
    root = fileparts(mfilename('fullpath'));
    previousPath = path; restorePath = onCleanup(@() path(previousPath));
    addpath(fullfile(root, 'coder-tests'));
    parent = char(options.OutputFolder);
    if isempty(parent), parent = fullfile(root, 'artifacts', 'coder'); end
    if ~isfolder(parent), mkdir(parent); end
    % FILEATTRIB supports R2023b; filePermissions is newer.
    [ok, attributes] = fileattrib(parent); %#ok<FILEATTRIB>
    assert(ok, 'nfxkit:OutputFolder', 'Cannot resolve the output folder.');
    folder = tempname(attributes.Name); mkdir(folder);
    files = nfxkit.sourceFiles(root);
    for k = 1:numel(files)
        target = fullfile(folder, files{k});
        if ~isfolder(fileparts(target)), mkdir(fileparts(target)); end
        copyfile(fullfile(root, files{k}), target);
    end
    nfxkit.writeJSON(fullfile(folder, 'source-hashes.json'), ...
        nfxkit.sourceHashes(folder));
    archive = [folder '.zip'];
    zip(archive, [files {'source-hashes.json'}], folder);
    fprintf('Portable NFX Coder source: %s\n', archive);
end
