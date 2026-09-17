function displayTRERecords(records) %#codegen
    %displayTRERecords - Dispatch only presentation by the encoded tag
    switch records(1).tag
        case 'ACFTB '
            showACFTB(records);
        case 'AIMIDB'
            showAIMIDB(records);
        case 'BANDSB'
            showBANDSB(records);
        case 'CAMSDA'
            showCAMSDA(records);
        case 'CONTXA'
            showCONTXA(records);
        case 'CSCRNA'
            showCSCRNA(records);
        case 'CSDIDA'
            showCSDIDA(records);
        case 'CSEXRB'
            showCSEXRB(records);
        case 'CSRLSB'
            showCSRLSB(records);
        case 'CSWRPB'
            showCSWRPB(records);
        case 'FASYWA'
            showFASYWA(records);
        case 'FCRNSA'
            showFCRNSA(records);
        case 'FREESA'
            showFREESA(records);
        case 'FSYNWA'
            showFSYNWA(records);
        case 'HISTOA'
            showHISTOA(records);
        case 'ICHIPB'
            showICHIPB(records);
        case 'ILLUMB'
            showILLUMB(records);
        case 'J2KLRA'
            showJ2KLRA(records);
        case 'MATESA'
            showMATESA(records);
        case 'MICIDA'
            showMICIDA(records);
        case 'MIMCSA'
            showMIMCSA(records);
        case 'MTIMFA'
            showMTIMFA(records);
        case 'MTIMSA'
            showMTIMSA(records);
        case 'RPC00B'
            showRPC00B(records);
        case 'RSMAPB'
            showRSMAPB(records);
        case 'RSMDCB'
            showRSMDCB(records);
        case 'RSMECB'
            showRSMECB(records);
        case 'RSMGGA'
            showRSMGGA(records);
        case 'RSMGIA'
            showRSMGIA(records);
        case 'RSMIDA'
            showRSMIDA(records);
        case 'RSMPCA'
            showRSMPCA(records);
        case 'RSMPIA'
            showRSMPIA(records);
        case 'SENSRB'
            showSENSRB(records);
        case 'TMINTA'
            showTMINTA(records);
        otherwise
            fprintf('    No concrete decoder supports this tag.\n');
    end
end

function showACFTB(records) %#codegen
    %showACFTB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.ACFTB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('ac_msn_id', obj.ac_msn_id);
    printTREField('ac_tail_no', obj.ac_tail_no);
    printTREField('ac_to', obj.ac_to);
    printTREField('sensor_id_type', obj.sensor_id_type);
    printTREField('sensor_id', obj.sensor_id);
    printTREField('scene_source', obj.scene_source);
    printTREField('scnum', obj.scnum);
    printTREField('pdate', obj.pdate);
    printTREField('imhostno', obj.imhostno);
    printTREField('imreqid', obj.imreqid);
    printTREField('mplan', obj.mplan);
    printTREField('entloc', obj.entloc);
    printTREField('loc_accy', obj.loc_accy);
    printTREField('entelv', obj.entelv);
    printTREField('elv_unit', obj.elv_unit);
    printTREField('exitloc', obj.exitloc);
    printTREField('exitelv', obj.exitelv);
    printTREField('tmap', obj.tmap);
    printTREField('row_spacing', obj.row_spacing);
    printTREField('row_spacing_units', obj.row_spacing_units);
    printTREField('col_spacing', obj.col_spacing);
    printTREField('col_spacing_units', obj.col_spacing_units);
    printTREField('focal_length', obj.focal_length);
    printTREField('senserial', obj.senserial);
    printTREField('abswver', obj.abswver);
    printTREField('cal_date', obj.cal_date);
    printTREField('patch_tot', obj.patch_tot);
    printTREField('mti_tot', obj.mti_tot);
end

function showAIMIDB(records) %#codegen
    %showAIMIDB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.AIMIDB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('acquisition_date', obj.acquisition_date);
    printTREField('mission_no', obj.mission_no);
    printTREField('mission_identification', obj.mission_identification);
    printTREField('flight_no', obj.flight_no);
    printTREField('op_num', obj.op_num);
    printTREField('current_segment', obj.current_segment);
    printTREField('repro_num', obj.repro_num);
    printTREField('replay', obj.replay);
    printTREField('start_tile_column', obj.start_tile_column);
    printTREField('start_tile_row', obj.start_tile_row);
    printTREField('end_segment', obj.end_segment);
    printTREField('end_tile_column', obj.end_tile_column);
    printTREField('end_tile_row', obj.end_tile_row);
    printTREField('country', obj.country);
    printTREField('location', obj.location);
