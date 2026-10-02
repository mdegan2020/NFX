function displayTRERecords(records) %#codegen
    %displayTRERecords - Dispatch only presentation by the encoded tag
    switch records(1).tag
        % BEGIN published TRE display dispatch
        case 'ACCHZB'
            showACCHZB(records);
        case 'ACCPOB'
            showACCPOB(records);
        case 'ACCVTB'
            showACCVTB(records);
        case 'ASTORA'
            showASTORA(records);
        case 'ATTPTA'
            showATTPTA(records);
        case 'BCHIPA'
            showBCHIPA(records);
        case 'BNDPLB'
            showBNDPLB(records);
        case 'CCINFA'
            showCCINFA(records);
        case 'COMNTA'
            showCOMNTA(records);
        case 'CSEPHA'
            showCSEPHA(records);
        case 'CSEXRA'
            showCSEXRA(records);
        case 'CSPROA'
            showCSPROA(records);
        case 'CSSFAA'
            showCSSFAA(records);
        case 'EXOPTA'
            showEXOPTA(records);
        case 'EXPLTB'
            showEXPLTB(records);
        case 'FACCBB'
            showFACCBB(records);
        case 'GEOLOB'
            showGEOLOB(records);
        case 'GRDPSB'
            showGRDPSB(records);
        case 'IOMAPA'
            showIOMAPA(records);
        case 'ISACPA'
            showISACPA(records);
        case 'ISASIA'
            showISASIA(records);
        case 'ISATPA'
            showISATPA(records);
        case 'J2KLRB'
            showJ2KLRB(records);
        case 'MAPLOB'
            showMAPLOB(records);
        case 'MENSRB'
            showMENSRB(records);
        case 'MITOCA'
            showMITOCA(records);
        case 'MTIRPB'
            showMTIRPB(records);
        case 'NBLOCA'
            showNBLOCA(records);
        case 'PATCHB'
            showPATCHB(records);
        case 'PIAEQA'
            showPIAEQA(records);
        case 'PIAEVA'
            showPIAEVA(records);
        case 'PIAIMC'
            showPIAIMC(records);
        case 'PIAPEB'
            showPIAPEB(records);
        case 'PIAPRD'
            showPIAPRD(records);
        case 'PIATGB'
            showPIATGB(records);
        case 'PIXMTA'
            showPIXMTA(records);
        case 'PRJPSB'
            showPRJPSB(records);
        case 'REGPTB'
            showREGPTB(records);
        case 'REGPTC'
            showREGPTC(records);
        case 'RELCCA'
            showRELCCA(records);
        case 'RSMAPA'
            showRSMAPA(records);
        case 'RSMDCA'
            showRSMDCA(records);
        case 'RSMECA'
            showRSMECA(records);
        case 'S2EVPA'
            showS2EVPA(records);
        case 'SECTGA'
            showSECTGA(records);
        case 'SNSPSB'
            showSNSPSB(records);
        case 'SOURCB'
            showSOURCB(records);
        case 'STDIDC'
            showSTDIDC(records);
        case 'STREOB'
            showSTREOB(records);
        case 'SYSIDA'
            showSYSIDA(records);
        case 'USE00A'
            showUSE00A(records);
        % END published TRE display dispatch
        case 'GEOPSB'
            showGEOPSB(records);
        case 'BNDPLC'
            showBNDPLC(records);
        case 'XMLDCA'
            showXMLDCA(records);
        case 'SECURA'
            showSECURA(records);
        case 'PIXQLA'
            showPIXQLA(records);
        case 'CSCCGA'
            showCSCCGA(records);
        case 'MSTGTA'
            showMSTGTA(records);
        case 'BLOCKA'
            showBLOCKA(records);
        case 'ENGRDA'
            showENGRDA(records);
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

% BEGIN published TRE display values
function showACCHZB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ACCHZB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('regions', obj.regions);
end

function showACCPOB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ACCPOB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('regions', obj.regions);
end

function showACCVTB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ACCVTB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('regions', obj.regions);
end

