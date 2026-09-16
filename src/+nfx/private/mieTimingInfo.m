function timing = mieTimingInfo(data) %#codegen
    %mieTimingInfo - Recover exact timing from an already validated snapshot
    width = double(data(144)); count = double(unsigned(data(149:152)));
    deltas = zeros(1,count,'uint64');
    for k = 1:count, deltas(k) = unsigned(data(153+width*(k-1):152+width*k)); end
    timing = nfx.MTIMSA(image_seg_index=number(data,1,3),geocoords_static=number(data,4,2), ...
        layer_id=strtrim(char(data(6:41))),camera_set_index=number(data,42,3),camera_id=strtrim(char(data(45:80))), ...
        time_interval_index=number(data,81,6),temp_block_index=number(data,87,3), ...
        nominal_frame_rate=number(data,90,13),reference_frame_num=number(data,103,9), ...
        base_timestamp=char(data(112:135)),dt_multiplier=unsigned(data(136:143)), ...
        number_frames=double(unsigned(data(145:148))),dt=deltas,dt_size=width);
end

function value = unsigned(data) %#codegen
    %unsigned - Read a native unsigned integer without double intermediates
    value = uint64(0);
    for k = 1:numel(data), value = bitor(bitshift(value,8),uint64(data(k))); end
end

function value = number(data,at,width) %#codegen
    %number - Read an ASCII field including its NaN or blank sentinel
    value = str2double(char(data(at:at+width-1)));
end
