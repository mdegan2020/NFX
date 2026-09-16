function value = fixtureTimeSyncError(layout)
    date = '20260915'; time = '120000.123456789';
    value = nfx.TimeSyncError(num_ts_grp=layout);
    switch layout
        case 1
            value.corr_ref_date_ts = date; value.corr_ref_time_ts = time;
            value.tsrr = 4; value.tsrc = 1; value.tscc = 9; value.ts_spdcf = 1;
        case 2
            value.corr_ref_date_tsp = date; value.corr_ref_time_tsp = time;
            value.corr_ref_date_tsa = date; value.corr_ref_time_tsa = time;
            value.ts_pos_cov = 4; value.ts_att_cov = 9; value.ts_pos_spdcf = 2; value.ts_att_spdcf = 3;
        case 3
            value.corr_ref_date_ts = date; value.corr_ref_time_ts = time;
            value.ts_pos_cov = 4; value.ts_pos_att_cov = 1; value.ts_pos_fl_cov = 2;
            value.ts_att_cov = 9; value.ts_att_fl_cov = 3; value.ts_fl_cov = 16; value.ts_spdcf = 1;
        case 4
            value.corr_ref_date_tspa = date; value.corr_ref_time_tspa = time;
            value.corr_ref_date_tsfl = date; value.corr_ref_time_tsfl = time;
            value.ts_pos_cov = 4; value.ts_pos_att_cov = 1; value.ts_att_cov = 9; value.ts_fl_cov = 16;
            value.ts_pa_spdcf = 4; value.ts_fl_spdcf = 5;
        case 5
            value = fixtureTimeSyncError(2); value.num_ts_grp = 5;
            value.corr_ref_date_tsfl = date; value.corr_ref_time_tsfl = time;
            value.ts_fl_cov = 16; value.ts_fl_spdcf = 5;
    end
end
