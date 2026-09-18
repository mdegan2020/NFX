function result = nfxCoderNative16(raw) %#codegen
    %nfxCoderNative16 - Specialize native byte paths for uint16 samples
    result = nfxkit.nativeCore(raw, zeros(1, 0, 'uint16'));
end
