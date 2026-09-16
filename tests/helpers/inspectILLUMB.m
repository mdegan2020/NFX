function out = inspectILLUMB(bytes)
    %inspectILLUMB - Independent field-level decoder for illumination fixtures
    at = 1;
    out.num_bands = numeric(4); out.band_unit = text(40);
    out.lbound = zeros(1,out.num_bands); out.ubound = out.lbound;
    for b = 1:out.num_bands, out.lbound(b) = numeric(16); out.ubound(b) = numeric(16); end
    out.num_others = numeric(2);
    out.other_name = repmat(' ',out.num_others,40);
    for j = 1:out.num_others, out.other_name(j,:) = text(40); end
    out.num_coms = numeric(1); out.comment = repmat(' ',out.num_coms,80);
    for j = 1:out.num_coms, out.comment(j,:) = text(80); end
    out.geo_datum = text(80); out.geo_datum_code = text(4); out.ellipsoid_name = text(80);
    out.ellipsoid_code = text(3); out.vertical_datum_ref = text(80); out.vertical_ref_code = text(4);
    maskBytes = take(3);
    out.existence_mask = double(maskBytes(1))*65536+double(maskBytes(2))*256+double(maskBytes(3));
    flags = mod(floor(out.existence_mask./2.^(0:23)),2) == 1;
    if flags(24), out.rad_quantity = text(40); out.radq_unit = text(40); end
    out.num_illum_sets = numeric(3);
    out.datetime = repmat(' ',out.num_illum_sets,14);
    out.target_lat_text = repmat(' ',out.num_illum_sets,10);
    out.target_lon_text = repmat(' ',out.num_illum_sets,11);
    out.target_hgt = NaN(1,out.num_illum_sets);
    for n = 1:out.num_illum_sets
        out.datetime(n,:) = text(14); out.target_lat_text(n,:) = text(10); out.target_lon_text(n,:) = text(11);
        out.target_hgt(n) = numeric(14);
        if flags(23), out.sun_azimuth(n) = numeric(5); out.sun_elev(n) = numeric(5); end
        if flags(22), out.moon_azimuth(n) = numeric(5); out.moon_elev(n) = numeric(5); end
        if flags(21), out.moon_phase_angle(n) = numeric(6); end
        if flags(20), out.moon_illum_percent(n) = numeric(3); end
        if flags(19)
            for j = 1:out.num_others, out.other_azimuth(j,n) = numeric(5); out.other_elev(j,n) = numeric(5); end
        end
        if flags(18), out.sensor_azimuth(n) = numeric(5); out.sensor_elev(n) = numeric(5); end
        if flags(17), out.cats_angle(n) = numeric(5); end
        if flags(16), out.sun_glint_lat(n) = numeric(10); out.sun_glint_lon(n) = numeric(11); end
        if flags(15), out.catm_angle(n) = numeric(5); end
        if flags(14), out.moon_glint_lat(n) = numeric(10); out.moon_glint_lon(n) = numeric(11); end
        if flags(11), out.sol_lun_dist_adjust(n) = numeric(7); end
        for b = 1:out.num_bands
            if flags(13), out.sun_illum_method(b,n) = text(1); out.sun_illum(b,n) = numeric(16); end
            if flags(12), out.moon_illum_method(b,n) = text(1); out.moon_illum(b,n) = numeric(16); end
            if flags(11), out.tot_sunmoon_illum(b,n) = numeric(16); end
            if flags(10)
                for j = 1:out.num_others
                    out.other_illum_method(j,b,n) = text(1); out.other_illum(j,b,n) = numeric(16);
                end
            end
            if flags(9)
                out.art_illum_method(b,n) = text(1); out.art_illum_min(b,n) = numeric(16); out.art_illum_max(b,n) = numeric(16);
            end
        end
    end
    assert(at == numel(bytes)+1,'oracle:ILLUMB','Unexpected bytes after illumination sets.');
    function value = take(count)
        assert(at+count-1 <= numel(bytes),'oracle:ILLUMB','Truncated illumination field.');
        value = bytes(at:at+count-1); at = at+count;
    end
    function value = text(count)
        value = char(take(count));
    end
    function value = numeric(count)
        word = text(count); value = str2double(word);
        assert(isfinite(value) || all(word == ' ') || all(word == '-'), 'oracle:ILLUMB','Invalid numeric field.');
    end
end