function showASTORA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ASTORA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('img_total_rows', obj.img_total_rows);
    printTREField('img_total_cols', obj.img_total_cols);
    printTREField('img_index_row', obj.img_index_row);
    printTREField('img_index_col', obj.img_index_col);
    printTREField('geoid_offset', obj.geoid_offset);
    printTREField('alpha_0', obj.alpha_0);
    printTREField('k_l', obj.k_l);
    printTREField('c_m', obj.c_m);
    printTREField('ac_roll', obj.ac_roll);
    printTREField('ac_pitch', obj.ac_pitch);
    printTREField('ac_yaw', obj.ac_yaw);
    printTREField('ac_track_heading', obj.ac_track_heading);
    printTREField('ap_origin_x', obj.ap_origin_x);
    printTREField('ap_origin_y', obj.ap_origin_y);
    printTREField('ap_origin_z', obj.ap_origin_z);
    printTREField('ap_dir_x', obj.ap_dir_x);
    printTREField('ap_dir_y', obj.ap_dir_y);
    printTREField('ap_dir_z', obj.ap_dir_z);
    printTREField('x_ap_start', obj.x_ap_start);
    printTREField('x_ap_end', obj.x_ap_end);
    printTREField('ss_row_shift', obj.ss_row_shift);
    printTREField('ss_col_shift', obj.ss_col_shift);
    printTREField('u_hat_x', obj.u_hat_x);
    printTREField('u_hat_y', obj.u_hat_y);
    printTREField('u_hat_z', obj.u_hat_z);
    printTREField('v_hat_x', obj.v_hat_x);
    printTREField('v_hat_y', obj.v_hat_y);
    printTREField('v_hat_z', obj.v_hat_z);
    printTREField('n_hat_x', obj.n_hat_x);
    printTREField('n_hat_y', obj.n_hat_y);
    printTREField('n_hat_z', obj.n_hat_z);
    printTREField('eta_0', obj.eta_0);
    printTREField('sigma_sm', obj.sigma_sm);
    printTREField('sigma_sn', obj.sigma_sn);
    printTREField('s_off', obj.s_off);
    printTREField('rn_offset', obj.rn_offset);
    printTREField('r_scl', obj.r_scl);
    printTREField('r_nav', obj.r_nav);
    printTREField('r_sc_exact', obj.r_sc_exact);
    printTREField('c_sc_x', obj.c_sc_x);
    printTREField('c_sc_y', obj.c_sc_y);
    printTREField('c_sc_z', obj.c_sc_z);
    printTREField('k_hat_x', obj.k_hat_x);
    printTREField('k_hat_y', obj.k_hat_y);
    printTREField('k_hat_z', obj.k_hat_z);
    printTREField('l_hat_x', obj.l_hat_x);
    printTREField('l_hat_y', obj.l_hat_y);
    printTREField('l_hat_z', obj.l_hat_z);
    printTREField('p_z', obj.p_z);
    printTREField('theta_c', obj.theta_c);
    printTREField('alpha_sl', obj.alpha_sl);
    printTREField('sigma_tc', obj.sigma_tc);
end

function showATTPTA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ATTPTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('att_cs', obj.att_cs);
    printTREField('id_type', obj.id_type);
    printTREField('images', obj.images);
    printTREField('global_constants', obj.global_constants);
    printTREField('global_variables', obj.global_variables);
    printTREField('groups', obj.groups);
end

function showBCHIPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.BCHIPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sde_uuid', obj.sde_uuid);
    printTREField('num_insts', obj.num_insts);
    printTREField('instance', obj.instance);
    printTREField('include_a', obj.include_a);
    printTREField('tot_orig_bands', obj.tot_orig_bands);
    printTREField('tot_curr_bands', obj.tot_curr_bands);
    printTREField('bwp_is', obj.bwp_is);
    printTREField('sdes', obj.sdes);
    printTREField('include_b', obj.include_b);
    printTREField('original_bands', obj.original_bands);
    printTREField('include_c', obj.include_c);
    printTREField('current_bands', obj.current_bands);
end

function showBNDPLB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.BNDPLB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('points', obj.points);
end

function showCCINFA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.CCINFA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('codes', obj.codes);
end

function showCOMNTA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.COMNTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('comment', obj.comment);
end

function showCSEPHA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.CSEPHA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('ephem_flag', obj.ephem_flag);
    printTREField('dt_ephem', obj.dt_ephem);
    printTREField('date_ephem', obj.date_ephem);
    printTREField('t0_ephem', obj.t0_ephem);
    printTREField('ephemeris', obj.ephemeris);
end

function showCSEXRA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.CSEXRA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sensor', obj.sensor);
    printTREField('time_first_line_image', obj.time_first_line_image);
    printTREField('time_image_duration', obj.time_image_duration);
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
    printTREField('grd_cover', obj.grd_cover);
    printTREField('snow_depth_cat', obj.snow_depth_cat);
    printTREField('sun_azimuth', obj.sun_azimuth);
    printTREField('sun_elevation', obj.sun_elevation);
    printTREField('predicted_niirs', obj.predicted_niirs);
    printTREField('circl_err', obj.circl_err);
    printTREField('linear_err', obj.linear_err);
end

function showCSPROA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.CSPROA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('reserved_6', obj.reserved_6);
    printTREField('bwc', obj.bwc);
end

function showCSSFAA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.CSSFAA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('bands', obj.bands);
end

function showEXOPTA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.EXOPTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('angle_to_north', obj.angle_to_north);
    printTREField('mean_gsd', obj.mean_gsd);
    printTREField('dynamic_range', obj.dynamic_range);
    printTREField('obl_ang', obj.obl_ang);
    printTREField('roll_ang', obj.roll_ang);
    printTREField('prime_id', obj.prime_id);
    printTREField('prime_be', obj.prime_be);
    printTREField('n_sec', obj.n_sec);
    printTREField('n_seg', obj.n_seg);
    printTREField('max_lp_seg', obj.max_lp_seg);
    printTREField('sun_el', obj.sun_el);
    printTREField('sun_az', obj.sun_az);
