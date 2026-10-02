function value = fullSensor()
    %fullSensor - All fifteen modules with explicitly supplied sensor data
    value = fixtureSensor();
    value.content_level = 9;
    value.sensor_uri = 'sensor:test'; value.platform_uri = 'platform:test';
    value.generation_count = 1; value.generation_date = '20260915'; value.generation_time = '120001.000';
    value.detection = 'Visible'; value.row_detectors = 2; value.column_detectors = 3;
    value.row_metric = 0.2; value.column_metric = 0.3; value.focal_length = 35;
    value.row_fov = 2*atan(0.2/(2*35))*180/pi;
    value.column_fov = 2*atan(0.3/(2*35))*180/pi; value.calibrated = 'Y';
    value.calibration_unit = 'mm';
    value.principal_point_offset_x = 0.01; value.principal_point_offset_y = -0.02;
    value.radial_distort_1 = 1e-8; value.radial_distort_2 = 2e-10; value.radial_distort_3 = -3e-12;
    value.radial_distort_limit = 1; value.decent_distort_1 = 4e-10; value.decent_distort_2 = 5e-10;
    value.affinity_distort_1 = 6e-8; value.affinity_distort_2 = 7e-8; value.calibration_date = '20260801';
    value.method = 'Single Frame'; value.mode = '000'; value.row_count = 2; value.column_count = 3;
    value.row_set = 2; value.column_set = 3; value.row_rate = 0; value.column_rate = 0;
    value.first_pixel_row = 1; value.first_pixel_column = 1; value.transform_param = [1 0 0 1 0 0];
    value.reference_row = 1.5; value.reference_column = 2;
    value.sensor_angle_model = 1; value.sensor_angle_1 = 0; value.sensor_angle_2 = 0;
    value.sensor_angle_3 = 0; value.platform_relative = 'Y';
    value.platform_heading = 0; value.platform_pitch = 0; value.platform_roll = 0;
    value.icx_north_or_x = 1; value.icx_east_or_y = 0; value.icx_down_or_z = 0;
    value.icy_north_or_x = 0; value.icy_east_or_y = 1; value.icy_down_or_z = 0;
    value.icz_north_or_x = 0; value.icz_east_or_y = 0; value.icz_down_or_z = 1;
    value.attitude_q1 = 0; value.attitude_q2 = 0; value.attitude_q3 = 0; value.attitude_q4 = 1;
    value.velocity_north_or_x = 50; value.velocity_east_or_y = 0; value.velocity_down_or_z = 0;
    value.point_data = nfx.SENSRB.pointSet('Image Center',1.5,2,p_latitude=40,p_longitude=-105,p_elevation=0,p_range=1000);
    value.time_stamped_data = nfx.SENSRB.timeSeries('06a',[0 1],[40 40.001]);
    value.pixel_referenced_data = nfx.SENSRB.pixelSeries('10a',[1 2],[1 3],[50 51]);
    value.uncertainty_data = [nfx.SENSRB.uncertainty('06a',0.25) nfx.SENSRB.uncertainty('06a',0.1,'06b')];
    value.additional_parameter_data = nfx.SENSRB.additionalParameter('TEST INTERNAL PARAMETER',["ONE" "TWO"],5);
end
