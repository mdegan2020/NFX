function result = inspectCSEXRB(data)
    %inspectCSEXRB - Independently parse the current complete exploitation TRE
    p = 1; result.image_uuid = text(36); n = number(3); result.assoc_des_uuid = cell(1,n);
    for k = 1:n, result.assoc_des_uuid{k} = text(36); end
    result.platform_id = text(6); result.payload_id = text(6); result.sensor_id = text(6);
    result.sensor_type = text(1); result.ground_ref_point = [number(12) number(12) number(12)];
    if strcmp(result.sensor_type,'S')
        result.day_first_line_image = text(8); result.time_first_line_image = number(15);
        result.time_image_duration = number(16);
    elseif strcmp(result.sensor_type,'F')
        result.time_stamp_loc = number(1);
        if result.time_stamp_loc == 0
            result.reference_frame_num = number(9); result.base_timestamp = text(24);
            result.dt_multiplier = integer(8); result.dt_size = double(integer(1));
            result.number_frames = double(integer(4)); count = double(integer(4));
            result.dt = zeros(1,count,'uint64');
            for k = 1:count, result.dt(k) = integer(result.dt_size); end
        end
    end
    result.gsd = zeros(1,7); for k = 1:7, result.gsd(k) = number(12); end
    result.gsd_beta_angle = number(5); result.dynamic_range = number(5);
    result.num_lines = number(7); result.num_samples = number(5);
    result.angles = [number(7) number(6) number(7)];
    result.flags = [number(1) number(1) number(1) number(1)];
    result.sun = [number(7) number(7)]; result.niirs = number(3);
    result.errors = [number(5) number(5)]; result.cloud_cover = number(3);
    if strcmp(result.sensor_type,'F'), result.rolling_shutter_flag = number(1); end
    result.ue_time_flag = number(1); result.reserved_len = number(5); reservedStart = p;
    if result.reserved_len > 0
        maskCount = number(2); result.reserved_field_mask = text(maskCount);
        assert(strcmp(result.reserved_field_mask,'1'),'oracle:Mask','Unsupported test mask.');
        result.reserved_len_area1 = number(5); areaStart = p;
        result.num_img_ops = number(2); result.tgt_id = sized(2); result.tgt_name = sized(2);
        result.tgt_type = sized(2); result.target = [number(9) number(10) number(8)];
        result.tgt_date_time = text(14); result.target_angles = [number(7) number(7) number(7)];
        result.coll_req_id = sized(3); result.collect_strat = sized(2); result.collect_type = sized(2);
        result.coll_code = sized(2); count = number(2); result.criteria = cell(1,count);
        for k = 1:count
            result.criteria{k} = struct('name',sized(2),'unit',sized(2),'value',sized(2));
        end
        count = number(2); result.operations = cell(1,count);
        for k = 1:count
            o = struct('cm_id',sized(2),'sensor_config',sized(2),'img_op_id',sized(2), ...
                'num_exp',number(2),'index_size',number(1),'indices',zeros(1,0,'uint64'));
            if o.index_size > 0
                n = number(2); o.indices = zeros(1,n,'uint64');
                for j = 1:n, o.indices(j) = integer(o.index_size); end
            end
            n = number(2); o.metrics = cell(1,n);
            for j = 1:n
                o.metrics{j} = struct('name',sized(2),'unit',sized(2),'type',text(1),'value',sized(2));
            end
            result.operations{k} = o;
        end
        assert(p-areaStart == result.reserved_len_area1,'oracle:AreaLength','Incorrect area-one size.');
    end
    assert(p-reservedStart == result.reserved_len,'oracle:ReservedLength','Incorrect reserved size.');
    assert(p == numel(data)+1,'oracle:Length','Unexpected trailing or missing fields.');

    function value = text(n)
        value = char(data(p:p+n-1)); p = p+n;
    end
    function value = number(n)
        value = str2double(text(n));
    end
    function value = sized(n)
        length = number(n); value = text(length);
    end
    function value = integer(n)
        value = uint64(0);
        for byte = 1:n, value = bitor(bitshift(value,8),uint64(data(p))); p = p+1; end
    end
end
