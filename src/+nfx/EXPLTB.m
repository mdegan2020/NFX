classdef (Sealed) EXPLTB < nfx.TRE
    %EXPLTB - Radar exploitation information
    %   OBJ = EXPLTB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   EXPLTB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   EXPLTB properties:
    %       cetag - Constant tag identifier
    %       angle_to_north - ANGLE_TO_NORTH metadata
    %       angle_to_north_accy - ANGLE_TO_NORTH_ACCY metadata
    %       squint_angle - SQUINT_ANGLE metadata
    %       squint_angle_accy - SQUINT_ANGLE_ACCY metadata
    %       mode - MODE metadata
    %       graze_ang - GRAZE_ANG metadata
    %       graze_ang_accy - GRAZE_ANG_ACCY metadata
    %       slope_ang - SLOPE_ANG metadata
    %       polar - POLAR metadata
    %       nsamp - NSAMP metadata
    %       seq_num - SEQ_NUM metadata
    %       prime_id - PRIME_ID metadata
    %       prime_be - PRIME_BE metadata
    %       n_sec - N_SEC metadata
    %       ipr - IPR metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'EXPLTB' % Registered tag identifier
    end
    properties
        % ANGLE_TO_NORTH metadata
        angle_to_north {mustBeMetadata(angle_to_north, ...
            0, 359.999, 0)} = NaN
        % ANGLE_TO_NORTH_ACCY metadata
        angle_to_north_accy {mustBeMetadata(angle_to_north_accy, ...
            0, 44.999, 0)} = NaN
        % SQUINT_ANGLE metadata
        squint_angle {mustBeMetadata(squint_angle, ...
            -60, 85, 0)} = NaN
        % SQUINT_ANGLE_ACCY metadata
        squint_angle_accy {mustBeMetadata(squint_angle_accy, ...
            0, 44.999, 0)} = NaN
        mode {mustBeAscii(mode, 3)} = '' % MODE metadata
        % GRAZE_ANG metadata
        graze_ang {mustBeMetadata(graze_ang, ...
            0, 90, 0)} = NaN
        % GRAZE_ANG_ACCY metadata
        graze_ang_accy {mustBeMetadata(graze_ang_accy, ...
            0, 90, 0)} = NaN
        % SLOPE_ANG metadata
        slope_ang {mustBeMetadata(slope_ang, ...
            0, 90, 0)} = NaN
        polar {mustBeAscii(polar, 2)} = '' % POLAR metadata
        % NSAMP metadata
        nsamp {mustBeMetadata(nsamp, ...
            1, 99999, 1)} = NaN
        % SEQ_NUM metadata
        seq_num {mustBeMetadata(seq_num, ...
            1, 6, 1)} = NaN
        prime_id {mustBeAscii(prime_id, 12)} = '' % PRIME_ID metadata
        prime_be {mustBeAscii(prime_be, 15)} = '' % PRIME_BE metadata
        % N_SEC metadata
        n_sec {mustBeMetadata(n_sec, ...
            0, 99, 1)} = 0
        % IPR metadata
        ipr {mustBeMetadata(ipr, ...
            0, 99, 1)} = 0
    end
    methods
        function obj = EXPLTB(options) %#codegen
            arguments
                options.?nfx.EXPLTB
            end
            if isfield(options, 'angle_to_north')
                obj.angle_to_north = options.angle_to_north;
            end
            if isfield(options, 'angle_to_north_accy')
                obj.angle_to_north_accy = options.angle_to_north_accy;
            end
            if isfield(options, 'squint_angle')
                obj.squint_angle = options.squint_angle;
            end
            if isfield(options, 'squint_angle_accy')
                obj.squint_angle_accy = options.squint_angle_accy;
            end
            if isfield(options, 'mode')
                obj.mode = options.mode;
            end
            if isfield(options, 'graze_ang')
                obj.graze_ang = options.graze_ang;
            end
            if isfield(options, 'graze_ang_accy')
                obj.graze_ang_accy = options.graze_ang_accy;
            end
            if isfield(options, 'slope_ang')
                obj.slope_ang = options.slope_ang;
            end
            if isfield(options, 'polar')
                obj.polar = options.polar;
            end
            if isfield(options, 'nsamp')
                obj.nsamp = options.nsamp;
            end
            if isfield(options, 'seq_num')
                obj.seq_num = options.seq_num;
            end
            if isfield(options, 'prime_id')
                obj.prime_id = options.prime_id;
            end
            if isfield(options, 'prime_be')
                obj.prime_be = options.prime_be;
            end
            if isfield(options, 'n_sec')
                obj.n_sec = options.n_sec;
            end
            if isfield(options, 'ipr')
                obj.ipr = options.ipr;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-12 (2025-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.angle_to_north, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'angle_to_north', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.angle_to_north_accy, 6, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'angle_to_north_accy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.squint_angle, 7, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'squint_angle', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.squint_angle_accy, 6, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'squint_angle_accy', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.mode))), ...
                'Required', 'mode', 'Supply MODE.', reference);
            [~, valid] = treNumber(obj.graze_ang, 5, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'graze_ang', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.graze_ang_accy, 5, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'graze_ang_accy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.slope_ang, 5, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'slope_ang', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.polar, {'HH', 'HV', 'VH', 'VV'})), ...
                'Enumeration', 'polar', 'Use a defined POLAR value.', reference);
            [~, valid] = treNumber(obj.nsamp, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'nsamp', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.seq_num, 1, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'seq_num', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_sec, 2, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_sec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ipr, 2, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ipr', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(char(obj.mode)) ~= 3, ...
                'Metadata', 'mode', 'Supply a registered three-character collection mode.', reference);
            payloadLength = 7 + ...
                6 + ...
                7 + ...
                6 + ...
                3 + ...
                16 + ...
                5 + ...
                5 + ...
                5 + ...
                2 + ...
                5 + ...
                1 + ...
                1 + ...
                12 + ...
                15 + ...
                1 + ...
                2 + ...
                2;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.angle_to_north, 7, 3, false, false, false)];
            data = [data treNumber(obj.angle_to_north_accy, 6, 3, false, false, false)];
            data = [data treNumber(obj.squint_angle, 7, 3, true, false, false)];
            data = [data treNumber(obj.squint_angle_accy, 6, 3, false, false, false)];
            data = [data textField(obj.mode, 3)];
            data = [data uint8('                ')];
            data = [data treNumber(obj.graze_ang, 5, 2, false, false, false)];
            data = [data treNumber(obj.graze_ang_accy, 5, 2, false, false, false)];
            data = [data treNumber(obj.slope_ang, 5, 2, false, false, false)];
            data = [data textField(obj.polar, 2)];
            data = [data treNumber(obj.nsamp, 5, 0, false, false, false)];
            data = [data uint8('0')];
            data = [data treNumber(obj.seq_num, 1, 0, false, true, false)];
            data = [data textField(obj.prime_id, 12)];
            data = [data textField(obj.prime_be, 15)];
            data = [data uint8('0')];
            data = [data treNumber(obj.n_sec, 2, 0, false, false, false)];
            data = [data treNumber(obj.ipr, 2, 0, false, false, false)];
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.EXPLTB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.number(7, 0, 359.999, ...
                false, false);
            if reader.ok, obj.angle_to_north = value; end
            [value, reader] = reader.number(6, 0, 44.999, ...
                false, false);
            if reader.ok, obj.angle_to_north_accy = value; end
            [value, reader] = reader.number(7, -60, 85, ...
                false, false);
            if reader.ok, obj.squint_angle = value; end
            [value, reader] = reader.number(6, 0, 44.999, ...
                false, false);
            if reader.ok, obj.squint_angle_accy = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.mode = value; end
            reader = reader.literal('                ');
            [value, reader] = reader.number(5, 0, 90, ...
                false, false);
            if reader.ok, obj.graze_ang = value; end
            [value, reader] = reader.number(5, 0, 90, ...
                false, false);
            if reader.ok, obj.graze_ang_accy = value; end
            [value, reader] = reader.number(5, 0, 90, ...
                false, false);
            if reader.ok, obj.slope_ang = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.polar = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.nsamp = value; end
            reader = reader.literal('0');
            [value, reader] = reader.number(1, 1, 6, ...
                true, true);
            if reader.ok, obj.seq_num = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.prime_id = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.prime_be = value; end
            reader = reader.literal('0');
            [value, reader] = reader.number(2, 0, 99, ...
                true, false);
            if reader.ok, obj.n_sec = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, false);
            if reader.ok, obj.ipr = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.EXPLTB());
        end
    end
end
