function event = fullHistoryEvent()
    %fullHistoryEvent - Supply every conditional field at a format boundary
    event = fixtureHistoryEvent();
    event.ipcom = repmat('X',9,80);
    event.disp_flag = 3;
    event.rot_flag = 1; event.rot_angle = 359.9999;
    event.asym_flag = 1; event.zoomrow = 99.9999; event.zoomcol = 99.9999;
    event.proj_flag = 1;
    event.sharp_flag = 1; event.sharpfam = 99; event.sharpmem = 99;
    event.mag_flag = 1; event.mag_level = 99.9999;
    event.dra_flag = 1; event.dra_mult = 999.999; event.dra_sub = -9999;
    event.ttc_flag = 1; event.ttcfam = 99; event.ttcmem = 99;
    event.devlut_flag = 1;
end
