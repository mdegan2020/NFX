classdef (Sealed) SpectralBand
    %SpectralBand - Optional BANDSB metadata for one spectral band
    %   OBJ = SpectralBand(Name=VALUE) supplies band metadata. Empty values
    %   omit a field group; each band in a BANDSB uses the same groups.
    %   NIIRS=NaN means unknown and values above 9.9 encode as +++.
    %
    %   Numeric values are double. Binary fields preserve uint8 bytes.
    %   Reserved DATA_FLD values require the provider's NTB registration.
    %   Decimal fields use the maximum precision that fits their width.
    %
    %   See also BANDSB
    properties
        bad_band {mustBeOptionalMetadata(bad_band,0,1,1)} = []
        niirs {mustBeOptionalMetadata(niirs,0,1.7976931348623157e308,0)} = []
        focal_len {mustBeOptionalMetadata(focal_len,1,99999,1)} = []
        cwave {mustBeOptionalMetadata(cwave,.00001,10000,0)} = []
        fwhm {mustBeOptionalMetadata(fwhm,.00001,10000,0)} = []
        fwhm_unc {mustBeOptionalMetadata(fwhm_unc,.00001,10000,0)} = []
        nom_wave {mustBeOptionalMetadata(nom_wave,.00001,10000,0)} = []
        nom_wave_unc {mustBeOptionalMetadata(nom_wave_unc,.00001,10000,0)} = []
        lbound {mustBeOptionalMetadata(lbound,.00001,10000,0)} = []
        ubound {mustBeOptionalMetadata(ubound,.00001,10000,0)} = []
        scale_factor {mustBeOptionalMetadata(scale_factor,-1e38,1e38,0)} = []
        additive_factor {mustBeOptionalMetadata(additive_factor,-1e38,1e38,0)} = []
        int_time {mustBeOptionalMetadata(int_time,.00001,999999,0)} = []
        caldrk {mustBeOptionalMetadata(caldrk,0,999999,0)} = []
        calibration_sensitivity {mustBeOptionalMetadata(calibration_sensitivity,0,99999,0)} = []
        row_gsd {mustBeOptionalMetadata(row_gsd,0,9999.99,0)} = []
        row_gsd_unc {mustBeOptionalMetadata(row_gsd_unc,0.001,9999.99,0)} = []
        col_gsd {mustBeOptionalMetadata(col_gsd,0.01,9999.99,0)} = []
        col_gsd_unc {mustBeOptionalMetadata(col_gsd_unc,0.01,9999.99,0)} = []
        bknoise {mustBeOptionalMetadata(bknoise,0,99999,0)} = []
        scnnoise {mustBeOptionalMetadata(scnnoise,0,99999,0)} = []
        spt_resp_function_row {mustBeOptionalMetadata(spt_resp_function_row,0.001,9999.99,0)} = []
        spt_resp_unc_row {mustBeOptionalMetadata(spt_resp_unc_row,0.001,9999.99,0)} = []
        spt_resp_function_col {mustBeOptionalMetadata(spt_resp_function_col,0.001,9999.99,0)} = []
        spt_resp_unc_col {mustBeOptionalMetadata(spt_resp_unc_col,0.001,9999.99,0)} = []
        bandid {mustBeAscii(bandid,50)} = ''
        start_time {mustBeAscii(start_time,16)} = ''
        row_gsd_unit {mustBeAscii(row_gsd_unit,1)} = ''
        col_gsd_unit {mustBeAscii(col_gsd_unit,1)} = ''
        spt_resp_unit_row {mustBeAscii(spt_resp_unit_row,1)} = ''
        spt_resp_unit_col {mustBeAscii(spt_resp_unit_col,1)} = ''
        data_fld_3 {mustBeByteField(data_fld_3,16,1)} = zeros(1,0,'uint8')
        data_fld_4 {mustBeByteField(data_fld_4,24,1)} = zeros(1,0,'uint8')
        data_fld_5 {mustBeByteField(data_fld_5,32,1)} = zeros(1,0,'uint8')
        data_fld_6 {mustBeByteField(data_fld_6,48,1)} = zeros(1,0,'uint8')
    end
    properties (Dependent, SetAccess = private)
        existence_mask
        byte_count
    end
    methods
        function obj = SpectralBand(options) %#codegen
            %SpectralBand - Construct editable metadata for a single band
            arguments
                options.?nfx.SpectralBand
            end
            if isfield(options,'bad_band'), obj.bad_band = options.bad_band; end
            if isfield(options,'niirs'), obj.niirs = options.niirs; end
            if isfield(options,'focal_len'), obj.focal_len = options.focal_len; end
            if isfield(options,'cwave'), obj.cwave = options.cwave; end
            if isfield(options,'fwhm'), obj.fwhm = options.fwhm; end
            if isfield(options,'fwhm_unc'), obj.fwhm_unc = options.fwhm_unc; end
            if isfield(options,'nom_wave'), obj.nom_wave = options.nom_wave; end
            if isfield(options,'nom_wave_unc'), obj.nom_wave_unc = options.nom_wave_unc; end
            if isfield(options,'lbound'), obj.lbound = options.lbound; end
            if isfield(options,'ubound'), obj.ubound = options.ubound; end
            if isfield(options,'scale_factor'), obj.scale_factor = options.scale_factor; end
            if isfield(options,'additive_factor'), obj.additive_factor = options.additive_factor; end
            if isfield(options,'int_time'), obj.int_time = options.int_time; end
            if isfield(options,'caldrk'), obj.caldrk = options.caldrk; end
            if isfield(options,'calibration_sensitivity'), obj.calibration_sensitivity = options.calibration_sensitivity; end
            if isfield(options,'row_gsd'), obj.row_gsd = options.row_gsd; end
            if isfield(options,'row_gsd_unc'), obj.row_gsd_unc = options.row_gsd_unc; end
            if isfield(options,'col_gsd'), obj.col_gsd = options.col_gsd; end
            if isfield(options,'col_gsd_unc'), obj.col_gsd_unc = options.col_gsd_unc; end
            if isfield(options,'bknoise'), obj.bknoise = options.bknoise; end
            if isfield(options,'scnnoise'), obj.scnnoise = options.scnnoise; end
            if isfield(options,'spt_resp_function_row'), obj.spt_resp_function_row = options.spt_resp_function_row; end
            if isfield(options,'spt_resp_unc_row'), obj.spt_resp_unc_row = options.spt_resp_unc_row; end
            if isfield(options,'spt_resp_function_col'), obj.spt_resp_function_col = options.spt_resp_function_col; end
            if isfield(options,'spt_resp_unc_col'), obj.spt_resp_unc_col = options.spt_resp_unc_col; end
            if isfield(options,'bandid'), obj.bandid = options.bandid; end
            if isfield(options,'start_time'), obj.start_time = options.start_time; end
            if isfield(options,'row_gsd_unit'), obj.row_gsd_unit = options.row_gsd_unit; end
            if isfield(options,'col_gsd_unit'), obj.col_gsd_unit = options.col_gsd_unit; end
            if isfield(options,'spt_resp_unit_row'), obj.spt_resp_unit_row = options.spt_resp_unit_row; end
            if isfield(options,'spt_resp_unit_col'), obj.spt_resp_unit_col = options.spt_resp_unit_col; end
            if isfield(options,'data_fld_3'), obj.data_fld_3 = options.data_fld_3; end
            if isfield(options,'data_fld_4'), obj.data_fld_4 = options.data_fld_4; end
            if isfield(options,'data_fld_5'), obj.data_fld_5 = options.data_fld_5; end
            if isfield(options,'data_fld_6'), obj.data_fld_6 = options.data_fld_6; end
        end
        function flags = maskBits(obj) %#codegen
            %MASKBITS - Derive each per-band field group from supplied values
            flags = false(1,32);
            flags(29) = ~isempty(char(obj.bandid));
            flags(28) = ~isempty(obj.bad_band);
            flags(27) = ~isempty(obj.niirs);
            flags(26) = ~isempty(obj.focal_len);
            flags(25) = ~isempty(obj.cwave);
            flags(24) = ~isempty(obj.fwhm);
            flags(23) = ~isempty(obj.fwhm_unc);
            flags(22) = ~isempty(obj.nom_wave);
            flags(21) = ~isempty(obj.nom_wave_unc);
            flags(20) = ~isempty(obj.lbound) || ~isempty(obj.ubound);
            flags(19) = ~isempty(obj.scale_factor) || ~isempty(obj.additive_factor);
            flags(18) = ~isempty(char(obj.start_time));
            flags(17) = ~isempty(obj.int_time);
            flags(16) = ~isempty(obj.caldrk) || ~isempty(obj.calibration_sensitivity);
            flags(15) = ~isempty(obj.row_gsd) || ~isempty(char(obj.row_gsd_unit)) || ~isempty(obj.col_gsd) || ~isempty(char(obj.col_gsd_unit));
            flags(14) = ~isempty(obj.row_gsd_unc) || ~isempty(obj.col_gsd_unc);
            flags(13) = ~isempty(obj.bknoise) || ~isempty(obj.scnnoise);
            flags(12) = ~isempty(obj.spt_resp_function_row) || ~isempty(char(obj.spt_resp_unit_row)) || ~isempty(obj.spt_resp_function_col) || ~isempty(char(obj.spt_resp_unit_col));
            flags(11) = ~isempty(obj.spt_resp_unc_row) || ~isempty(obj.spt_resp_unc_col);
            flags(10) = ~isempty(obj.data_fld_3);
            flags(9) = ~isempty(obj.data_fld_4);
            flags(8) = ~isempty(obj.data_fld_5);
            flags(7) = ~isempty(obj.data_fld_6);
        end
        function value = get.existence_mask(obj) %#codegen
            %get.existence_mask - Derive the common band contribution to the mask
            value = sum(double(obj.maskBits()).*2.^(0:31));
        end
        function value = get.byte_count(obj) %#codegen
            %get.byte_count - Count all selected band fields
            widths = [zeros(1,6) 48 32 24 16 14 16 10 14 16 11 6 16 8 14 7 7 7 7 7 5 3 1 50 0 0 0];
            value = sum(double(obj.maskBits()).*widths);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check complete mask groups and supplied field values
            report = newReport('STDI-0002 Appendix X spectral band');
            reference = 'STDI-0002-1 Appendix X, Tables X.6-1 and X.9-1';
            flags = obj.maskBits();
            report = addIssue(report,flags(29) && (isempty(char(obj.bandid))), ...
                'BandFields','bandid', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(28) && (isempty(obj.bad_band) || any(isnan([obj.bad_band]))), ...
                'BandFields','bad_band', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(27) && (isempty(obj.niirs)), ...
                'BandFields','niirs', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(26) && (isempty(obj.focal_len) || any(isnan([obj.focal_len]))), ...
                'BandFields','focal_len', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(25) && (isempty(obj.cwave) || any(isnan([obj.cwave]))), ...
                'BandFields','cwave', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(24) && (isempty(obj.fwhm) || any(isnan([obj.fwhm]))), ...
                'BandFields','fwhm', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(23) && (isempty(obj.fwhm_unc) || any(isnan([obj.fwhm_unc]))), ...
                'BandFields','fwhm_unc', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(22) && (isempty(obj.nom_wave) || any(isnan([obj.nom_wave]))), ...
                'BandFields','nom_wave', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(21) && (isempty(obj.nom_wave_unc) || any(isnan([obj.nom_wave_unc]))), ...
                'BandFields','nom_wave_unc', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(20) && (isempty(obj.lbound) || isempty(obj.ubound) || any(isnan([obj.lbound obj.ubound]))), ...
                'BandFields','lbound/ubound', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(19) && (isempty(obj.scale_factor) || isempty(obj.additive_factor) || any(isnan([obj.scale_factor obj.additive_factor]))), ...
                'BandFields','scale_factor/additive_factor', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(18) && (isempty(char(obj.start_time))), ...
                'BandFields','start_time', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(17) && (isempty(obj.int_time) || any(isnan([obj.int_time]))), ...
                'BandFields','int_time', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(16) && (isempty(obj.caldrk) || isempty(obj.calibration_sensitivity) || any(isnan([obj.caldrk obj.calibration_sensitivity]))), ...
                'BandFields','caldrk/calibration_sensitivity', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(15) && (isempty(obj.row_gsd) || isempty(char(obj.row_gsd_unit)) || isempty(obj.col_gsd) || isempty(char(obj.col_gsd_unit)) || any(isnan([obj.row_gsd obj.col_gsd]))), ...
                'BandFields','row_gsd/row_gsd_unit/col_gsd/col_gsd_unit', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(14) && (isempty(obj.row_gsd_unc) || isempty(obj.col_gsd_unc) || any(isnan([obj.row_gsd_unc obj.col_gsd_unc]))), ...
                'BandFields','row_gsd_unc/col_gsd_unc', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(13) && (isempty(obj.bknoise) || isempty(obj.scnnoise) || any(isnan([obj.bknoise obj.scnnoise]))), ...
                'BandFields','bknoise/scnnoise', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(12) && (isempty(obj.spt_resp_function_row) || isempty(char(obj.spt_resp_unit_row)) || isempty(obj.spt_resp_function_col) || isempty(char(obj.spt_resp_unit_col)) || any(isnan([obj.spt_resp_function_row obj.spt_resp_function_col]))), ...
                'BandFields','spt_resp_function_row/spt_resp_unit_row/spt_resp_function_col/spt_resp_unit_col', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(11) && (isempty(obj.spt_resp_unc_row) || isempty(obj.spt_resp_unc_col) || any(isnan([obj.spt_resp_unc_row obj.spt_resp_unc_col]))), ...
                'BandFields','spt_resp_unc_row/spt_resp_unc_col', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(10) && (isempty(obj.data_fld_3)), ...
                'BandFields','data_fld_3', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(9) && (isempty(obj.data_fld_4)), ...
                'BandFields','data_fld_4', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(8) && (isempty(obj.data_fld_5)), ...
                'BandFields','data_fld_5', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(7) && (isempty(obj.data_fld_6)), ...
                'BandFields','data_fld_6', 'Supply every field in an included mask group.',reference);
            report = addIssue(report,flags(29) && isempty(strtrim(char(obj.bandid))), ...
                'BandIdentifier','bandid','An included band identifier must be nonblank.',reference);
            units = {obj.row_gsd_unit,obj.col_gsd_unit,obj.spt_resp_unit_row,obj.spt_resp_unit_col};
            for k = 1:numel(units)
                report = addIssue(report,~isempty(char(units{k})) && ~any(strcmp(units{k},{'M','R'})), ...
                    'SpatialUnit','unit','Use M for meters or R for microradians.',reference);
            end
            report = addIssue(report,flags(18) && ~bandStartTime(obj.start_time), ...
                'BandTime','start_time','Use YYMMDDhhmmss.sss with hyphens for unknown digits.',reference);
            values = [obj.scale_factor obj.additive_factor];
            report = addIssue(report,any(values ~= 0 & abs(values) < double(single(1e-38))), ...
                'BinaryFloatRange','scale_factor/additive_factor','Nonzero IEEE values must have magnitude at least 1e-38.',reference);
            report = addIssue(report,~isempty(obj.lbound) && ~isempty(obj.ubound) && obj.lbound > obj.ubound, ...
                'WavelengthOrder','lbound/ubound','Lower wavelength must not exceed upper wavelength.',reference);
            report = addIssue(report,any(flags(24:25)) && any(flags([20 22])), ...
                'SpectralRepresentation','cwave/fwhm/nom_wave/lbound','Select compatible symmetric or asymmetric spectral fields.',reference);
            report = addIssue(report,(flags(23) && ~flags(24)) || (flags(21) && ~flags(22)) || ...
                (flags(14) && ~flags(15)) || (flags(11) && ~flags(12)), ...
                'UncertaintyBase','uncertainty','An uncertainty requires the corresponding measured field group.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize the selected fields in BANDSB table order
            requireValid(validate(obj));
            value = zeros(1,obj.byte_count,'uint8'); at = 0;
            flags = obj.maskBits();
            if flags(29), append(textField(obj.bandid,50)); end
            if flags(28), append(decimalField(obj.bad_band,1,0,false)); end
            if flags(27)
                if isnan(obj.niirs), append(uint8('---'));
                elseif obj.niirs > 9.9, append(uint8('+++'));
                else, append(decimalField(obj.niirs,3,1,false));
                end
            end
            if flags(26), append(decimalField(obj.focal_len,5,0,false)); end
            if flags(25), append(bandDecimal(obj.cwave,7)); end
            if flags(24), append(bandDecimal(obj.fwhm,7)); end
            if flags(23), append(bandDecimal(obj.fwhm_unc,7)); end
            if flags(22), append(bandDecimal(obj.nom_wave,7)); end
            if flags(21), append(bandDecimal(obj.nom_wave_unc,7)); end
            if flags(20), append([bandDecimal(obj.lbound,7) bandDecimal(obj.ubound,7)]); end
            if flags(19), append([float32Bytes(obj.scale_factor) float32Bytes(obj.additive_factor)]); end
            if flags(18), append(textField(obj.start_time,16)); end
            if flags(17), append(bandDecimal(obj.int_time,6)); end
            if flags(16), append([bandDecimal(obj.caldrk,6) bandDecimal(obj.calibration_sensitivity,5)]); end
            if flags(15)
                append(bandDecimal(obj.row_gsd,7));
                if flags(14), append(bandDecimal(obj.row_gsd_unc,7)); end
                append(textField(obj.row_gsd_unit,1)); append(bandDecimal(obj.col_gsd,7));
                if flags(14), append(bandDecimal(obj.col_gsd_unc,7)); end
                append(textField(obj.col_gsd_unit,1));
            end
            if flags(13), append([bandDecimal(obj.bknoise,5) bandDecimal(obj.scnnoise,5)]); end
            if flags(12)
                append(bandDecimal(obj.spt_resp_function_row,7));
                if flags(11), append(bandDecimal(obj.spt_resp_unc_row,7)); end
                append(textField(obj.spt_resp_unit_row,1)); append(bandDecimal(obj.spt_resp_function_col,7));
                if flags(11), append(bandDecimal(obj.spt_resp_unc_col,7)); end
                append(textField(obj.spt_resp_unit_col,1));
            end
            if flags(10), append(obj.data_fld_3); end
            if flags(9), append(obj.data_fld_4); end
            if flags(8), append(obj.data_fld_5); end
            if flags(7), append(obj.data_fld_6); end

            function append(part)
                %append - Copy one field into the preallocated payload
                value(at+1:at+numel(part)) = part; at = at+numel(part);
            end
        end
    end
end
