classdef (Sealed) RPC00B < nfx.TRE
    %RPC00B - Editable rational polynomial camera metadata
    %   OBJ = RPC00B creates unset normalization fields and coefficients.
    %   Error estimates default to zero, meaning unavailable in Appendix E.
    %
    %   OBJ = RPC00B(Name=VALUE) sets metadata properties. Numeric inputs must
    %   be doubles. Each coefficient group accepts a row or column vector of
    %   exactly 20 elements. NaN means unset and prevents serialization.
    %
    %   RPC00B functions:
    %       validate - Check required values and encoded precision
    %       payload  - Serialize 1041 ASCII bytes
    %       bytes    - Serialize the 1052-byte tagged record
    %       ascii    - Return the ASCII payload as a character row
    %
    %   RPC00B properties:
    %       cetag          - RPC00B identifier
    %       cel            - Payload length
    %       success        - Required success flag
    %       err_bias       - Bias error estimate in meters
    %       err_rand       - Random error estimate in meters
    %       line_off       - Line offset in pixels
    %       samp_off       - Sample offset in pixels
    %       lat_off        - Latitude offset in degrees
    %       long_off       - Longitude offset in degrees
    %       height_off     - Height offset in meters
    %       line_scale     - Line scale in pixels
    %       samp_scale     - Sample scale in pixels
    %       lat_scale      - Nonzero latitude scale in degrees
    %       long_scale     - Nonzero longitude scale in degrees
    %       height_scale   - Nonzero height scale in meters
    %       line_num_coeff - Twenty line numerator coefficients
    %       line_den_coeff - Twenty line denominator coefficients
    %       samp_num_coeff - Twenty sample numerator coefficients
    %       samp_den_coeff - Twenty sample denominator coefficients
    %
    %   See also TRE, ImageSegment

    properties (Constant)
        cetag = 'RPC00B' % Extension identifier
        success = 1 % Required success flag
    end
    properties
        err_bias {mustBeMetadata(err_bias, 0, 9999.99, 0)} = 0 % Bias error
        err_rand {mustBeMetadata(err_rand, 0, 9999.99, 0)} = 0 % Random error
        line_off {mustBeMetadata(line_off, 0, 999999, 1)} = NaN % Line offset
        samp_off {mustBeMetadata(samp_off, 0, 99999, 1)} = NaN % Sample offset
        lat_off {mustBeMetadata(lat_off, -90, 90, 0)} = NaN % Latitude offset
        long_off {mustBeMetadata(long_off, -180, 180, 0)} = NaN % Longitude offset
        height_off {mustBeMetadata(height_off, -9999, 9999, 1)} = NaN % Height offset
        line_scale {mustBeMetadata(line_scale, 1, 999999, 1)} = NaN % Line scale
        samp_scale {mustBeMetadata(samp_scale, 1, 99999, 1)} = NaN % Sample scale
        lat_scale {mustBeMetadata(lat_scale, -90, 90, 0)} = NaN % Latitude scale
        long_scale {mustBeMetadata(long_scale, -180, 180, 0)} = NaN % Longitude scale
        height_scale {mustBeMetadata(height_scale, -9999, 9999, 1)} = NaN % Height scale
        line_num_coeff {mustBeCoefficients} = nan(1, 20) % Line numerator
        line_den_coeff {mustBeCoefficients} = nan(1, 20) % Line denominator
        samp_num_coeff {mustBeCoefficients} = nan(1, 20) % Sample numerator
        samp_den_coeff {mustBeCoefficients} = nan(1, 20) % Sample denominator
    end
    methods
        function obj = RPC00B(options) %#codegen
            %RPC00B - Construct editable metadata
            arguments
                options.?nfx.RPC00B
            end
            if isfield(options, 'err_bias'), obj.err_bias = options.err_bias; end
            if isfield(options, 'err_rand'), obj.err_rand = options.err_rand; end
            if isfield(options, 'line_off'), obj.line_off = options.line_off; end
            if isfield(options, 'samp_off'), obj.samp_off = options.samp_off; end
            if isfield(options, 'lat_off'), obj.lat_off = options.lat_off; end
            if isfield(options, 'long_off'), obj.long_off = options.long_off; end
            if isfield(options, 'height_off'), obj.height_off = options.height_off; end
            if isfield(options, 'line_scale'), obj.line_scale = options.line_scale; end
            if isfield(options, 'samp_scale'), obj.samp_scale = options.samp_scale; end
            if isfield(options, 'lat_scale'), obj.lat_scale = options.lat_scale; end
            if isfield(options, 'long_scale'), obj.long_scale = options.long_scale; end
            if isfield(options, 'height_scale'), obj.height_scale = options.height_scale; end
            if isfield(options, 'line_num_coeff'), obj.line_num_coeff = options.line_num_coeff; end
            if isfield(options, 'line_den_coeff'), obj.line_den_coeff = options.line_den_coeff; end
            if isfield(options, 'samp_num_coeff'), obj.samp_num_coeff = options.samp_num_coeff; end
            if isfield(options, 'samp_den_coeff'), obj.samp_den_coeff = options.samp_den_coeff; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check required values and encoded precision
            %   REPORT = VALIDATE(OBJ) returns valid, scope, and an issue
            %   collection with field locations and specification references.
            arguments
                obj (1,1) nfx.RPC00B
            end
            report = newReport('RPC00B');
            reference = 'STDI-0002-1 App E (2025-02), E.3.12 Table E-22';
            values = [obj.err_bias obj.err_rand obj.line_off obj.samp_off ...
                obj.lat_off obj.long_off obj.height_off obj.line_scale ...
                obj.samp_scale obj.lat_scale obj.long_scale obj.height_scale];
            names = char('err_bias','err_rand','line_off','samp_off','lat_off', ...
                'long_off','height_off','line_scale','samp_scale', ...
                'lat_scale','long_scale','height_scale');
            for k = 1:numel(values)
                report = addIssue(report, isnan(values(k)), 'Required', strtrim(names(k,:)), ...
                    'Supply a value; NaN denotes unset metadata.', reference);
            end
            for k = 1:2
                report = addIssue(report, values(k) > 0 && round(values(k)*100) == 0, ...
                    'ErrorPrecision', strtrim(names(k,:)), ...
                    'A supplied error estimate must not encode as zero (unavailable).', reference);
            end
            scales = [obj.lat_scale obj.long_scale obj.height_scale];
            scaleNames = char('lat_scale','long_scale','height_scale');
            factors = [1e4 1e4 1];
            for k = 1:3
                report = addIssue(report, round(scales(k)*factors(k)) == 0, ...
                    'ZeroScale', strtrim(scaleNames(k,:)), 'Scale must remain nonzero after encoding.', reference);
            end
            groups = [obj.line_num_coeff(:) obj.line_den_coeff(:) ...
                obj.samp_num_coeff(:) obj.samp_den_coeff(:)];
            groupNames = char('line_num_coeff','line_den_coeff','samp_num_coeff','samp_den_coeff');
            for group = 1:4
                for k = 1:20
                    [~, valid] = rpcCoefficient(groups(k, group));
                    report = addIssue(report, ~valid, 'Coefficient', ...
                        sprintf('%s(%d)', strtrim(groupNames(group,:)), k), ...
                        'Supply a finite coefficient representable with a one-digit exponent.', reference);
                end
            end
            report = addIssue(report, all(groups(:,2) == 0), 'ZeroDenominator', ...
                'line_den_coeff', 'The denominator polynomial cannot be identically zero.', reference);
            report = addIssue(report, all(groups(:,4) == 0), 'ZeroDenominator', ...
                'samp_den_coeff', 'The denominator polynomial cannot be identically zero.', reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the validated RPC00B payload
            %   VALUE = PAYLOAD(OBJ) returns a 1-by-1041 uint8 ASCII payload.
            arguments
                obj (1,1) nfx.RPC00B
            end
            requireValid(validate(obj));
            value = [uint8('1') ...
                decimalField(obj.err_bias, 7, 2, false) ...
                decimalField(obj.err_rand, 7, 2, false) ...
                decimalField(obj.line_off, 6, 0, false) ...
                decimalField(obj.samp_off, 5, 0, false) ...
                decimalField(obj.lat_off, 8, 4, true) ...
                decimalField(obj.long_off, 9, 4, true) ...
                decimalField(obj.height_off, 5, 0, true) ...
                decimalField(obj.line_scale, 6, 0, false) ...
                decimalField(obj.samp_scale, 5, 0, false) ...
                decimalField(obj.lat_scale, 8, 4, true) ...
                decimalField(obj.long_scale, 9, 4, true) ...
                decimalField(obj.height_scale, 5, 0, true) zeros(1, 960, 'uint8')];
            groups = [obj.line_num_coeff(:) obj.line_den_coeff(:) ...
                obj.samp_num_coeff(:) obj.samp_den_coeff(:)];
            for k = 1:80
                value(82+(k-1)*12:81+k*12) = rpcCoefficient(groups(k));
            end
        end
        function value = ascii(obj) %#codegen
            %ASCII - Return the payload as ASCII characters
            %   VALUE = ASCII(OBJ) returns the validated payload without the
            %   tag and length envelope. No newline is appended.
            arguments
                obj (1,1) nfx.RPC00B
            end
            value = char(payload(obj));
        end
    end

    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %DESERIALIZE - Recover editable RPC00B metadata from its payload
            %   OBJ = DESERIALIZE(DATA) decodes a uint8 payload without its
            %   tag/length envelope. Failure returns a default scalar RPC00B.
            %
            %   [OBJ,OK] = DESERIALIZE(...) also reports decoding success.
            %
            %   [OBJ,OK,STATUS] = DESERIALIZE(...) also returns a diagnostic
            %   code, message and one-based payload cursor. No parsing error
            %   is thrown. Values retain the precision of their encoding.
            arguments
                data
            end
            obj = nfx.RPC00B();
            reader = nfx.internal.TREReader(data);
            reader = reader.literal('1');
            [obj.err_bias, reader] = reader.number(7, 0, 9999.99);
            [obj.err_rand, reader] = reader.number(7, 0, 9999.99);
            [obj.line_off, reader] = reader.number(6, 0, 999999, true);
            [obj.samp_off, reader] = reader.number(5, 0, 99999, true);
            [obj.lat_off, reader] = reader.number(8, -90, 90);
            [obj.long_off, reader] = reader.number(9, -180, 180);
            [obj.height_off, reader] = reader.number(5, -9999, 9999, true);
            [obj.line_scale, reader] = reader.number(6, 1, 999999, true);
            [obj.samp_scale, reader] = reader.number(5, 1, 99999, true);
            [obj.lat_scale, reader] = reader.number(8, -90, 90);
            [obj.long_scale, reader] = reader.number(9, -180, 180);
            [obj.height_scale, reader] = reader.number(5, -9999, 9999, true);
            [coefficients, reader] = reader.numbers(80, 12);
            if reader.ok
                obj.line_num_coeff = coefficients(1:20);
                obj.line_den_coeff = coefficients(21:40);
                obj.samp_num_coeff = coefficients(41:60);
                obj.samp_den_coeff = coefficients(61:80);
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RPC00B());
        end
    end
end
