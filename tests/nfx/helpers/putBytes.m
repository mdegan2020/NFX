function putBytes(filename, bytes)
    %putBytes - Create a sentinel destination for filesystem tests
    fid = fopen(filename, 'wb');
    cleanup = onCleanup(@() fclose(fid));
    fwrite(fid, bytes, 'uint8');
end
