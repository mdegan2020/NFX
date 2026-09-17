function [obj, reader] = readSensorPayload(data, geo, angle, later) %#codegen
    %readSensorPayload - Decode one physical instance in its logical context
    obj = nfx.SENSRB();
    reader = nfx.internal.TREReader(data);
    [general, reader] = reader.choice('YN');
    if (later && strcmp(general, 'Y')) || (~later && strcmp(general, 'N'))
        reader = reader.fail('MissingContext', ...
            'Decode continuations together with their first SENSRB instance.');
    end
    if ~later
        [value, reader] = reader.text(25, true, false);
        if reader.ok
            obj.sensor = value;
        end
        [value, reader] = reader.text(32, true, false);
        if reader.ok
            obj.sensor_uri = value;
        end
        [value, reader] = reader.text(25, true, false);
        if reader.ok
            obj.platform = value;
        end
        [value, reader] = reader.text(32, true, false);
        if reader.ok
            obj.platform_uri = value;
        end
        [value, reader] = reader.text(10, true, false);
        if reader.ok
            obj.operation_domain = value;
        end
        [value, reader] = reader.number( ...
            1, 0, 9, 1, false);
        if reader.ok
            obj.content_level = value;
        end
        [value, reader] = reader.text(5, true, false);
        if reader.ok
            obj.geodetic_system = value;
        end
        [value, reader] = reader.text(1, true, false);
        if reader.ok
            obj.geodetic_type = value;
        end
        [value, reader] = reader.text(3, true, false);
        if reader.ok
            obj.elevation_datum = value;
        end
        [value, reader] = reader.text(2, true, false);
        if reader.ok
            obj.length_unit = value;
        end
        [value, reader] = reader.text(3, true, false);
        if reader.ok
            obj.angular_unit = value;
        end
        [value, reader] = reader.text(8, true, false);
        if reader.ok
            obj.start_date = value;
        end
        [value, reader] = reader.number( ...
            14, 0, 86399.99999999, 0, false);
        if reader.ok
            obj.start_time = value;
        end
        [value, reader] = reader.text(8, true, false);
        if reader.ok
            obj.end_date = value;
        end
        [value, reader] = reader.number( ...
            14, 0, 86399.99999999, 0, false);
        if reader.ok
            obj.end_time = value;
        end
        [value, reader] = reader.number( ...
            2, 0, 99, 1, false);
        if reader.ok
            obj.generation_count = value;
        end
        [value, reader] = reader.text(8, true, false);
        if reader.ok
            obj.generation_date = value;
        end
        [value, reader] = reader.text(10, true, false);
        if reader.ok
            obj.generation_time = value;
        end
        if ~isempty(obj.sensor_uri) && all(obj.sensor_uri == '-')
            obj.sensor_uri = '';
        end
        if ~isempty(obj.platform_uri) && all(obj.platform_uri == '-')
            obj.platform_uri = '';
        end
        if obj.generation_count == 0
            obj.generation_date = '';
            obj.generation_time = '';
        end
        geo = obj.geodetic_type;
        angle = obj.angular_unit;
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [~, value, reader] = readSensorField( ...
            reader, '02a', geo, angle, false);
        if reader.ok
            obj.detection = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02b', geo, angle, false);
        if reader.ok
            obj.row_detectors = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02c', geo, angle, false);
        if reader.ok
            obj.column_detectors = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02d', geo, angle, false);
        if reader.ok
            obj.row_metric = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02e', geo, angle, false);
        if reader.ok
            obj.column_metric = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02f', geo, angle, false);
        if reader.ok
            obj.focal_length = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02g', geo, angle, false);
        if reader.ok
            obj.row_fov = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '02h', geo, angle, false);
        if reader.ok
            obj.column_fov = value;
        end
        [~, value, reader] = readSensorField( ...
            reader, '02i', geo, angle, false);
        if reader.ok
            obj.calibrated = value;
        end
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [~, value, reader] = readSensorField( ...
            reader, '03a', geo, angle, false);
        if reader.ok
            obj.calibration_unit = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03b', geo, angle, false);
        if reader.ok
            obj.principal_point_offset_x = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03c', geo, angle, false);
        if reader.ok
            obj.principal_point_offset_y = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03d', geo, angle, false);
        if reader.ok
            obj.radial_distort_1 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03e', geo, angle, false);
        if reader.ok
            obj.radial_distort_2 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03f', geo, angle, false);
        if reader.ok
            obj.radial_distort_3 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03g', geo, angle, false);
        if reader.ok
            obj.radial_distort_limit = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03h', geo, angle, false);
        if reader.ok
            obj.decent_distort_1 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03i', geo, angle, false);
        if reader.ok
            obj.decent_distort_2 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03j', geo, angle, false);
        if reader.ok
            obj.affinity_distort_1 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '03k', geo, angle, false);
        if reader.ok
            obj.affinity_distort_2 = value;
        end
        [~, value, reader] = readSensorField( ...
            reader, '03l', geo, angle, false);
        if reader.ok
            obj.calibration_date = value;
        end
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [~, value, reader] = readSensorField( ...
            reader, '04a', geo, angle, false);
        if reader.ok
            obj.method = value;
        end
        [~, value, reader] = readSensorField( ...
            reader, '04b', geo, angle, false);
        if reader.ok
            obj.mode = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04c', geo, angle, false);
        if reader.ok
            obj.row_count = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04d', geo, angle, false);
        if reader.ok
            obj.column_count = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04e', geo, angle, false);
        if reader.ok
            obj.row_set = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04f', geo, angle, false);
        if reader.ok
            obj.column_set = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04g', geo, angle, false);
        if reader.ok
            obj.row_rate = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04h', geo, angle, false);
        if reader.ok
            obj.column_rate = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04i', geo, angle, false);
        if reader.ok
            obj.first_pixel_row = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '04j', geo, angle, false);
        if reader.ok
            obj.first_pixel_column = value;
        end
        [count, reader] = reader.count(1, 12, 8);
        if reader.ok && ~any(count == [0 2 4 5 6 8])
            reader = reader.fail('InvalidCount', 'Invalid transform count.');
        end
        [values, reader] = reader.numbers(count, 12);
        if reader.ok
            obj.transform_param = values;
        end
    end
    [value, ~, reader] = readSensorField( ...
        reader, '05a', geo, angle, false);
    if reader.ok
        obj.reference_time = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '05b', geo, angle, false);
    if reader.ok
        obj.reference_row = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '05c', geo, angle, false);
    if reader.ok
        obj.reference_column = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06a', geo, angle, false);
    if reader.ok
        obj.latitude_or_x = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06b', geo, angle, false);
    if reader.ok
        obj.longitude_or_y = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06c', geo, angle, false);
    if reader.ok
        obj.altitude_or_z = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06d', geo, angle, false);
    if reader.ok
        obj.sensor_x_offset = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06e', geo, angle, false);
    if reader.ok
        obj.sensor_y_offset = value;
    end
    [value, ~, reader] = readSensorField( ...
        reader, '06f', geo, angle, false);
    if reader.ok
        obj.sensor_z_offset = value;
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [value, ~, reader] = readSensorField( ...
            reader, '07a', geo, angle, false);
        if reader.ok
            obj.sensor_angle_model = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07b', geo, angle, false);
        if reader.ok
            obj.sensor_angle_1 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07c', geo, angle, false);
        if reader.ok
            obj.sensor_angle_2 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07d', geo, angle, false);
        if reader.ok
            obj.sensor_angle_3 = value;
        end
        [~, value, reader] = readSensorField( ...
            reader, '07e', geo, angle, false);
        if reader.ok
            obj.platform_relative = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07f', geo, angle, false);
        if reader.ok
            obj.platform_heading = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07g', geo, angle, false);
        if reader.ok
            obj.platform_pitch = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '07h', geo, angle, false);
        if reader.ok
            obj.platform_roll = value;
        end
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [value, ~, reader] = readSensorField( ...
            reader, '08a', geo, angle, false);
        if reader.ok
            obj.icx_north_or_x = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08b', geo, angle, false);
        if reader.ok
            obj.icx_east_or_y = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08c', geo, angle, false);
        if reader.ok
            obj.icx_down_or_z = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08d', geo, angle, false);
        if reader.ok
            obj.icy_north_or_x = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08e', geo, angle, false);
        if reader.ok
            obj.icy_east_or_y = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08f', geo, angle, false);
        if reader.ok
            obj.icy_down_or_z = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08g', geo, angle, false);
        if reader.ok
            obj.icz_north_or_x = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08h', geo, angle, false);
        if reader.ok
            obj.icz_east_or_y = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '08i', geo, angle, false);
        if reader.ok
            obj.icz_down_or_z = value;
        end
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [value, ~, reader] = readSensorField( ...
            reader, '09a', geo, angle, false);
        if reader.ok
            obj.attitude_q1 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '09b', geo, angle, false);
        if reader.ok
            obj.attitude_q2 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '09c', geo, angle, false);
        if reader.ok
            obj.attitude_q3 = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '09d', geo, angle, false);
        if reader.ok
            obj.attitude_q4 = value;
        end
    end
    [included, reader] = reader.choice('YN');
    if strcmp(included, 'Y')
        [value, ~, reader] = readSensorField( ...
            reader, '10a', geo, angle, false);
        if reader.ok
            obj.velocity_north_or_x = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '10b', geo, angle, false);
        if reader.ok
            obj.velocity_east_or_y = value;
        end
        [value, ~, reader] = readSensorField( ...
            reader, '10c', geo, angle, false);
        if reader.ok
            obj.velocity_down_or_z = value;
        end
    end
    [count, reader] = reader.count(2, 28, 99);
    point = struct('point_set_type', '', 'p_row', [], 'p_column', [], ...
        'p_latitude', [], 'p_longitude', [], 'p_elevation', [], 'p_range', []);
    points = repmat(point, 1, count);
    for k = 1:count
        [points(k).point_set_type, reader] = reader.text(25);
        [number, reader] = reader.count(3, 51, 999);
        points(k).p_row = zeros(1, number);
        points(k).p_column = zeros(1, number);
        points(k).p_latitude = zeros(1, number);
        points(k).p_longitude = zeros(1, number);
        points(k).p_elevation = zeros(1, number);
        points(k).p_range = zeros(1, number);
        for j = 1:number
            [points(k).p_row(j), reader] = ...
                reader.number(8, -Inf, Inf);
            [points(k).p_column(j), reader] = ...
                reader.number(8, -Inf, Inf);
            [points(k).p_latitude(j), reader] = ...
                reader.dashed(10, -90, 90);
            [points(k).p_longitude(j), reader] = ...
                reader.dashed(11, -180, 180);
            [points(k).p_elevation(j), reader] = ...
                reader.dashed(6, -Inf, Inf);
            [points(k).p_range(j), reader] = ...
                reader.dashed(8, 0, Inf);
        end
    end
    if reader.ok
        obj.point_data = points;
    end
    [count, reader] = reader.count(2, 7, 99);
    sample = struct('numeric', [], 'text', '');
    group = struct('time_stamp_type', '', 'time_stamp_time', [], ...
        'time_stamp_value', sample);
    groups = repmat(group, 1, count);
    for k = 1:count
        [type, reader] = reader.text(3, false);
        info = sensFieldInfo(type, geo, angle);
        if reader.ok && ~info.valid
            reader = reader.fail('InvalidField', 'Unknown dynamic field.');
        end
        [number, reader] = reader.count(4, 12 + info.width, 9999);
        groups(k).time_stamp_type = type;
        groups(k).time_stamp_time = zeros(1, number);
        values = sample;
        if any(info.format == 'AD')
            values.text = repmat(' ', number, info.width);
        else
            values.numeric = zeros(1, number);
        end
        for j = 1:number
            [groups(k).time_stamp_time(j), reader] = reader.number(12);
            [numeric, word, reader] = readSensorField( ...
                reader, type, geo, angle, true);
            if reader.ok
                if any(info.format == 'AD')
                    values.text(j, :) = char(textField(word, info.width));
                else
                    values.numeric(j) = numeric;
                end
            end
        end
        groups(k).time_stamp_value = values;
    end
    if reader.ok
        obj.time_stamped_data = groups;
    end
    [count, reader] = reader.count(2, 7, 99);
    sample = struct('numeric', [], 'text', '');
    group = struct('pixel_reference_type', '', 'pixel_reference_row', [], ...
        'pixel_reference_column', [], ...
        'pixel_reference_value', sample);
    groups = repmat(group, 1, count);
    for k = 1:count
        [type, reader] = reader.text(3, false);
        info = sensFieldInfo(type, geo, angle);
        if reader.ok && ~info.valid
            reader = reader.fail('InvalidField', 'Unknown dynamic field.');
        end
        [number, reader] = reader.count(4, 16 + info.width, 9999);
        groups(k).pixel_reference_type = type;
        groups(k).pixel_reference_row = zeros(1, number);
        groups(k).pixel_reference_column = zeros(1, number);
        values = sample;
        if any(info.format == 'AD')
            values.text = repmat(' ', number, info.width);
        else
            values.numeric = zeros(1, number);
        end
        for j = 1:number
            [groups(k).pixel_reference_row(j), reader] = reader.number(8);
            [groups(k).pixel_reference_column(j), reader] = reader.number(8);
            [numeric, word, reader] = readSensorField( ...
                reader, type, geo, angle, true);
            if reader.ok
                if any(info.format == 'AD')
                    values.text(j, :) = char(textField(word, info.width));
                else
                    values.numeric(j) = numeric;
                end
            end
        end
        groups(k).pixel_reference_value = values;
    end
    if reader.ok
        obj.pixel_referenced_data = groups;
    end
    [count, reader] = reader.count(3, 32, 999);
    uncertainty = struct('uncertainty_first_type', '', ...
        'uncertainty_second_type', '', 'uncertainty_value', NaN);
    uncertainties = repmat(uncertainty, 1, count);
    for k = 1:count
        [uncertainties(k).uncertainty_first_type, reader] = reader.text(11);
        [uncertainties(k).uncertainty_second_type, reader] = reader.text(11);
        [number, reader] = reader.number(10);
        first = uncertainties(k).uncertainty_first_type;
        second = uncertainties(k).uncertainty_second_type;
        if all(second == '-')
            uncertainties(k).uncertainty_second_type = '';
            second = '';
        end
        if number == 0 && (isempty(second) || strcmp(first, second))
            % The wire zero denotes a positive sigma below 1e-99.
            number = 1e-100;
        end
        uncertainties(k).uncertainty_value = number;
    end
    [count, reader] = reader.count(3, 32, 999);
    additional = struct('parameter_name', '', 'parameter_size', 1, ...
        'parameter_value', '');
    parameters = repmat(additional, 1, count);
    for k = 1:count
        [parameters(k).parameter_name, reader] = reader.text(25);
        [width, reader] = reader.number(3, 1, 999, true);
        [number, reader] = reader.count(4, width, 9999);
        [parameters(k).parameter_value, reader] = ...
            reader.textRows(width, number, false);
        parameters(k).parameter_size = width;
    end
    if reader.ok
        obj.uncertainty_data = uncertainties;
        obj.additional_parameter_data = parameters;
    end
    reader = reader.finish();
end
