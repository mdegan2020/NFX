function [obj, reader] = readSpectralBand(reader, flags) %#codegen
    %readSpectralBand - Decode the shared presence mask in table order
    obj = nfx.SpectralBand();
    if flags(29)
        [value, reader] = reader.text(50, true, false);
        if reader.ok
            obj.bandid = value;
        end
    end
    if flags(28)
        [value, reader] = reader.number(1, 0, 1, 1);
        if reader.ok
            obj.bad_band = value;
        end
    end
    if flags(27)
        [raw, reader] = reader.text(3, false);
        number = NaN;
        if strcmp(raw, '+++')
            % The encoded category means greater than 9.9, not the input NIIRS.
            number = 10;
        elseif ~strcmp(raw, '---')
            number = str2double(raw);
            if reader.ok && (~isreal(number) || ~isfinite(number) || ...
                    number < 0 || number > 9.9)
                reader = reader.fail('InvalidNumber', 'Invalid NIIRS field.');
            end
        end
        if reader.ok
            obj.niirs = number;
        end
    end
    if flags(26)
        [value, reader] = reader.number(5, 1, 99999, 1);
        if reader.ok
            obj.focal_len = value;
        end
    end
    if flags(25)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.cwave = value;
        end
    end
    if flags(24)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.fwhm = value;
        end
    end
    if flags(23)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.fwhm_unc = value;
        end
    end
    if flags(22)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.nom_wave = value;
        end
    end
    if flags(21)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.nom_wave_unc = value;
        end
    end
    if flags(20)
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.lbound = value;
        end
        [value, reader] = reader.dashed(7, .00001, 10000);
        if reader.ok
            obj.ubound = value;
        end
    end
    if flags(19)
        [value, reader] = reader.float32(1, -1e38, 1e38);
        if reader.ok
            obj.scale_factor = value;
        end
        [value, reader] = reader.float32(1, -1e38, 1e38);
        if reader.ok
            obj.additive_factor = value;
        end
    end
    if flags(18)
        [value, reader] = reader.text(16, true, false);
        if reader.ok
            obj.start_time = value;
        end
    end
    if flags(17)
        [value, reader] = reader.dashed(6, .00001, 999999);
        if reader.ok
            obj.int_time = value;
        end
    end
    if flags(16)
        [value, reader] = reader.dashed(6, 0, 999999);
        if reader.ok
            obj.caldrk = value;
        end
        [value, reader] = reader.dashed(5, 0, 99999);
        if reader.ok
            obj.calibration_sensitivity = value;
        end
    end
    if flags(15)
        [value, reader] = reader.dashed(7, 0, 9999.99);
        if reader.ok
            obj.row_gsd = value;
        end
        if flags(14)
            [value, reader] = reader.dashed(7, 0.001, 9999.99);
            if reader.ok
                obj.row_gsd_unc = value;
            end
        end
        [value, reader] = reader.text(1, true, false);
        if reader.ok
            obj.row_gsd_unit = value;
        end
        [value, reader] = reader.dashed(7, 0.01, 9999.99);
        if reader.ok
            obj.col_gsd = value;
        end
        if flags(14)
            [value, reader] = reader.dashed(7, 0.01, 9999.99);
            if reader.ok
                obj.col_gsd_unc = value;
            end
        end
        [value, reader] = reader.text(1, true, false);
        if reader.ok
            obj.col_gsd_unit = value;
        end
    end
    if flags(13)
        [value, reader] = reader.dashed(5, 0, 99999);
        if reader.ok
            obj.bknoise = value;
        end
        [value, reader] = reader.dashed(5, 0, 99999);
        if reader.ok
            obj.scnnoise = value;
        end
    end
    if flags(12)
        [value, reader] = reader.dashed(7, 0.001, 9999.99);
        if reader.ok
            obj.spt_resp_function_row = value;
        end
        if flags(11)
            [value, reader] = reader.dashed(7, 0.001, 9999.99);
            if reader.ok
                obj.spt_resp_unc_row = value;
            end
        end
        [value, reader] = reader.text(1, true, false);
        if reader.ok
            obj.spt_resp_unit_row = value;
        end
        [value, reader] = reader.dashed(7, 0.001, 9999.99);
        if reader.ok
            obj.spt_resp_function_col = value;
        end
        if flags(11)
            [value, reader] = reader.dashed(7, 0.001, 9999.99);
            if reader.ok
                obj.spt_resp_unc_col = value;
            end
        end
        [value, reader] = reader.text(1, true, false);
        if reader.ok
            obj.spt_resp_unit_col = value;
        end
    end
    if flags(10)
        [value, reader] = reader.take(16);
        if reader.ok
            obj.data_fld_3 = value;
        end
    end
    if flags(9)
        [value, reader] = reader.take(24);
        if reader.ok
            obj.data_fld_4 = value;
        end
    end
    if flags(8)
        [value, reader] = reader.take(32);
        if reader.ok
            obj.data_fld_5 = value;
        end
    end
    if flags(7)
        [value, reader] = reader.take(48);
        if reader.ok
            obj.data_fld_6 = value;
        end
    end
end