end

function showBANDSB(records) %#codegen
    %showBANDSB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.BANDSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('radiometric_quantity', obj.radiometric_quantity);
    printTREField('radiometric_quantity_unit', obj.radiometric_quantity_unit);
    printTREField('scale_factor', obj.scale_factor);
    printTREField('additive_factor', obj.additive_factor);
    printTREField('atmospheric_adjustment_altitude', obj.atmospheric_adjustment_altitude);
    printTREField('row_gsd', obj.row_gsd);
    printTREField('col_gsd', obj.col_gsd);
    printTREField('spt_resp_row', obj.spt_resp_row);
    printTREField('spt_resp_col', obj.spt_resp_col);
    printTREField('row_gsd_unit', obj.row_gsd_unit);
    printTREField('col_gsd_unit', obj.col_gsd_unit);
    printTREField('spt_resp_unit_row', obj.spt_resp_unit_row);
    printTREField('spt_resp_unit_col', obj.spt_resp_unit_col);
    printTREField('wave_length_unit', obj.wave_length_unit);
    printTREField('radiometric_adjustment_surface', obj.radiometric_adjustment_surface);
    printTREField('diameter', obj.diameter);
    printTREField('data_fld_1', obj.data_fld_1);
    printTREField('data_fld_2', obj.data_fld_2);
    printTREField('band', obj.band);
    printTREField('aux_b', obj.aux_b);
    printTREField('aux_c', obj.aux_c);
end

function showCAMSDA(records) %#codegen
    %showCAMSDA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CAMSDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('camera_sets', obj.camera_sets);
    printTREField('first_camera_set_in_tre', obj.first_camera_set_in_tre);
end

function showCONTXA(records) %#codegen
    %showCONTXA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CONTXA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('context_type', obj.context_type);
    printTREField('aggregation_mode', obj.aggregation_mode);
    printTREField('index_list', obj.index_list);
    printTREField('tre_ids', obj.tre_ids);
    printTREField('tre_tags', obj.tre_tags);
end

function showCSCRNA(records) %#codegen
    %showCSCRNA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSCRNA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('predict_corners', obj.predict_corners);
    printTREField('ulcrn_lat', obj.ulcrn_lat);
    printTREField('ulcrn_lon', obj.ulcrn_lon);
    printTREField('ulcrn_ht', obj.ulcrn_ht);
    printTREField('urcrn_lat', obj.urcrn_lat);
    printTREField('urcrn_lon', obj.urcrn_lon);
    printTREField('urcrn_ht', obj.urcrn_ht);
    printTREField('lrcrn_lat', obj.lrcrn_lat);
    printTREField('lrcrn_lon', obj.lrcrn_lon);
    printTREField('lrcrn_ht', obj.lrcrn_ht);
    printTREField('llcrn_lat', obj.llcrn_lat);
    printTREField('llcrn_lon', obj.llcrn_lon);
    printTREField('llcrn_ht', obj.llcrn_ht);
end

function showCSDIDA(records) %#codegen
    %showCSDIDA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSDIDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('platform_code', obj.platform_code);
    printTREField('vehicle_id', obj.vehicle_id);
    printTREField('pass', obj.pass);
    printTREField('operation', obj.operation);
    printTREField('sensor_id', obj.sensor_id);
    printTREField('product_id', obj.product_id);
    printTREField('time', obj.time);
    printTREField('process_time', obj.process_time);
    printTREField('software_version_number', obj.software_version_number);
end

