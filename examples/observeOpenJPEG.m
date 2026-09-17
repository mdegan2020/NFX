function observations = observeOpenJPEG(encoder)
    %observeOpenJPEG - Observe synthetic codec timings and MATLAB memory
    %   OBSERVATIONS = observeOpenJPEG(ENCODER) measures three synthetic
    %   still-image cases in both profiles. ENCODER is the pinned Windows
    %   opj_compress.exe. Memory deltas are pre/post MATLAB process values;
    %   they omit transient peaks and the encoder process's memory.
    %   Timings are single observations rather than benchmark assertions.
    %
    %   See also openjpegExample, memory, nfx.JPEG2000

    arguments
        encoder {mustBeTextScalar, mustBeNonzeroLengthText}
    end

    stream = RandStream('mt19937ar', Seed=20260916);
    ramp = repmat(uint16(0:2047), 2048, 1);
    noise = randi(stream, [0 65535], 1024, 1024, 5, 'uint16');
    rgb = repmat(reshape(uint8(0:255), 1, 256), 1024, 4, 3);
    cases = {ramp, noise, rgb};
    names = ["mono16_ramp" "msi16_noise" "rgb8_ramp"];
    rows = cell(1, 6);
    next = 1;

    for k = 1:numel(cases)
        for profile = ["NPJE" "EPJE"]
            before = memory().MemUsedMATLAB;
            started = tic;
            packed = nfx.JPEG2000(cases{k}, encoder, Profile=profile);
            seconds = toc(started);
            after = memory().MemUsedMATLAB;

            m = packed.metrics;
            rows{next} = table( ...
                names(k), profile, m.raw_bytes, m.codestream_bytes, ...
                m.encode_seconds, m.normalize_seconds, seconds, ...
                m.temporary_bytes, after - before, ...
                VariableNames={ ...
                    'Scene', 'Profile', 'RawBytes', 'CodestreamBytes', ...
                    'EncodeSeconds', 'NormalizeSeconds', ...
                    'TotalSeconds', 'TemporaryBytes', 'MATLABDeltaBytes'});
            next = next + 1;
            clear packed
        end
    end

    observations = vertcat(rows{:});
end
