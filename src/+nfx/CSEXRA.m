classdef (Sealed) CSEXRA < nfx.TRE
    %CSEXRA - Commercial exploitation reference metadata
    %   OBJ = CSEXRA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   CSEXRA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   CSEXRA properties:
    %       cetag - Constant tag identifier
    %       sensor - SENSOR metadata
    %       time_first_line_image - TIME_FIRST_LINE_IMAGE metadata
    %       time_image_duration - TIME_IMAGE_DURATION metadata
    %       max_gsd - MAX_GSD metadata
    %       along_scan_gsd - ALONG_SCAN_GSD metadata
    %       cross_scan_gsd - CROSS_SCAN_GSD metadata
    %       geo_mean_gsd - GEO_MEAN_GSD metadata
    %       a_s_vert_gsd - A_S_VERT_GSD metadata
    %       c_s_vert_gsd - C_S_VERT_GSD metadata
    %       geo_mean_vert_gsd - GEO_MEAN_VERT_GSD metadata
    %       gsd_beta_angle - GSD_BETA_ANGLE metadata
    %       dynamic_range - DYNAMIC_RANGE metadata
    %       num_lines - NUM_LINES metadata
    %       num_samples - NUM_SAMPLES metadata
    %       angle_to_north - ANGLE_TO_NORTH metadata
    %       obliquity_angle - OBLIQUITY_ANGLE metadata
    %       az_of_obliquity - AZ_OF_OBLIQUITY metadata
    %       grd_cover - GRD_COVER metadata
    %       snow_depth_cat - SNOW_DEPTH_CAT metadata
    %       sun_azimuth - SUN_AZIMUTH metadata
    %       sun_elevation - SUN_ELEVATION metadata
    %       predicted_niirs - PREDICTED_NIIRS metadata
    %       circl_err - CIRCL_ERR metadata
    %       linear_err - LINEAR_ERR metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'CSEXRA' % Registered tag identifier
    end
    properties
        sensor {mustBeAscii(sensor, 6)} = '' % SENSOR metadata
        % TIME_FIRST_LINE_IMAGE metadata
        time_first_line_image {mustBeMetadata(time_first_line_image, ...
            0, 86400, 0)} = NaN
        % TIME_IMAGE_DURATION metadata
        time_image_duration {mustBeMetadata(time_image_duration, ...
            -9999.999999, 86400, 0)} = NaN
        % MAX_GSD metadata
        max_gsd {mustBeMetadata(max_gsd, ...
            0, 99999, 0)} = NaN
        % ALONG_SCAN_GSD metadata
        along_scan_gsd {mustBeMetadata(along_scan_gsd, ...
            0, 99999, 0)} = NaN
        % CROSS_SCAN_GSD metadata
        cross_scan_gsd {mustBeMetadata(cross_scan_gsd, ...
            0, 99999, 0)} = NaN
        % GEO_MEAN_GSD metadata
        geo_mean_gsd {mustBeMetadata(geo_mean_gsd, ...
            0, 99999, 0)} = NaN
        % A_S_VERT_GSD metadata
        a_s_vert_gsd {mustBeMetadata(a_s_vert_gsd, ...
            0, 999.9, 0)} = NaN
        % C_S_VERT_GSD metadata
        c_s_vert_gsd {mustBeMetadata(c_s_vert_gsd, ...
            0, 999.9, 0)} = NaN
        % GEO_MEAN_VERT_GSD metadata
        geo_mean_vert_gsd {mustBeMetadata(geo_mean_vert_gsd, ...
            0, 999.9, 0)} = NaN
        % GSD_BETA_ANGLE metadata
        gsd_beta_angle {mustBeMetadata(gsd_beta_angle, ...
            0, 999.9, 0)} = NaN
        % DYNAMIC_RANGE metadata
        dynamic_range {mustBeMetadata(dynamic_range, ...
            0, 99999, 1)} = NaN
        % NUM_LINES metadata
        num_lines {mustBeMetadata(num_lines, ...
            101, 9999999, 1)} = NaN
        % NUM_SAMPLES metadata
        num_samples {mustBeMetadata(num_samples, ...
            101, 99999, 1)} = NaN
        % ANGLE_TO_NORTH metadata
        angle_to_north {mustBeMetadata(angle_to_north, ...
            0, 360, 0)} = NaN
        % OBLIQUITY_ANGLE metadata
        obliquity_angle {mustBeMetadata(obliquity_angle, ...
            0, 90, 0)} = NaN
        % AZ_OF_OBLIQUITY metadata
        az_of_obliquity {mustBeMetadata(az_of_obliquity, ...
            0, 360, 0)} = NaN
        % GRD_COVER metadata
        grd_cover {mustBeMetadata(grd_cover, ...
            0, 9, 1)} = NaN
        % SNOW_DEPTH_CAT metadata
        snow_depth_cat {mustBeMetadata(snow_depth_cat, ...
            0, 9, 1)} = NaN
        % SUN_AZIMUTH metadata
        sun_azimuth {mustBeMetadata(sun_azimuth, ...
            0, 360, 0)} = NaN
        % SUN_ELEVATION metadata
        sun_elevation {mustBeMetadata(sun_elevation, ...
            -90, 90, 0)} = NaN
        % PREDICTED_NIIRS metadata
        predicted_niirs {mustBeMetadata(predicted_niirs, ...
            0, 9, 0)} = NaN
        % CIRCL_ERR metadata
        circl_err {mustBeMetadata(circl_err, ...
            0, 999, 1)} = NaN
        % LINEAR_ERR metadata
        linear_err {mustBeMetadata(linear_err, ...
            0, 999, 1)} = NaN
    end
    methods
        function obj = CSEXRA(options) %#codegen
            arguments
                options.?nfx.CSEXRA
            end
            if isfield(options, 'sensor')
                obj.sensor = options.sensor;
            end
            if isfield(options, 'time_first_line_image')
                obj.time_first_line_image = options.time_first_line_image;
            end
            if isfield(options, 'time_image_duration')
                obj.time_image_duration = options.time_image_duration;
            end
            if isfield(options, 'max_gsd')
                obj.max_gsd = options.max_gsd;
            end
            if isfield(options, 'along_scan_gsd')
                obj.along_scan_gsd = options.along_scan_gsd;
            end
            if isfield(options, 'cross_scan_gsd')
                obj.cross_scan_gsd = options.cross_scan_gsd;
            end
            if isfield(options, 'geo_mean_gsd')
                obj.geo_mean_gsd = options.geo_mean_gsd;
            end
            if isfield(options, 'a_s_vert_gsd')
                obj.a_s_vert_gsd = options.a_s_vert_gsd;
            end
            if isfield(options, 'c_s_vert_gsd')
                obj.c_s_vert_gsd = options.c_s_vert_gsd;
            end
            if isfield(options, 'geo_mean_vert_gsd')
                obj.geo_mean_vert_gsd = options.geo_mean_vert_gsd;
            end
            if isfield(options, 'gsd_beta_angle')
                obj.gsd_beta_angle = options.gsd_beta_angle;
            end
            if isfield(options, 'dynamic_range')
                obj.dynamic_range = options.dynamic_range;
            end
            if isfield(options, 'num_lines')
                obj.num_lines = options.num_lines;
            end
            if isfield(options, 'num_samples')
                obj.num_samples = options.num_samples;
            end
            if isfield(options, 'angle_to_north')
                obj.angle_to_north = options.angle_to_north;
            end
            if isfield(options, 'obliquity_angle')
                obj.obliquity_angle = options.obliquity_angle;
            end
            if isfield(options, 'az_of_obliquity')
                obj.az_of_obliquity = options.az_of_obliquity;
            end
            if isfield(options, 'grd_cover')
                obj.grd_cover = options.grd_cover;
            end
            if isfield(options, 'snow_depth_cat')
                obj.snow_depth_cat = options.snow_depth_cat;
            end
            if isfield(options, 'sun_azimuth')
                obj.sun_azimuth = options.sun_azimuth;
            end
            if isfield(options, 'sun_elevation')
                obj.sun_elevation = options.sun_elevation;
            end
            if isfield(options, 'predicted_niirs')
                obj.predicted_niirs = options.predicted_niirs;
            end
            if isfield(options, 'circl_err')
                obj.circl_err = options.circl_err;
            end
            if isfield(options, 'linear_err')
                obj.linear_err = options.linear_err;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix D, Table D-4 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.sensor))), ...
                'Required', 'sensor', 'Supply SENSOR.', reference);
            [~, valid] = treNumber(obj.time_first_line_image, 12, 6, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'time_first_line_image', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.time_image_duration, 12, 6, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'time_image_duration', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.max_gsd, false);
            report = addIssue(report, ~valid, 'Encoding', 'max_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.along_scan_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'along_scan_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.cross_scan_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'cross_scan_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.geo_mean_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'geo_mean_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.a_s_vert_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'a_s_vert_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.c_s_vert_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'c_s_vert_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.geo_mean_vert_gsd, true);
            report = addIssue(report, ~valid, 'Encoding', 'geo_mean_vert_gsd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = commercialGSDNumber(obj.gsd_beta_angle, true);
            report = addIssue(report, ~valid, 'Encoding', 'gsd_beta_angle', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dynamic_range, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'dynamic_range', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.num_lines, 7, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'num_lines', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.num_samples, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'num_samples', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = markedNumber(obj.angle_to_north, 7, 3, '-------');
            report = addIssue(report, ~valid, 'Encoding', 'angle_to_north', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.obliquity_angle, 6, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'obliquity_angle', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.az_of_obliquity, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'az_of_obliquity', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.grd_cover, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'grd_cover', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.snow_depth_cat, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'snow_depth_cat', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sun_azimuth, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'sun_azimuth', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sun_elevation, 7, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'sun_elevation', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = markedNumber(obj.predicted_niirs, 3, 1, 'N/A');
            report = addIssue(report, ~valid, 'Encoding', 'predicted_niirs', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.circl_err, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'circl_err', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.linear_err, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'linear_err', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ~any(obj.grd_cover == [0 1 9]), ...
                'Metadata', 'grd_cover', 'Use 0, 1 or 9.', reference);
            report = addIssue(report, ~any(obj.snow_depth_cat == [0 1 2 3 9]), ...
                'Metadata', 'snow_depth_cat', 'Use 0 to 3 or 9.', reference);
            payloadLength = 6 + ...
                12 + ...
                12 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                7 + ...
                5 + ...
                7 + ...
                6 + ...
                7 + ...
                1 + ...
                1 + ...
                7 + ...
                7 + ...
                3 + ...
                3 + ...
                3;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.sensor, 6)];
            data = [data treNumber(obj.time_first_line_image, 12, 6, false, false, false)];
            data = [data treNumber(obj.time_image_duration, 12, 6, false, false, false)];
            data = [data commercialGSDNumber(obj.max_gsd, false)];
            data = [data commercialGSDNumber(obj.along_scan_gsd, true)];
            data = [data commercialGSDNumber(obj.cross_scan_gsd, true)];
            data = [data commercialGSDNumber(obj.geo_mean_gsd, true)];
            data = [data commercialGSDNumber(obj.a_s_vert_gsd, true)];
            data = [data commercialGSDNumber(obj.c_s_vert_gsd, true)];
            data = [data commercialGSDNumber(obj.geo_mean_vert_gsd, true)];
            data = [data commercialGSDNumber(obj.gsd_beta_angle, true)];
            data = [data treNumber(obj.dynamic_range, 5, 0, false, false, false)];
            data = [data treNumber(obj.num_lines, 7, 0, false, false, false)];
            data = [data treNumber(obj.num_samples, 5, 0, false, false, false)];
            data = [data markedNumber(obj.angle_to_north, 7, 3, '-------')];
            data = [data treNumber(obj.obliquity_angle, 6, 3, false, false, false)];
            data = [data treNumber(obj.az_of_obliquity, 7, 3, false, false, false)];
            data = [data treNumber(obj.grd_cover, 1, 0, false, false, false)];
            data = [data treNumber(obj.snow_depth_cat, 1, 0, false, false, false)];
            data = [data treNumber(obj.sun_azimuth, 7, 3, false, false, false)];
            data = [data treNumber(obj.sun_elevation, 7, 3, true, false, false)];
            data = [data markedNumber(obj.predicted_niirs, 3, 1, 'N/A')];
            data = [data treNumber(obj.circl_err, 3, 0, false, false, false)];
            data = [data treNumber(obj.linear_err, 3, 0, false, false, false)];
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
            obj = nfx.CSEXRA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(6, true, false);
            if reader.ok, obj.sensor = value; end
            [value, reader] = reader.number(12, 0, 86400, ...
                false, false);
            if reader.ok, obj.time_first_line_image = value; end
            [value, reader] = reader.number(12, -9999.999999, 86400, ...
                false, false);
            if reader.ok, obj.time_image_duration = value; end
            [value, reader] = reader.number(5, 0, 99999, ...
                false, false);
            if reader.ok, obj.max_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 99999, false);
            if reader.ok, obj.along_scan_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 99999, false);
            if reader.ok, obj.cross_scan_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 99999, false);
            if reader.ok, obj.geo_mean_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 999.9, false);
            if reader.ok, obj.a_s_vert_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 999.9, false);
            if reader.ok, obj.c_s_vert_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 999.9, false);
            if reader.ok, obj.geo_mean_vert_gsd = value; end
            [value, reader] = readMarkedNumber(reader, 5, 'N/A  ', 0, 999.9, false);
            if reader.ok, obj.gsd_beta_angle = value; end
            [value, reader] = reader.number(5, 0, 99999, ...
                true, false);
            if reader.ok, obj.dynamic_range = value; end
            [value, reader] = reader.number(7, 101, 9999999, ...
                true, false);
            if reader.ok, obj.num_lines = value; end
            [value, reader] = reader.number(5, 101, 99999, ...
                true, false);
            if reader.ok, obj.num_samples = value; end
            [value, reader] = readMarkedNumber(reader, 7, '-------', 0, 360, false);
            if reader.ok, obj.angle_to_north = value; end
            [value, reader] = reader.number(6, 0, 90, ...
                false, false);
            if reader.ok, obj.obliquity_angle = value; end
            [value, reader] = reader.number(7, 0, 360, ...
                false, false);
            if reader.ok, obj.az_of_obliquity = value; end
            [value, reader] = reader.number(1, 0, 9, ...
                true, false);
            if reader.ok, obj.grd_cover = value; end
            [value, reader] = reader.number(1, 0, 9, ...
                true, false);
            if reader.ok, obj.snow_depth_cat = value; end
            [value, reader] = reader.number(7, 0, 360, ...
                false, false);
            if reader.ok, obj.sun_azimuth = value; end
            [value, reader] = reader.number(7, -90, 90, ...
                false, false);
            if reader.ok, obj.sun_elevation = value; end
            [value, reader] = readMarkedNumber(reader, 3, 'N/A', 0, 9, false);
            if reader.ok, obj.predicted_niirs = value; end
            [value, reader] = reader.number(3, 0, 999, ...
                true, false);
            if reader.ok, obj.circl_err = value; end
            [value, reader] = reader.number(3, 0, 999, ...
                true, false);
            if reader.ok, obj.linear_err = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSEXRA());
        end
    end
end
