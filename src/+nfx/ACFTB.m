classdef (Sealed) ACFTB < nfx.TRE
    %ACFTB - Aircraft acquisition, sensor and image spacing metadata
    %   OBJ = ACFTB(Name=VALUE) supplies the 207-byte airborne record.
    %   Optional numeric fields use NaN for spaces. Unknown pixel spacing
    %   uses NaN and encodes seven zeros; unknown FOCAL_LENGTH encodes 999.99.
    %   ENTLOC/EXITLOC retain either specified 25-character coordinate form.
    %
    %   Sensor identifiers and modes use the published Appendix E registry
    %   values. Additional registered values require a verified table update.
    %   Values describe supplied acquisition geometry; no geometry is fitted.
    %
    %   See also AIMIDB, ImageHeader, BANDSB

    properties (Constant)
        cetag = 'ACFTB '
    end
    properties
        ac_msn_id {mustBeAscii(ac_msn_id,20)} = 'NOT AVAILABLE'
        ac_tail_no {mustBeAscii(ac_tail_no,10)} = ''
        ac_to {mustBeAscii(ac_to,12)} = ''
        sensor_id_type {mustBeAscii(sensor_id_type,4)} = ''
        sensor_id {mustBeAscii(sensor_id,6)} = ''
        scene_source {mustBeMetadata(scene_source,0,9,1)} = NaN
        scnum {mustBeMetadata(scnum,0,999999,1)} = 0
        pdate {mustBeAscii(pdate,8)} = ''
        imhostno {mustBeMetadata(imhostno,0,999999,1)} = 0
        imreqid {mustBeMetadata(imreqid,0,99999,1)} = 0
        mplan {mustBeMetadata(mplan,1,999,1)} = NaN
        entloc {mustBeAscii(entloc,25)} = ''
        loc_accy {mustBeMetadata(loc_accy,0,999.99,0)} = 0
        entelv {mustBeMetadata(entelv,-1000,30000,1)} = NaN
        elv_unit {mustBeAscii(elv_unit,1)} = ''
        exitloc {mustBeAscii(exitloc,25)} = ''
        exitelv {mustBeMetadata(exitelv,-1000,30000,1)} = NaN
        tmap {mustBeMetadata(tmap,0,180,0)} = NaN
        row_spacing {mustBeMetadata(row_spacing,0,9999.99,0)} = NaN
        row_spacing_units {mustBeAscii(row_spacing_units,1)} = 'u'
        col_spacing {mustBeMetadata(col_spacing,0,9999.99,0)} = NaN
        col_spacing_units {mustBeAscii(col_spacing_units,1)} = 'u'
        focal_length {mustBeMetadata(focal_length,0.01,999.99,0)} = NaN
        senserial {mustBeMetadata(senserial,1,999999,1)} = NaN
        abswver {mustBeAscii(abswver,7)} = ''
        cal_date {mustBeAscii(cal_date,8)} = ''
        patch_tot {mustBeMetadata(patch_tot,0,9999,1)} = 0
        mti_tot {mustBeMetadata(mti_tot,0,999,1)} = 0
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable ACFTB value
            %   [OBJ, OK, STATUS] = nfx.ACFTB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also ACFTB, ACFTB.payload
            arguments
                data
            end
            obj = nfx.ACFTB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(20, true, false);
            if reader.ok
                obj.ac_msn_id = value;
            end
            [value, reader] = reader.text(10, true, false);
            if reader.ok
                obj.ac_tail_no = value;
            end
            [value, reader] = reader.text(12, true, false);
            if reader.ok
                obj.ac_to = value;
            end
            [value, reader] = reader.text(4, true, false);
            if reader.ok
                obj.sensor_id_type = value;
            end
            [value, reader] = reader.text(6, true, false);
            if reader.ok
                obj.sensor_id = value;
            end
            [value, reader] = reader.number( ...
                1, 0, 9, 1, true);
            if reader.ok
                obj.scene_source = value;
            end
            [value, reader] = reader.number( ...
                6, 0, 999999, 1, false);
            if reader.ok
                obj.scnum = value;
            end
            [value, reader] = reader.text(8, true, false);
            if reader.ok
                obj.pdate = value;
            end
            [value, reader] = reader.number( ...
                6, 0, 999999, 1, false);
            if reader.ok
                obj.imhostno = value;
            end
            [value, reader] = reader.number( ...
                5, 0, 99999, 1, false);
            if reader.ok
                obj.imreqid = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 999, 1, false);
            if reader.ok
                obj.mplan = value;
            end
            [value, reader] = reader.text(25, true, false);
            if reader.ok
                obj.entloc = value;
            end
            [value, reader] = reader.number( ...
                6, 0, 999.99, 0, false);
            if reader.ok
                obj.loc_accy = value;
            end
            [value, reader] = reader.number( ...
                6, -1000, 30000, 1, true);
            if reader.ok
                obj.entelv = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.elv_unit = value;
            end
            [value, reader] = reader.text(25, true, false);
            if reader.ok
                obj.exitloc = value;
            end
            [value, reader] = reader.number( ...
                6, -1000, 30000, 1, true);
            if reader.ok
                obj.exitelv = value;
            end
            [value, reader] = reader.number( ...
                7, 0, 180, 0, true);
            if reader.ok
                obj.tmap = value;
            end
            [value, reader] = reader.number( ...
                7, 0, 9999.99, 0, false);
            if reader.ok
                if all(reader.data(reader.position - 7: ...
                        reader.position - 1) == '0')
                    value = NaN;
                end
                obj.row_spacing = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.row_spacing_units = value;
            end
            [value, reader] = reader.number( ...
                7, 0, 9999.99, 0, false);
            if reader.ok
                if all(reader.data(reader.position - 7: ...
                        reader.position - 1) == '0')
                    value = NaN;
                end
                obj.col_spacing = value;
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok
                obj.col_spacing_units = value;
            end
            [value, reader] = reader.number( ...
                6, 0.01, 999.99, 0, false);
            if reader.ok
                obj.focal_length = value;
            end
            [value, reader] = reader.number( ...
                6, 1, 999999, 1, true);
            if reader.ok
                obj.senserial = value;
            end
            [value, reader] = reader.text(7, true, false);
            if reader.ok
                obj.abswver = value;
            end
            [value, reader] = reader.text(8, true, false);
            if reader.ok
                obj.cal_date = value;
            end
            [value, reader] = reader.number( ...
                4, 0, 9999, 1, false);
            if reader.ok
                obj.patch_tot = value;
            end
            [value, reader] = reader.number( ...
                3, 0, 999, 1, false);
            if reader.ok
                obj.mti_tot = value;
            end
            if obj.focal_length == 999.99
                obj.focal_length = NaN;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ACFTB());
        end
    end
    methods
        function obj = ACFTB(options) %#codegen
            %ACFTB - Construct editable aircraft/sensor information
            arguments
                options.?nfx.ACFTB
            end
            if isfield(options,'ac_msn_id'), obj.ac_msn_id = options.ac_msn_id; end
            if isfield(options,'ac_tail_no'), obj.ac_tail_no = options.ac_tail_no; end
            if isfield(options,'ac_to'), obj.ac_to = options.ac_to; end
            if isfield(options,'sensor_id_type'), obj.sensor_id_type = options.sensor_id_type; end
            if isfield(options,'sensor_id'), obj.sensor_id = options.sensor_id; end
            if isfield(options,'scene_source'), obj.scene_source = options.scene_source; end
            if isfield(options,'scnum'), obj.scnum = options.scnum; end
            if isfield(options,'pdate'), obj.pdate = options.pdate; end
            if isfield(options,'imhostno'), obj.imhostno = options.imhostno; end
            if isfield(options,'imreqid'), obj.imreqid = options.imreqid; end
            if isfield(options,'mplan'), obj.mplan = options.mplan; end
            if isfield(options,'entloc'), obj.entloc = options.entloc; end
            if isfield(options,'loc_accy'), obj.loc_accy = options.loc_accy; end
            if isfield(options,'entelv'), obj.entelv = options.entelv; end
            if isfield(options,'elv_unit'), obj.elv_unit = options.elv_unit; end
            if isfield(options,'exitloc'), obj.exitloc = options.exitloc; end
            if isfield(options,'exitelv'), obj.exitelv = options.exitelv; end
            if isfield(options,'tmap'), obj.tmap = options.tmap; end
            if isfield(options,'row_spacing'), obj.row_spacing = options.row_spacing; end
            if isfield(options,'row_spacing_units'), obj.row_spacing_units = options.row_spacing_units; end
            if isfield(options,'col_spacing'), obj.col_spacing = options.col_spacing; end
            if isfield(options,'col_spacing_units'), obj.col_spacing_units = options.col_spacing_units; end
            if isfield(options,'focal_length'), obj.focal_length = options.focal_length; end
            if isfield(options,'senserial'), obj.senserial = options.senserial; end
            if isfield(options,'abswver'), obj.abswver = options.abswver; end
            if isfield(options,'cal_date'), obj.cal_date = options.cal_date; end
            if isfield(options,'patch_tot'), obj.patch_tot = options.patch_tot; end
            if isfield(options,'mti_tot'), obj.mti_tot = options.mti_tot; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check published codes, dates, units and sensor conditions
            report = newReport('STDI-0002 Appendix E ACFTB');
            reference = 'STDI-0002-1 Appendix E, E.3.2.2 and Tables E-6/E-6a';
            report = addIssue(report,isempty(strtrim(char(obj.ac_msn_id))), ...
                'Required','ac_msn_id','Supply a mission identifier or NOT AVAILABLE.',reference);
            report = addIssue(report,~knownDate(obj.pdate,8) || ...
                (~isempty(strtrim(char(obj.ac_to))) && ~knownDate(obj.ac_to,12)) || ...
                (~isempty(strtrim(char(obj.cal_date))) && ~knownDate(obj.cal_date,8)), ...
                'Date','pdate/ac_to/cal_date','Use fully known UTC dates/times, or blank optional dates.',reference);
            type = strtrim(char(obj.sensor_id_type));
            radar = strcmp(type,'SAR');
            optical = numel(type) == 4 && any(strcmp(type(1:2), ...
                {'HH','HM','HL','IH','IM','IL','MH','MM','ML','VF','VH','VM','VL'})) && ...
                any(strcmp(type(3:4),{'FR','LS','PB','PS'}));
            lidar = any(strcmp(type,{'LIGM','LILN'}));
            report = addIssue(report,~(radar || optical || lidar),'SensorType', ...
                'sensor_id_type','Use SAR, a published category/format, or LIGM/LILN.',reference);
            [idValid,modeValid,sourceValid,spot,typeValid] = aircraftCodes(obj.sensor_id,obj.mplan,obj.scene_source,radar,optical);
            report = addIssue(report,~idValid,'SensorId','sensor_id','Supply a published registered sensor identifier.',reference);
            report = addIssue(report,~typeValid,'SensorCategory','sensor_id_type/sensor_id/mplan', ...
                'The sensor type must match the registered sensor and the selected collection mode.',reference);
            report = addIssue(report,~modeValid,'SensorMode','mplan', ...
                'The mode must be published for this sensor; reserved/unverified modes cannot be asserted.',reference);
            report = addIssue(report,~sourceValid,'SceneSource','scene_source', ...
                'Use blank, preplanned zero, or a published source for this sensor.',reference);
            report = addIssue(report,any(isnan([obj.scnum obj.imhostno obj.imreqid obj.mplan ...
                obj.loc_accy obj.patch_tot obj.mti_tot])), ...
                'Required','numeric fields','Supply all required numeric metadata.',reference);
            report = addIssue(report,obj.scnum ~= 0 && (obj.imhostno ~= 0 || obj.imreqid ~= 0), ...
                'ImmediateScene','imhostno/imreqid','Only immediate scenes use nonzero immediate request fields.',reference);
            report = addIssue(report,~validAcquisitionLocation(obj.entloc,'precise') || ...
                ~validAcquisitionLocation(obj.exitloc,'precise'),'Location','entloc/exitloc', ...
                'Use the specified 25-byte decimal/DMS coordinate form, or blank.',reference);
            unit = char(obj.elv_unit);
            report = addIssue(report,~any(strcmp(unit,{'',' ','f','m'})) || ...
                (any(~isnan([obj.entelv obj.exitelv])) && ~any(strcmp(unit,{'f','m'}))), ...
                'ElevationUnits','elv_unit','Known elevations require f or m units.',reference);
            report = addIssue(report,~spacingValid(obj.row_spacing,obj.row_spacing_units) || ...
                ~spacingValid(obj.col_spacing,obj.col_spacing_units),'PixelSpacing','row_spacing/col_spacing', ...
                'Use f/m spacing up to 99.9999, r up to 9999.99, or unknown u with no nonzero spacing.',reference);
            report = addIssue(report,obj.focal_length > 899.99 && obj.focal_length ~= 999.99, ...
                'FocalLength','focal_length','Use 0.01 to 899.99, or the unknown sentinel.',reference);
            report = addIssue(report,optical && (obj.patch_tot ~= 0 || obj.mti_tot ~= 0), ...
                'OpticalCounts','patch_tot/mti_tot','EO-IR imagery has zero SAR patch and MTI counts.',reference);
            report = addIssue(report,radar && spot && obj.patch_tot > 1, ...
                'SpotPatchCount','patch_tot','A SAR spot contains at most one patch.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode exact ASCII fields and unknown-value sentinels
            requireValid(validate(obj));
            focal = obj.focal_length;
            if isnan(focal), focal = 999.99; end
            value = [textField(obj.ac_msn_id,20) textField(obj.ac_tail_no,10) textField(obj.ac_to,12) ...
                textField(obj.sensor_id_type,4) textField(obj.sensor_id,6) blankDecimal(obj.scene_source,1,0,false) ...
                decimalField(obj.scnum,6,0,false) textField(obj.pdate,8) decimalField(obj.imhostno,6,0,false) ...
                decimalField(obj.imreqid,5,0,false) decimalField(obj.mplan,3,0,false) textField(obj.entloc,25) ...
                decimalField(obj.loc_accy,6,2,false) blankDecimal(obj.entelv,6,0,true) textField(obj.elv_unit,1) ...
                textField(obj.exitloc,25) blankDecimal(obj.exitelv,6,0,true) blankDecimal(obj.tmap,7,3,false) ...
                spacingBytes(obj.row_spacing,obj.row_spacing_units) textField(obj.row_spacing_units,1) ...
                spacingBytes(obj.col_spacing,obj.col_spacing_units) textField(obj.col_spacing_units,1) ...
                decimalField(focal,6,2,false) blankDecimal(obj.senserial,6,0,false) textField(obj.abswver,7) ...
                textField(obj.cal_date,8) decimalField(obj.patch_tot,4,0,false) decimalField(obj.mti_tot,3,0,false)];
        end
    end
end

function valid = spacingValid(number,units) %#codegen
    %spacingValid - Check spacing representation against its physical unit
    valid = any(strcmp(units,{'f','m','r','u'}));
    if strcmp(units,'u'), valid = valid && (isnan(number) || number == 0); end
    if any(strcmp(units,{'f','m'})), valid = valid && (isnan(number) || number <= 99.9999); end
end

function value = spacingBytes(number,units) %#codegen
    %spacingBytes - Preserve the seven-zero unknown spacing representation
    if isnan(number) || strcmp(units,'u')
        value = uint8('0000000');
    else
        places = 4;
        if strcmp(units,'r'), places = 2; end
        value = decimalField(number,7,places,false);
    end
end
