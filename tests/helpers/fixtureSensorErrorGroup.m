function value = fixtureSensorErrorGroup()
    %fixtureSensorErrorGroup - Supply a correlated two-parameter basic group
    value = nfx.SensorErrorGroup(corr_ref_date='20260915',corr_ref_time='120000.123456789', ...
        adj_parm_id=[1 2],errcov_c1=[4 1;1 9]);
end
