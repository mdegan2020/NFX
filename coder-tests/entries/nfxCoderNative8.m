function result = nfxCoderNative8(raw) %#codegen
    %nfxCoderNative8 - Specialize native byte paths for uint8 samples
    result = nfxkit.nativeCore(raw, zeros(1, 0, 'uint8'));
end