end

function showEXPLTB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.EXPLTB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('angle_to_north', obj.angle_to_north);
    printTREField('angle_to_north_accy', obj.angle_to_north_accy);
    printTREField('squint_angle', obj.squint_angle);
    printTREField('squint_angle_accy', obj.squint_angle_accy);
    printTREField('mode', obj.mode);
    printTREField('graze_ang', obj.graze_ang);
    printTREField('graze_ang_accy', obj.graze_ang_accy);
    printTREField('slope_ang', obj.slope_ang);
    printTREField('polar', obj.polar);
    printTREField('nsamp', obj.nsamp);
    printTREField('seq_num', obj.seq_num);
    printTREField('prime_id', obj.prime_id);
    printTREField('prime_be', obj.prime_be);
    printTREField('n_sec', obj.n_sec);
    printTREField('ipr', obj.ipr);
end

function showFACCBB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.FACCBB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('attributes', obj.attributes);
end

function showGEOLOB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.GEOLOB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('arv', obj.arv);
    printTREField('brv', obj.brv);
    printTREField('lso', obj.lso);
    printTREField('pso', obj.pso);
end

function showGRDPSB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.GRDPSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('grids', obj.grids);
end

function showIOMAPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.IOMAPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('band_number', obj.band_number);
    printTREField('map_select', obj.map_select);
    printTREField('table_id', obj.table_id);
    printTREField('s1', obj.s1);
    printTREField('s2', obj.s2);
    printTREField('output_map', obj.output_map);
    printTREField('r_whole', obj.r_whole);
    printTREField('r_fraction', obj.r_fraction);
    printTREField('xob', obj.xob);
    printTREField('out_b', obj.out_b);
end

function showISACPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ISACPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('task_id', obj.task_id);
    printTREField('frame_num', obj.frame_num);
    printTREField('date_time_utc', obj.date_time_utc);
    printTREField('ref_pt_lat', obj.ref_pt_lat);
    printTREField('ref_pt_lon', obj.ref_pt_lon);
    printTREField('ref_pt_hgt', obj.ref_pt_hgt);
    printTREField('ref_pt_hdg', obj.ref_pt_hdg);
    printTREField('ref_pt_spd', obj.ref_pt_spd);
    printTREField('ref_pt_slt_rng', obj.ref_pt_slt_rng);
    printTREField('side', obj.side);
    printTREField('rng_res', obj.rng_res);
    printTREField('fit', obj.fit);
    printTREField('rng_spacing', obj.rng_spacing);
    printTREField('dop_spacing', obj.dop_spacing);
    printTREField('dop_scale', obj.dop_scale);
    printTREField('db_res', obj.db_res);
    printTREField('prf', obj.prf);
    printTREField('pol_tr', obj.pol_tr);
    printTREField('pol_re', obj.pol_re);
    printTREField('wf_cenfrq', obj.wf_cenfrq);
    printTREField('weight', obj.weight);
    printTREField('rng_sll', obj.rng_sll);
    printTREField('dop_sll', obj.dop_sll);
    printTREField('rng_tay_nbar', obj.rng_tay_nbar);
    printTREField('dop_tay_nbar', obj.dop_tay_nbar);
    printTREField('weight_norm', obj.weight_norm);
    printTREField('img_fom', obj.img_fom);
    printTREField('ref_trk', obj.ref_trk);
end

function showISASIA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ISASIA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('snsr_lat', obj.snsr_lat);
    printTREField('snsr_lon', obj.snsr_lon);
    printTREField('snsr_hgt', obj.snsr_hgt);
    printTREField('snsr_n_vel', obj.snsr_n_vel);
    printTREField('snsr_e_vel', obj.snsr_e_vel);
    printTREField('snsr_d_vel', obj.snsr_d_vel);
    printTREField('snsr_lat_err', obj.snsr_lat_err);
    printTREField('snsr_lon_err', obj.snsr_lon_err);
    printTREField('snsr_hgt_err', obj.snsr_hgt_err);
    printTREField('snsr_n_vel_err', obj.snsr_n_vel_err);
    printTREField('snsr_e_vel_err', obj.snsr_e_vel_err);
    printTREField('snsr_d_vel_err', obj.snsr_d_vel_err);
    printTREField('snsr_roll', obj.snsr_roll);
    printTREField('snsr_pitch', obj.snsr_pitch);
    printTREField('snsr_yaw', obj.snsr_yaw);
end

function showISATPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.ISATPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('tgt_det', obj.tgt_det);
    printTREField('tgt_len', obj.tgt_len);
    printTREField('tgt_len_uncy', obj.tgt_len_uncy);
    printTREField('tgt_strt_rng', obj.tgt_strt_rng);
    printTREField('tgt_strt_dop', obj.tgt_strt_dop);
    printTREField('tgt_end_rng', obj.tgt_end_rng);
    printTREField('tgt_end_dop', obj.tgt_end_dop);
    printTREField('tgt_info', obj.tgt_info);
