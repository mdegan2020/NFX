function bytes = readBytes(filename)
    %readBytes - Read a test file without invoking the NFX serializer
    fid = fopen(filename, 'rb');
    cleanup = onCleanup(@() fclose(fid));
    bytes = fread(fid, Inf, '*uint8').';
end