function showCSEXRB(records) %#codegen
    %showCSEXRB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSEXRB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('image_uuid', obj.image_uuid);
    printTREField('assoc_des_uuid', obj.assoc_des_uuid);
    printTREField('platform_id', obj.platform_id);
    printTREField('payload_id', obj.payload_id);
    printTREField('sensor_id', obj.sensor_id);
    printTREField('sensor_type', obj.sensor_type);
    printTREField('ground_ref_point_x', obj.ground_ref_point_x);
    printTREField('ground_ref_point_y', obj.ground_ref_point_y);
    printTREField('ground_ref_point_z', obj.ground_ref_point_z);
    printTREField('day_first_line_image', obj.day_first_line_image);
    printTREField('time_first_line_image', obj.time_first_line_image);
    printTREField('time_image_duration', obj.time_image_duration);
    printTREField('time_stamp_loc', obj.time_stamp_loc);
    printTREField('reference_frame_num', obj.reference_frame_num);
    printTREField('base_timestamp', obj.base_timestamp);
    printTREField('dt_multiplier', obj.dt_multiplier);
    printTREField('number_frames', obj.number_frames);
    printTREField('dt', obj.dt);
    printTREField('max_gsd', obj.max_gsd);
    printTREField('along_scan_gsd', obj.along_scan_gsd);
    printTREField('cross_scan_gsd', obj.cross_scan_gsd);
    printTREField('geo_mean_gsd', obj.geo_mean_gsd);
    printTREField('a_s_vert_gsd', obj.a_s_vert_gsd);
    printTREField('c_s_vert_gsd', obj.c_s_vert_gsd);
    printTREField('geo_mean_vert_gsd', obj.geo_mean_vert_gsd);
    printTREField('gsd_beta_angle', obj.gsd_beta_angle);
    printTREField('dynamic_range', obj.dynamic_range);
    printTREField('num_lines', obj.num_lines);
    printTREField('num_samples', obj.num_samples);
    printTREField('angle_to_north', obj.angle_to_north);
    printTREField('obliquity_angle', obj.obliquity_angle);
    printTREField('az_of_obliquity', obj.az_of_obliquity);
    printTREField('atm_refr_flag', obj.atm_refr_flag);
    printTREField('vel_aber_flag', obj.vel_aber_flag);
    printTREField('grd_cover', obj.grd_cover);
    printTREField('snow_depth_category', obj.snow_depth_category);
    printTREField('sun_azimuth', obj.sun_azimuth);
    printTREField('sun_elevation', obj.sun_elevation);
    printTREField('predicted_niirs', obj.predicted_niirs);
    printTREField('circl_err', obj.circl_err);
    printTREField('linear_err', obj.linear_err);
    printTREField('cloud_cover', obj.cloud_cover);
    printTREField('rolling_shutter_flag', obj.rolling_shutter_flag);
    printTREField('ue_time_flag', obj.ue_time_flag);
    printTREField('exploitation', obj.exploitation);
end

function showCSRLSB(records) %#codegen
    %showCSRLSB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSRLSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('rs_dt_1', obj.rs_dt_1);
    printTREField('rs_dt_2', obj.rs_dt_2);
    printTREField('rs_dt_3', obj.rs_dt_3);
    printTREField('rs_dt_4', obj.rs_dt_4);
end

function showCSWRPB(records) %#codegen
    %showCSWRPB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSWRPB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sensor_type', obj.sensor_type);
    printTREField('wrp_interp', obj.wrp_interp);
    printTREField('warp_data', obj.warp_data);
end

function showFASYWA(records) %#codegen
    %showFASYWA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.FASYWA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('start_timestamp', obj.start_timestamp);
    printTREField('end_timestamp', obj.end_timestamp);
    printTREField('tre_ids', obj.tre_ids);
    printTREField('tre_tags', obj.tre_tags);
end

function showFCRNSA(records) %#codegen
    %showFCRNSA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.FCRNSA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('predict_corners', obj.predict_corners);
    printTREField('ulcrn_lat', obj.ulcrn_lat);
    printTREField('ulcrn_lon', obj.ulcrn_lon);
    printTREField('ulcrn_ht', obj.ulcrn_ht);
    printTREField('urcrn_lat', obj.urcrn_lat);
    printTREField('urcrn_lon', obj.urcrn_lon);
    printTREField('urcrn_ht', obj.urcrn_ht);
    printTREField('lrcrn_lat', obj.lrcrn_lat);
    printTREField('lrcrn_lon', obj.lrcrn_lon);
    printTREField('lrcrn_ht', obj.lrcrn_ht);
    printTREField('llcrn_lat', obj.llcrn_lat);
    printTREField('llcrn_lon', obj.llcrn_lon);
    printTREField('llcrn_ht', obj.llcrn_ht);
end

function showFREESA(records) %#codegen
    %showFREESA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.FREESA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('count', obj.count);
end

function showFSYNWA(records) %#codegen
    %showFSYNWA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.FSYNWA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('start_frame_number', obj.start_frame_number);
    printTREField('end_frame_number', obj.end_frame_number);
    printTREField('tre_ids', obj.tre_ids);
    printTREField('tre_tags', obj.tre_tags);
