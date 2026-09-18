function result = nfxCoderFile16(raw) %#codegen
    %nfxCoderFile16 - Probe complete File inference with intended uint16 storage
    result = nfxkit.fileCore(raw, zeros(1, 0, 'uint16'));
end
