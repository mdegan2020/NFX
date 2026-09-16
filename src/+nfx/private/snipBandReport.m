function [report,wavelength] = snipBandReport(data,header) %#codegen
    %snipBandReport - Check required spectral groups in a validated snapshot
    report = newReport('SNIP BANDSB'); count = number(data,1,5);
    wavelength = NaN(1,count); mask = uint32(0);
    for k = 119:122, mask = bitshift(mask,8)+uint32(data(k)); end
    f = bitget(mask,1:32) ~= 0;
    report = snipIssue(report,count ~= numel(header.isubcat),'SNIPBandCount','BANDSB.count', ...
        'BANDSB must describe every stored band.','Table 17-1');
    report = snipIssue(report,~f(29) || ~((f(25) && f(24)) || (f(22) && f(20))), ...
        'SNIPSpectralGroups','BANDSB.existence_mask', ...
        'Supply band identifiers and either CWAVE/FWHM or NOM_WAVE/LBOUND/UBOUND.','Table 17-1');
    spatial = [number(data,39,7) number(data,47,7) number(data,55,7) number(data,63,7)];
    report = snipIssue(report,any(~isfinite(spatial) | spatial <= 0), ...
        'SNIPSpatialResponse','BANDSB.row_gsd/col_gsd/spt_resp_row/spt_resp_col', ...
        'Supply known ground spacing and spatial response for the cube.','Table 17-1');
    report = snipIssue(report,~any(char(data(30)) == 'VDN') && ~f(32), ...
        'SNIPRadiometricSurface','BANDSB.radiometric_adjustment_surface', ...
        'Physical radiometric units require the adjustment-surface group.','17.1.2');
    at = 123+28*f(32)+7*f(31)+32*f(30); unit = ' ';
    if any(f(20:25)), unit = char(data(at)); at = at+1; end
    widths = [zeros(1,6) 48 32 24 16 14 16 10 14 16 11 6 16 8 14 7 7 7 7 7 5 3 1 50 0 0 0];
    stride = sum(widths.*double(f));
    for b = 1:count
        offset = at+sum(widths(26:29).*double(f(26:29)));
        if f(25), wavelength(b) = number(data,offset,7);
        elseif f(22), wavelength(b) = number(data,offset+7*sum(f(23:25)),7);
        end
        if unit == 'U', wavelength(b) = wavelength(b)*1000;
        elseif unit == 'W', wavelength(b) = 1e7/wavelength(b);
        end
        if f(20) && f(22)
            offset = offset+7*sum(f(21:25));
            bounds = [number(data,offset,7) number(data,offset+7,7)];
            center = wavelength(b); if unit == 'U', center = center/1000; else, center = 1e7/center; end
            report = snipIssue(report,center < bounds(1) || center > bounds(2), ...
                'SNIPBandBounds','BANDSB.band','Representative wavelength must lie within the band bounds.','17.1.3');
        end
        at = at+stride;
    end
    report = snipIssue(report,any(~isfinite(wavelength) | wavelength <= 0) || any(diff(wavelength) < 0), ...
        'SNIPBandOrder','BANDSB.band','Bands must be ordered by increasing representative wavelength.','6.4.4.2');
    if count == numel(header.isubcat)
        mismatch = false;
        for b = 1:count
            if ~isfinite(wavelength(b)) || wavelength(b) > 999999
                mismatch = true; continue
            end
            expected = str2double(char(bandDecimal(wavelength(b),6)));
            actual = str2double(char(bandDecimal(header.isubcat(b),6)));
            mismatch = mismatch || ~isfinite(actual) || actual ~= expected;
        end
        report = snipIssue(report,mismatch,'SNIPBandWavelength','header.isubcat', ...
            'ISUBCAT must give the corresponding BANDSB wavelength in nanometers.','10.7.4 and Table 10-5');
    end
end

function value = number(data,at,width) %#codegen
    %number - Read a validated ASCII field, preserving unknown as NaN
    value = str2double(char(data(at:at+width-1)));
end