end

function showHISTOA(records) %#codegen
    %showHISTOA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.HISTOA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('systype', obj.systype);
    printTREField('pc', obj.pc);
    printTREField('pe', obj.pe);
    printTREField('remap_flag', obj.remap_flag);
    printTREField('lutid', obj.lutid);
    printTREField('event', obj.event);
end

function showICHIPB(records) %#codegen
    %showICHIPB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.ICHIPB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('xfrm_flag', obj.xfrm_flag);
    printTREField('scale_factor', obj.scale_factor);
    printTREField('anamrph_corr', obj.anamrph_corr);
    printTREField('scanblk_num', obj.scanblk_num);
    printTREField('op_row_11', obj.op_row_11);
    printTREField('op_col_11', obj.op_col_11);
    printTREField('op_row_12', obj.op_row_12);
    printTREField('op_col_12', obj.op_col_12);
    printTREField('op_row_21', obj.op_row_21);
    printTREField('op_col_21', obj.op_col_21);
    printTREField('op_row_22', obj.op_row_22);
    printTREField('op_col_22', obj.op_col_22);
    printTREField('fi_row_11', obj.fi_row_11);
    printTREField('fi_col_11', obj.fi_col_11);
    printTREField('fi_row_12', obj.fi_row_12);
    printTREField('fi_col_12', obj.fi_col_12);
    printTREField('fi_row_21', obj.fi_row_21);
    printTREField('fi_col_21', obj.fi_col_21);
    printTREField('fi_row_22', obj.fi_row_22);
    printTREField('fi_col_22', obj.fi_col_22);
    printTREField('fi_row', obj.fi_row);
    printTREField('fi_col', obj.fi_col);
end

function showILLUMB(records) %#codegen
    %showILLUMB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.ILLUMB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('lbound', obj.lbound);
    printTREField('ubound', obj.ubound);
    printTREField('band_unit', obj.band_unit);
    printTREField('geo_datum', obj.geo_datum);
    printTREField('geo_datum_code', obj.geo_datum_code);
    printTREField('ellipsoid_name', obj.ellipsoid_name);
    printTREField('ellipsoid_code', obj.ellipsoid_code);
    printTREField('vertical_datum_ref', obj.vertical_datum_ref);
    printTREField('vertical_ref_code', obj.vertical_ref_code);
    printTREField('rad_quantity', obj.rad_quantity);
    printTREField('radq_unit', obj.radq_unit);
    printTREField('target_lat', obj.target_lat);
    printTREField('target_lon', obj.target_lon);
    printTREField('target_hgt', obj.target_hgt);
    printTREField('sun_azimuth', obj.sun_azimuth);
    printTREField('sun_elev', obj.sun_elev);
    printTREField('moon_azimuth', obj.moon_azimuth);
    printTREField('moon_elev', obj.moon_elev);
    printTREField('moon_phase_angle', obj.moon_phase_angle);
    printTREField('moon_illum_percent', obj.moon_illum_percent);
    printTREField('other_azimuth', obj.other_azimuth);
    printTREField('other_elev', obj.other_elev);
    printTREField('sensor_azimuth', obj.sensor_azimuth);
    printTREField('sensor_elev', obj.sensor_elev);
    printTREField('cats_angle', obj.cats_angle);
    printTREField('sun_glint_lat', obj.sun_glint_lat);
    printTREField('sun_glint_lon', obj.sun_glint_lon);
    printTREField('catm_angle', obj.catm_angle);
    printTREField('moon_glint_lat', obj.moon_glint_lat);
    printTREField('moon_glint_lon', obj.moon_glint_lon);
    printTREField('sol_lun_dist_adjust', obj.sol_lun_dist_adjust);
    printTREField('sun_illum', obj.sun_illum);
    printTREField('moon_illum', obj.moon_illum);
    printTREField('tot_sunmoon_illum', obj.tot_sunmoon_illum);
    printTREField('other_illum', obj.other_illum);
    printTREField('art_illum_min', obj.art_illum_min);
    printTREField('art_illum_max', obj.art_illum_max);
    printTREField('sun_illum_method', obj.sun_illum_method);
    printTREField('moon_illum_method', obj.moon_illum_method);
    printTREField('other_illum_method', obj.other_illum_method);
    printTREField('art_illum_method', obj.art_illum_method);
    printTREField('coordinate_precision', obj.coordinate_precision);
