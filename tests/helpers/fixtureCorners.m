function value = fixtureCorners(kind)
    %fixtureCorners - Supply explicitly synthetic WGS 84 corners
    arguments
        kind = 'CSCRNA'
    end
    if strcmp(kind, 'CSCRNA')
        value = nfx.CSCRNA();
    else
        value = nfx.FCRNSA();
    end
    value.predict_corners = 'N';
    value.ulcrn_lat = 40; value.ulcrn_lon = -75; value.ulcrn_ht = 100;
    value.urcrn_lat = 40; value.urcrn_lon = -74; value.urcrn_ht = 101;
    value.lrcrn_lat = 39; value.lrcrn_lon = -74; value.lrcrn_ht = 102;
    value.llcrn_lat = 39; value.llcrn_lon = -75; value.llcrn_ht = 103;
end
