function value = fixtureInteriorOrientation()
    %fixtureInteriorOrientation - Supply a zero-distortion lens calibration
    value = nfx.InteriorOrientation(fl_cal_iop=0.5,ppo_x0=0,ppo_y0=0,rld_k0=0, ...
        rld_k1=0,rld_k2=0,rld_k3=0,dcd_p1=0,dcd_p2=0,dcd_p3=0,ad_a1=0,ad_a2=0,radius_of_validity=100);
end
