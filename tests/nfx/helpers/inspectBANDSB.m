function out = inspectBANDSB(bytes)
    %inspectBANDSB - Decode the published field table without toolbox helpers
    at = 1;
    out.count = number(5); out.radiometric_quantity = text(24); out.radiometric_quantity_unit = text(1);
    out.scale_factor = real32(); out.additive_factor = real32();
    out.row_gsd = number(7); out.row_gsd_unit = text(1); out.col_gsd = number(7); out.col_gsd_unit = text(1);
    out.spt_resp_row = number(7); out.spt_resp_unit_row = text(1); out.spt_resp_col = number(7); out.spt_resp_unit_col = text(1);
    out.data_fld_1 = take(48); word = take(4);
    out.mask = double(word)*[16777216;65536;256;1];
    if flag(31), out.surface = text(24); out.altitude = real32(); end
    if flag(30), out.diameter = number(7); end
    if flag(29), out.data_fld_2 = take(32); end
    if any(mod(floor(out.mask./2.^(19:24)),2)), out.wave_length_unit = text(1); end
    out.band = cell(1,out.count);
    for k = 1:out.count
        item = struct;
        if flag(28), item.bandid = text(50); end
        if flag(27), item.bad_band = number(1); end
        if flag(26), item.niirs = text(3); end
        if flag(25), item.focal_len = number(5); end
        if flag(24), item.cwave = number(7); end
        if flag(23), item.fwhm = number(7); end
        if flag(22), item.fwhm_unc = number(7); end
        if flag(21), item.nom_wave = number(7); end
        if flag(20), item.nom_wave_unc = number(7); end
        if flag(19), item.lbound = number(7); item.ubound = number(7); end
        if flag(18), item.scale_factor = real32(); item.additive_factor = real32(); end
        if flag(17), item.start_time = text(16); end
        if flag(16), item.int_time = number(6); end
        if flag(15), item.caldrk = number(6); item.calibration_sensitivity = number(5); end
        if flag(14)
            item.row_gsd = number(7);
            if flag(13), item.row_gsd_unc = number(7); end
            item.row_gsd_unit = text(1); item.col_gsd = number(7);
            if flag(13), item.col_gsd_unc = number(7); end
            item.col_gsd_unit = text(1);
        end
        if flag(12), item.bknoise = number(5); item.scnnoise = number(5); end
        if flag(11)
            item.spt_resp_function_row = number(7);
            if flag(10), item.spt_resp_unc_row = number(7); end
            item.spt_resp_unit_row = text(1); item.spt_resp_function_col = number(7);
            if flag(10), item.spt_resp_unc_col = number(7); end
            item.spt_resp_unit_col = text(1);
        end
        if flag(9), item.data_fld_3 = take(16); end
        if flag(8), item.data_fld_4 = take(24); end
        if flag(7), item.data_fld_5 = take(32); end
        if flag(6), item.data_fld_6 = take(48); end
        out.band{k} = item;
    end
    out.aux_b = cell(1,0); out.aux_c = cell(1,0);
    if flag(0)
        nb = number(2); nc = number(2);
        for k = 1:nb, out.aux_b{k} = auxiliary(out.count); end
        for k = 1:nc, out.aux_c{k} = auxiliary(1); end
    end
    assert(at == numel(bytes)+1,'oracle:BANDSB','Unexpected bytes after BANDSB auxiliary data.');
    function value = flag(bit)
        value = mod(floor(out.mask/2^bit),2) == 1;
    end
    function value = take(count)
        assert(at+count-1 <= numel(bytes),'oracle:BANDSB','Truncated BANDSB field.');
        value = bytes(at:at+count-1); at = at+count;
    end
    function value = text(count)
        value = char(take(count));
    end
    function value = number(count)
        value = str2double(text(count));
    end
    function value = real32()
        raw = take(4);
        [~,~,order] = computer;
        if order == 'L', raw = fliplr(raw); end
        value = double(typecast(raw,'single'));
    end
    function item = auxiliary(count)
        item.format = text(1); item.unit = text(7); item.values = cell(1,count);
        for b = 1:count
            switch item.format
                case 'I', item.values{b} = number(10);
                case 'R', item.values{b} = real32();
                case 'A', item.values{b} = text(20);
                otherwise, error('oracle:BANDSB','Invalid auxiliary format.');
            end
        end
    end
end
