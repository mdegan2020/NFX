classdef (Sealed) SENSRB < nfx.TRE
    %SENSRB - Describe a sensor with static and dynamic metadata
    %   OBJ = SENSRB(Name=VALUE) accepts specification-mnemonic fields.
    %   General, reference, and position data are required. Optional modules
    %   appear when their fields are supplied. [] omits a numeric field;
    %   NaN represents an unknown value where the standard permits it.
    %   A documented compatibility exception permits omitted velocity for
    %   Pushbroom and Whiskbroom at CONTENT_LEVEL=8. Other prerequisites
    %   remain enforced; this exception deviates from Table Z.5.1-1.
    %
    %   timeSeries, pixelSeries, pointSet, uncertainty, and
    %   additionalParameter construct the repeating data groups. Counts
    %   derive from the arrays. TIME_STAMP_TIME is always relative to
    %   START_TIME. Sample order and duplicate times are preserved.
    %
    %   physicalRecords returns one or more complete payload snapshots.
    %   Module 12 automatically continues in further SENSRB instances.
    %   Attaching OBJ with + captures the group under one removable ID.
    %   payload, bytes, and cel require a single physical instance.
    %
    %   Registry labels and scientific values come from the caller. This
    %   class validates serialization and declared content prerequisites;
    %   it does not estimate, interpolate, or fit sensor measurements.
    %
    %   See also TRE, ImageSegment, FSYNWA

    properties (Constant)
        cetag = 'SENSRB'
    end
    properties
        sensor {mustBeAscii(sensor,25)} = ''
        sensor_uri {mustBeAscii(sensor_uri,32)} = ''
        platform {mustBeAscii(platform,25)} = ''
        platform_uri {mustBeAscii(platform_uri,32)} = ''
        operation_domain {mustBeAscii(operation_domain,10)} = ''
        content_level {mustBeMetadata(content_level,0,9,1)} = 0
        geodetic_system {mustBeAscii(geodetic_system,5)} = 'WGS84'
        geodetic_type {mustBeAscii(geodetic_type,1)} = 'G'
        elevation_datum {mustBeAscii(elevation_datum,3)} = 'HAE'
        length_unit {mustBeAscii(length_unit,2)} = 'SI'
        angular_unit {mustBeAscii(angular_unit,3)} = 'DEG'
        start_date {mustBeAscii(start_date,8)} = ''
        start_time {mustBeMetadata(start_time,0,86399.99999999,0)} = NaN
        end_date {mustBeAscii(end_date,8)} = ''
        end_time {mustBeMetadata(end_time,0,86399.99999999,0)} = NaN
        generation_count {mustBeMetadata(generation_count,0,99,1)} = 0
        generation_date {mustBeAscii(generation_date,8)} = ''
        generation_time {mustBeAscii(generation_time,10)} = ''
        detection {mustBeAscii(detection,20)} = ''
        row_detectors {mustBeSensorNumber} = []
        column_detectors {mustBeSensorNumber} = []
        row_metric {mustBeSensorNumber} = []
        column_metric {mustBeSensorNumber} = []
        focal_length {mustBeSensorNumber} = []
        row_fov {mustBeSensorNumber} = []
        column_fov {mustBeSensorNumber} = []
        calibrated {mustBeAscii(calibrated,1)} = ''
        calibration_unit {mustBeAscii(calibration_unit,2)} = ''
        principal_point_offset_x {mustBeSensorNumber} = []
        principal_point_offset_y {mustBeSensorNumber} = []
        radial_distort_1 {mustBeSensorNumber} = []
        radial_distort_2 {mustBeSensorNumber} = []
        radial_distort_3 {mustBeSensorNumber} = []
        radial_distort_limit {mustBeSensorNumber} = []
        decent_distort_1 {mustBeSensorNumber} = []
        decent_distort_2 {mustBeSensorNumber} = []
        affinity_distort_1 {mustBeSensorNumber} = []
        affinity_distort_2 {mustBeSensorNumber} = []
        calibration_date {mustBeAscii(calibration_date,8)} = ''
        method {mustBeAscii(method,15)} = ''
        mode {mustBeAscii(mode,3)} = ''
        row_count {mustBeSensorNumber} = []
        column_count {mustBeSensorNumber} = []
        row_set {mustBeSensorNumber} = []
        column_set {mustBeSensorNumber} = []
        row_rate {mustBeSensorNumber} = []
        column_rate {mustBeSensorNumber} = []
        first_pixel_row {mustBeSensorNumber} = []
        first_pixel_column {mustBeSensorNumber} = []
        reference_time {mustBeSensorNumber} = []
        reference_row {mustBeSensorNumber} = []
        reference_column {mustBeSensorNumber} = []
        latitude_or_x {mustBeSensorNumber} = []
        longitude_or_y {mustBeSensorNumber} = []
        altitude_or_z {mustBeSensorNumber} = []
        sensor_x_offset {mustBeSensorNumber} = 0
        sensor_y_offset {mustBeSensorNumber} = 0
        sensor_z_offset {mustBeSensorNumber} = 0
        sensor_angle_model {mustBeSensorNumber} = []
        sensor_angle_1 {mustBeSensorNumber} = []
        sensor_angle_2 {mustBeSensorNumber} = []
        sensor_angle_3 {mustBeSensorNumber} = []
        platform_relative {mustBeAscii(platform_relative,1)} = ''
        platform_heading {mustBeSensorNumber} = []
        platform_pitch {mustBeSensorNumber} = []
        platform_roll {mustBeSensorNumber} = []
        icx_north_or_x {mustBeSensorNumber} = []
        icx_east_or_y {mustBeSensorNumber} = []
        icx_down_or_z {mustBeSensorNumber} = []
        icy_north_or_x {mustBeSensorNumber} = []
        icy_east_or_y {mustBeSensorNumber} = []
        icy_down_or_z {mustBeSensorNumber} = []
        icz_north_or_x {mustBeSensorNumber} = []
        icz_east_or_y {mustBeSensorNumber} = []
        icz_down_or_z {mustBeSensorNumber} = []
        attitude_q1 {mustBeSensorNumber} = []
        attitude_q2 {mustBeSensorNumber} = []
        attitude_q3 {mustBeSensorNumber} = []
        attitude_q4 {mustBeSensorNumber} = []
        velocity_north_or_x {mustBeSensorNumber} = []
        velocity_east_or_y {mustBeSensorNumber} = []
        velocity_down_or_z {mustBeSensorNumber} = []
        transform_param {mustBeTransform} = zeros(1,0)
        point_data {mustBePoints} = struct('point_set_type',{},'p_row',{},'p_column',{},'p_latitude',{},'p_longitude',{},'p_elevation',{},'p_range',{})
        time_stamped_data {mustBeTimeSeries} = struct('time_stamp_type',{},'time_stamp_time',{},'time_stamp_value',{})
        pixel_referenced_data {mustBePixelSeries} = struct('pixel_reference_type',{},'pixel_reference_row',{},'pixel_reference_column',{},'pixel_reference_value',{})
        uncertainty_data {mustBeUncertainty} = struct('uncertainty_first_type',{},'uncertainty_second_type',{},'uncertainty_value',{})
        additional_parameter_data {mustBeAdditional} = struct('parameter_name',{},'parameter_size',{},'parameter_value',{})
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode one complete SENSRB payload
            %   [OBJ, OK, STATUS] = nfx.SENSRB.deserialize(PAYLOAD)
            %   returns an independent scalar value. Failure returns the
            %   default scalar and OK=false. Use deserializeRecords for
            %   a logical attachment containing continuation instances.
            %
            %   See also SENSRB.deserializeRecords, SENSRB.physicalRecords
            arguments
                data
            end
            reader = nfx.internal.TREReader(data);
            if ~reader.ok
                obj = nfx.SENSRB();
                ok = false;
                status = decodeStatus(reader.code, ...
                    reader.message, reader.position);
                return
            end
            records = struct('tag', 'SENSRB', 'payload', data);
            [obj, ok, status] = nfx.SENSRB.deserializeRecords(records);
        end

        function [obj, ok, status] = deserializeRecords(records) %#codegen
            %deserializeRecords - Reconstruct a logical sensor attachment
            %   [OBJ, OK, STATUS] = deserializeRecords(RECORDS) accepts
            %   physical records in their stored order. Every continuation
            %   must have the minimum repeated reference/position payload.
            %   Encoded time-series chunks remain ordered groups; original
            %   boundaries within split input groups are not on the wire.
            %
            %   See also SENSRB.deserialize, ImageSegment.SENSRB
            arguments
                records
            end
            obj = nfx.SENSRB();
            ok = false;
            status = decodeStatus('InvalidPayload', ...
                'Supply a nonempty row of SENSRB tag/payload records.');
            if ~isstruct(records) || ~isrow(records) || isempty(records) || ...
                    ~all(isfield(records, {'tag', 'payload'}))
                return
            end
            for k = 1:numel(records)
                if ~ischar(records(k).tag) || ...
                        ~strcmp(records(k).tag, 'SENSRB')
                    return
                end
            end
            [obj, reader] = readSensorPayload( ...
                records(1).payload, 'G', 'DEG', false);
            for k = 2:numel(records)
                if ~reader.ok
                    break
                end
                [part, child] = readSensorPayload(records(k).payload, ...
                    obj.geodetic_type, obj.angular_unit, true);
                if ~child.ok
                    reader = reader.fail(child.code, child.message);
                    break
                end
                obj.time_stamped_data = ...
                    [obj.time_stamped_data part.time_stamped_data];
            end
            if reader.ok
                [encoded, report] = encodeSensor(obj);
                if ~report.valid
                    reader = reader.fail('InvalidMetadata', ...
                        report.issues(1).message);
                elseif numel(encoded) ~= numel(records)
                    reader = reader.fail('InvalidContinuation', ...
                        'Sensor instances do not form one encoded group.');
                else
                    for k = 1:numel(records)
                        if ~isequal(encoded(k).payload, records(k).payload)
                            reader = reader.fail('NoncanonicalPayload', ...
                                'Sensor data or continuation context differs.');
                            break
                        end
                    end
                end
            end
            ok = reader.ok;
            if ok
                status = decodeStatus();
            else
                obj = nfx.SENSRB();
                status = decodeStatus(reader.code, ...
                    reader.message, reader.position);
            end
        end
    end
    methods
        function obj = SENSRB(options) %#codegen
            %SENSRB - Construct editable sensor metadata
            arguments
                options.?nfx.SENSRB
            end
            if isfield(options,'sensor'), obj.sensor = options.sensor; end
            if isfield(options,'sensor_uri'), obj.sensor_uri = options.sensor_uri; end
            if isfield(options,'platform'), obj.platform = options.platform; end
            if isfield(options,'platform_uri'), obj.platform_uri = options.platform_uri; end
            if isfield(options,'operation_domain'), obj.operation_domain = options.operation_domain; end
            if isfield(options,'content_level'), obj.content_level = options.content_level; end
            if isfield(options,'geodetic_system'), obj.geodetic_system = options.geodetic_system; end
            if isfield(options,'geodetic_type'), obj.geodetic_type = options.geodetic_type; end
            if isfield(options,'elevation_datum'), obj.elevation_datum = options.elevation_datum; end
            if isfield(options,'length_unit'), obj.length_unit = options.length_unit; end
            if isfield(options,'angular_unit'), obj.angular_unit = options.angular_unit; end
            if isfield(options,'start_date'), obj.start_date = options.start_date; end
            if isfield(options,'start_time'), obj.start_time = options.start_time; end
            if isfield(options,'end_date'), obj.end_date = options.end_date; end
            if isfield(options,'end_time'), obj.end_time = options.end_time; end
            if isfield(options,'generation_count'), obj.generation_count = options.generation_count; end
            if isfield(options,'generation_date'), obj.generation_date = options.generation_date; end
            if isfield(options,'generation_time'), obj.generation_time = options.generation_time; end
            if isfield(options,'detection'), obj.detection = options.detection; end
            if isfield(options,'row_detectors'), obj.row_detectors = options.row_detectors; end
            if isfield(options,'column_detectors'), obj.column_detectors = options.column_detectors; end
            if isfield(options,'row_metric'), obj.row_metric = options.row_metric; end
            if isfield(options,'column_metric'), obj.column_metric = options.column_metric; end
            if isfield(options,'focal_length'), obj.focal_length = options.focal_length; end
            if isfield(options,'row_fov'), obj.row_fov = options.row_fov; end
            if isfield(options,'column_fov'), obj.column_fov = options.column_fov; end
            if isfield(options,'calibrated'), obj.calibrated = options.calibrated; end
            if isfield(options,'calibration_unit'), obj.calibration_unit = options.calibration_unit; end
            if isfield(options,'principal_point_offset_x'), obj.principal_point_offset_x = options.principal_point_offset_x; end
            if isfield(options,'principal_point_offset_y'), obj.principal_point_offset_y = options.principal_point_offset_y; end
            if isfield(options,'radial_distort_1'), obj.radial_distort_1 = options.radial_distort_1; end
            if isfield(options,'radial_distort_2'), obj.radial_distort_2 = options.radial_distort_2; end
            if isfield(options,'radial_distort_3'), obj.radial_distort_3 = options.radial_distort_3; end
            if isfield(options,'radial_distort_limit'), obj.radial_distort_limit = options.radial_distort_limit; end
            if isfield(options,'decent_distort_1'), obj.decent_distort_1 = options.decent_distort_1; end
            if isfield(options,'decent_distort_2'), obj.decent_distort_2 = options.decent_distort_2; end
            if isfield(options,'affinity_distort_1'), obj.affinity_distort_1 = options.affinity_distort_1; end
            if isfield(options,'affinity_distort_2'), obj.affinity_distort_2 = options.affinity_distort_2; end
            if isfield(options,'calibration_date'), obj.calibration_date = options.calibration_date; end
            if isfield(options,'method'), obj.method = options.method; end
            if isfield(options,'mode'), obj.mode = options.mode; end
            if isfield(options,'row_count'), obj.row_count = options.row_count; end
            if isfield(options,'column_count'), obj.column_count = options.column_count; end
            if isfield(options,'row_set'), obj.row_set = options.row_set; end
            if isfield(options,'column_set'), obj.column_set = options.column_set; end
            if isfield(options,'row_rate'), obj.row_rate = options.row_rate; end
            if isfield(options,'column_rate'), obj.column_rate = options.column_rate; end
            if isfield(options,'first_pixel_row'), obj.first_pixel_row = options.first_pixel_row; end
            if isfield(options,'first_pixel_column'), obj.first_pixel_column = options.first_pixel_column; end
            if isfield(options,'reference_time'), obj.reference_time = options.reference_time; end
            if isfield(options,'reference_row'), obj.reference_row = options.reference_row; end
            if isfield(options,'reference_column'), obj.reference_column = options.reference_column; end
            if isfield(options,'latitude_or_x'), obj.latitude_or_x = options.latitude_or_x; end
            if isfield(options,'longitude_or_y'), obj.longitude_or_y = options.longitude_or_y; end
            if isfield(options,'altitude_or_z'), obj.altitude_or_z = options.altitude_or_z; end
            if isfield(options,'sensor_x_offset'), obj.sensor_x_offset = options.sensor_x_offset; end
            if isfield(options,'sensor_y_offset'), obj.sensor_y_offset = options.sensor_y_offset; end
            if isfield(options,'sensor_z_offset'), obj.sensor_z_offset = options.sensor_z_offset; end
            if isfield(options,'sensor_angle_model'), obj.sensor_angle_model = options.sensor_angle_model; end
            if isfield(options,'sensor_angle_1'), obj.sensor_angle_1 = options.sensor_angle_1; end
            if isfield(options,'sensor_angle_2'), obj.sensor_angle_2 = options.sensor_angle_2; end
            if isfield(options,'sensor_angle_3'), obj.sensor_angle_3 = options.sensor_angle_3; end
            if isfield(options,'platform_relative'), obj.platform_relative = options.platform_relative; end
            if isfield(options,'platform_heading'), obj.platform_heading = options.platform_heading; end
            if isfield(options,'platform_pitch'), obj.platform_pitch = options.platform_pitch; end
            if isfield(options,'platform_roll'), obj.platform_roll = options.platform_roll; end
            if isfield(options,'icx_north_or_x'), obj.icx_north_or_x = options.icx_north_or_x; end
            if isfield(options,'icx_east_or_y'), obj.icx_east_or_y = options.icx_east_or_y; end
            if isfield(options,'icx_down_or_z'), obj.icx_down_or_z = options.icx_down_or_z; end
            if isfield(options,'icy_north_or_x'), obj.icy_north_or_x = options.icy_north_or_x; end
            if isfield(options,'icy_east_or_y'), obj.icy_east_or_y = options.icy_east_or_y; end
            if isfield(options,'icy_down_or_z'), obj.icy_down_or_z = options.icy_down_or_z; end
            if isfield(options,'icz_north_or_x'), obj.icz_north_or_x = options.icz_north_or_x; end
            if isfield(options,'icz_east_or_y'), obj.icz_east_or_y = options.icz_east_or_y; end
            if isfield(options,'icz_down_or_z'), obj.icz_down_or_z = options.icz_down_or_z; end
            if isfield(options,'attitude_q1'), obj.attitude_q1 = options.attitude_q1; end
            if isfield(options,'attitude_q2'), obj.attitude_q2 = options.attitude_q2; end
            if isfield(options,'attitude_q3'), obj.attitude_q3 = options.attitude_q3; end
            if isfield(options,'attitude_q4'), obj.attitude_q4 = options.attitude_q4; end
            if isfield(options,'velocity_north_or_x'), obj.velocity_north_or_x = options.velocity_north_or_x; end
            if isfield(options,'velocity_east_or_y'), obj.velocity_east_or_y = options.velocity_east_or_y; end
            if isfield(options,'velocity_down_or_z'), obj.velocity_down_or_z = options.velocity_down_or_z; end
            if isfield(options,'transform_param'), obj.transform_param = options.transform_param; end
            if isfield(options,'point_data'), obj.point_data = options.point_data; end
            if isfield(options,'time_stamped_data'), obj.time_stamped_data = options.time_stamped_data; end
            if isfield(options,'pixel_referenced_data'), obj.pixel_referenced_data = options.pixel_referenced_data; end
            if isfield(options,'uncertainty_data'), obj.uncertainty_data = options.uncertainty_data; end
            if isfield(options,'additional_parameter_data'), obj.additional_parameter_data = options.additional_parameter_data; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check fields, relationships and physical record limits
            [~,report] = encodeSensor(obj);
        end
        function value = physicalRecords(obj) %#codegen
            %PHYSICALRECORDS - Serialize the ordered continuation group
            %   VALUE is a row of tag/payload structs. Each payload fits
            %   the standard limit. Subsequent records retain the required
            %   reference and position fields and carry excess time series.
            [value,report] = encodeSensor(obj);
            requireValid(report);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize metadata that fits one physical SENSRB
            records = physicalRecords(obj);
            if numel(records) ~= 1
                error('nfx:MultipleTREs','Use physicalRecords or attach the logical SENSRB with +.');
            end
            value = records.payload;
        end
    end
    methods (Static)
        function value = timeSeries(type,time,samples) %#codegen
            %TIMESERIES - Construct a time-stamped parameter group
            %   VALUE = TIMESERIES(TYPE,TIME,SAMPLES) accepts a three-byte
            %   field index, a double row of times relative to START_TIME,
            %   and a double row or text rows of corresponding values.
            arguments
                type {mustBeAscii(type,3)}
                time {mustBeSensorRow}
                samples
            end
            info = sensFieldInfo(char(type),'G','DEG');
            if ~info.valid, error('nfx:SensorIndex','Use an index from 02a through 10c.'); end
            value = struct('time_stamp_type',char(type),'time_stamp_time',time, ...
                'time_stamp_value',sensValues(samples,info.width));
            mustBeTimeSeries(value);
        end
        function value = pixelSeries(type,row,column,samples) %#codegen
            %PIXELSERIES - Construct a pixel-referenced parameter group
            arguments
                type {mustBeAscii(type,3)}
                row {mustBeSensorRow}
                column {mustBeSensorRow}
                samples
            end
            info = sensFieldInfo(char(type),'G','DEG');
            if ~info.valid, error('nfx:SensorIndex','Use an index from 02a through 10c.'); end
            value = struct('pixel_reference_type',char(type),'pixel_reference_row',row, ...
                'pixel_reference_column',column,'pixel_reference_value',sensValues(samples,info.width));
            mustBePixelSeries(value);
        end
        function value = pointSet(type,row,column,options) %#codegen
            %POINTSET - Construct image points with optional ground locations
            arguments
                type {mustBeAscii(type,25)}
                row {mustBeSensorRow}
                column {mustBeSensorRow}
                options.p_latitude {mustBeSensorRow} = NaN(size(row))
                options.p_longitude {mustBeSensorRow} = NaN(size(row))
                options.p_elevation {mustBeSensorRow} = NaN(size(row))
                options.p_range {mustBeSensorRow} = NaN(size(row))
            end
            value = struct('point_set_type',char(type),'p_row',row,'p_column',column, ...
                'p_latitude',options.p_latitude,'p_longitude',options.p_longitude, ...
                'p_elevation',options.p_elevation,'p_range',options.p_range);
            mustBePoints(value);
        end
        function value = uncertainty(first,sigma,second) %#codegen
            %UNCERTAINTY - Construct a standard deviation or correlation
            %   VALUE = UNCERTAINTY(FIRST,SIGMA) names a parameter index
            %   and its standard deviation. A different SECOND index makes
            %   SIGMA a correlation coefficient between -1 and 1.
            arguments
                first {mustBeAscii(first,11)}
                sigma {mustBeSensorNumber,mustBeFinite}
                second {mustBeAscii(second,11)} = ''
            end
            if isempty(sigma), error('nfx:SensorNumber','Supply a scalar uncertainty value.'); end
            value = struct('uncertainty_first_type',char(first), ...
                'uncertainty_second_type',char(second),'uncertainty_value',sigma);
        end
        function value = additionalParameter(name,samples,width) %#codegen
            %ADDITIONALPARAMETER - Construct an explicitly sized extension
            %   VALUE = ADDITIONALPARAMETER(NAME,SAMPLES,WIDTH) preserves
            %   ASCII text rows and pads to WIDTH. The caller supplies the
            %   registered or documented internal parameter semantics.
            arguments
                name {mustBeAscii(name,25)}
                samples
                width {mustBeMetadata(width,1,999,1),mustBeFinite}
            end
            value = struct('parameter_name',char(name),'parameter_size',width, ...
                'parameter_value',metadataRows(samples,width,9999,false));
            mustBeAdditional(value);
        end
    end

