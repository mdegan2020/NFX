function count = writeBytes(fid, bytes) %#codegen
    %writeBytes - Write a byte buffer and detect short writes
    count = fwrite(fid, bytes, 'uint8');
    if count ~= numel(bytes)
        error('nfx:WriteFailed', 'The filesystem accepted only part of the output.');
    end
end
