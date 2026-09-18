function files = sourceFiles(root)
    %sourceFiles - List only source and portable-kit documentation
    files = {'runCoderTests.m', 'exportCoderTests.m', 'CODER_TESTS.md'};
    for folder = {'src', 'coder-tests'}
        listing = dir(fullfile(root, folder{1}, '**', '*.m'));
        for k = 1:numel(listing)
            path = fullfile(listing(k).folder, listing(k).name);
            files{end + 1} = path(numel(root) + 2:end); %#ok<AGROW>
        end
    end
    files = sort(files);
end