end

function showJ2KLRB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.J2KLRB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('orig', obj.orig);
    printTREField('cstream', obj.cstream);
    printTREField('nlevels_o', obj.nlevels_o);
    printTREField('nbands_o', obj.nbands_o);
    printTREField('layers', obj.layers);
    printTREField('nlevels_i', obj.nlevels_i);
    printTREField('nbands_i', obj.nbands_i);
    printTREField('nlayers_i', obj.nlayers_i);
end

function showMAPLOB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.MAPLOB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('uniloa', obj.uniloa);
    printTREField('lod', obj.lod);
    printTREField('lad', obj.lad);
    printTREField('lso', obj.lso);
    printTREField('pso', obj.pso);
end

function showMENSRB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.MENSRB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('acft_loc', obj.acft_loc);
    printTREField('acft_loc_accy', obj.acft_loc_accy);
    printTREField('acft_alt', obj.acft_alt);
    printTREField('rp_loc', obj.rp_loc);
    printTREField('rp_loc_accy', obj.rp_loc_accy);
    printTREField('rp_elv', obj.rp_elv);
    printTREField('of_pc_r', obj.of_pc_r);
    printTREField('of_pc_a', obj.of_pc_a);
    printTREField('cosgrz', obj.cosgrz);
    printTREField('rgcrp', obj.rgcrp);
    printTREField('rlmap', obj.rlmap);
    printTREField('rp_row', obj.rp_row);
    printTREField('rp_col', obj.rp_col);
    printTREField('c_r_nc', obj.c_r_nc);
    printTREField('c_r_ec', obj.c_r_ec);
    printTREField('c_r_dc', obj.c_r_dc);
    printTREField('c_az_nc', obj.c_az_nc);
    printTREField('c_az_ec', obj.c_az_ec);
    printTREField('c_az_dc', obj.c_az_dc);
    printTREField('c_al_nc', obj.c_al_nc);
    printTREField('c_al_ec', obj.c_al_ec);
    printTREField('c_al_dc', obj.c_al_dc);
    printTREField('total_tiles_cols', obj.total_tiles_cols);
    printTREField('total_tiles_rows', obj.total_tiles_rows);
end

function showMITOCA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.MITOCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('scene_type', obj.scene_type);
    printTREField('scene_id', obj.scene_id);
    printTREField('look_composite_index', obj.look_composite_index);
    printTREField('look_composite_id', obj.look_composite_id);
    printTREField('look_corner_1', obj.look_corner_1);
    printTREField('look_corner_2', obj.look_corner_2);
    printTREField('look_corner_3', obj.look_corner_3);
    printTREField('look_corner_4', obj.look_corner_4);
    printTREField('num_volumes', obj.num_volumes);
    printTREField('look_instance', obj.look_instance);
    printTREField('volume_num', obj.volume_num);
    printTREField('sensor_id', obj.sensor_id);
    printTREField('sensor_id_type', obj.sensor_id_type);
    printTREField('mplan', obj.mplan);
    printTREField('volume_composite_index', obj.volume_composite_index);
    printTREField('volume_composite_id', obj.volume_composite_id);
    printTREField('volume_corner_1', obj.volume_corner_1);
    printTREField('volume_corner_2', obj.volume_corner_2);
    printTREField('volume_corner_3', obj.volume_corner_3);
    printTREField('volume_corner_4', obj.volume_corner_4);
    printTREField('components_flag', obj.components_flag);
    printTREField('num_rows', obj.num_rows);
    printTREField('num_cols', obj.num_cols);
    printTREField('dsr', obj.dsr);
    printTREField('components', obj.components);
end

function showMTIRPB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.MTIRPB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('mti_dp', obj.mti_dp);
    printTREField('mti_packet_id', obj.mti_packet_id);
    printTREField('patch_no', obj.patch_no);
    printTREField('wamti_frame_no', obj.wamti_frame_no);
    printTREField('wamti_bar_no', obj.wamti_bar_no);
    printTREField('datime', obj.datime);
    printTREField('acft_loc', obj.acft_loc);
    printTREField('acft_alt', obj.acft_alt);
    printTREField('acft_alt_unit', obj.acft_alt_unit);
    printTREField('acft_heading', obj.acft_heading);
    printTREField('mti_lr', obj.mti_lr);
    printTREField('squint_angle', obj.squint_angle);
    printTREField('cosgrz', obj.cosgrz);
    printTREField('targets', obj.targets);
end

function showNBLOCA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.NBLOCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('frame_1_offset', obj.frame_1_offset);
    printTREField('offsets', obj.offsets);
end

