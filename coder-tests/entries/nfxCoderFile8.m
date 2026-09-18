function result = nfxCoderFile8(raw) %#codegen
    %nfxCoderFile8 - Probe complete File inference with intended uint8 storage
    result = nfxkit.fileCore(raw, zeros(1, 0, 'uint8'));
end
