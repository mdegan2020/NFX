function writeJSON(filename, value)
    %writeJSON - Write a UTF-8 machine-readable kit record
    [fid, message] = fopen(filename, 'w', 'n', 'UTF-8');
    if fid < 0, error('nfxkit:ReportWrite', '%s', message); end
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s\n', jsonencode(value, PrettyPrint=true));
end