function showPATCHB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PATCHB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('pat_no', obj.pat_no);
    printTREField('last_pat_flag', obj.last_pat_flag);
    printTREField('lnstrt', obj.lnstrt);
    printTREField('lnstop', obj.lnstop);
    printTREField('azl', obj.azl);
    printTREField('nvl', obj.nvl);
    printTREField('fvl', obj.fvl);
    printTREField('npixel', obj.npixel);
    printTREField('fvpix', obj.fvpix);
    printTREField('frame', obj.frame);
    printTREField('utc', obj.utc);
    printTREField('shead', obj.shead);
    printTREField('gravity', obj.gravity);
    printTREField('ins_v_nc', obj.ins_v_nc);
    printTREField('ins_v_ec', obj.ins_v_ec);
    printTREField('ins_v_dc', obj.ins_v_dc);
    printTREField('offlat', obj.offlat);
    printTREField('offlong', obj.offlong);
    printTREField('track', obj.track);
    printTREField('gsweep', obj.gsweep);
    printTREField('shear', obj.shear);
    printTREField('batch_no', obj.batch_no);
end

function showPIAEQA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIAEQA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('eqpcode', obj.eqpcode);
    printTREField('eqpnomen', obj.eqpnomen);
    printTREField('eqpman', obj.eqpman);
    printTREField('obtype', obj.obtype);
    printTREField('ordbat', obj.ordbat);
    printTREField('ctryprod', obj.ctryprod);
    printTREField('ctrydsn', obj.ctrydsn);
    printTREField('objview', obj.objview);
end

function showPIAEVA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIAEVA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('eventname', obj.eventname);
    printTREField('eventtype', obj.eventtype);
end

