function values = sourceHashes(root)
    %sourceHashes - Fingerprint the portable source without Git access
    files = nfxkit.sourceFiles(root);
    item = struct('path', '', 'sha256', ''); values = repmat(item, 1, numel(files));
    for k = 1:numel(files)
        [fid, message] = fopen(fullfile(root, files{k}), 'rb');
        if fid < 0, error('nfxkit:SourceRead', '%s', message); end
        cleanup = onCleanup(@() fclose(fid));
        raw = fread(fid, Inf, '*uint8'); clear cleanup
        digest = javaMethod('getInstance', 'java.security.MessageDigest', 'SHA-256');
        digest.update(typecast(raw(:), 'int8'));
        values(k).path = strrep(files{k}, '\', '/');
        values(k).sha256 = lower(reshape(dec2hex(typecast(digest.digest(), 'uint8'), 2).', 1, []));
    end
end