end

function [records,report] = encodeSensor(obj) %#codegen
    %encodeSensor - Validate and serialize a complete logical sensor record
    report = newReport('STDI-0002 Appendix Z SENSRB 2.3');
    records = repmat(struct('tag','SENSRB','payload',zeros(1,0,'uint8')),1,0);
    [general,report] = generalFields(obj,report);
    parts = repmat({zeros(1,0,'uint8')},1,10);
    present = false(1,10); present([1 5 6]) = true;
    parts{1} = [uint8('Y') general];
    indexed = repmat({zeros(1,0,'uint8')},1,100);
    present(2) = ~isempty(char(obj.detection)) || ...
        ~isempty(obj.row_detectors) || ...
        ~isempty(obj.column_detectors) || ...
        ~isempty(obj.row_metric) || ...
        ~isempty(obj.column_metric) || ...
        ~isempty(obj.focal_length) || ...
        ~isempty(obj.row_fov) || ...
        ~isempty(obj.column_fov) || ...
        ~isempty(char(obj.calibrated));
    if present(2)
        [field,valid] = sensField([],char(obj.detection),'02a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','detection','Supply a valid 02a field.');
        indexed{1} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.row_detectors,'','02b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_detectors','Supply a valid 02b field.');
        indexed{2} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.column_detectors,'','02c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_detectors','Supply a valid 02c field.');
        indexed{3} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.row_metric,'','02d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_metric','Supply a valid 02d field.');
        indexed{4} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.column_metric,'','02e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_metric','Supply a valid 02e field.');
        indexed{5} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.focal_length,'','02f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','focal_length','Supply a valid 02f field.');
        indexed{6} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.row_fov,'','02g',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_fov','Supply a valid 02g field.');
        indexed{7} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField(obj.column_fov,'','02h',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_fov','Supply a valid 02h field.');
        indexed{8} = field;
        parts{2} = [parts{2} field];
        [field,valid] = sensField([],char(obj.calibrated),'02i',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','calibrated','Supply a valid 02i field.');
        indexed{9} = field;
        parts{2} = [parts{2} field];
    end
    parts{2} = [uint8(78+11*present(2)) parts{2}];
    present(3) = ~isempty(char(obj.calibration_unit)) || ...
        ~isempty(obj.principal_point_offset_x) || ...
        ~isempty(obj.principal_point_offset_y) || ...
        ~isempty(obj.radial_distort_1) || ...
        ~isempty(obj.radial_distort_2) || ...
        ~isempty(obj.radial_distort_3) || ...
        ~isempty(obj.radial_distort_limit) || ...
        ~isempty(obj.decent_distort_1) || ...
        ~isempty(obj.decent_distort_2) || ...
        ~isempty(obj.affinity_distort_1) || ...
        ~isempty(obj.affinity_distort_2) || ...
        ~isempty(char(obj.calibration_date));
    if present(3)
        [field,valid] = sensField([],char(obj.calibration_unit),'03a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','calibration_unit','Supply a valid 03a field.');
        indexed{10} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.principal_point_offset_x,'','03b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','principal_point_offset_x','Supply a valid 03b field.');
        indexed{11} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.principal_point_offset_y,'','03c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','principal_point_offset_y','Supply a valid 03c field.');
        indexed{12} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.radial_distort_1,'','03d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','radial_distort_1','Supply a valid 03d field.');
        indexed{13} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.radial_distort_2,'','03e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','radial_distort_2','Supply a valid 03e field.');
        indexed{14} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.radial_distort_3,'','03f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','radial_distort_3','Supply a valid 03f field.');
        indexed{15} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.radial_distort_limit,'','03g',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','radial_distort_limit','Supply a valid 03g field.');
        indexed{16} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.decent_distort_1,'','03h',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','decent_distort_1','Supply a valid 03h field.');
        indexed{17} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.decent_distort_2,'','03i',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','decent_distort_2','Supply a valid 03i field.');
        indexed{18} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.affinity_distort_1,'','03j',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','affinity_distort_1','Supply a valid 03j field.');
        indexed{19} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField(obj.affinity_distort_2,'','03k',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','affinity_distort_2','Supply a valid 03k field.');
        indexed{20} = field;
        parts{3} = [parts{3} field];
        [field,valid] = sensField([],char(obj.calibration_date),'03l',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','calibration_date','Supply a valid 03l field.');
        indexed{21} = field;
        parts{3} = [parts{3} field];
    end
    parts{3} = [uint8(78+11*present(3)) parts{3}];
    present(4) = ~isempty(char(obj.method)) || ...
        ~isempty(char(obj.mode)) || ...
        ~isempty(obj.row_count) || ...
        ~isempty(obj.column_count) || ...
        ~isempty(obj.row_set) || ...
        ~isempty(obj.column_set) || ...
        ~isempty(obj.row_rate) || ...
        ~isempty(obj.column_rate) || ...
        ~isempty(obj.first_pixel_row) || ...
        ~isempty(obj.first_pixel_column) || ~isempty(obj.transform_param);
    if present(4)
        [field,valid] = sensField([],char(obj.method),'04a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','method','Supply a valid 04a field.');
        indexed{22} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField([],char(obj.mode),'04b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','mode','Supply a valid 04b field.');
        indexed{23} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.row_count,'','04c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_count','Supply a valid 04c field.');
        indexed{24} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.column_count,'','04d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_count','Supply a valid 04d field.');
        indexed{25} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.row_set,'','04e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_set','Supply a valid 04e field.');
        indexed{26} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.column_set,'','04f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_set','Supply a valid 04f field.');
        indexed{27} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.row_rate,'','04g',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','row_rate','Supply a valid 04g field.');
        indexed{28} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.column_rate,'','04h',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','column_rate','Supply a valid 04h field.');
        indexed{29} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.first_pixel_row,'','04i',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','first_pixel_row','Supply a valid 04i field.');
        indexed{30} = field;
        parts{4} = [parts{4} field];
        [field,valid] = sensField(obj.first_pixel_column,'','04j',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','first_pixel_column','Supply a valid 04j field.');
        indexed{31} = field;
        parts{4} = [parts{4} field];
        parts{4} = [parts{4} uint8(48+numel(obj.transform_param))];
        for k = 1:numel(obj.transform_param)
            [field,valid] = sensNumber(obj.transform_param(k),12,'E');
            report = sensorIssue(report,~valid,'Field','transform_param','Each transform value must fit its numeric field.');
            indexed{31+k} = field;
            parts{4} = [parts{4} field];
        end
    end
    parts{4} = [uint8(78+11*present(4)) parts{4}];
    if present(5)
        [field,valid] = sensField(obj.reference_time,'','05a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','reference_time','Supply a valid 05a field.');
        indexed{40} = field;
        parts{5} = [parts{5} field];
        [field,valid] = sensField(obj.reference_row,'','05b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','reference_row','Supply a valid 05b field.');
        indexed{41} = field;
        parts{5} = [parts{5} field];
        [field,valid] = sensField(obj.reference_column,'','05c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','reference_column','Supply a valid 05c field.');
        indexed{42} = field;
        parts{5} = [parts{5} field];
    end
    if present(6)
        [field,valid] = sensField(obj.latitude_or_x,'','06a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','latitude_or_x','Supply a valid 06a field.');
        indexed{43} = field;
        parts{6} = [parts{6} field];
        [field,valid] = sensField(obj.longitude_or_y,'','06b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','longitude_or_y','Supply a valid 06b field.');
        indexed{44} = field;
        parts{6} = [parts{6} field];
        [field,valid] = sensField(obj.altitude_or_z,'','06c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','altitude_or_z','Supply a valid 06c field.');
        indexed{45} = field;
        parts{6} = [parts{6} field];
        [field,valid] = sensField(obj.sensor_x_offset,'','06d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_x_offset','Supply a valid 06d field.');
        indexed{46} = field;
        parts{6} = [parts{6} field];
        [field,valid] = sensField(obj.sensor_y_offset,'','06e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_y_offset','Supply a valid 06e field.');
        indexed{47} = field;
        parts{6} = [parts{6} field];
        [field,valid] = sensField(obj.sensor_z_offset,'','06f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_z_offset','Supply a valid 06f field.');
        indexed{48} = field;
        parts{6} = [parts{6} field];
    end
    present(7) = ~isempty(obj.sensor_angle_model) || ...
        ~isempty(obj.sensor_angle_1) || ...
        ~isempty(obj.sensor_angle_2) || ...
        ~isempty(obj.sensor_angle_3) || ...
        ~isempty(char(obj.platform_relative)) || ...
        ~isempty(obj.platform_heading) || ...
        ~isempty(obj.platform_pitch) || ...
        ~isempty(obj.platform_roll);
    if present(7)
        [field,valid] = sensField(obj.sensor_angle_model,'','07a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_angle_model','Supply a valid 07a field.');
        indexed{49} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.sensor_angle_1,'','07b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_angle_1','Supply a valid 07b field.');
        indexed{50} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.sensor_angle_2,'','07c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_angle_2','Supply a valid 07c field.');
        indexed{51} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.sensor_angle_3,'','07d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','sensor_angle_3','Supply a valid 07d field.');
        indexed{52} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField([],char(obj.platform_relative),'07e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','platform_relative','Supply a valid 07e field.');
        indexed{53} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.platform_heading,'','07f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','platform_heading','Supply a valid 07f field.');
        indexed{54} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.platform_pitch,'','07g',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','platform_pitch','Supply a valid 07g field.');
        indexed{55} = field;
        parts{7} = [parts{7} field];
        [field,valid] = sensField(obj.platform_roll,'','07h',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','platform_roll','Supply a valid 07h field.');
        indexed{56} = field;
        parts{7} = [parts{7} field];
    end
    parts{7} = [uint8(78+11*present(7)) parts{7}];
    present(8) = ~isempty(obj.icx_north_or_x) || ...
        ~isempty(obj.icx_east_or_y) || ...
        ~isempty(obj.icx_down_or_z) || ...
        ~isempty(obj.icy_north_or_x) || ...
        ~isempty(obj.icy_east_or_y) || ...
        ~isempty(obj.icy_down_or_z) || ...
        ~isempty(obj.icz_north_or_x) || ...
        ~isempty(obj.icz_east_or_y) || ...
        ~isempty(obj.icz_down_or_z);
    if present(8)
        [field,valid] = sensField(obj.icx_north_or_x,'','08a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icx_north_or_x','Supply a valid 08a field.');
        indexed{57} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icx_east_or_y,'','08b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icx_east_or_y','Supply a valid 08b field.');
        indexed{58} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icx_down_or_z,'','08c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icx_down_or_z','Supply a valid 08c field.');
        indexed{59} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icy_north_or_x,'','08d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icy_north_or_x','Supply a valid 08d field.');
        indexed{60} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icy_east_or_y,'','08e',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icy_east_or_y','Supply a valid 08e field.');
        indexed{61} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icy_down_or_z,'','08f',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icy_down_or_z','Supply a valid 08f field.');
        indexed{62} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icz_north_or_x,'','08g',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icz_north_or_x','Supply a valid 08g field.');
        indexed{63} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icz_east_or_y,'','08h',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icz_east_or_y','Supply a valid 08h field.');
        indexed{64} = field;
        parts{8} = [parts{8} field];
        [field,valid] = sensField(obj.icz_down_or_z,'','08i',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','icz_down_or_z','Supply a valid 08i field.');
        indexed{65} = field;
        parts{8} = [parts{8} field];
    end
    parts{8} = [uint8(78+11*present(8)) parts{8}];
    present(9) = ~isempty(obj.attitude_q1) || ...
        ~isempty(obj.attitude_q2) || ...
        ~isempty(obj.attitude_q3) || ...
        ~isempty(obj.attitude_q4);
    if present(9)
        [field,valid] = sensField(obj.attitude_q1,'','09a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','attitude_q1','Supply a valid 09a field.');
        indexed{66} = field;
        parts{9} = [parts{9} field];
        [field,valid] = sensField(obj.attitude_q2,'','09b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','attitude_q2','Supply a valid 09b field.');
        indexed{67} = field;
        parts{9} = [parts{9} field];
        [field,valid] = sensField(obj.attitude_q3,'','09c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','attitude_q3','Supply a valid 09c field.');
        indexed{68} = field;
        parts{9} = [parts{9} field];
        [field,valid] = sensField(obj.attitude_q4,'','09d',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','attitude_q4','Supply a valid 09d field.');
        indexed{69} = field;
        parts{9} = [parts{9} field];
    end
    parts{9} = [uint8(78+11*present(9)) parts{9}];
    present(10) = ~isempty(obj.velocity_north_or_x) || ...
        ~isempty(obj.velocity_east_or_y) || ...
        ~isempty(obj.velocity_down_or_z);
    if present(10)
        [field,valid] = sensField(obj.velocity_north_or_x,'','10a',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','velocity_north_or_x','Supply a valid 10a field.');
        indexed{70} = field;
        parts{10} = [parts{10} field];
        [field,valid] = sensField(obj.velocity_east_or_y,'','10b',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','velocity_east_or_y','Supply a valid 10b field.');
        indexed{71} = field;
        parts{10} = [parts{10} field];
        [field,valid] = sensField(obj.velocity_down_or_z,'','10c',obj.geodetic_type,obj.angular_unit,false);
        report = sensorIssue(report,~valid,'Field','velocity_down_or_z','Supply a valid 10c field.');
        indexed{72} = field;
        parts{10} = [parts{10} field];
    end
    parts{10} = [uint8(78+11*present(10)) parts{10}];
    [report] = sensorRelationships(obj,present,report);
    [points,report] = encodePoints(obj.point_data,report);
    [series,report] = encodeSeries(obj.time_stamped_data,obj.geodetic_type,obj.angular_unit,report);
    [pixels,report] = encodePixels(obj.pixel_referenced_data,obj.geodetic_type,obj.angular_unit,report);
    [additional,report] = encodeAdditional(obj.additional_parameter_data,report);
    report = sensorIssue(report,numel(obj.uncertainty_data) > 999,'UncertaintyCount','uncertainty_data','At most 999 uncertainty entries fit the counter.');
    if ~report.valid, return; end
    prefix = [parts{:} points];
    minimalPrefix = [uint8('NNNN') parts{5} parts{6} uint8('NNNN00')];
    uncertainty = zeros(1,3+32*numel(obj.uncertainty_data),'uint8');
    suffix = [pixels uncertainty additional];
    [records,map,valid] = packSensorSeries(prefix,suffix,minimalPrefix,series);
    report = sensorIssue(report,~valid,'StaticPayloadLength','SENSRB','All non-module-12 metadata must fit the first physical instance.');
    if ~valid, return; end
    conflict = sensorContinuationConflict(records,numel(prefix),numel(minimalPrefix), ...
        parts{5},parts{6},pixels,obj.geodetic_type,obj.angular_unit);
    report = sensorIssue(report,conflict,'ContinuationReferenceConflict','time_stamped_data/pixel_referenced_data', ...
        'A continuation would repeat a required reference position that conflicts with an earlier sample at that reference.');
    [uncertainty,report] = encodeUncertainty(obj,map,indexed,present,report);
    if ~report.valid, return; end
    offset = numel(records(1).payload)-numel(additional)-numel(uncertainty);
    records(1).payload(offset+1:offset+numel(uncertainty)) = uncertainty;
end

function report = sensorIssue(report,failed,id,field,message) %#codegen
    %sensorIssue - Attach an actionable sensor validation failure
    report = addIssue(report,failed,id,field,message, ...
        'STDI-0002-1 Appendix Z 2.3, Table Z.3-1 and Z.4-Z.5');
end

function [value,report] = generalFields(obj,report) %#codegen
    %generalFields - Encode the required first-instance collection context
    valid = ~isempty(strtrim(char(obj.sensor))) && ~isempty(strtrim(char(obj.platform))) && ...
        ~isempty(strtrim(char(obj.geodetic_system))) && ...
        any(strcmp(obj.operation_domain,{'Airborne','Waterborne','Spaceborne','Ground'})) && ...
        any(strcmp(obj.geodetic_type,{'G','C'})) && any(strcmp(obj.elevation_datum,{'HAE','MSL','AGL'})) && ...
        any(strcmp(obj.length_unit,{'SI','EE'})) && any(strcmp(obj.angular_unit,{'DEG','RAD','SMC'})) && ...
        isfinite(obj.content_level) && isfinite(obj.generation_count);
    report = sensorIssue(report,~valid,'GeneralData','SENSRB','Supply sensor, platform, domain and valid coordinate/unit definitions.');
    first = char(obj.start_date); last = char(obj.end_date);
    validDates = sensorDate(first) && sensorDate(last);
    [start,okStart] = sensNumber(obj.start_time,14,'N');
    [finish,okEnd] = sensNumber(obj.end_time,14,'N');
    validTimes = okStart && okEnd && str2double(char(start)) < 86400 && str2double(char(finish)) < 86400;
    report = sensorIssue(report,~validDates || ~validTimes,'CollectionTime','start_date/end_date','Supply valid collection dates and times within the UTC day.');
    if validDates && validTimes
        known = min([find([first '-'] == '-',1) find([last '-'] == '-',1)])-1;
        earlier = str2double(last(1:known)) < str2double(first(1:known));
        reversed = ~contains(first,'-') && strcmp(first,last) && obj.end_time < obj.start_time;
        report = sensorIssue(report,earlier || reversed,'TimeOrder','end_date/end_time','The collection must end at or after its start.');
    end
    date = repmat(uint8('-'),1,8); time = repmat(uint8('-'),1,10);
    if obj.generation_count > 0
        word = char(obj.generation_time);
        valid = sensorDate(char(obj.generation_date)) && ~contains(char(obj.generation_date),'-') && ...
            numel(word) == 10 && word(7) == '.' && all(word([1:6 8:10]) >= '0' & word([1:6 8:10]) <= '9');
        if valid
            valid = str2double(word(1:2)) <= 23 && str2double(word(3:4)) <= 59 && str2double(word(5:6)) <= 59;
        end
        report = sensorIssue(report,~valid,'GenerationTime','generation_date/generation_time','Adjusted metadata requires a valid UTC generation date and HHMMSS.sss time.');
        date = textField(obj.generation_date,8); time = textField(obj.generation_time,10);
    end
    value = [textField(obj.sensor,25) unknownText(obj.sensor_uri,32) textField(obj.platform,25) ...
        unknownText(obj.platform_uri,32) textField(obj.operation_domain,10) ...
        uint8(sprintf('%01.0f',obj.content_level)) textField(obj.geodetic_system,5) ...
        textField(obj.geodetic_type,1) textField(obj.elevation_datum,3) textField(obj.length_unit,2) ...
        textField(obj.angular_unit,3) textField(first,8) start textField(last,8) finish ...
        uint8(sprintf('%02.0f',obj.generation_count)) date time];
end

function valid = sensorDate(word) %#codegen
    %sensorDate - Check a nonempty date prefix and possible calendar values
    valid = numel(word) == 8 && word(1) ~= '-' && partialDate14([word '------']);
end

function value = unknownText(word,width) %#codegen
    %unknownText - Preserve the standard's unspecified field indicator
    if isempty(strtrim(char(word))), value = repmat(uint8('-'),1,width);
    else, value = textField(word,width);
    end
end

function report = sensorRelationships(obj,present,report) %#codegen
    %sensorRelationships - Check module prerequisites and geometric invariants
    if present(2)
        [complete,consistent] = sensorArrayGeometry(obj.row_metric,obj.column_metric, ...
            obj.focal_length,obj.row_fov,obj.column_fov,obj.angular_unit);
        report = sensorIssue(report,~consistent,'SensorArrayConsistency','row_metric/column_metric/focal_length/row_fov/column_fov', ...
            'Redundant sensor geometry must agree within field quantization and 0.01 percent relative tolerance.');
        report = sensorIssue(report,obj.content_level >= 6 && ~complete,'SensorArrayGeometry','content_level', ...
            'Geopositioning content levels require optical geometry that defines both detector dimensions.');
    end
    knownTime = ~isempty(obj.reference_time) && isfinite(obj.reference_time);
    knownPixel = ~isempty(obj.reference_row) && ~isempty(obj.reference_column) && ...
        isfinite(obj.reference_row) && isfinite(obj.reference_column);
    report = sensorIssue(report,~knownTime && ~knownPixel,'ReferenceRequired','reference_time/reference_row/reference_column', ...
        'Supply a reference time or both reference pixel coordinates.');
    if present(4) && allKnown([obj.row_count obj.column_count obj.row_set obj.column_set obj.first_pixel_row obj.first_pixel_column],6)
        report = sensorIssue(report,obj.row_set > obj.row_count || obj.column_set > obj.column_count || ...
            obj.first_pixel_row > obj.row_count || obj.first_pixel_column > obj.column_count, ...
            'FormationBounds','row_set/column_set/first_pixel','Detection sets and the first pixel must lie within the initial image array.');
        framing = any(strcmp(obj.method,{'Single Frame','Single MIDSI'}));
        report = sensorIssue(report,framing && (obj.row_set ~= obj.row_count || obj.column_set ~= obj.column_count), ...
            'FramingSet','row_set/column_set','An instantaneous frame uses the full initial image as its detection set.');
    end
    if present(7) && strcmp(obj.platform_relative,'Y')
        report = sensorIssue(report,~allKnown([obj.platform_heading obj.platform_pitch obj.platform_roll],3), ...
            'PlatformAttitude','platform_relative','Platform-relative sensor angles require all three platform angles.');
    end
    if present(8)
        matrix = [obj.icx_north_or_x obj.icx_east_or_y obj.icx_down_or_z ...
            obj.icy_north_or_x obj.icy_east_or_y obj.icy_down_or_z ...
            obj.icz_north_or_x obj.icz_east_or_y obj.icz_down_or_z];
        if allKnown(matrix,9)
            matrix = reshape(matrix,3,3);
            report = sensorIssue(report,norm(matrix'*matrix-eye(3),'fro') > 1e-6 || abs(det(matrix)-1) > 1e-6, ...
                'AttitudeBasis','icx/icy/icz','Unit vectors must form an orthonormal right-handed basis.');
        end
    end
    if present(9)
        q = [obj.attitude_q1 obj.attitude_q2 obj.attitude_q3 obj.attitude_q4];
        report = sensorIssue(report,allKnown(q,4) && abs(sum(q.^2)-1) > 1e-6, ...
            'QuaternionNorm','attitude_q1/attitude_q2/attitude_q3/attitude_q4','The quaternion must have unit norm.');
    end
    level = obj.content_level;
    required = (mod(level,2) == 1 && isempty(obj.point_data)) || ...
        (level >= 2 && ~all(present([2 4]))) || (level >= 4 && ~any(present(7:9))) || ...
        (level >= 6 && isempty(obj.uncertainty_data)) || (level >= 8 && ~present(3));
    moving = any(strcmp(obj.method,{'Multi-Frame','Multi-MIDSI','Pushbroom','Whiskbroom'}));
    % Known compatibility deviation: Appendix Z 2.3, Table Z.5.1-1,
    % footnote a (Z-54) requires module 10 for these methods at levels 4+.
    % Accept observed level-8 scanner products without inventing velocity.
    allowMissingVelocity = level == 8 && ...
        any(strcmp(obj.method, {'Pushbroom', 'Whiskbroom'}));
    required = required || (level >= 4 && moving && ...
        ((~present(10) && ~allowMissingVelocity) || ...
        (isempty(obj.time_stamped_data) && isempty(obj.pixel_referenced_data))));
    report = sensorIssue(report,required,'ContentLevel','content_level','The declared content level requires additional modules (Table Z.5.1-1).');
end

function valid = allKnown(value,count) %#codegen
    %allKnown - Check an exact number of supplied numeric components
    valid = numel(value) == count && all(isfinite(value));
end

function [value,report] = encodePoints(groups,report) %#codegen
    %encodePoints - Encode registered point sets without inferring locations
    value = uint8(sprintf('%02.0f',numel(groups)));
    report = sensorIssue(report,numel(groups) > 99,'PointSetCount','point_data','At most 99 point sets are allowed.');
    for k = 1:numel(groups)
        item = groups(k); count = numel(item.p_row);
        typeValid = any(strcmp(item.point_set_type,{'Sensor Aimpoint','Image Center','Image Footprint', ...
            'Ground Area','Ground Points','Point of Interest','Area of Interest','LRF Measurements'}));
        report = sensorIssue(report,~typeValid || count < 1 || count > 999,'PointSet','point_data','Supply a published point-set type and 1 to 999 points.');
        if count > 999, continue; end
        data = zeros(51,count,'uint8');
        for j = 1:count
            [row,a] = sensNumber(item.p_row(j),8,'N'); [column,b] = sensNumber(item.p_column(j),8,'N');
            [lat,c] = pointNumber(item.p_latitude(j),10,'L',-90,90);
            [lon,d] = pointNumber(item.p_longitude(j),11,'O',-180,180);
            [height,e] = pointNumber(item.p_elevation(j),6,'N',-Inf,Inf);
            [range,f] = pointNumber(item.p_range(j),8,'N',0,Inf);
            report = sensorIssue(report,~(a && b && c && d && e && f) || item.p_range(j) == 0, ...
                'PointValue','point_data','Point locations must fit their fields; a known range must be positive.');
            data(:,j) = [row column lat lon height range]';
        end
        value = [value textField(item.point_set_type,25) uint8(sprintf('%03.0f',count)) reshape(data,1,[])]; %#ok<AGROW>
    end
end

function [value,valid] = pointNumber(number,width,format,lower,upper) %#codegen
    %pointNumber - Encode an optional coordinate without conflating zero
    value = repmat(uint8('-'),1,width); valid = isnan(number);
    if valid, return; end
    [value,valid] = sensNumber(number,width,format);
    rounded = str2double(char(value));
    valid = valid && number >= lower && number <= upper && rounded >= lower && rounded <= upper;
end

function [groups,report] = encodeSeries(input,geo,angle,report) %#codegen
    %encodeSeries - Encode complete typed pairs in their original order
    groups = repmat(struct('type','   ','data',zeros(0,0,'uint8')),1,numel(input));
    for k = 1:numel(input)
        item = input(k); type = char(item.time_stamp_type);
        info = sensFieldInfo(type,geo,angle); count = numel(item.time_stamp_time);
        report = sensorIssue(report,~info.valid || count == 0,'TimeSeries','time_stamped_data','Supply an eligible field index and at least one sample.');
        if ~info.valid || count == 0, continue; end
        data = zeros(12+info.width,count,'uint8'); valid = true;
        for j = 1:count
            [time,a] = sensNumber(item.time_stamp_time(j),12,'N');
            [sample,b] = sampleField(item.time_stamp_value,j,type,geo,angle);
            valid = valid && a && b; data(:,j) = [time sample]';
        end
        report = sensorIssue(report,~valid,'TimeSeriesValue','time_stamped_data','Each known sample must match its indexed field type, range and width.');
        groups(k) = struct('type',type,'data',data);
    end
end

function [value,report] = encodePixels(input,geo,angle,report) %#codegen
    %encodePixels - Encode complete pixel/value triples in their original order
    value = uint8(sprintf('%02.0f',numel(input)));
    report = sensorIssue(report,numel(input) > 99,'PixelSeriesCount','pixel_referenced_data','At most 99 pixel-referenced groups are allowed.');
    for k = 1:numel(input)
        item = input(k); type = char(item.pixel_reference_type);
        info = sensFieldInfo(type,geo,angle); count = numel(item.pixel_reference_row);
        report = sensorIssue(report,~info.valid || count < 1 || count > 9999,'PixelSeries','pixel_referenced_data','Supply an eligible index and 1 to 9999 samples.');
        if ~info.valid || count < 1 || count > 9999, continue; end
        data = zeros(16+info.width,count,'uint8'); valid = true;
        for j = 1:count
            [row,a] = sensNumber(item.pixel_reference_row(j),8,'N');
            [column,b] = sensNumber(item.pixel_reference_column(j),8,'N');
            [sample,c] = sampleField(item.pixel_reference_value,j,type,geo,angle);
            valid = valid && a && b && c; data(:,j) = [row column sample]';
        end
        report = sensorIssue(report,~valid,'PixelSeriesValue','pixel_referenced_data','Each known sample must match its indexed field type, range and width.');
        value = [value uint8(type) uint8(sprintf('%04.0f',count)) reshape(data,1,[])]; %#ok<AGROW>
    end
end

function [value,valid] = sampleField(samples,j,type,geo,angle) %#codegen
    %sampleField - Dispatch explicitly stored numeric or text sample data
    if isempty(samples.numeric), number = []; word = samples.text(j,:);
    else, number = samples.numeric(j); word = '';
    end
    [value,valid] = sensField(number,word,type,geo,angle,true);
end

function [value,report] = encodeAdditional(input,report) %#codegen
    %encodeAdditional - Preserve declared extension rows and their padding
    value = uint8(sprintf('%03.0f',numel(input)));
    report = sensorIssue(report,numel(input) > 999,'AdditionalCount','additional_parameter_data','At most 999 additional parameters are allowed.');
    for k = 1:numel(input)
        item = input(k); count = size(item.parameter_value,1);
        report = sensorIssue(report,isempty(strtrim(char(item.parameter_name))) || count < 1 || count > 9999, ...
            'AdditionalParameter','additional_parameter_data','Supply a name and 1 to 9999 fixed-width values.');
        value = [value textField(item.parameter_name,25) uint8(sprintf('%03.0f%04.0f',item.parameter_size,count)) ...
            reshape(uint8(item.parameter_value'),1,[])]; %#ok<AGROW>
    end
end

function [records,map,valid] = packSensorSeries(prefix,suffix,minimalPrefix,groups) %#codegen
    %packSensorSeries - Split only whole pairs using actual encoded byte sizes
    records = repmat(struct('tag','SENSRB','payload',zeros(1,0,'uint8')),1,0);
    map = repmat(struct('source',0,'first',0,'count',0,'group',0),1,0);
    valid = numel(prefix)+2+numel(suffix) <= 99985;
    if ~valid, return; end
    first = true; chunks = zeros(1,0,'uint8'); count = 0;
    for k = 1:numel(groups)
        at = 1; data = groups(k).data;
        while at <= size(data,2)
            available = 99985-numel(prefix)-2-numel(suffix)-numel(chunks)-7;
            take = min([size(data,2)-at+1 9999 floor(available/size(data,1))]);
            if take < 1 || count == 99
                records(end+1) = struct('tag','SENSRB','payload',[prefix uint8(sprintf('%02.0f',count)) chunks suffix]);
                first = false; prefix = minimalPrefix; suffix = uint8('00000000');
                chunks = zeros(1,0,'uint8'); count = 0;
                continue
            end
            count = count+1;
            if first, map(end+1) = struct('source',k,'first',at,'count',take,'group',count); end
            chunks = [chunks uint8(groups(k).type) uint8(sprintf('%04.0f',take)) reshape(data(:,at:at+take-1),1,[])]; %#ok<AGROW>
            at = at+take;
        end
    end
    records(end+1) = struct('tag','SENSRB','payload',[prefix uint8(sprintf('%02.0f',count)) chunks suffix]);
end

function mustBeSensorRow(value) %#codegen
    %mustBeSensorRow - Reject coerced, complex, sparse or column samples
    mustBeMetadataArray(value,-Inf,Inf,false);
    if ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:SensorRow','Supply a real full double row.');
    end
end

function mustBeTransform(value) %#codegen
    %mustBeTransform - Accept only transformation classes defined in Table Z5
    mustBeSensorRow(value);
    if ~any(numel(value) == [0 2 4 5 6 8]) || any(~isfinite(value))
        error('nfx:SensorTransform','Supply 0, 2, 4, 5, 6 or 8 finite transform coefficients.');
    end
end

function requireStruct(value,names) %#codegen
    %requireStruct - Validate exact repeating-group schemas
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~all(isfield(value,names)) || numel(fieldnames(value)) ~= numel(names)
        error('nfx:SensorGroup','Supply row structs with exactly the documented fields.');
    end
end

function mustBeSamples(value,count) %#codegen
    %mustBeSamples - Validate the uniform explicit numeric/text sample union
    requireStruct(value,{'numeric','text'});
    if ~isscalar(value), error('nfx:SensorSamples','Each value group must be scalar.'); end
    mustBeSensorRow(value.numeric);
    if ~ischar(value.text) || ~ismatrix(value.text) || any(value.text(:) < ' ' | value.text(:) > '~') || ...
            (~isempty(value.numeric) && ~isempty(value.text)) || ...
            (isempty(value.numeric) && size(value.text,1) ~= count) || ...
            (~isempty(value.numeric) && numel(value.numeric) ~= count)
        error('nfx:SensorSamples','Use one numeric row or ASCII text rows, matching the reference count.');
    end
end

function mustBeTimeSeries(value) %#codegen
    %mustBeTimeSeries - Validate aligned time/value groups without coercion
    requireStruct(value,{'time_stamp_type','time_stamp_time','time_stamp_value'});
    for k = 1:numel(value)
        mustBeAscii(value(k).time_stamp_type,3); mustBeSensorRow(value(k).time_stamp_time);
        mustBeSamples(value(k).time_stamp_value,numel(value(k).time_stamp_time));
    end
end

function mustBePixelSeries(value) %#codegen
    %mustBePixelSeries - Validate aligned pixel/value groups without coercion
    requireStruct(value,{'pixel_reference_type','pixel_reference_row','pixel_reference_column','pixel_reference_value'});
    for k = 1:numel(value)
        mustBeAscii(value(k).pixel_reference_type,3); mustBeSensorRow(value(k).pixel_reference_row);
        mustBeSensorRow(value(k).pixel_reference_column);
        count = numel(value(k).pixel_reference_row);
        if numel(value(k).pixel_reference_column) ~= count, error('nfx:SensorSamples','Pixel rows and columns must align.'); end
        mustBeSamples(value(k).pixel_reference_value,count);
    end
end

function mustBePoints(value) %#codegen
    %mustBePoints - Validate aligned point fields without reshaping arrays
    requireStruct(value,{'point_set_type','p_row','p_column','p_latitude','p_longitude','p_elevation','p_range'});
    for k = 1:numel(value)
        item = value(k); mustBeAscii(item.point_set_type,25);
        mustBeSensorRow(item.p_row); mustBeSensorRow(item.p_column);
        mustBeSensorRow(item.p_latitude); mustBeSensorRow(item.p_longitude);
        mustBeSensorRow(item.p_elevation); mustBeSensorRow(item.p_range);
        if any([numel(item.p_column) numel(item.p_latitude) numel(item.p_longitude) ...
                numel(item.p_elevation) numel(item.p_range)] ~= numel(item.p_row))
            error('nfx:SensorSamples','All point fields must have the same number of samples.');
        end
    end
end

function mustBeUncertainty(value) %#codegen
    %mustBeUncertainty - Validate explicitly indexed uncertainty entries
    requireStruct(value,{'uncertainty_first_type','uncertainty_second_type','uncertainty_value'});
    for k = 1:numel(value)
        mustBeAscii(value(k).uncertainty_first_type,11); mustBeAscii(value(k).uncertainty_second_type,11);
        mustBeMetadata(value(k).uncertainty_value,-Inf,Inf,false);
    end
end

function mustBeAdditional(value) %#codegen
    %mustBeAdditional - Validate exact-width registered/internal text values
    requireStruct(value,{'parameter_name','parameter_size','parameter_value'});
    for k = 1:numel(value)
        item = value(k); mustBeAscii(item.parameter_name,25); mustBeMetadata(item.parameter_size,1,999,true);
        if ~isfinite(item.parameter_size) || ~ischar(item.parameter_value) || ~ismatrix(item.parameter_value) || ...
                size(item.parameter_value,2) ~= item.parameter_size || any(item.parameter_value(:) < ' ' | item.parameter_value(:) > '~')
            error('nfx:SensorAdditional','Additional values must be ASCII rows of the declared width.');
        end
    end
end


function [value,report] = encodeUncertainty(obj,map,indexed,present,report) %#codegen
    %encodeUncertainty - Resolve uncertainty indices against encoded samples
    groups = obj.uncertainty_data;
    value = uint8(sprintf('%03.0f',numel(groups)));
    for k = 1:numel(groups)
        item = groups(k);
        [first,firstValid,firstDeferred] = uncertaintyIndex(char(item.uncertainty_first_type),obj,map,indexed,present);
        second = strtrim(char(item.uncertainty_second_type));
        secondValid = true; secondDeferred = false;
        absent = isempty(second) || all(second == '-');
        if ~absent, [second,secondValid,secondDeferred] = uncertaintyIndex(second,obj,map,indexed,present); end
        sigma = absent || strcmp(first,second);
        number = item.uncertainty_value;
        valid = isfinite(number) && ((sigma && number > 0) || (~sigma && abs(number) <= 1));
        if sigma && valid
            number = min(number,9.99999e99);
            if number < 1e-99, number = 0; end
        end
        [encoded,numberValid] = sensNumber(number,10,'E');
        report = sensorIssue(report,~firstValid || ~secondValid,'UncertaintyIndex','uncertainty_data', ...
            'Uncertainty indices must identify existing known numeric parameters or loop samples.');
        report = sensorIssue(report,firstDeferred || secondDeferred,'ContinuationUncertainty','uncertainty_data', ...
            'An uncertainty in the first instance cannot reference a module-12 sample moved to a later instance.');
        report = sensorIssue(report,~valid || ~numberValid,'UncertaintyValue','uncertainty_data', ...
            'Supply a positive standard deviation or a correlation in [-1,1].');
        value = [value textField(first,11) unknownText(second,11) encoded]; %#ok<AGROW>
    end
end

function [canonical,valid,deferred] = uncertaintyIndex(word,obj,map,indexed,present) %#codegen
    %uncertaintyIndex - Resolve concrete data fields without changing meaning
    word = strtrim(word); canonical = word; valid = false; deferred = false;
    if numel(word) < 3, return; end
    base = word(1:3); tail = word(4:end);
    module = str2double(base(1:2));
    if isempty(tail) && module >= 2 && module <= 10
        slot = sensorSlot(base);
        if slot == 0 || ~present(module) || isempty(indexed{slot}), return; end
        info = sensFieldInfo(base,obj.geodetic_type,obj.angular_unit);
        valid = info.valid && ~any(info.format == 'AD') && isfinite(str2double(char(indexed{slot})));
        return
    end
    dot = find(tail == '.');
    if numel(dot) ~= 1 || dot == 1 || dot == numel(tail), return; end
    outerWord = tail(1:dot-1); innerWord = tail(dot+1:end);
    if any(outerWord < '0' | outerWord > '9') || any(innerWord < '0' | innerWord > '9'), return; end
    outer = str2double(outerWord); inner = str2double(innerWord);
    if outer < 1 || inner < 1, return; end
    switch base
        case {'11c','11d','11e','11f','11g','11h'}
            if outer > numel(obj.point_data), return; end
            group = obj.point_data(outer);
            if inner > numel(group.p_row), return; end
            switch base
                case '11c', number = group.p_row(inner);
                case '11d', number = group.p_column(inner);
                case '11e', number = group.p_latitude(inner);
                case '11f', number = group.p_longitude(inner);
                case '11g', number = group.p_elevation(inner);
                otherwise, number = group.p_range(inner);
            end
            valid = isfinite(number);
        case {'12c','12d'}
            if outer > numel(obj.time_stamped_data), return; end
            group = obj.time_stamped_data(outer);
            if inner > numel(group.time_stamp_time), return; end
            valid = strcmp(base,'12c') || isnumericSeries(group.time_stamp_type,group.time_stamp_value,inner,obj);
            if ~valid, return; end
            location = find([map.source] == outer & inner >= [map.first] & inner < [map.first]+[map.count],1);
            if isempty(location), deferred = true; return; end
            outer = map(location).group; inner = inner-map(location).first+1;
        case {'13c','13d','13e'}
            if outer > numel(obj.pixel_referenced_data), return; end
            group = obj.pixel_referenced_data(outer);
            if inner > numel(group.pixel_reference_row), return; end
            valid = ~strcmp(base,'13e') || isnumericSeries(group.pixel_reference_type,group.pixel_reference_value,inner,obj);
        case '15d'
            if outer > numel(obj.additional_parameter_data), return; end
            group = obj.additional_parameter_data(outer);
            if inner > size(group.parameter_value,1), return; end
            number = str2double(group.parameter_value(inner,:));
            valid = isreal(number) && isfinite(number);
    end
    if valid, canonical = sprintf('%s%.0f.%.0f',base,outer,inner); end
end

function valid = isnumericSeries(type,samples,j,obj) %#codegen
    %isnumericSeries - Exclude textual and unspecified uncertainty targets
    info = sensFieldInfo(char(type),obj.geodetic_type,obj.angular_unit);
    valid = info.valid && ~any(info.format == 'AD') && ...
        ~isempty(samples.numeric) && isfinite(samples.numeric(j));
end

function slot = sensorSlot(index) %#codegen
    %sensorSlot - Map each numeric field to its explicitly encoded snapshot
    slot = 0;
    switch index
        case '02a', slot = 1;
        case '02b', slot = 2;
        case '02c', slot = 3;
        case '02d', slot = 4;
        case '02e', slot = 5;
        case '02f', slot = 6;
        case '02g', slot = 7;
        case '02h', slot = 8;
        case '02i', slot = 9;
        case '03a', slot = 10;
        case '03b', slot = 11;
        case '03c', slot = 12;
        case '03d', slot = 13;
        case '03e', slot = 14;
        case '03f', slot = 15;
        case '03g', slot = 16;
        case '03h', slot = 17;
        case '03i', slot = 18;
        case '03j', slot = 19;
        case '03k', slot = 20;
        case '03l', slot = 21;
        case '04a', slot = 22;
        case '04b', slot = 23;
        case '04c', slot = 24;
        case '04d', slot = 25;
        case '04e', slot = 26;
        case '04f', slot = 27;
        case '04g', slot = 28;
        case '04h', slot = 29;
        case '04i', slot = 30;
        case '04j', slot = 31;
        case '04l', slot = 32;
        case '04m', slot = 33;
        case '04n', slot = 34;
        case '04o', slot = 35;
        case '04p', slot = 36;
        case '04q', slot = 37;
        case '04r', slot = 38;
        case '04s', slot = 39;
        case '05a', slot = 40;
        case '05b', slot = 41;
        case '05c', slot = 42;
        case '06a', slot = 43;
        case '06b', slot = 44;
        case '06c', slot = 45;
        case '06d', slot = 46;
        case '06e', slot = 47;
        case '06f', slot = 48;
        case '07a', slot = 49;
        case '07b', slot = 50;
        case '07c', slot = 51;
        case '07d', slot = 52;
        case '07e', slot = 53;
        case '07f', slot = 54;
        case '07g', slot = 55;
        case '07h', slot = 56;
        case '08a', slot = 57;
        case '08b', slot = 58;
        case '08c', slot = 59;
        case '08d', slot = 60;
        case '08e', slot = 61;
        case '08f', slot = 62;
        case '08g', slot = 63;
        case '08h', slot = 64;
        case '08i', slot = 65;
        case '09a', slot = 66;
        case '09b', slot = 67;
        case '09c', slot = 68;
        case '09d', slot = 69;
        case '10a', slot = 70;
        case '10b', slot = 71;
        case '10c', slot = 72;
    end
end