function showPIAIMC(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIAIMC(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('cloudcvr', obj.cloudcvr);
    printTREField('srp', obj.srp);
    printTREField('sensmode', obj.sensmode);
    printTREField('sensname', obj.sensname);
    printTREField('source', obj.source);
    printTREField('comgen', obj.comgen);
    printTREField('subqual', obj.subqual);
    printTREField('piamsnnum', obj.piamsnnum);
    printTREField('camspecs', obj.camspecs);
    printTREField('projid', obj.projid);
    printTREField('generation', obj.generation);
    printTREField('esd', obj.esd);
    printTREField('othercond', obj.othercond);
    printTREField('meangsd', obj.meangsd);
    printTREField('idatum', obj.idatum);
    printTREField('iellip', obj.iellip);
    printTREField('preproc', obj.preproc);
    printTREField('iproj', obj.iproj);
    printTREField('sattrack', obj.sattrack);
end

function showPIAPEB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIAPEB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('lastnme', obj.lastnme);
    printTREField('firstnme', obj.firstnme);
    printTREField('midnme', obj.midnme);
    printTREField('dob', obj.dob);
    printTREField('assoctry', obj.assoctry);
end

function showPIAPRD(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIAPRD(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('accessid', obj.accessid);
    printTREField('fmcontrol', obj.fmcontrol);
    printTREField('subdet', obj.subdet);
    printTREField('prodcode', obj.prodcode);
    printTREField('producerse', obj.producerse);
    printTREField('prodidno', obj.prodidno);
    printTREField('prodsnme', obj.prodsnme);
    printTREField('producercd', obj.producercd);
    printTREField('prodcrtime', obj.prodcrtime);
    printTREField('mapid', obj.mapid);
    printTREField('sections', obj.sections);
    printTREField('organizations', obj.organizations);
    printTREField('keywords', obj.keywords);
    printTREField('reports', obj.reports);
    printTREField('texts', obj.texts);
end

function showPIATGB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIATGB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('tgtutm', obj.tgtutm);
    printTREField('piatgaid', obj.piatgaid);
    printTREField('piactry', obj.piactry);
    printTREField('piacat', obj.piacat);
    printTREField('tgtgeo', obj.tgtgeo);
    printTREField('datum', obj.datum);
    printTREField('tgtname', obj.tgtname);
    printTREField('percover', obj.percover);
    printTREField('tgtlat', obj.tgtlat);
    printTREField('tgtlon', obj.tgtlon);
end

function showPIXMTA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PIXMTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('aisdlvl', obj.aisdlvl);
    printTREField('origin_x', obj.origin_x);
    printTREField('origin_y', obj.origin_y);
    printTREField('scale_x', obj.scale_x);
    printTREField('scale_y', obj.scale_y);
    printTREField('sample_mode', obj.sample_mode);
    printTREField('perband', obj.perband);
    printTREField('metrics', obj.metrics);
    printTREField('reserved', obj.reserved);
    printTREField('all_images', obj.all_images);
end

function showPRJPSB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.PRJPSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('prn', obj.prn);
    printTREField('pco', obj.pco);
    printTREField('prj', obj.prj);
    printTREField('xor', obj.xor);
    printTREField('yor', obj.yor);
end

function showREGPTB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.REGPTB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('points', obj.points);
end

function showREGPTC(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.REGPTC(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('points', obj.points);
end

function showRELCCA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.RELCCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('reldate', obj.reldate);
    printTREField('relsours', obj.relsours);
    printTREField('relccstd', obj.relccstd);
    printTREField('rcolstd', obj.rcolstd);
    printTREField('rorgstd', obj.rorgstd);
    printTREField('coalid', obj.coalid);
    printTREField('coalcc', obj.coalcc);
    printTREField('relccodes', obj.relccodes);
    printTREField('relorg', obj.relorg);
end

function showRSMAPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.RSMAPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('xuol', obj.xuol);
    printTREField('yuol', obj.yuol);
    printTREField('zuol', obj.zuol);
    printTREField('xuxl', obj.xuxl);
    printTREField('xuyl', obj.xuyl);
    printTREField('xuzl', obj.xuzl);
    printTREField('yuxl', obj.yuxl);
    printTREField('yuyl', obj.yuyl);
    printTREField('yuzl', obj.yuzl);
    printTREField('zuxl', obj.zuxl);
    printTREField('zuyl', obj.zuyl);
    printTREField('zuzl', obj.zuzl);
    printTREField('iro', obj.iro);
    printTREField('irx', obj.irx);
    printTREField('iry', obj.iry);
    printTREField('irz', obj.irz);
    printTREField('irxx', obj.irxx);
    printTREField('irxy', obj.irxy);
    printTREField('irxz', obj.irxz);
    printTREField('iryy', obj.iryy);
    printTREField('iryz', obj.iryz);
    printTREField('irzz', obj.irzz);
    printTREField('ico', obj.ico);
    printTREField('icx', obj.icx);
    printTREField('icy', obj.icy);
    printTREField('icz', obj.icz);
    printTREField('icxx', obj.icxx);
    printTREField('icxy', obj.icxy);
    printTREField('icxz', obj.icxz);
    printTREField('icyy', obj.icyy);
    printTREField('icyz', obj.icyz);
    printTREField('iczz', obj.iczz);
    printTREField('gxo', obj.gxo);
    printTREField('gyo', obj.gyo);
    printTREField('gzo', obj.gzo);
    printTREField('gxr', obj.gxr);
    printTREField('gyr', obj.gyr);
    printTREField('gzr', obj.gzr);
    printTREField('gs', obj.gs);
    printTREField('gxx', obj.gxx);
    printTREField('gxy', obj.gxy);
    printTREField('gxz', obj.gxz);
    printTREField('gyx', obj.gyx);
    printTREField('gyy', obj.gyy);
    printTREField('gyz', obj.gyz);
    printTREField('gzx', obj.gzx);
    printTREField('gzy', obj.gzy);
    printTREField('gzz', obj.gzz);
    printTREField('parval', obj.parval);
end

function showRSMDCA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.RSMDCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('images', obj.images);
    printTREField('xuol', obj.xuol);
    printTREField('yuol', obj.yuol);
    printTREField('zuol', obj.zuol);
    printTREField('xuxl', obj.xuxl);
    printTREField('xuyl', obj.xuyl);
    printTREField('xuzl', obj.xuzl);
    printTREField('yuxl', obj.yuxl);
    printTREField('yuyl', obj.yuyl);
    printTREField('yuzl', obj.yuzl);
    printTREField('zuxl', obj.zuxl);
    printTREField('zuyl', obj.zuyl);
    printTREField('zuzl', obj.zuzl);
    printTREField('iro', obj.iro);
    printTREField('irx', obj.irx);
    printTREField('iry', obj.iry);
    printTREField('irz', obj.irz);
    printTREField('irxx', obj.irxx);
    printTREField('irxy', obj.irxy);
    printTREField('irxz', obj.irxz);
    printTREField('iryy', obj.iryy);
    printTREField('iryz', obj.iryz);
    printTREField('irzz', obj.irzz);
    printTREField('ico', obj.ico);
    printTREField('icx', obj.icx);
    printTREField('icy', obj.icy);
    printTREField('icz', obj.icz);
    printTREField('icxx', obj.icxx);
    printTREField('icxy', obj.icxy);
    printTREField('icxz', obj.icxz);
    printTREField('icyy', obj.icyy);
    printTREField('icyz', obj.icyz);
    printTREField('iczz', obj.iczz);
    printTREField('gxo', obj.gxo);
    printTREField('gyo', obj.gyo);
    printTREField('gzo', obj.gzo);
    printTREField('gxr', obj.gxr);
    printTREField('gyr', obj.gyr);
    printTREField('gzr', obj.gzr);
    printTREField('gs', obj.gs);
    printTREField('gxx', obj.gxx);
    printTREField('gxy', obj.gxy);
    printTREField('gxz', obj.gxz);
    printTREField('gyx', obj.gyx);
    printTREField('gyy', obj.gyy);
    printTREField('gyz', obj.gyz);
    printTREField('gzx', obj.gzx);
    printTREField('gzy', obj.gzy);
    printTREField('gzz', obj.gzz);
    printTREField('dercov', obj.dercov);
end

function showRSMECA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.RSMECA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('iid', obj.iid);
    printTREField('edition', obj.edition);
    printTREField('tid', obj.tid);
    printTREField('inclic', obj.inclic);
    printTREField('incluc', obj.incluc);
    printTREField('cvdate', obj.cvdate);
    printTREField('xuol', obj.xuol);
    printTREField('yuol', obj.yuol);
    printTREField('zuol', obj.zuol);
    printTREField('xuxl', obj.xuxl);
    printTREField('xuyl', obj.xuyl);
    printTREField('xuzl', obj.xuzl);
    printTREField('yuxl', obj.yuxl);
    printTREField('yuyl', obj.yuyl);
    printTREField('yuzl', obj.yuzl);
    printTREField('zuxl', obj.zuxl);
    printTREField('zuyl', obj.zuyl);
    printTREField('zuzl', obj.zuzl);
    printTREField('iro', obj.iro);
    printTREField('irx', obj.irx);
    printTREField('iry', obj.iry);
    printTREField('irz', obj.irz);
    printTREField('irxx', obj.irxx);
    printTREField('irxy', obj.irxy);
    printTREField('irxz', obj.irxz);
    printTREField('iryy', obj.iryy);
    printTREField('iryz', obj.iryz);
    printTREField('irzz', obj.irzz);
    printTREField('ico', obj.ico);
    printTREField('icx', obj.icx);
    printTREField('icy', obj.icy);
    printTREField('icz', obj.icz);
    printTREField('icxx', obj.icxx);
    printTREField('icxy', obj.icxy);
    printTREField('icxz', obj.icxz);
    printTREField('icyy', obj.icyy);
    printTREField('icyz', obj.icyz);
    printTREField('iczz', obj.iczz);
    printTREField('gxo', obj.gxo);
    printTREField('gyo', obj.gyo);
    printTREField('gzo', obj.gzo);
    printTREField('gxr', obj.gxr);
    printTREField('gyr', obj.gyr);
    printTREField('gzr', obj.gzr);
    printTREField('gs', obj.gs);
    printTREField('gxx', obj.gxx);
    printTREField('gxy', obj.gxy);
    printTREField('gxz', obj.gxz);
    printTREField('gyx', obj.gyx);
    printTREField('gyy', obj.gyy);
    printTREField('gyz', obj.gyz);
    printTREField('gzx', obj.gzx);
    printTREField('gzy', obj.gzy);
    printTREField('gzz', obj.gzz);
    printTREField('groups', obj.groups);
    printTREField('map', obj.map);
    printTREField('urr', obj.urr);
    printTREField('urc', obj.urc);
    printTREField('ucc', obj.ucc);
    printTREField('row_correlations', obj.row_correlations);
    printTREField('column_correlations', obj.column_correlations);
end

function showS2EVPA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.S2EVPA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('quantity_name', obj.quantity_name);
    printTREField('uom', obj.uom);
    printTREField('first_band', obj.first_band);
    printTREField('last_band', obj.last_band);
    printTREField('coef', obj.coef);
end

function showSECTGA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.SECTGA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sec_id', obj.sec_id);
    printTREField('sec_be', obj.sec_be);
end

function showSNSPSB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.SNSPSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('sensors', obj.sensors);
end

function showSOURCB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.SOURCB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('is_sca', obj.is_sca);
    printTREField('cpatch', obj.cpatch);
    printTREField('sources', obj.sources);
end

function showSTDIDC(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.STDIDC(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('acquisition_date', obj.acquisition_date);
    printTREField('mission', obj.mission);
    printTREField('pass', obj.pass);
    printTREField('op_num', obj.op_num);
    printTREField('start_segment', obj.start_segment);
    printTREField('repro_num', obj.repro_num);
    printTREField('replay_regen', obj.replay_regen);
    printTREField('blank_fill', obj.blank_fill);
    printTREField('start_column', obj.start_column);
    printTREField('start_row', obj.start_row);
    printTREField('end_segment', obj.end_segment);
    printTREField('end_column', obj.end_column);
    printTREField('end_row', obj.end_row);
    printTREField('country', obj.country);
    printTREField('wac', obj.wac);
    printTREField('location', obj.location);
end

function showSTREOB(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.STREOB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('st_id', obj.st_id);
    printTREField('n_mates', obj.n_mates);
    printTREField('mate_instance', obj.mate_instance);
    printTREField('b_conv', obj.b_conv);
    printTREField('e_conv', obj.e_conv);
    printTREField('b_asym', obj.b_asym);
    printTREField('e_asym', obj.e_asym);
    printTREField('b_bie', obj.b_bie);
    printTREField('e_bie', obj.e_bie);
end

function showSYSIDA(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.SYSIDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('platform_id', obj.platform_id);
    printTREField('payload_id', obj.payload_id);
    printTREField('sensor_id', obj.sensor_id);
end

function showUSE00A(records) %#codegen
    [obj, ok, status] = readTRE(records, nfx.USE00A(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('angle_to_north', obj.angle_to_north);
    printTREField('mean_gsd', obj.mean_gsd);
    printTREField('dynamic_range', obj.dynamic_range);
    printTREField('obl_ang', obj.obl_ang);
    printTREField('roll_ang', obj.roll_ang);
    printTREField('n_ref', obj.n_ref);
    printTREField('rev_num', obj.rev_num);
    printTREField('n_seg', obj.n_seg);
    printTREField('max_lp_seg', obj.max_lp_seg);
    printTREField('sun_el', obj.sun_el);
    printTREField('sun_az', obj.sun_az);
end
% END published TRE display values
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

function showGEOPSB(records) %#codegen
    %showGEOPSB - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.GEOPSB(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('typ', obj.typ);
    printTREField('uni', obj.uni);
    printTREField('dag', obj.dag);
    printTREField('dcd', obj.dcd);
    printTREField('ell', obj.ell);
    printTREField('elc', obj.elc);
    printTREField('dvr', obj.dvr);
    printTREField('vdcdvr', obj.vdcdvr);
    printTREField('sda', obj.sda);
    printTREField('vdcsda', obj.vdcsda);
    printTREField('zor', obj.zor);
    printTREField('grd', obj.grd);
    printTREField('grn', obj.grn);
    printTREField('zna', obj.zna);
end

function showBNDPLC(records) %#codegen
    %showBNDPLC - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.BNDPLC(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('rings', obj.rings);
end

function showXMLDCA(records) %#codegen
    %showXMLDCA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.XMLDCA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('trecrc', obj.trecrc);
    printTREField('tredata', obj.tredata);
    printTREField('treshft', obj.treshft);
    printTREField('treshdt', obj.treshdt);
    printTREField('treshrp', obj.treshrp);
    printTREField('treshsi', obj.treshsi);
    printTREField('treshsv', obj.treshsv);
    printTREField('treshsd', obj.treshsd);
    printTREField('treshtn', obj.treshtn);
    printTREField('treshlpg', obj.treshlpg);
    printTREField('treshlpt', obj.treshlpt);
    printTREField('treshli', obj.treshli);
    printTREField('treshlin', obj.treshlin);
    printTREField('treshabs', obj.treshabs);
end

function showSECURA(records) %#codegen
    %showSECURA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.SECURA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('fdattim', obj.fdattim);
    printTREField('formatver', obj.formatver);
    printTREField('secflds', obj.secflds);
    printTREField('secstd', obj.secstd);
    printTREField('seccomp', obj.seccomp);
    printTREField('security', obj.security);
end

function showPIXQLA(records) %#codegen
    %showPIXQLA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.PIXQLA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('aisdlvl', obj.aisdlvl);
    printTREField('all_images', obj.all_images);
    printTREField('pq_condition', obj.pq_condition);
end

function showCSCCGA(records) %#codegen
    %showCSCCGA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.CSCCGA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('ccg_source', obj.ccg_source);
    printTREField('reg_sensor', obj.reg_sensor);
    printTREField('origin_line', obj.origin_line);
    printTREField('origin_sample', obj.origin_sample);
    printTREField('as_cell_size', obj.as_cell_size);
    printTREField('cs_cell_size', obj.cs_cell_size);
    printTREField('ccg_max_line', obj.ccg_max_line);
    printTREField('ccg_max_sample', obj.ccg_max_sample);
end

function showMSTGTA(records) %#codegen
    %showMSTGTA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.MSTGTA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('tgt_num', obj.tgt_num);
    printTREField('tgt_id', obj.tgt_id);
    printTREField('tgt_be', obj.tgt_be);
    printTREField('tgt_pri', obj.tgt_pri);
    printTREField('tgt_req', obj.tgt_req);
    printTREField('tgt_ltiov', obj.tgt_ltiov);
    printTREField('tgt_type', obj.tgt_type);
    printTREField('tgt_coll', obj.tgt_coll);
    printTREField('tgt_cat', obj.tgt_cat);
    printTREField('tgt_utc', obj.tgt_utc);
    printTREField('tgt_elev', obj.tgt_elev);
    printTREField('tgt_elev_unit', obj.tgt_elev_unit);
    printTREField('tgt_loc', obj.tgt_loc);
end

function showBLOCKA(records) %#codegen
    %showBLOCKA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.BLOCKA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('block_instance', obj.block_instance);
    printTREField('n_gray', obj.n_gray);
    printTREField('l_lines', obj.l_lines);
    printTREField('layover_angle', obj.layover_angle);
    printTREField('shadow_angle', obj.shadow_angle);
    printTREField('frlc_loc', obj.frlc_loc);
    printTREField('lrlc_loc', obj.lrlc_loc);
    printTREField('lrfc_loc', obj.lrfc_loc);
    printTREField('frfc_loc', obj.frfc_loc);
end

function showENGRDA(records) %#codegen
    %showENGRDA - Decode one statically typed temporary for display
    [obj, ok, status] = readTRE(records, nfx.ENGRDA(), 1, []);
    if ~ok
        fprintf('    %s: %s\n', status.code, status.message);
        return
    end
    printTREField('resrc', obj.resrc);
    printTREField('redata', obj.redata);
end
