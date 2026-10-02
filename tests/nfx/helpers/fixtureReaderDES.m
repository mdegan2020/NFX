function value = fixtureReaderDES(kind)
    %fixtureReaderDES - Exercise supported sensor-DES wire conditionals
    switch kind
        case {'attitude', 'attitudeV1', 'attitudeECI', ...
              'attitudeLagrange', 'attitudeSpherical', 'attitudeLinear'}
            value = fixtureCSATTB();
            switch kind
                case 'attitudeV1'
                    value.desver = 1; value.eci_ecf_att = 0;
                case 'attitudeECI'
                    value.eci_ecf_att = 0;
                    value.earth_orientation = fixtureEarthOrientation();
                case 'attitudeLagrange'
                    value.interp_type_att = 2; value.interp_order_att = 7;
                case 'attitudeSpherical'
                    value.interp_type_att = 3; value.interp_order_att = 3;
                case 'attitudeLinear'
                    value.interp_type_att = 1;
            end
        case {'ephemeris', 'ephemerisV1', 'ephemerisECI', ...
              'ephemerisLagrange', 'velocity', 'acceleration'}
            value = fixtureCSEPHB();
            switch kind
                case 'ephemerisV1'
                    value.desver = 1; value.eci_ecf_ephem = 0;
                case 'ephemerisECI'
                    value.eci_ecf_ephem = 0;
                    value.earth_orientation = fixtureEarthOrientation();
                case 'ephemerisLagrange'
                    value.interp_type_eph = 2; value.interp_order_eph = 5;
                case {'velocity', 'acceleration'}
                    value.vel_x = [1 2]; value.vel_y = [3 4];
                    value.vel_z = [5 6];
                    if strcmp(kind, 'acceleration')
                        value.accel_x = [7 8]; value.accel_y = [9 10];
                        value.accel_z = [11 12];
                    end
            end
        case {'scanner', 'scannerBands'}
            value = fixtureCSSFAB();
            if strcmp(kind, 'scannerBands')
                value.bands = [ ...
                    nfx.SensorBand(band_index=2, irepband='R', isubcat=0.65), ...
                    nfx.SensorBand(band_index=1, irepband='G')];
                value.foc_length_time = [0 1.123456789];
                value.foc_length = [0.5 0.75];
                value.start_falign_x = [1 2 3];
                value.start_falign_y = [4 5 6];
                value.end_falign_x = [7 8 9];
                value.end_falign_y = [10 11 12];
            end
        case {'grid', 'fiducial', 'telescopeFrame', 'telescopeTime', ...
              'telescopeZeroFrame', 'telescopeZeroTime'}
            value = fixtureCSSFAB('F', double(strcmp(kind, 'fiducial')));
            if strcmp(kind, 'grid')
                grid = fixtureFieldAlignmentGrid();
                names = {'fa_x1', 'fa_y1', 'fa_x2', 'fa_y2', ...
                         'fa_x3', 'fa_y3', 'fa_x4', 'fa_y4'};
                for k = 1:8, grid.(names{k}) = [1 2 3; 4 5 6] + 6 * k; end
                value.fa_grids = [grid grid];
            elseif strcmp(kind, 'fiducial')
                transform = fixtureFiducialTransform();
                for k = 0:7
                    transform.(sprintf('ls_fid_trans_t%d', k)) = ...
                        [1 2 3; 4 5 6] + 6 * k;
                end
                value.fiducial_transform = transform;
                value.iop = [value.iop value.iop];
            else
                mode = 1 + contains(kind, 'Time');
                if contains(kind, 'Zero')
                    telescope = nfx.TelescopeOptics(telescope_optics_flag=mode);
                    if mode == 2, telescope.tele_date = '20260915'; end
                else
                    telescope = fixtureTelescopeOptics(mode);
                    telescope.tele_iop = fixtureInteriorOrientation();
                    if mode == 2
                        telescope.time_varying_io_parm_id = [11 1];
                        telescope.time_varying_io_m = [1 2; 3 4];
                    end
                end
                value.telescope = telescope;
            end
        case {'covariance', 'covarianceEmpty', 'covarianceFull', ...
              'postsCommon', 'postsDistinct', 'postsOnly', ...
              'correlationPiecewise', 'correlationCosine', ...
              'timeSync1', 'timeSync2', 'timeSync3', 'timeSync4', 'timeSync5'}
            value = fixtureCSCSDB();
            if strcmp(kind, 'covarianceEmpty')
                value.cores = nfx.SensorErrorCore.empty(1, 0);
                value.spdcf = nfx.SPDCF.empty(1, 0);
            elseif strcmp(kind, 'covarianceFull')
                value.calibration_groups = fixtureCalibrationErrorGroup();
                value.calibration_groups.errcov_c3 = cat(3, [4 1; 1 9], eye(2));
                value.focal_length_cal = [0.5 0.75];
                value.time_sync = fixtureTimeSyncError(3);
                value.unmodeled = nfx.UnmodeledErrorGrid( ...
                    urr=[1 2 3; 4 5 6], urc=zeros(2, 3), ...
                    ucc=[6 5 4; 3 2 1], line_spdcf=1, sample_spdcf=2);
                value.spdcf(2) = value.spdcf(1); value.spdcf(2).spdcf_id = 2;
                count = value.parameter_count;
                value.adj = 1:count; value.errcov_c4 = diag(1:count);
                value.spdcf_id_adj = ones(1, count);
            elseif startsWith(kind, 'posts')
                group = value.cores.groups;
                group.errcov_c2 = [4 1; 1 9];
                if strcmp(kind, 'postsDistinct')
                    group.errcov_c2 = cat(3, group.errcov_c2, eye(2));
                end
                group.post_start_date = '20260915'; group.post_start_time = 1;
                group.post_dt = 0.1; group.num_posts = 2; group.post_interp = 1;
                pairing = nfx.CorrelationPairing(spdcf_id=1, ...
                    sensor_id={'SENS01', 'SENS02'});
                group.basic_pf = pairing; group.basic_pl = pairing;
                group.post_pf = pairing; group.post_pl = pairing;
                group.post_sr_spdcf = 1; group.post_corr = 1;
                if strcmp(kind, 'postsOnly')
                    group.errcov_c1 = []; group.basic_sr_spdcf = NaN;
                    group.basic_pf = nfx.CorrelationPairing.empty(1, 0);
                    group.basic_pl = nfx.CorrelationPairing.empty(1, 0);
                end
                value.cores.groups = group;
            elseif strcmp(kind, 'correlationPiecewise')
                value.spdcf.components = nfx.GLASCorrelation( ...
                    spdcf_fam=1, spdcf_weight=1, ...
                    pl_max_cor=[1 0.5 0], pl_tau_max_cor=[0 2 4]);
            elseif strcmp(kind, 'correlationCosine')
                value.spdcf.components = nfx.GLASCorrelation( ...
                    spdcf_fam=2, spdcf_weight=1, dc_a=1, dc_t=2, dc_p=3);
            elseif startsWith(kind, 'timeSync')
                value.time_sync = fixtureTimeSyncError(str2double(kind(end)));
                for k = 2:5
                    value.spdcf(k) = value.spdcf(1); value.spdcf(k).spdcf_id = k;
                end
            end
        otherwise
            error('nfx:TestFixture', 'Unknown sensor-DES test case.');
    end
end
