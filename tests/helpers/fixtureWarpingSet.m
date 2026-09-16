function value = fixtureWarpingSet()
    %fixtureWarpingSet - Supply synthetic normalization and constant terms
    value = nfx.WarpingSet(offset_line=1,offset_samp=2,scale_line=3,scale_samp=4, ...
        offset_line_unwrp=5,offset_samp_unwrp=6,scale_line_unwrp=7,scale_samp_unwrp=8,a=1,b=2);
end
