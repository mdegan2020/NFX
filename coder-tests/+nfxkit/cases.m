function values = cases(name, folder)
    %cases - Build portable inputs and independent primitive expectations
    % These tiny host fixtures deliberately concatenate varying case sizes.
    %#ok<*AGROW>
    item = struct('name', '', 'args', {{}}, 'expected', struct());
    values = repmat(item, 1, 0);
    switch name
        case 'storage'
            counts = {zeros(1, 0), 1, [0 1 9], [9 0 1 9]};
            lengths = {zeros(1, 0), 251, [1 251 99985], [99985 1 251 7]};
            for k = 1:numel(counts)
                expected = struct('counts', counts{k}, 'comments', zeros(1, 0, 'uint8'), ...
                    'lengths', lengths{k}, 'payload', repmat(uint8(255), 1, sum(lengths{k})), ...
                    'missing', true);
                for j = 1:numel(counts{k})
                    expected.comments = [expected.comments repmat(uint8(64 + j), 1, 80 * counts{k}(j))];
                end
                values(end + 1) = makeCase(sprintf('shape%d', k), {counts{k}, lengths{k}}, expected);
            end
        case 'rpc'
            rpc = nfx.RPC00B(line_off=2, samp_off=3, lat_off=0, long_off=0, ...
                height_off=0, line_scale=2, samp_scale=3, lat_scale=1, ...
                long_scale=1, height_scale=100, ...
                line_num_coeff=[0 0 1 zeros(1, 17)], line_den_coeff=[1 zeros(1, 19)], ...
                samp_num_coeff=[0 1 zeros(1, 18)], samp_den_coeff=[1 zeros(1, 19)]);
            payload = rpc.payload();
            expected = struct('ok', true, 'code', 'OK', 'line_off', 2, ...
                'coefficients', [0 0 1 zeros(1, 17)], 'payload', payload, 'independent', true);
            values(end + 1) = makeCase('valid', {payload}, expected);
            failed = struct('ok', false, 'code', 'TruncatedPayload', 'line_off', NaN, ...
                'coefficients', nan(1, 20), 'payload', zeros(1, 0, 'uint8'), 'independent', false);
            values(end + 1) = makeCase('truncated', {payload(1:end - 1)}, failed);
            failed.code = 'InvalidPayload';
            values(end + 1) = makeCase('empty', {zeros(1, 0, 'uint8')}, failed);
            payload(1) = uint8('X'); failed.code = 'InvalidField';
            values(end + 1) = makeCase('invalid', {payload}, failed);
        case 'timing'
            exact = bitshift(uint64(1), 53) + uint64(7);
            deltas = {zeros(1, 0, 'uint64'), uint64(1), [exact intmax('uint64') uint64(0)]};
            multipliers = {uint64(1), exact, uint64(1)};
            tails = {zeros(1, 0, 'uint8'), uint8([0 0 0 0 0 0 0 1]), ...
                uint8([0 32 0 0 0 0 0 7 255 255 255 255 255 255 255 255 zeros(1, 8)])};
            for k = 1:numel(deltas)
                expected = struct('ok', true, 'code', 'OK', 'dt', deltas{k}, ...
                    'multiplier', multipliers{k}, 'timestamp', '20260917120000.000000001', ...
                    'tail', tails{k});
                values(end + 1) = makeCase(sprintf('uint64_%d', k), {deltas{k}, multipliers{k}}, expected);
            end
        case 'groups'
            for count = [0 1 10001]
                expected = struct('ok', true, 'values', repmat(40, 1, count), ...
                    'times', 0:count - 1, 'split', count > 9999, 'wrapperCount', 251, ...
                    'independent', true, 'removed', true);
                values(end + 1) = makeCase(sprintf('samples%d', count), {count}, expected);
            end
        case 'engineering'
            for count = 1:3
                data = uint16([1 256; 65535 2]);
                prefix = uint8(['Sensor' repmat(' ', 1, 14) ...
                    sprintf('%03d', count)]);
                payload = [prefix uint8('01A00020002I2UD00000004') ...
                    uint8([0 1 1 0 255 255 0 2])];
                counts = 4;
                if count >= 2
                    payload = [payload uint8('04Text00030001A1UD00000003NFX')];
                    counts(end + 1) = 3;
                end
                if count == 3
                    payload = [payload uint8('03Raw00010001I3UD00000001') ...
                        uint8([128 0 1])];
                    counts(end + 1) = 1;
                end
                expected = struct('ok', true, 'matrix', data, ...
                    'counts', counts, 'payload', payload, ...
                    'missing', true, 'independent', true);
                values(end + 1) = makeCase(sprintf('entries%d', count), ...
                    {data, count}, expected);
            end
        case {'native8', 'native16', 'file8', 'file16'}
            values = nfxkit.nativeCases(name, folder);
        case 'mixed'
            for k = [1 3]
                first = reshape(uint8(1:2 * k), 2, k);
                second = reshape(uint16(1001:1000 + k), 1, k);
                values(end + 1) = makeCase(sprintf('size%d', k), {first, second}, ...
                    struct('first', first, 'second', second, 'native', true));
            end
        otherwise
            error('nfxkit:Probe', 'Unknown probe name.');
    end
end

function value = makeCase(name, args, expected)
    value = struct('name', name, 'args', {args}, 'expected', expected);
end
