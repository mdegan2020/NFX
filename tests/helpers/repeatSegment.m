function file = repeatSegment(segment, count)
    %repeatSegment - Build deterministic segment-count boundary fixtures
    header = nfx.FileHeader(ostaid='NFXTEST',fdt='20260915120000',fsclas='U');
    file = nfx.File(header=header);
    for k = 1:count, file = file+segment; end
end
