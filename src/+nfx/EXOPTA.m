classdef (Sealed) EXOPTA < nfx.TRE
    %EXOPTA - Optical exploitation usability metadata
    %   OBJ = EXOPTA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   EXOPTA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   EXOPTA properties:
    %       cetag - Constant tag identifier
    %       angle_to_north - ANGLE_TO_NORTH metadata
    %       mean_gsd - MEAN_GSD metadata
    %       dynamic_range - DYNAMIC_RANGE metadata
    %       obl_ang - OBL_ANG metadata
    %       roll_ang - ROLL_ANG metadata
    %       prime_id - PRIME_ID metadata
    %       prime_be - PRIME_BE metadata
    %       n_sec - N_SEC metadata
    %       n_seg - N_SEG metadata
    %       max_lp_seg - MAX_LP_SEG metadata
    %       sun_el - SUN_EL metadata
    %       sun_az - SUN_AZ metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'EXOPTA' % Registered tag identifier
    end
    properties
        % ANGLE_TO_NORTH metadata
        angle_to_north {mustBeMetadata(angle_to_north, ...
            0, 359, 1)} = NaN
        % MEAN_GSD metadata
        mean_gsd {mustBeMetadata(mean_gsd, ...
            0, 999.9, 0)} = NaN
        % DYNAMIC_RANGE metadata
        dynamic_range {mustBeMetadata(dynamic_range, ...
            0, 65535, 1)} = NaN
        % OBL_ANG metadata
        obl_ang {mustBeMetadata(obl_ang, ...
            0, 90, 0)} = NaN
        % ROLL_ANG metadata
        roll_ang {mustBeMetadata(roll_ang, ...
            -90, 90, 0)} = NaN
        prime_id {mustBeAscii(prime_id, 12)} = '' % PRIME_ID metadata
        prime_be {mustBeAscii(prime_be, 15)} = '' % PRIME_BE metadata
        % N_SEC metadata
        n_sec {mustBeMetadata(n_sec, ...
            0, 250, 1)} = 0
        % N_SEG metadata
        n_seg {mustBeMetadata(n_seg, ...
            1, 999, 1)} = 1
        % MAX_LP_SEG metadata
        max_lp_seg {mustBeMetadata(max_lp_seg, ...
            1, 199999, 1)} = NaN
        % SUN_EL metadata
        sun_el {mustBeMetadata(sun_el, ...
            -90, 999.9, 0)} = NaN
        % SUN_AZ metadata
        sun_az {mustBeMetadata(sun_az, ...
            0, 999.9, 0)} = NaN
    end
    methods
        function obj = EXOPTA(options) %#codegen
            arguments
                options.?nfx.EXOPTA
            end
            if isfield(options, 'angle_to_north')
                obj.angle_to_north = options.angle_to_north;
            end
            if isfield(options, 'mean_gsd')
                obj.mean_gsd = options.mean_gsd;
            end
            if isfield(options, 'dynamic_range')
                obj.dynamic_range = options.dynamic_range;
            end
            if isfield(options, 'obl_ang')
                obj.obl_ang = options.obl_ang;
            end
            if isfield(options, 'roll_ang')
                obj.roll_ang = options.roll_ang;
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
            if isfield(options, 'n_seg')
                obj.n_seg = options.n_seg;
            end
            if isfield(options, 'max_lp_seg')
                obj.max_lp_seg = options.max_lp_seg;
            end
            if isfield(options, 'sun_el')
                obj.sun_el = options.sun_el;
            end
            if isfield(options, 'sun_az')
                obj.sun_az = options.sun_az;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-10 (2025-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.angle_to_north, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'angle_to_north', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.mean_gsd, 5, 1, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'mean_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dynamic_range, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'dynamic_range', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.obl_ang, 5, 2, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'obl_ang', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.roll_ang, 6, 2, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'roll_ang', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_sec, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_sec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_seg, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_seg', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.max_lp_seg, 6, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'max_lp_seg', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = sunElevationNumber(obj.sun_el);
            report = addIssue(report, ~valid, 'Encoding', 'sun_el', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sun_az, 5, 1, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'sun_az', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, obj.sun_az > 359.9 && obj.sun_az ~= 999.9, ...
                'Metadata', 'sun_az', 'Use an azimuth below 360 degrees or 999.9 for unknown.', reference);
            payloadLength = 3 + ...
                5 + ...
                1 + ...
                5 + ...
                7 + ...
                5 + ...
                6 + ...
                12 + ...
                15 + ...
                5 + ...
                3 + ...
                9 + ...
                3 + ...
                6 + ...
                12 + ...
                5 + ...
                5;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.angle_to_north, 3, 0, false, true, false)];
            data = [data treNumber(obj.mean_gsd, 5, 1, false, true, false)];
            data = [data uint8('1')];
            data = [data treNumber(obj.dynamic_range, 5, 0, false, true, false)];
            data = [data uint8('       ')];
            data = [data treNumber(obj.obl_ang, 5, 2, false, true, false)];
            data = [data treNumber(obj.roll_ang, 6, 2, true, true, false)];
            data = [data textField(obj.prime_id, 12)];
            data = [data textField(obj.prime_be, 15)];
            data = [data uint8('     ')];
            data = [data treNumber(obj.n_sec, 3, 0, false, false, false)];
            data = [data uint8('  0000001')];
            data = [data treNumber(obj.n_seg, 3, 0, false, false, false)];
            data = [data treNumber(obj.max_lp_seg, 6, 0, false, true, false)];
            data = [data uint8('            ')];
            data = [data sunElevationNumber(obj.sun_el)];
            data = [data treNumber(obj.sun_az, 5, 1, false, false, false)];
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
            obj = nfx.EXOPTA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.number(3, 0, 359, ...
                true, true);
            if reader.ok, obj.angle_to_north = value; end
            [value, reader] = reader.number(5, 0, 999.9, ...
                false, true);
            if reader.ok, obj.mean_gsd = value; end
            reader = reader.literal('1');
            [value, reader] = reader.number(5, 0, 65535, ...
                true, true);
            if reader.ok, obj.dynamic_range = value; end
            reader = reader.literal('       ');
            [value, reader] = reader.number(5, 0, 90, ...
                false, true);
            if reader.ok, obj.obl_ang = value; end
            [value, reader] = reader.number(6, -90, 90, ...
                false, true);
            if reader.ok, obj.roll_ang = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.prime_id = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.prime_be = value; end
            reader = reader.literal('     ');
            [value, reader] = reader.number(3, 0, 250, ...
                true, false);
            if reader.ok, obj.n_sec = value; end
            reader = reader.literal('  0000001');
            [value, reader] = reader.number(3, 1, 999, ...
                true, false);
            if reader.ok, obj.n_seg = value; end
            [value, reader] = reader.number(6, 1, 199999, ...
                true, true);
            if reader.ok, obj.max_lp_seg = value; end
            reader = reader.literal('            ');
            [value, reader] = reader.number(5, -90, 999.9, ...
                false, false);
            if reader.ok, obj.sun_el = value; end
            [value, reader] = reader.number(5, 0, 999.9, ...
                false, false);
            if reader.ok, obj.sun_az = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.EXOPTA());
        end
    end
end