end

function showJ2KLRA(records) %#codegen
    %showJ2KLRA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.J2KLRA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('orig', obj.orig);
    printTREField('nlevels_o', obj.nlevels_o);
    printTREField('nbands_o', obj.nbands_o);
    printTREField('layer_id', obj.layer_id);
    printTREField('bitrate', obj.bitrate);
end

function showMATESA(records) %#codegen
    %showMATESA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MATESA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('cur_source', obj.cur_source);
    printTREField('cur_mate_type', obj.cur_mate_type);
    printTREField('cur_file_id', obj.cur_file_id);
    printTREField('groups', obj.groups);
end

function showMICIDA(records) %#codegen
    %showMICIDA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MICIDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('cameras', obj.cameras);
end

function showMIMCSA(records) %#codegen
    %showMIMCSA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MIMCSA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('layer_id', obj.layer_id);
    printTREField('nominal_frame_rate', obj.nominal_frame_rate);
    printTREField('min_frame_rate', obj.min_frame_rate);
    printTREField('max_frame_rate', obj.max_frame_rate);
    printTREField('t_rset', obj.t_rset);
    printTREField('mi_req_decoder', obj.mi_req_decoder);
    printTREField('mi_req_profile', obj.mi_req_profile);
    printTREField('mi_req_level', obj.mi_req_level);
end

function showMTIMFA(records) %#codegen
    %showMTIMFA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MTIMFA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('layer_id', obj.layer_id);
    printTREField('camera_set_index', obj.camera_set_index);
    printTREField('time_interval_index', obj.time_interval_index);
    printTREField('cameras', obj.cameras);
end

function showMTIMSA(records) %#codegen
    %showMTIMSA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MTIMSA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('image_seg_index', obj.image_seg_index);
    printTREField('geocoords_static', obj.geocoords_static);
    printTREField('layer_id', obj.layer_id);
    printTREField('camera_set_index', obj.camera_set_index);
    printTREField('camera_id', obj.camera_id);
    printTREField('time_interval_index', obj.time_interval_index);
    printTREField('temp_block_index', obj.temp_block_index);
    printTREField('nominal_frame_rate', obj.nominal_frame_rate);
    printTREField('reference_frame_num', obj.reference_frame_num);
    printTREField('base_timestamp', obj.base_timestamp);
    printTREField('dt_multiplier', obj.dt_multiplier);
    printTREField('number_frames', obj.number_frames);
    printTREField('dt', obj.dt);
end

