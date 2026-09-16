function value = fixtureCSCSDB()
    group = fixtureSensorErrorGroup(); group.basic_sr_spdcf = 1;
    core = nfx.SensorErrorCore(ref_frame_position=1,ref_frame_attitude=2,groups=group);
    corr = nfx.GLASCorrelation(spdcf_fam=0,spdcf_weight=1,fp_a=1,fp_alpha=0.25,fp_beta=2,fp_t=3);
    value = nfx.CSCSDB(uuid='20000000-0000-4000-8000-000000000004',aisdlvl=1, ...
        cov_version_date='20260915',cores=core,spdcf=nfx.SPDCF(spdcf_id=1,components=corr));
end
