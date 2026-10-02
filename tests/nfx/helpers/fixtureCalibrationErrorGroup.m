function value = fixtureCalibrationErrorGroup()
    value = nfx.CalibrationErrorGroup(corr_ref_date_io='20260915',corr_ref_time_io='120000.123456789', ...
        cal_ap_id=[1 11],errcov_c3=[4 1;1 9],cal_interp=1,spdcf_id_time=1,spdcf_id_fl=2);
end