function showRPC00B(records) %#codegen
    %showRPC00B - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RPC00B(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('err_bias', obj.err_bias);
    printTREField('err_rand', obj.err_rand);
    printTREField('line_off', obj.line_off);
    printTREField('samp_off', obj.samp_off);
    printTREField('lat_off', obj.lat_off);
    printTREField('long_off', obj.long_off);
    printTREField('height_off', obj.height_off);
    printTREField('line_scale', obj.line_scale);
    printTREField('samp_scale', obj.samp_scale);
    printTREField('lat_scale', obj.lat_scale);
    printTREField('long_scale', obj.long_scale);
    printTREField('height_scale', obj.height_scale);
    printTREField('line_num_coeff', obj.line_num_coeff);
    printTREField('line_den_coeff', obj.line_den_coeff);
    printTREField('samp_num_coeff', obj.samp_num_coeff);
    printTREField('samp_den_coeff', obj.samp_den_coeff);
end

function showRSMAPB(records) %#codegen
    %showRSMAPB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMAPB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('parameters', obj.parameters);
    printTREField('parval', obj.parval);
end

function showRSMDCB(records) %#codegen
    %showRSMDCB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMDCB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('parameters', obj.parameters);
    printTREField('blocks', obj.blocks);
end

function showRSMECB(records) %#codegen
    %showRSMECB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMECB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('cvdate', obj.cvdate);
    printTREField('parameters', obj.parameters);
    printTREField('subgroups', obj.subgroups);
    printTREField('map', obj.map);
    printTREField('urr', obj.urr);
    printTREField('urc', obj.urc);
    printTREField('ucc', obj.ucc);
    printTREField('row_correlation', obj.row_correlation);
    printTREField('column_correlation', obj.column_correlation);
end

function showRSMGGA(records) %#codegen
    %showRSMGGA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMGGA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('ggrsn', obj.ggrsn);
    printTREField('ggcsn', obj.ggcsn);
    printTREField('ggrfep', obj.ggrfep);
    printTREField('ggcfep', obj.ggcfep);
    printTREField('intord', obj.intord);
    printTREField('deltaz', obj.deltaz);
    printTREField('deltax', obj.deltax);
    printTREField('deltay', obj.deltay);
    printTREField('zpln1', obj.zpln1);
    printTREField('xipln1', obj.xipln1);
    printTREField('yipln1', obj.yipln1);
    printTREField('refrow', obj.refrow);
    printTREField('refcol', obj.refcol);
    printTREField('fnumrd', obj.fnumrd);
    printTREField('fnumcd', obj.fnumcd);
    printTREField('planes', obj.planes);
end

function showRSMGIA(records) %#codegen
    %showRSMGIA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMGIA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('gr0', obj.gr0);
    printTREField('grx', obj.grx);
    printTREField('gry', obj.gry);
    printTREField('grz', obj.grz);
    printTREField('grxx', obj.grxx);
    printTREField('grxy', obj.grxy);
    printTREField('grxz', obj.grxz);
    printTREField('gryy', obj.gryy);
    printTREField('gryz', obj.gryz);
    printTREField('grzz', obj.grzz);
    printTREField('gc0', obj.gc0);
    printTREField('gcx', obj.gcx);
    printTREField('gcy', obj.gcy);
    printTREField('gcz', obj.gcz);
    printTREField('gcxx', obj.gcxx);
    printTREField('gcxy', obj.gcxy);
    printTREField('gcxz', obj.gcxz);
    printTREField('gcyy', obj.gcyy);
    printTREField('gcyz', obj.gcyz);
    printTREField('gczz', obj.gczz);
    printTREField('grnis', obj.grnis);
    printTREField('gcnis', obj.gcnis);
    printTREField('grssiz', obj.grssiz);
    printTREField('gcssiz', obj.gcssiz);
end

function showRSMIDA(records) %#codegen
    %showRSMIDA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMIDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('isid', obj.isid);
    printTREField('sid', obj.sid);
    printTREField('stid', obj.stid);
    printTREField('grndd', obj.grndd);
    printTREField('year', obj.year);
    printTREField('month', obj.month);
    printTREField('day', obj.day);
    printTREField('hour', obj.hour);
    printTREField('minute', obj.minute);
    printTREField('second', obj.second);
    printTREField('nrg', obj.nrg);
    printTREField('ncg', obj.ncg);
    printTREField('fullr', obj.fullr);
    printTREField('fullc', obj.fullc);
    printTREField('minr', obj.minr);
    printTREField('maxr', obj.maxr);
    printTREField('minc', obj.minc);
    printTREField('maxc', obj.maxc);
    printTREField('trg', obj.trg);
    printTREField('tcg', obj.tcg);
    printTREField('xuor', obj.xuor);
    printTREField('yuor', obj.yuor);
    printTREField('zuor', obj.zuor);
    printTREField('xuxr', obj.xuxr);
    printTREField('xuyr', obj.xuyr);
    printTREField('xuzr', obj.xuzr);
    printTREField('yuxr', obj.yuxr);
    printTREField('yuyr', obj.yuyr);
    printTREField('yuzr', obj.yuzr);
    printTREField('zuxr', obj.zuxr);
    printTREField('zuyr', obj.zuyr);
    printTREField('zuzr', obj.zuzr);
    printTREField('v1x', obj.v1x);
    printTREField('v1y', obj.v1y);
    printTREField('v1z', obj.v1z);
    printTREField('v2x', obj.v2x);
    printTREField('v2y', obj.v2y);
    printTREField('v2z', obj.v2z);
    printTREField('v3x', obj.v3x);
    printTREField('v3y', obj.v3y);
    printTREField('v3z', obj.v3z);
    printTREField('v4x', obj.v4x);
    printTREField('v4y', obj.v4y);
    printTREField('v4z', obj.v4z);
    printTREField('v5x', obj.v5x);
    printTREField('v5y', obj.v5y);
    printTREField('v5z', obj.v5z);
    printTREField('v6x', obj.v6x);
    printTREField('v6y', obj.v6y);
    printTREField('v6z', obj.v6z);
    printTREField('v7x', obj.v7x);
    printTREField('v7y', obj.v7y);
    printTREField('v7z', obj.v7z);
    printTREField('v8x', obj.v8x);
    printTREField('v8y', obj.v8y);
    printTREField('v8z', obj.v8z);
    printTREField('grpx', obj.grpx);
    printTREField('grpy', obj.grpy);
    printTREField('grpz', obj.grpz);
    printTREField('ie0', obj.ie0);
    printTREField('ier', obj.ier);
    printTREField('iec', obj.iec);
    printTREField('ierr', obj.ierr);
    printTREField('ierc', obj.ierc);
    printTREField('iecc', obj.iecc);
    printTREField('ia0', obj.ia0);
    printTREField('iar', obj.iar);
    printTREField('iac', obj.iac);
    printTREField('iarr', obj.iarr);
    printTREField('iarc', obj.iarc);
    printTREField('iacc', obj.iacc);
    printTREField('spx', obj.spx);
    printTREField('svx', obj.svx);
    printTREField('sax', obj.sax);
    printTREField('spy', obj.spy);
    printTREField('svy', obj.svy);
    printTREField('say', obj.say);
    printTREField('spz', obj.spz);
    printTREField('svz', obj.svz);
    printTREField('saz', obj.saz);
end

function showRSMPCA(records) %#codegen
    %showRSMPCA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMPCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('rsn', obj.rsn);
    printTREField('csn', obj.csn);
    printTREField('rfep', obj.rfep);
    printTREField('cfep', obj.cfep);
    printTREField('rnrmo', obj.rnrmo);
    printTREField('cnrmo', obj.cnrmo);
    printTREField('xnrmo', obj.xnrmo);
    printTREField('ynrmo', obj.ynrmo);
    printTREField('znrmo', obj.znrmo);
    printTREField('rnrmsf', obj.rnrmsf);
    printTREField('cnrmsf', obj.cnrmsf);
    printTREField('xnrmsf', obj.xnrmsf);
    printTREField('ynrmsf', obj.ynrmsf);
    printTREField('znrmsf', obj.znrmsf);
    printTREField('rnpcf', obj.rnpcf);
    printTREField('rdpcf', obj.rdpcf);
    printTREField('cnpcf', obj.cnpcf);
    printTREField('cdpcf', obj.cdpcf);
end

function showRSMPIA(records) %#codegen
    %showRSMPIA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.RSMPIA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('r0', obj.r0);
    printTREField('rx', obj.rx);
    printTREField('ry', obj.ry);
    printTREField('rz', obj.rz);
    printTREField('rxx', obj.rxx);
    printTREField('rxy', obj.rxy);
    printTREField('rxz', obj.rxz);
    printTREField('ryy', obj.ryy);
    printTREField('ryz', obj.ryz);
    printTREField('rzz', obj.rzz);
    printTREField('c0', obj.c0);
    printTREField('cx', obj.cx);
    printTREField('cy', obj.cy);
    printTREField('cz', obj.cz);
    printTREField('cxx', obj.cxx);
    printTREField('cxy', obj.cxy);
    printTREField('cxz', obj.cxz);
    printTREField('cyy', obj.cyy);
    printTREField('cyz', obj.cyz);
    printTREField('czz', obj.czz);
    printTREField('rnis', obj.rnis);
    printTREField('cnis', obj.cnis);
    printTREField('rssiz', obj.rssiz);
    printTREField('cssiz', obj.cssiz);
end

function showSENSRB(records) %#codegen
    %showSENSRB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.SENSRB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sensor', obj.sensor);
    printTREField('sensor_uri', obj.sensor_uri);
    printTREField('platform', obj.platform);
    printTREField('platform_uri', obj.platform_uri);
    printTREField('operation_domain', obj.operation_domain);
    printTREField('content_level', obj.content_level);
    printTREField('geodetic_system', obj.geodetic_system);
    printTREField('geodetic_type', obj.geodetic_type);
    printTREField('elevation_datum', obj.elevation_datum);
    printTREField('length_unit', obj.length_unit);
    printTREField('angular_unit', obj.angular_unit);
    printTREField('start_date', obj.start_date);
    printTREField('start_time', obj.start_time);
    printTREField('end_date', obj.end_date);
    printTREField('end_time', obj.end_time);
    printTREField('generation_count', obj.generation_count);
    printTREField('generation_date', obj.generation_date);
    printTREField('generation_time', obj.generation_time);
    printTREField('detection', obj.detection);
    printTREField('row_detectors', obj.row_detectors);
    printTREField('column_detectors', obj.column_detectors);
    printTREField('row_metric', obj.row_metric);
    printTREField('column_metric', obj.column_metric);
    printTREField('focal_length', obj.focal_length);
    printTREField('row_fov', obj.row_fov);
    printTREField('column_fov', obj.column_fov);
    printTREField('calibrated', obj.calibrated);
    printTREField('calibration_unit', obj.calibration_unit);
    printTREField('principal_point_offset_x', obj.principal_point_offset_x);
    printTREField('principal_point_offset_y', obj.principal_point_offset_y);
    printTREField('radial_distort_1', obj.radial_distort_1);
    printTREField('radial_distort_2', obj.radial_distort_2);
    printTREField('radial_distort_3', obj.radial_distort_3);
    printTREField('radial_distort_limit', obj.radial_distort_limit);
    printTREField('decent_distort_1', obj.decent_distort_1);
    printTREField('decent_distort_2', obj.decent_distort_2);
    printTREField('affinity_distort_1', obj.affinity_distort_1);
    printTREField('affinity_distort_2', obj.affinity_distort_2);
    printTREField('calibration_date', obj.calibration_date);
    printTREField('method', obj.method);
    printTREField('mode', obj.mode);
    printTREField('row_count', obj.row_count);
    printTREField('column_count', obj.column_count);
    printTREField('row_set', obj.row_set);
    printTREField('column_set', obj.column_set);
    printTREField('row_rate', obj.row_rate);
    printTREField('column_rate', obj.column_rate);
    printTREField('first_pixel_row', obj.first_pixel_row);
    printTREField('first_pixel_column', obj.first_pixel_column);
    printTREField('reference_time', obj.reference_time);
    printTREField('reference_row', obj.reference_row);
    printTREField('reference_column', obj.reference_column);
    printTREField('latitude_or_x', obj.latitude_or_x);
    printTREField('longitude_or_y', obj.longitude_or_y);
    printTREField('altitude_or_z', obj.altitude_or_z);
    printTREField('sensor_x_offset', obj.sensor_x_offset);
    printTREField('sensor_y_offset', obj.sensor_y_offset);
    printTREField('sensor_z_offset', obj.sensor_z_offset);
    printTREField('sensor_angle_model', obj.sensor_angle_model);
    printTREField('sensor_angle_1', obj.sensor_angle_1);
    printTREField('sensor_angle_2', obj.sensor_angle_2);
    printTREField('sensor_angle_3', obj.sensor_angle_3);
    printTREField('platform_relative', obj.platform_relative);
    printTREField('platform_heading', obj.platform_heading);
    printTREField('platform_pitch', obj.platform_pitch);
    printTREField('platform_roll', obj.platform_roll);
    printTREField('icx_north_or_x', obj.icx_north_or_x);
    printTREField('icx_east_or_y', obj.icx_east_or_y);
    printTREField('icx_down_or_z', obj.icx_down_or_z);
    printTREField('icy_north_or_x', obj.icy_north_or_x);
    printTREField('icy_east_or_y', obj.icy_east_or_y);
    printTREField('icy_down_or_z', obj.icy_down_or_z);
    printTREField('icz_north_or_x', obj.icz_north_or_x);
    printTREField('icz_east_or_y', obj.icz_east_or_y);
    printTREField('icz_down_or_z', obj.icz_down_or_z);
    printTREField('attitude_q1', obj.attitude_q1);
    printTREField('attitude_q2', obj.attitude_q2);
    printTREField('attitude_q3', obj.attitude_q3);
    printTREField('attitude_q4', obj.attitude_q4);
    printTREField('velocity_north_or_x', obj.velocity_north_or_x);
    printTREField('velocity_east_or_y', obj.velocity_east_or_y);
    printTREField('velocity_down_or_z', obj.velocity_down_or_z);
    printTREField('transform_param', obj.transform_param);
    printTREField('point_data', obj.point_data);
    printTREField('time_stamped_data', obj.time_stamped_data);
    printTREField('pixel_referenced_data', obj.pixel_referenced_data);
    printTREField('uncertainty_data', obj.uncertainty_data);
    printTREField('additional_parameter_data', obj.additional_parameter_data);
end

function showTMINTA(records) %#codegen
    %showTMINTA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.TMINTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('intervals', obj.intervals);
end
