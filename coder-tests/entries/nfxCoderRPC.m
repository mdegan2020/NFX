function result = nfxCoderRPC(payload) %#codegen
    %nfxCoderRPC - Probe concrete decoding, status and copied TRE edits
    [rpc, ok, status] = nfx.RPC00B.deserialize(payload);
    result = struct('ok', ok, 'code', status.code, 'offset', status.offset, ...
        'line_off', rpc.line_off, 'coefficients', rpc.line_num_coeff, ...
        'payload', zeros(1, 0, 'uint8'), 'independent', false);
    if ~ok, return, end
    image = nfx.ImageSegment(uint8(1)) + rpc;
    copy = image.RPC00B(); copy.err_bias = rpc.err_bias + 1;
    result.payload = image.RPC00B().payload();
    result.independent = image.RPC00B().err_bias == rpc.err_bias && ...
        copy.err_bias ~= rpc.err_bias;
end
