function results = benchmarkOpenJPEGMex(data, encoder, options)
    %benchmarkOpenJPEGMex - Compare complete encoding and decoding calls
    %   RESULTS = benchmarkOpenJPEGMex(DATA,ENCODER) compares the executable
    %   and MEX encoders, and the MATLAB and MEX decoders, using TIMEIT.
    %   DATA is one native uint8/uint16 image; ENCODER is opj_compress.exe.
    %   All decoded pixels must match exactly. Build the optional MEX first.
    %
    %   Profile="NPJE" is the default; "EPJE" selects the other profile.
    %   Threads=4 controls the additional multithread MEX measurement. A
    %   single-thread measurement is always included for both backends.
    %   Results include MATLAB validation, layout conversion, normalization,
    %   and any temporary-file staging. TIMEIT runs repeated encodes, which
    %   can take several minutes for large images. No windows are opened.
    %
    %   See also timeit, buildOpenJPEGMex, nfx.JPEG2000
    arguments
        data
        encoder {mustBeTextScalar, mustBeNonzeroLengthText}
        options.Profile {mustBeTextScalar, ...
            mustBeMember(options.Profile, {'NPJE', 'EPJE'})} = 'NPJE'
        options.Threads = 4
    end
    if ~nfx.internal.validJPEG2000Options('auto', options.Threads)
        error('nfx:OpenJPEGThreads', ...
            'Supply a positive int32-range double Threads value.');
    end
    backends = ["cli" "mex" "mex"];
    counts = [1 1 options.Threads];
    encodeSeconds = zeros(3, 1);
    decodeSeconds = zeros(3, 1);
    temporaryBytes = zeros(3, 1);
    for k = 1:3
        executable = '';
        decoder = 'mex';
        if k == 1, executable = char(encoder); decoder = 'matlab'; end
        encode = @() nfx.JPEG2000(data, executable, ...
            Backend=backends(k), Profile=options.Profile, Threads=counts(k));
        packed = encode();
        decode = @() nfx.JPEG2000.decode(packed.codestream, ...
            Backend=decoder, Threads=counts(k));
        assert(isequal(decode(), data), 'Pixel mismatch.');
        encodeSeconds(k) = timeit(encode);
        decodeSeconds(k) = timeit(decode);
        temporaryBytes(k) = packed.metrics.temporary_bytes;
    end
    results = table(backends', counts', encodeSeconds, decodeSeconds, ...
        temporaryBytes, VariableNames={'Encoder', 'Threads', ...
            'EncodeSeconds', 'DecodeSeconds', 'TemporaryBytes'});
end
