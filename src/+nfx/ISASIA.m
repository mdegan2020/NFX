classdef (Sealed) ISASIA < nfx.TRE
    %ISASIA - Inverse radar sensor information
    %   OBJ = ISASIA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ISASIA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ISASIA properties:
    %       cetag - Constant tag identifier
    %       snsr_lat - SNSR_LAT metadata
    %       snsr_lon - SNSR_LON metadata
    %       snsr_hgt - SNSR_HGT metadata
    %       snsr_n_vel - SNSR_N_VEL metadata
    %       snsr_e_vel - SNSR_E_VEL metadata
    %       snsr_d_vel - SNSR_D_VEL metadata
    %       snsr_lat_err - SNSR_LAT_ERR metadata
    %       snsr_lon_err - SNSR_LON_ERR metadata
    %       snsr_hgt_err - SNSR_HGT_ERR metadata
    %       snsr_n_vel_err - SNSR_N_VEL_ERR metadata
    %       snsr_e_vel_err - SNSR_E_VEL_ERR metadata
    %       snsr_d_vel_err - SNSR_D_VEL_ERR metadata
    %       snsr_roll - SNSR_ROLL metadata
    %       snsr_pitch - SNSR_PITCH metadata
    %       snsr_yaw - SNSR_YAW metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ISASIA' % Registered tag identifier
    end
    properties
        % SNSR_LAT metadata
        snsr_lat {mustBeMetadata(snsr_lat, ...
            -90, 90, 0)} = NaN
        % SNSR_LON metadata
        snsr_lon {mustBeMetadata(snsr_lon, ...
            -180, 180, 0)} = NaN
        % SNSR_HGT metadata
        snsr_hgt {mustBeMetadata(snsr_hgt, ...
            -999.999, 99999.999, 0)} = NaN
        % SNSR_N_VEL metadata
        snsr_n_vel {mustBeMetadata(snsr_n_vel, ...
            -999.999, 99999.999, 0)} = NaN
        % SNSR_E_VEL metadata
        snsr_e_vel {mustBeMetadata(snsr_e_vel, ...
            -999.999, 99999.999, 0)} = NaN
        % SNSR_D_VEL metadata
        snsr_d_vel {mustBeMetadata(snsr_d_vel, ...
            -999.999, 99999.999, 0)} = NaN
        % SNSR_LAT_ERR metadata
        snsr_lat_err {mustBeMetadata(snsr_lat_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_LON_ERR metadata
        snsr_lon_err {mustBeMetadata(snsr_lon_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_HGT_ERR metadata
        snsr_hgt_err {mustBeMetadata(snsr_hgt_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_N_VEL_ERR metadata
        snsr_n_vel_err {mustBeMetadata(snsr_n_vel_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_E_VEL_ERR metadata
        snsr_e_vel_err {mustBeMetadata(snsr_e_vel_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_D_VEL_ERR metadata
        snsr_d_vel_err {mustBeMetadata(snsr_d_vel_err, ...
            0, 9999.999, 0)} = NaN
        % SNSR_ROLL metadata
        snsr_roll {mustBeMetadata(snsr_roll, ...
            -180, 179.999, 0)} = NaN
        % SNSR_PITCH metadata
        snsr_pitch {mustBeMetadata(snsr_pitch, ...
            -180, 179.999, 0)} = NaN
        % SNSR_YAW metadata
        snsr_yaw {mustBeMetadata(snsr_yaw, ...
            -180, 179.999, 0)} = NaN
    end
    methods
        function obj = ISASIA(options) %#codegen
            arguments
                options.?nfx.ISASIA
            end
            if isfield(options, 'snsr_lat')
                obj.snsr_lat = options.snsr_lat;
            end
            if isfield(options, 'snsr_lon')
                obj.snsr_lon = options.snsr_lon;
            end
            if isfield(options, 'snsr_hgt')
                obj.snsr_hgt = options.snsr_hgt;
            end
            if isfield(options, 'snsr_n_vel')
                obj.snsr_n_vel = options.snsr_n_vel;
            end
            if isfield(options, 'snsr_e_vel')
                obj.snsr_e_vel = options.snsr_e_vel;
            end
            if isfield(options, 'snsr_d_vel')
                obj.snsr_d_vel = options.snsr_d_vel;
            end
            if isfield(options, 'snsr_lat_err')
                obj.snsr_lat_err = options.snsr_lat_err;
            end
            if isfield(options, 'snsr_lon_err')
                obj.snsr_lon_err = options.snsr_lon_err;
            end
            if isfield(options, 'snsr_hgt_err')
                obj.snsr_hgt_err = options.snsr_hgt_err;
            end
            if isfield(options, 'snsr_n_vel_err')
                obj.snsr_n_vel_err = options.snsr_n_vel_err;
            end
            if isfield(options, 'snsr_e_vel_err')
                obj.snsr_e_vel_err = options.snsr_e_vel_err;
            end
            if isfield(options, 'snsr_d_vel_err')
                obj.snsr_d_vel_err = options.snsr_d_vel_err;
            end
            if isfield(options, 'snsr_roll')
                obj.snsr_roll = options.snsr_roll;
            end
            if isfield(options, 'snsr_pitch')
                obj.snsr_pitch = options.snsr_pitch;
            end
            if isfield(options, 'snsr_yaw')
                obj.snsr_yaw = options.snsr_yaw;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AX, Table AX-2 (2024-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.snsr_lat, 10, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_lat', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_lon, 11, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_lon', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_hgt, 10, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_hgt', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_n_vel, 10, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_n_vel', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_e_vel, 10, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_e_vel', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_d_vel, 10, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_d_vel', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_lat_err, 8, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_lat_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_lon_err, 8, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_lon_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_hgt_err, 8, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_hgt_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_n_vel_err, 8, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_n_vel_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_e_vel_err, 8, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_e_vel_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_d_vel_err, 8, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_d_vel_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_roll, 8, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_roll', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_pitch, 8, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_pitch', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snsr_yaw, 8, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'snsr_yaw', ...
                'Supply a value fitting the encoded precision.', reference);
            payloadLength = 10 + ...
                11 + ...
                10 + ...
                10 + ...
                10 + ...
                10 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                8;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.snsr_lat, 10, 6, true, false, false)];
            data = [data treNumber(obj.snsr_lon, 11, 6, true, false, false)];
            data = [data treNumber(obj.snsr_hgt, 10, 3, true, false, false)];
            data = [data treNumber(obj.snsr_n_vel, 10, 3, true, false, false)];
            data = [data treNumber(obj.snsr_e_vel, 10, 3, true, false, false)];
            data = [data treNumber(obj.snsr_d_vel, 10, 3, true, false, false)];
            data = [data treNumber(obj.snsr_lat_err, 8, 3, false, false, false)];
            data = [data treNumber(obj.snsr_lon_err, 8, 3, false, false, false)];
            data = [data treNumber(obj.snsr_hgt_err, 8, 3, false, false, false)];
            data = [data treNumber(obj.snsr_n_vel_err, 8, 3, false, true, false)];
            data = [data treNumber(obj.snsr_e_vel_err, 8, 3, false, true, false)];
            data = [data treNumber(obj.snsr_d_vel_err, 8, 3, false, true, false)];
            data = [data treNumber(obj.snsr_roll, 8, 3, true, true, false)];
            data = [data treNumber(obj.snsr_pitch, 8, 3, true, true, false)];
            data = [data treNumber(obj.snsr_yaw, 8, 3, true, true, false)];
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
            obj = nfx.ISASIA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(10, -90, 90, ...
                false, false);
            if reader.ok, obj.snsr_lat = value; end
            [value, reader] = reader.number(11, -180, 180, ...
                false, false);
            if reader.ok, obj.snsr_lon = value; end
            [value, reader] = reader.number(10, -999.999, 99999.999, ...
                false, false);
            if reader.ok, obj.snsr_hgt = value; end
            [value, reader] = reader.number(10, -999.999, 99999.999, ...
                false, false);
            if reader.ok, obj.snsr_n_vel = value; end
            [value, reader] = reader.number(10, -999.999, 99999.999, ...
                false, false);
            if reader.ok, obj.snsr_e_vel = value; end
            [value, reader] = reader.number(10, -999.999, 99999.999, ...
                false, false);
            if reader.ok, obj.snsr_d_vel = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, false);
            if reader.ok, obj.snsr_lat_err = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, false);
            if reader.ok, obj.snsr_lon_err = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, false);
            if reader.ok, obj.snsr_hgt_err = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, true);
            if reader.ok, obj.snsr_n_vel_err = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, true);
            if reader.ok, obj.snsr_e_vel_err = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, true);
            if reader.ok, obj.snsr_d_vel_err = value; end
            [value, reader] = reader.number(8, -180, 179.999, ...
                false, true);
            if reader.ok, obj.snsr_roll = value; end
            [value, reader] = reader.number(8, -180, 179.999, ...
                false, true);
            if reader.ok, obj.snsr_pitch = value; end
            [value, reader] = reader.number(8, -180, 179.999, ...
                false, true);
            if reader.ok, obj.snsr_yaw = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ISASIA());
        end
    end
end
