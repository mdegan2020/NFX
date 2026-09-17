classdef (Sealed) BANDSB < nfx.TRE
    %BANDSB - Spectral cube, band and auxiliary characterization
    %   OBJ = BANDSB(band=BANDS,Name=VALUE) supplies one SpectralBand value
    %   per image band. COUNT, EXISTENCE_MASK and auxiliary counts derive
    %   from the supplied values. Each band uses the same optional groups.
    %
    %   AUX_B structs have BAPF, UBAP, APN, APR and APA fields; AUX_C uses
    %   CAPF and UCAP instead of BAPF and UBAP. The I/R/A format selects
    %   integer double values, real double values or ASCII text rows.
    %   Supply one value per band in AUX_B and one per cube in AUX_C.
    %
    %   NaN denotes unknown cube spatial values. Decimal fields use the
    %   maximum precision fitting their widths. IEEE fields round metadata
    %   to binary32; this does not modify the associated pixel array.
    %   Reserved DATA_FLD values require the provider's NTB registration.
    %
    %   See also SpectralBand, ImageSegment, ILLUMB
    properties (Constant)
        cetag = 'BANDSB'
    end
    properties
        radiometric_quantity {mustBeAscii(radiometric_quantity,24)} = 'RAW'
        radiometric_quantity_unit {mustBeAscii(radiometric_quantity_unit,1)} = 'D'
        scale_factor {mustBeMetadata(scale_factor,-1e38,1e38,0)} = 1
        additive_factor {mustBeMetadata(additive_factor,-1e38,1e38,0)} = 0
        atmospheric_adjustment_altitude {mustBeMetadata(atmospheric_adjustment_altitude,-1e38,1e38,0)} = NaN
        row_gsd {mustBeMetadata(row_gsd,.001,9999.99,0)} = NaN
        col_gsd {mustBeMetadata(col_gsd,.001,9999.99,0)} = NaN
        spt_resp_row {mustBeMetadata(spt_resp_row,.001,9999.99,0)} = NaN
        spt_resp_col {mustBeMetadata(spt_resp_col,.001,9999.99,0)} = NaN
        row_gsd_unit {mustBeAscii(row_gsd_unit,1)} = ''
        col_gsd_unit {mustBeAscii(col_gsd_unit,1)} = ''
        spt_resp_unit_row {mustBeAscii(spt_resp_unit_row,1)} = ''
        spt_resp_unit_col {mustBeAscii(spt_resp_unit_col,1)} = ''
        wave_length_unit {mustBeAscii(wave_length_unit,1)} = ''
        radiometric_adjustment_surface {mustBeAscii(radiometric_adjustment_surface,24)} = ''
        diameter {mustBeOptionalMetadata(diameter,.01,8999.99,0)} = []
        data_fld_1 {mustBeByteField(data_fld_1,48,0)} = zeros(1,48,'uint8')
        data_fld_2 {mustBeByteField(data_fld_2,32,1)} = zeros(1,0,'uint8')
        band {mustBeBands} = nfx.SpectralBand.empty(1,0)
        aux_b {mustBeBandAuxiliary(aux_b,1)} = struct('bapf',{},'ubap',{},'apn',{},'apr',{},'apa',{})
        aux_c {mustBeBandAuxiliary(aux_c,0)} = struct('capf',{},'ucap',{},'apn',{},'apr',{},'apa',{})
    end
    properties (Dependent, SetAccess = private)
        count
        existence_mask
        num_aux_b
        num_aux_c
        byte_count
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable BANDSB value
            %   [OBJ, OK, STATUS] = nfx.BANDSB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also BANDSB, BANDSB.payload
            arguments
                data
            end
            obj = nfx.BANDSB();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.number(5, 1, 99999, true);
            [value, reader] = reader.text(24, true, false);
            if reader.ok
                obj.radiometric_quantity = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.radiometric_quantity_unit = value;
            end
            [value, reader] = reader.float32(1, -1e38, 1e38);
            if reader.ok
                obj.scale_factor = value;
            end
            [value, reader] = reader.float32(1, -1e38, 1e38);
            if reader.ok
                obj.additive_factor = value;
            end
            [value, reader] = reader.dashed(7, .001, 9999.99);
            if reader.ok
                obj.row_gsd = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.row_gsd_unit = value;
            end
            [value, reader] = reader.dashed(7, .001, 9999.99);
            if reader.ok
                obj.col_gsd = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.col_gsd_unit = value;
            end
            [value, reader] = reader.dashed(7, .001, 9999.99);
            if reader.ok
                obj.spt_resp_row = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.spt_resp_unit_row = value;
            end
            [value, reader] = reader.dashed(7, .001, 9999.99);
            if reader.ok
                obj.spt_resp_col = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.spt_resp_unit_col = value;
            end
            [value, reader] = reader.take(48);
            if reader.ok
                obj.data_fld_1 = value;
            end
            [mask, reader] = reader.unsigned(4);
            flags = false(1, 32);
            if reader.ok
                flags = bitget(uint32(mask), 1:32) ~= 0;
                if any(flags(2:6))
                    reader = reader.fail('InvalidField', 'Reserved mask bits are set.');
                end
            end
            if flags(32)
                [value, reader] = reader.text(24, true, false);
                if reader.ok
                    obj.radiometric_adjustment_surface = value;
                end
                [value, reader] = reader.float32(1, -1e38, 1e38);
                if reader.ok
                    obj.atmospheric_adjustment_altitude = value;
                end
            end
            if flags(31)
                [value, reader] = reader.dashed(7, .01, 8999.99);
                if reader.ok
                    obj.diameter = value;
                end
            end
            if flags(30)
                [value, reader] = reader.take(32);
                if reader.ok
                    obj.data_fld_2 = value;
                end
            end
            if any(flags(20:25))
                [value, reader] = reader.text(1, true, false);
                if reader.ok
                    obj.wave_length_unit = value;
                end
            end
            widths = [zeros(1, 6) 48 32 24 16 14 16 10 14 16 11 6 16 ...
                8 14 7 7 7 7 7 5 3 1 50 0 0 0];
            width = sum(double(flags) .* widths);
            if reader.ok && count * width > numel(data) - reader.position + 1
                reader = reader.fail('TruncatedPayload', ...
                    'Band definitions exceed the remaining payload.');
            end
            bands = nfx.SpectralBand.empty(1, 0);
            if reader.ok
                bands = repmat(nfx.SpectralBand(), 1, count);
                for k = 1:count
                    [bands(k), reader] = readSpectralBand(reader, flags);
                    if ~reader.ok
                        break
                    end
                end
            end
            if flags(1)
                [bandCount, reader] = reader.count(2, 8, 99);
                [cubeCount, reader] = reader.count(2, 8, 99);
                [bandAux, reader] = readBandAuxiliaryB(reader, bandCount, count);
                [cubeAux, reader] = readBandAuxiliaryC(reader, cubeCount, 1);
                if reader.ok
                    obj.aux_b = bandAux;
                    obj.aux_c = cubeAux;
                end
            end
            if reader.ok
                obj.band = bands;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.BANDSB());
        end
    end
    methods
        function obj = BANDSB(options) %#codegen
            %BANDSB - Construct editable spectral metadata
            arguments
                options.?nfx.BANDSB
            end
            if isfield(options,'radiometric_quantity'), obj.radiometric_quantity = options.radiometric_quantity; end
            if isfield(options,'radiometric_quantity_unit'), obj.radiometric_quantity_unit = options.radiometric_quantity_unit; end
            if isfield(options,'scale_factor'), obj.scale_factor = options.scale_factor; end
            if isfield(options,'additive_factor'), obj.additive_factor = options.additive_factor; end
            if isfield(options,'atmospheric_adjustment_altitude'), obj.atmospheric_adjustment_altitude = options.atmospheric_adjustment_altitude; end
            if isfield(options,'row_gsd'), obj.row_gsd = options.row_gsd; end
            if isfield(options,'col_gsd'), obj.col_gsd = options.col_gsd; end
            if isfield(options,'spt_resp_row'), obj.spt_resp_row = options.spt_resp_row; end
            if isfield(options,'spt_resp_col'), obj.spt_resp_col = options.spt_resp_col; end
            if isfield(options,'row_gsd_unit'), obj.row_gsd_unit = options.row_gsd_unit; end
            if isfield(options,'col_gsd_unit'), obj.col_gsd_unit = options.col_gsd_unit; end
            if isfield(options,'spt_resp_unit_row'), obj.spt_resp_unit_row = options.spt_resp_unit_row; end
            if isfield(options,'spt_resp_unit_col'), obj.spt_resp_unit_col = options.spt_resp_unit_col; end
            if isfield(options,'wave_length_unit'), obj.wave_length_unit = options.wave_length_unit; end
            if isfield(options,'radiometric_adjustment_surface'), obj.radiometric_adjustment_surface = options.radiometric_adjustment_surface; end
            if isfield(options,'diameter'), obj.diameter = options.diameter; end
            if isfield(options,'data_fld_1'), obj.data_fld_1 = options.data_fld_1; end
            if isfield(options,'data_fld_2'), obj.data_fld_2 = options.data_fld_2; end
            if isfield(options,'band'), obj.band = options.band; end
            if isfield(options,'aux_b'), obj.aux_b = options.aux_b; end
            if isfield(options,'aux_c'), obj.aux_c = options.aux_c; end
        end
        function value = get.count(obj) %#codegen
            %get.count - Derive the number of described spectral bands
            value = numel(obj.band);
        end
        function value = get.num_aux_b(obj) %#codegen
            %get.num_aux_b - Derive the band-level auxiliary group count
            value = numel(obj.aux_b);
        end
        function value = get.num_aux_c(obj) %#codegen
            %get.num_aux_c - Derive the cube-level auxiliary group count
            value = numel(obj.aux_c);
        end
        function value = get.existence_mask(obj) %#codegen
            %get.existence_mask - Derive cube and common per-band presence bits
            value = 0;
            if obj.count > 0, value = obj.band(1).existence_mask; end
            value = value+2^31*~isempty(char(obj.radiometric_adjustment_surface)) + ...
                2^30*~isempty(obj.diameter)+2^29*~isempty(obj.data_fld_2) + ...
                double(obj.num_aux_b+obj.num_aux_c > 0);
        end
        function value = get.byte_count(obj) %#codegen
            %get.byte_count - Count all selected cube, band and auxiliary fields
            mask = uint32(obj.existence_mask);
            value = 122+28*double(bitget(mask,32))+7*double(bitget(mask,31)) + ...
                32*double(bitget(mask,30))+double(any(bitget(mask,20:25)));
            if obj.count > 0, value = value+sum([obj.band.byte_count]); end
            if obj.num_aux_b+obj.num_aux_c > 0
                [~,~,bandSize] = bandAuxiliary(obj.aux_b,obj.count,true,false);
                [~,~,cubeSize] = bandAuxiliary(obj.aux_c,obj.count,false,false);
                value = value+4+bandSize+cubeSize;
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check field groups, common band layout and length
            report = newReport('STDI-0002 Appendix X BANDSB');
            reference = 'STDI-0002-1 Appendix X, Tables X.6-1 and X.9-1';
            report = addIssue(report,obj.count < 1 || obj.count > 99999,'BandCount','band', ...
                'Supply one to 99999 bands; the associated image must have the same count.',reference);
            report = addIssue(report,isempty(strtrim(char(obj.radiometric_quantity))) || ...
                ~any(strcmp(obj.radiometric_quantity_unit,{'A','D','E','F','G','H','I','K','L','N','P','Q','S','T','U','V','X','Y'})), ...
                'RadiometricQuantity','radiometric_quantity/unit','Supply clear-text quantity and a current published unit code.',reference);
            report = addIssue(report,~quantityUnit(obj.radiometric_quantity,obj.radiometric_quantity_unit), ...
                'QuantityUnit','radiometric_quantity_unit','The unit must describe the specified radiometric quantity.',reference);
            numbers = [obj.scale_factor obj.additive_factor];
            report = addIssue(report,any(isnan(numbers) | (numbers ~= 0 & abs(numbers) < double(single(1e-38)))), ...
                'BinaryFloatRange','scale_factor/additive_factor','Supply zero or finite magnitudes from 1e-38 to 1e38.',reference);
            spatial = [obj.row_gsd obj.col_gsd obj.spt_resp_row obj.spt_resp_col];
            units = {obj.row_gsd_unit,obj.col_gsd_unit,obj.spt_resp_unit_row,obj.spt_resp_unit_col};
            for k = 1:4
                legalUnit = any(strcmp(units{k},{'M','R'})) || (isnan(spatial(k)) && isempty(strtrim(char(units{k}))));
                report = addIssue(report,~legalUnit,'SpatialUnit','unit','Known spatial values require M or R units.',reference);
            end
            within = strcmp(strtrim(char(obj.radiometric_adjustment_surface)),'WITHIN ATMOSPHERE');
            altitude = obj.atmospheric_adjustment_altitude;
            report = addIssue(report,(within && (isnan(altitude) || (altitude ~= 0 && abs(altitude) < double(single(1e-38))))) || ...
                (~within && ~isnan(altitude)),'AdjustmentAltitude','atmospheric_adjustment_altitude', ...
                'Supply altitude only for WITHIN ATMOSPHERE; use NaN otherwise.',reference);
            report = addIssue(report,~isempty(char(obj.radiometric_adjustment_surface)) && ...
                isempty(strtrim(char(obj.radiometric_adjustment_surface))), ...
                'AdjustmentSurface','radiometric_adjustment_surface','An included adjustment surface must be nonblank.',reference);
            report = addIssue(report,~isempty(obj.diameter) && isnan(obj.diameter),'Diameter','diameter', ...
                'Supply a known lens diameter or [] to omit it.',reference);
            wave = any(bitget(uint32(obj.existence_mask),20:25));
            report = addIssue(report,(wave && ~any(strcmp(obj.wave_length_unit,{'U','W'}))) || ...
                (~wave && ~isempty(strtrim(char(obj.wave_length_unit)))), ...
                'WavelengthUnit','wave_length_unit','Supply U or W exactly when wavelength groups are present.',reference);
            identifiers = repmat(' ',obj.count,50);
            for k = 1:obj.count
                report = mergeReport(report,validate(obj.band(k)),sprintf('band(%d).',k));
                report = addIssue(report,obj.band(k).existence_mask ~= obj.band(1).existence_mask, ...
                    'BandLayout',sprintf('band(%d)',k),'All bands must populate the same field groups.',reference);
                identifiers(k,:) = textField(obj.band(k).bandid,50);
            end
            if obj.count > 0 && ~isempty(char(obj.band(1).bandid))
                report = addIssue(report,size(unique(identifiers,'rows'),1) ~= obj.count, ...
                    'BandIdentifier','band.bandid','Band identifiers must be unique within the cube.',reference);
            end
            [auxReport,~,~] = bandAuxiliary(obj.aux_b,obj.count,true,false);
            report = mergeReport(report,auxReport,'aux_b.');
            [auxReport,~,~] = bandAuxiliary(obj.aux_c,obj.count,false,false);
            report = mergeReport(report,auxReport,'aux_c.');
            report = addIssue(report,obj.byte_count > 99985,'TRELength','band/auxiliary', ...
                'The complete BANDSB payload must fit 99985 bytes.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the derived mask and big-endian metadata
            requireValid(validate(obj));
            value = zeros(1,obj.byte_count,'uint8'); at = 0;
            append([decimalField(obj.count,5,0,false) textField(obj.radiometric_quantity,24) ...
                textField(obj.radiometric_quantity_unit,1) float32Bytes(obj.scale_factor) ...
                float32Bytes(obj.additive_factor) bandDecimal(obj.row_gsd,7) textField(obj.row_gsd_unit,1) ...
                bandDecimal(obj.col_gsd,7) textField(obj.col_gsd_unit,1) bandDecimal(obj.spt_resp_row,7) ...
                textField(obj.spt_resp_unit_row,1) bandDecimal(obj.spt_resp_col,7) textField(obj.spt_resp_unit_col,1) ...
                obj.data_fld_1 unsignedBytes(uint64(obj.existence_mask),4)]);
            if ~isempty(char(obj.radiometric_adjustment_surface))
                append([textField(obj.radiometric_adjustment_surface,24) float32Bytes(obj.atmospheric_adjustment_altitude)]);
            end
            if ~isempty(obj.diameter), append(bandDecimal(obj.diameter,7)); end
            if ~isempty(obj.data_fld_2), append(obj.data_fld_2); end
            if any(bitget(uint32(obj.existence_mask),20:25)), append(textField(obj.wave_length_unit,1)); end
            for k = 1:obj.count, append(bytes(obj.band(k))); end
            if obj.num_aux_b+obj.num_aux_c > 0
                append([decimalField(obj.num_aux_b,2,0,false) decimalField(obj.num_aux_c,2,0,false)]);
                [~,part,~] = bandAuxiliary(obj.aux_b,obj.count,true,true); append(part);
                [~,part,~] = bandAuxiliary(obj.aux_c,obj.count,false,true); append(part);
            end

            function append(part)
                %append - Copy one field into the preallocated payload
                value(at+1:at+numel(part)) = part; at = at+numel(part);
            end
        end
    end
end

function mustBeBands(value) %#codegen
    %mustBeBands - Require a row of concrete spectral band values
    if ~isa(value,'nfx.SpectralBand') || ~(isrow(value) || isempty(value)) || numel(value) > 99999
        error('nfx:SpectralBands','Supply a row of at most 99999 SpectralBand values.');
    end
end

function valid = quantityUnit(quantity,unit) %#codegen
    %quantityUnit - Check unit relationships for the published quantities
    valid = true;
    switch strtrim(char(quantity))
        case {'EMISSIVITY','REFLECTANCE'}, valid = strcmp(unit,'P');
        case {'EMITTANCE','IRRADIANCE'}, valid = any(strcmp(unit,{'E','H'}));
        case {'KINETIC TEMPERATURE','RADIANT TEMPERATURE'}, valid = strcmp(unit,'K');
        case 'RADIANCE', valid = any(strcmp(unit,{'L','Q'}));
        case 'RADIANT FLUX', valid = any(strcmp(unit,{'F','G'}));
        case {'SPECTRAL EMITTANCE','SPECTRAL IRRADIANCE'}, valid = any(strcmp(unit,{'X','Y'}));
        case 'SPECTRAL RADIANCE', valid = any(strcmp(unit,{'S','T','U'}));
        case 'THERMAL INERTIA', valid = strcmp(unit,'I');
        case 'APPARENT THERMAL INERTIA', valid = any(strcmp(unit,{'I','A'}));
        case {'UNCALIBRATED','RAW'}, valid = any(strcmp(unit,{'D','V','N'}));
    end
end
