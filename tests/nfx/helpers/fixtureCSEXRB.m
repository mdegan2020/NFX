function value = fixtureCSEXRB(type)
    %fixtureCSEXRB - Supply deterministic exploitation or sensor-model fields
    if nargin == 0, type = ''; end
    value = nfx.CSEXRB(image_uuid='10000000-0000-4000-8000-000000000001', ...
        platform_id='PLAT',payload_id='PAYLD',sensor_id='SENSOR',num_lines=32,num_samples=64);
    if isempty(type), return; end
    value.sensor_type = type;
    value.assoc_des_uuid = {'20000000-0000-4000-8000-000000000001', ...
        '20000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000003', ...
        '20000000-0000-4000-8000-000000000004'};
    if strcmp(type,'S')
        value.day_first_line_image = '20260915'; value.time_first_line_image = 1.25;
        value.time_image_duration = -0.5;
    else
        value.time_stamp_loc = 0; value.base_timestamp = '20260915235959.123456789';
        value.number_frames = 1;
    end
end
