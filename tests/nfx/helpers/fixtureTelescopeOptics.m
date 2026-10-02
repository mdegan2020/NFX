function value = fixtureTelescopeOptics(mode)
    %fixtureTelescopeOptics - Supply two telescope transforms with small shifts
    if nargin == 0, mode = 1; end
    value = nfx.TelescopeOptics(telescope_optics_flag=mode,tele_trans_t0=[0 0.1], ...
        tele_trans_t1=[1 1],tele_trans_t2=[0 0],tele_trans_t3=[0 0],tele_trans_t4=[0 0], ...
        tele_trans_t5=[0 0.2],tele_trans_t6=[0 0],tele_trans_t7=[1 1]);
    if mode == 2, value.tele_date = '20260915'; value.tele_time = [1 2]; end
end
