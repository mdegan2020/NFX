classdef (Sealed) ASTORA < nfx.TRE
    %ASTORA - Radar spot and swath geometry
    %   OBJ = ASTORA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ASTORA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ASTORA properties:
    %       cetag - Constant tag identifier
    %       img_total_rows - IMG_TOTAL_ROWS metadata
    %       img_total_cols - IMG_TOTAL_COLS metadata
    %       img_index_row - IMG_INDEX_ROW metadata
    %       img_index_col - IMG_INDEX_COL metadata
    %       geoid_offset - GEOID_OFFSET metadata
    %       alpha_0 - ALPHA_0 metadata
    %       k_l - K_L metadata
    %       c_m - C_M metadata
    %       ac_roll - AC_ROLL metadata
    %       ac_pitch - AC_PITCH metadata
    %       ac_yaw - AC_YAW metadata
    %       ac_track_heading - AC_TRACK_HEADING metadata
    %       ap_origin_x - AP_ORIGIN_X metadata
    %       ap_origin_y - AP_ORIGIN_Y metadata
    %       ap_origin_z - AP_ORIGIN_Z metadata
    %       ap_dir_x - AP_DIR_X metadata
    %       ap_dir_y - AP_DIR_Y metadata
    %       ap_dir_z - AP_DIR_Z metadata
    %       x_ap_start - X_AP_START metadata
    %       x_ap_end - X_AP_END metadata
    %       ss_row_shift - SS_ROW_SHIFT metadata
    %       ss_col_shift - SS_COL_SHIFT metadata
    %       u_hat_x - U_HAT_X metadata
    %       u_hat_y - U_HAT_Y metadata
    %       u_hat_z - U_HAT_Z metadata
    %       v_hat_x - V_HAT_X metadata
    %       v_hat_y - V_HAT_Y metadata
    %       v_hat_z - V_HAT_Z metadata
    %       n_hat_x - N_HAT_X metadata
    %       n_hat_y - N_HAT_Y metadata
    %       n_hat_z - N_HAT_Z metadata
    %       eta_0 - ETA_0 metadata
    %       sigma_sm - SIGMA_SM metadata
    %       sigma_sn - SIGMA_SN metadata
    %       s_off - S_OFF metadata
    %       rn_offset - RN_OFFSET metadata
    %       r_scl - R_SCL metadata
    %       r_nav - R_NAV metadata
    %       r_sc_exact - R_SC_EXACT metadata
    %       c_sc_x - C_SC_X metadata
    %       c_sc_y - C_SC_Y metadata
    %       c_sc_z - C_SC_Z metadata
    %       k_hat_x - K_HAT_X metadata
    %       k_hat_y - K_HAT_Y metadata
    %       k_hat_z - K_HAT_Z metadata
    %       l_hat_x - L_HAT_X metadata
    %       l_hat_y - L_HAT_Y metadata
    %       l_hat_z - L_HAT_Z metadata
    %       p_z - P_Z metadata
    %       theta_c - THETA_C metadata
    %       alpha_sl - ALPHA_SL metadata
    %       sigma_tc - SIGMA_TC metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ASTORA' % Registered tag identifier
    end
    properties
        % IMG_TOTAL_ROWS metadata
        img_total_rows {mustBeMetadata(img_total_rows, ...
            0, 999999, 1)} = NaN
        % IMG_TOTAL_COLS metadata
        img_total_cols {mustBeMetadata(img_total_cols, ...
            0, 999999, 1)} = NaN
        % IMG_INDEX_ROW metadata
        img_index_row {mustBeMetadata(img_index_row, ...
            0, 999999, 1)} = NaN
        % IMG_INDEX_COL metadata
        img_index_col {mustBeMetadata(img_index_col, ...
            0, 999999, 1)} = NaN
        % GEOID_OFFSET metadata
        geoid_offset {mustBeMetadata(geoid_offset, ...
            -999.99, 999.99, 0)} = NaN
        % ALPHA_0 metadata
        alpha_0 {mustBeMetadata(alpha_0, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % K_L metadata
        k_l {mustBeMetadata(k_l, ...
            -1, 1, 1)} = NaN
        % C_M metadata
        c_m {mustBeMetadata(c_m, ...
            0, 999999999.99999, 0)} = NaN
        % AC_ROLL metadata
        ac_roll {mustBeMetadata(ac_roll, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % AC_PITCH metadata
        ac_pitch {mustBeMetadata(ac_pitch, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % AC_YAW metadata
        ac_yaw {mustBeMetadata(ac_yaw, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % AC_TRACK_HEADING metadata
        ac_track_heading {mustBeMetadata(ac_track_heading, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % AP_ORIGIN_X metadata
        ap_origin_x {mustBeMetadata(ap_origin_x, ...
            -99999999.999, 99999999.999, 0)} = NaN
        % AP_ORIGIN_Y metadata
        ap_origin_y {mustBeMetadata(ap_origin_y, ...
            -99999999.999, 99999999.999, 0)} = NaN
        % AP_ORIGIN_Z metadata
        ap_origin_z {mustBeMetadata(ap_origin_z, ...
            -99999999.999, 99999999.999, 0)} = NaN
        % AP_DIR_X metadata
        ap_dir_x {mustBeMetadata(ap_dir_x, ...
            -1, 1, 0)} = NaN
        % AP_DIR_Y metadata
        ap_dir_y {mustBeMetadata(ap_dir_y, ...
            -1, 1, 0)} = NaN
        % AP_DIR_Z metadata
        ap_dir_z {mustBeMetadata(ap_dir_z, ...
            -1, 1, 0)} = NaN
        % X_AP_START metadata
        x_ap_start {mustBeMetadata(x_ap_start, ...
            -99999.99999, 99999.99999, 0)} = NaN
        % X_AP_END metadata
        x_ap_end {mustBeMetadata(x_ap_end, ...
            -99999.99999, 99999.99999, 0)} = NaN
        % SS_ROW_SHIFT metadata
        ss_row_shift {mustBeMetadata(ss_row_shift, ...
            -999, 999, 1)} = NaN
        % SS_COL_SHIFT metadata
        ss_col_shift {mustBeMetadata(ss_col_shift, ...
            -999, 999, 1)} = NaN
        % U_HAT_X metadata
        u_hat_x {mustBeMetadata(u_hat_x, ...
            -1, 1, 0)} = NaN
        % U_HAT_Y metadata
        u_hat_y {mustBeMetadata(u_hat_y, ...
            -1, 1, 0)} = NaN
        % U_HAT_Z metadata
        u_hat_z {mustBeMetadata(u_hat_z, ...
            -1, 1, 0)} = NaN
        % V_HAT_X metadata
        v_hat_x {mustBeMetadata(v_hat_x, ...
            -1, 1, 0)} = NaN
        % V_HAT_Y metadata
        v_hat_y {mustBeMetadata(v_hat_y, ...
            -1, 1, 0)} = NaN
        % V_HAT_Z metadata
        v_hat_z {mustBeMetadata(v_hat_z, ...
            -1, 1, 0)} = NaN
        % N_HAT_X metadata
        n_hat_x {mustBeMetadata(n_hat_x, ...
            -1, 1, 0)} = NaN
        % N_HAT_Y metadata
        n_hat_y {mustBeMetadata(n_hat_y, ...
            -1, 1, 0)} = NaN
        % N_HAT_Z metadata
        n_hat_z {mustBeMetadata(n_hat_z, ...
            -1, 1, 0)} = NaN
        % ETA_0 metadata
        eta_0 {mustBeMetadata(eta_0, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % SIGMA_SM metadata
        sigma_sm {mustBeMetadata(sigma_sm, ...
            -99999999.999, 99999999.999, 0)} = NaN
        % SIGMA_SN metadata
        sigma_sn {mustBeMetadata(sigma_sn, ...
            -99999999.999, 99999999.999, 0)} = NaN
        % S_OFF metadata
        s_off {mustBeMetadata(s_off, ...
            -9999.9999, 9999.9999, 0)} = NaN
        % RN_OFFSET metadata
        rn_offset {mustBeMetadata(rn_offset, ...
            -999999.9999, 999999.9999, 0)} = NaN
        % R_SCL metadata
        r_scl {mustBeMetadata(r_scl, ...
            0, 9999999.99999999, 0)} = NaN
        % R_NAV metadata
        r_nav {mustBeMetadata(r_nav, ...
            0, 9999999.99999999, 0)} = NaN
        % R_SC_EXACT metadata
        r_sc_exact {mustBeMetadata(r_sc_exact, ...
            0, 999999.999999999, 0)} = NaN
        % C_SC_X metadata
        c_sc_x {mustBeMetadata(c_sc_x, ...
            -999999.99999999, 999999.99999999, 0)} = NaN
        % C_SC_Y metadata
        c_sc_y {mustBeMetadata(c_sc_y, ...
            -999999.99999999, 999999.99999999, 0)} = NaN
        % C_SC_Z metadata
        c_sc_z {mustBeMetadata(c_sc_z, ...
            -999999.99999999, 999999.99999999, 0)} = NaN
        % K_HAT_X metadata
        k_hat_x {mustBeMetadata(k_hat_x, ...
            -1, 1, 0)} = NaN
        % K_HAT_Y metadata
        k_hat_y {mustBeMetadata(k_hat_y, ...
            -1, 1, 0)} = NaN
        % K_HAT_Z metadata
        k_hat_z {mustBeMetadata(k_hat_z, ...
            -1, 1, 0)} = NaN
        % L_HAT_X metadata
        l_hat_x {mustBeMetadata(l_hat_x, ...
            -1, 1, 0)} = NaN
        % L_HAT_Y metadata
        l_hat_y {mustBeMetadata(l_hat_y, ...
            -1, 1, 0)} = NaN
        % L_HAT_Z metadata
        l_hat_z {mustBeMetadata(l_hat_z, ...
            -1, 1, 0)} = NaN
        % P_Z metadata
        p_z {mustBeMetadata(p_z, ...
            -999999.99999999, 999999.99999999, 0)} = NaN
        % THETA_C metadata
        theta_c {mustBeMetadata(theta_c, ...
            -9.9999999999999, 9.9999999999999, 0)} = NaN
        % ALPHA_SL metadata
        alpha_sl {mustBeMetadata(alpha_sl, ...
            0, 9.99999999999999, 0)} = NaN
        % SIGMA_TC metadata
        sigma_tc {mustBeMetadata(sigma_tc, ...
            0, 9.99999999999999, 0)} = NaN
    end
    methods
        function obj = ASTORA(options) %#codegen
            arguments
                options.?nfx.ASTORA
            end
            if isfield(options, 'img_total_rows')
                obj.img_total_rows = options.img_total_rows;
            end
            if isfield(options, 'img_total_cols')
                obj.img_total_cols = options.img_total_cols;
            end
            if isfield(options, 'img_index_row')
                obj.img_index_row = options.img_index_row;
            end
            if isfield(options, 'img_index_col')
                obj.img_index_col = options.img_index_col;
            end
            if isfield(options, 'geoid_offset')
                obj.geoid_offset = options.geoid_offset;
            end
            if isfield(options, 'alpha_0')
                obj.alpha_0 = options.alpha_0;
            end
            if isfield(options, 'k_l')
                obj.k_l = options.k_l;
            end
            if isfield(options, 'c_m')
                obj.c_m = options.c_m;
            end
            if isfield(options, 'ac_roll')
                obj.ac_roll = options.ac_roll;
            end
            if isfield(options, 'ac_pitch')
                obj.ac_pitch = options.ac_pitch;
            end
            if isfield(options, 'ac_yaw')
                obj.ac_yaw = options.ac_yaw;
            end
            if isfield(options, 'ac_track_heading')
                obj.ac_track_heading = options.ac_track_heading;
            end
            if isfield(options, 'ap_origin_x')
                obj.ap_origin_x = options.ap_origin_x;
            end
            if isfield(options, 'ap_origin_y')
                obj.ap_origin_y = options.ap_origin_y;
            end
            if isfield(options, 'ap_origin_z')
                obj.ap_origin_z = options.ap_origin_z;
            end
            if isfield(options, 'ap_dir_x')
                obj.ap_dir_x = options.ap_dir_x;
            end
            if isfield(options, 'ap_dir_y')
                obj.ap_dir_y = options.ap_dir_y;
            end
            if isfield(options, 'ap_dir_z')
                obj.ap_dir_z = options.ap_dir_z;
            end
            if isfield(options, 'x_ap_start')
                obj.x_ap_start = options.x_ap_start;
            end
            if isfield(options, 'x_ap_end')
                obj.x_ap_end = options.x_ap_end;
            end
            if isfield(options, 'ss_row_shift')
                obj.ss_row_shift = options.ss_row_shift;
            end
            if isfield(options, 'ss_col_shift')
                obj.ss_col_shift = options.ss_col_shift;
            end
            if isfield(options, 'u_hat_x')
                obj.u_hat_x = options.u_hat_x;
            end
            if isfield(options, 'u_hat_y')
                obj.u_hat_y = options.u_hat_y;
            end
            if isfield(options, 'u_hat_z')
                obj.u_hat_z = options.u_hat_z;
            end
            if isfield(options, 'v_hat_x')
                obj.v_hat_x = options.v_hat_x;
            end
            if isfield(options, 'v_hat_y')
                obj.v_hat_y = options.v_hat_y;
            end
            if isfield(options, 'v_hat_z')
                obj.v_hat_z = options.v_hat_z;
            end
            if isfield(options, 'n_hat_x')
                obj.n_hat_x = options.n_hat_x;
            end
            if isfield(options, 'n_hat_y')
                obj.n_hat_y = options.n_hat_y;
            end
            if isfield(options, 'n_hat_z')
                obj.n_hat_z = options.n_hat_z;
            end
            if isfield(options, 'eta_0')
                obj.eta_0 = options.eta_0;
            end
            if isfield(options, 'sigma_sm')
                obj.sigma_sm = options.sigma_sm;
            end
            if isfield(options, 'sigma_sn')
                obj.sigma_sn = options.sigma_sn;
            end
            if isfield(options, 's_off')
                obj.s_off = options.s_off;
            end
            if isfield(options, 'rn_offset')
                obj.rn_offset = options.rn_offset;
            end
            if isfield(options, 'r_scl')
                obj.r_scl = options.r_scl;
            end
            if isfield(options, 'r_nav')
                obj.r_nav = options.r_nav;
            end
            if isfield(options, 'r_sc_exact')
                obj.r_sc_exact = options.r_sc_exact;
            end
            if isfield(options, 'c_sc_x')
                obj.c_sc_x = options.c_sc_x;
            end
            if isfield(options, 'c_sc_y')
                obj.c_sc_y = options.c_sc_y;
            end
            if isfield(options, 'c_sc_z')
                obj.c_sc_z = options.c_sc_z;
            end
            if isfield(options, 'k_hat_x')
                obj.k_hat_x = options.k_hat_x;
            end
            if isfield(options, 'k_hat_y')
                obj.k_hat_y = options.k_hat_y;
            end
            if isfield(options, 'k_hat_z')
                obj.k_hat_z = options.k_hat_z;
            end
            if isfield(options, 'l_hat_x')
                obj.l_hat_x = options.l_hat_x;
            end
            if isfield(options, 'l_hat_y')
                obj.l_hat_y = options.l_hat_y;
            end
            if isfield(options, 'l_hat_z')
                obj.l_hat_z = options.l_hat_z;
            end
            if isfield(options, 'p_z')
                obj.p_z = options.p_z;
            end
            if isfield(options, 'theta_c')
                obj.theta_c = options.theta_c;
            end
            if isfield(options, 'alpha_sl')
                obj.alpha_sl = options.alpha_sl;
            end
            if isfield(options, 'sigma_tc')
                obj.sigma_tc = options.sigma_tc;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AQ, format table (2022-04)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.img_total_rows, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'img_total_rows', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.img_total_cols, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'img_total_cols', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.img_index_row, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'img_index_row', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.img_index_col, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'img_index_col', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.geoid_offset, 7, 2, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'geoid_offset', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.alpha_0, 16, 13, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'alpha_0', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.k_l, 2, 0, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'k_l', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_m, 15, 5, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_m', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ac_roll, 16, 13, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ac_roll', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ac_pitch, 16, 13, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ac_pitch', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ac_yaw, 16, 13, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ac_yaw', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ac_track_heading, 16, 13, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ac_track_heading', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_origin_x, 13, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_origin_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_origin_y, 13, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_origin_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_origin_z, 13, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_origin_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_dir_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_dir_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_dir_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_dir_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ap_dir_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ap_dir_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.x_ap_start, 12, 5, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'x_ap_start', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.x_ap_end, 12, 5, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'x_ap_end', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ss_row_shift, 4, 0, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ss_row_shift', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ss_col_shift, 4, 0, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ss_col_shift', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.u_hat_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'u_hat_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.u_hat_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'u_hat_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.u_hat_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'u_hat_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.v_hat_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'v_hat_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.v_hat_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'v_hat_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.v_hat_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'v_hat_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_hat_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_hat_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_hat_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_hat_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.n_hat_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_hat_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.eta_0, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'eta_0', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sigma_sm, 13, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'sigma_sm', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sigma_sn, 13, 3, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'sigma_sn', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.s_off, 10, 4, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 's_off', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rn_offset, 12, 4, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rn_offset', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.r_scl, 16, 8, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'r_scl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.r_nav, 16, 8, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'r_nav', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.r_sc_exact, 16, 9, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'r_sc_exact', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_sc_x, 16, 8, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_sc_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_sc_y, 16, 8, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_sc_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_sc_z, 16, 8, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_sc_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.k_hat_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'k_hat_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.k_hat_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'k_hat_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.k_hat_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'k_hat_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.l_hat_x, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'l_hat_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.l_hat_y, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'l_hat_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.l_hat_z, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'l_hat_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.p_z, 16, 8, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'p_z', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.theta_c, 16, 13, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'theta_c', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.alpha_sl, 16, 14, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'alpha_sl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.sigma_tc, 16, 14, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'sigma_tc', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ~any(obj.k_l == [-1 1]), ...
                'Metadata', 'k_l', 'Use -1 or +1 for look direction.', reference);
            spot = [ ...
                obj.ap_origin_x ...
                obj.ap_origin_y ...
                obj.ap_origin_z ...
                obj.ap_dir_x ...
                obj.ap_dir_y ...
                obj.ap_dir_z ...
                obj.x_ap_start ...
                obj.x_ap_end ...
                obj.ss_row_shift ...
                obj.ss_col_shift];
            swath = [ ...
                obj.u_hat_x ...
                obj.u_hat_y ...
                obj.u_hat_z ...
                obj.v_hat_x ...
                obj.v_hat_y ...
                obj.v_hat_z ...
                obj.n_hat_x ...
                obj.n_hat_y ...
                obj.n_hat_z ...
                obj.eta_0 ...
                obj.sigma_sm ...
                obj.sigma_sn ...
                obj.s_off ...
                obj.rn_offset ...
                obj.r_scl ...
                obj.r_nav ...
                obj.r_sc_exact ...
                obj.c_sc_x ...
                obj.c_sc_y ...
                obj.c_sc_z ...
                obj.k_hat_x ...
                obj.k_hat_y ...
                obj.k_hat_z ...
                obj.l_hat_x ...
                obj.l_hat_y ...
                obj.l_hat_z ...
                obj.p_z ...
                obj.theta_c ...
                obj.alpha_sl ...
                obj.sigma_tc];
            report = addIssue(report, ~((all(isfinite(spot)) && all(isnan(swath))) || ...
                (all(isnan(spot)) && all(isfinite(swath)))), ...
                'Metadata', 'spot/swath', 'Populate one complete geometry group and leave the other blank.', reference);
            payloadLength = 6 + ...
                6 + ...
                6 + ...
                6 + ...
                7 + ...
                16 + ...
                2 + ...
                15 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                13 + ...
                13 + ...
                13 + ...
                16 + ...
                16 + ...
                16 + ...
                12 + ...
                12 + ...
                4 + ...
                4 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                13 + ...
                13 + ...
                10 + ...
                12 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16 + ...
                16;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.img_total_rows, 6, 0, false, false, false)];
            data = [data treNumber(obj.img_total_cols, 6, 0, false, false, false)];
            data = [data treNumber(obj.img_index_row, 6, 0, false, false, false)];
            data = [data treNumber(obj.img_index_col, 6, 0, false, false, false)];
            data = [data treNumber(obj.geoid_offset, 7, 2, true, false, false)];
            data = [data treNumber(obj.alpha_0, 16, 13, true, false, false)];
            data = [data treNumber(obj.k_l, 2, 0, true, false, false)];
            data = [data treNumber(obj.c_m, 15, 5, false, false, false)];
            data = [data treNumber(obj.ac_roll, 16, 13, true, false, false)];
            data = [data treNumber(obj.ac_pitch, 16, 13, true, false, false)];
            data = [data treNumber(obj.ac_yaw, 16, 13, true, false, false)];
            data = [data treNumber(obj.ac_track_heading, 16, 13, true, false, false)];
            data = [data treNumber(obj.ap_origin_x, 13, 3, true, true, false)];
            data = [data treNumber(obj.ap_origin_y, 13, 3, true, true, false)];
            data = [data treNumber(obj.ap_origin_z, 13, 3, true, true, false)];
            data = [data treNumber(obj.ap_dir_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.ap_dir_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.ap_dir_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.x_ap_start, 12, 5, true, true, false)];
            data = [data treNumber(obj.x_ap_end, 12, 5, true, true, false)];
            data = [data treNumber(obj.ss_row_shift, 4, 0, true, true, false)];
            data = [data treNumber(obj.ss_col_shift, 4, 0, true, true, false)];
            data = [data treNumber(obj.u_hat_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.u_hat_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.u_hat_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.v_hat_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.v_hat_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.v_hat_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.n_hat_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.n_hat_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.n_hat_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.eta_0, 16, 13, true, true, false)];
            data = [data treNumber(obj.sigma_sm, 13, 3, true, true, false)];
            data = [data treNumber(obj.sigma_sn, 13, 3, true, true, false)];
            data = [data treNumber(obj.s_off, 10, 4, true, true, false)];
            data = [data treNumber(obj.rn_offset, 12, 4, true, true, false)];
            data = [data treNumber(obj.r_scl, 16, 8, false, true, false)];
            data = [data treNumber(obj.r_nav, 16, 8, false, true, false)];
            data = [data treNumber(obj.r_sc_exact, 16, 9, false, true, false)];
            data = [data treNumber(obj.c_sc_x, 16, 8, true, true, false)];
            data = [data treNumber(obj.c_sc_y, 16, 8, true, true, false)];
            data = [data treNumber(obj.c_sc_z, 16, 8, true, true, false)];
            data = [data treNumber(obj.k_hat_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.k_hat_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.k_hat_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.l_hat_x, 16, 13, true, true, false)];
            data = [data treNumber(obj.l_hat_y, 16, 13, true, true, false)];
            data = [data treNumber(obj.l_hat_z, 16, 13, true, true, false)];
            data = [data treNumber(obj.p_z, 16, 8, true, true, false)];
            data = [data treNumber(obj.theta_c, 16, 13, true, true, false)];
            data = [data treNumber(obj.alpha_sl, 16, 14, false, true, false)];
            data = [data treNumber(obj.sigma_tc, 16, 14, false, true, false)];
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
            obj = nfx.ASTORA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.img_total_rows = value; end
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.img_total_cols = value; end
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.img_index_row = value; end
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.img_index_col = value; end
            [value, reader] = reader.number(7, -999.99, 999.99, ...
                false, false);
            if reader.ok, obj.geoid_offset = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, false);
            if reader.ok, obj.alpha_0 = value; end
            [value, reader] = reader.number(2, -1, 1, ...
                true, false);
            if reader.ok, obj.k_l = value; end
            [value, reader] = reader.number(15, 0, 999999999.99999, ...
                false, false);
            if reader.ok, obj.c_m = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, false);
            if reader.ok, obj.ac_roll = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, false);
            if reader.ok, obj.ac_pitch = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, false);
            if reader.ok, obj.ac_yaw = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, false);
            if reader.ok, obj.ac_track_heading = value; end
            [value, reader] = reader.number(13, -99999999.999, 99999999.999, ...
                false, true);
            if reader.ok, obj.ap_origin_x = value; end
            [value, reader] = reader.number(13, -99999999.999, 99999999.999, ...
                false, true);
            if reader.ok, obj.ap_origin_y = value; end
            [value, reader] = reader.number(13, -99999999.999, 99999999.999, ...
                false, true);
            if reader.ok, obj.ap_origin_z = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.ap_dir_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.ap_dir_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.ap_dir_z = value; end
            [value, reader] = reader.number(12, -99999.99999, 99999.99999, ...
                false, true);
            if reader.ok, obj.x_ap_start = value; end
            [value, reader] = reader.number(12, -99999.99999, 99999.99999, ...
                false, true);
            if reader.ok, obj.x_ap_end = value; end
            [value, reader] = reader.number(4, -999, 999, ...
                true, true);
            if reader.ok, obj.ss_row_shift = value; end
            [value, reader] = reader.number(4, -999, 999, ...
                true, true);
            if reader.ok, obj.ss_col_shift = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.u_hat_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.u_hat_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.u_hat_z = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.v_hat_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.v_hat_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.v_hat_z = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.n_hat_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.n_hat_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.n_hat_z = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, true);
            if reader.ok, obj.eta_0 = value; end
            [value, reader] = reader.number(13, -99999999.999, 99999999.999, ...
                false, true);
            if reader.ok, obj.sigma_sm = value; end
            [value, reader] = reader.number(13, -99999999.999, 99999999.999, ...
                false, true);
            if reader.ok, obj.sigma_sn = value; end
            [value, reader] = reader.number(10, -9999.9999, 9999.9999, ...
                false, true);
            if reader.ok, obj.s_off = value; end
            [value, reader] = reader.number(12, -999999.9999, 999999.9999, ...
                false, true);
            if reader.ok, obj.rn_offset = value; end
            [value, reader] = reader.number(16, 0, 9999999.99999999, ...
                false, true);
            if reader.ok, obj.r_scl = value; end
            [value, reader] = reader.number(16, 0, 9999999.99999999, ...
                false, true);
            if reader.ok, obj.r_nav = value; end
            [value, reader] = reader.number(16, 0, 999999.999999999, ...
                false, true);
            if reader.ok, obj.r_sc_exact = value; end
            [value, reader] = reader.number(16, -999999.99999999, 999999.99999999, ...
                false, true);
            if reader.ok, obj.c_sc_x = value; end
            [value, reader] = reader.number(16, -999999.99999999, 999999.99999999, ...
                false, true);
            if reader.ok, obj.c_sc_y = value; end
            [value, reader] = reader.number(16, -999999.99999999, 999999.99999999, ...
                false, true);
            if reader.ok, obj.c_sc_z = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.k_hat_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.k_hat_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.k_hat_z = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.l_hat_x = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.l_hat_y = value; end
            [value, reader] = reader.number(16, -1, 1, ...
                false, true);
            if reader.ok, obj.l_hat_z = value; end
            [value, reader] = reader.number(16, -999999.99999999, 999999.99999999, ...
                false, true);
            if reader.ok, obj.p_z = value; end
            [value, reader] = reader.number(16, -9.9999999999999, 9.9999999999999, ...
                false, true);
            if reader.ok, obj.theta_c = value; end
            [value, reader] = reader.number(16, 0, 9.99999999999999, ...
                false, true);
            if reader.ok, obj.alpha_sl = value; end
            [value, reader] = reader.number(16, 0, 9.99999999999999, ...
                false, true);
            if reader.ok, obj.sigma_tc = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ASTORA());
        end
    end
end
