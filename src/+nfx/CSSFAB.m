classdef (Sealed) CSSFAB < nfx.SensorDES
    %CSSFAB - Encode supplied scanner or frame sensor field alignment
    %   OBJ = CSSFAB(Name=VALUE) writes version-two field alignment metadata.
    %   SENSOR_TYPE='S' uses four START_FALIGN/END_FALIGN double rows and the
    %   first sample and pair spacing. SENSOR_TYPE='F' uses FIELD_ANGLE_TYPE=0
    %   with FA_GRIDS, or =1 with FIDUCIAL_TRANSFORM and IOP calibration sets.
    %
    %   BANDS is an ordered SensorBand row; empty means all associated bands.
    %   BAND_TYPE is informational and does not select image/model bindings.
    %   FOC_LENGTH_TIME and FOC_LENGTH are matching chronological double rows.
    %   Focal lengths and PPOFF use meters; ANGOFF uses radians.
    %
    %   Optional TELESCOPE contains one TelescopeOptics value for frame or
    %   time-based corrections. All counts and telescope flags derive.
    %   No geometry is inferred, fitted or transformed by this serializer.
    %
    %   See also SensorDES, FieldAlignmentGrid, FiducialTransform
    %   See also InteriorOrientation, TelescopeOptics, SensorBand

    properties (Constant)
        desid = 'CSSFAB'
    end
    properties
        sensor_type {mustBeAscii(sensor_type,1)} = ''
        band_type {mustBeAscii(band_type,1)} = ''
        band_wavelength {mustBeMetadata(band_wavelength,0,99.99999999,0)} = NaN
        bands {mustBeGLASObjects(bands,'nfx.SensorBand')} = nfx.SensorBand.empty(1,0)
        fl_interp {mustBeMetadata(fl_interp,0,1,1)} = NaN
        foc_length_date {mustBeAscii(foc_length_date,8)} = ''
        foc_length_time {mustBeFocalRow(foc_length_time,99999.999999999)} = zeros(1,0)
        foc_length {mustBeFocalRow(foc_length,99.99999999)} = zeros(1,0)
        ppoff_x {mustBeMetadata(ppoff_x,-99.999999,99.999999,0)} = NaN
        ppoff_y {mustBeMetadata(ppoff_y,-99.999999,99.999999,0)} = NaN
        ppoff_z {mustBeMetadata(ppoff_z,-99.999999,99.999999,0)} = NaN
        angoff_x {mustBeMetadata(angoff_x,-3.1415927,3.1415927,0)} = NaN
        angoff_y {mustBeMetadata(angoff_y,-3.1415927,3.1415927,0)} = NaN
        angoff_z {mustBeMetadata(angoff_z,-3.1415927,3.1415927,0)} = NaN
        smpl_num_first {mustBeMetadata(smpl_num_first,-99999.99999,99999.99999,0)} = NaN
        delta_smpl_pairs {mustBeMetadata(delta_smpl_pairs,0,99999.99999,0)} = NaN
        start_falign_x {mustBeGLASMatrix(start_falign_x,1,999,99.9999999)} = zeros(1,0)
        start_falign_y {mustBeGLASMatrix(start_falign_y,1,999,99.9999999)} = zeros(1,0)
        end_falign_x {mustBeGLASMatrix(end_falign_x,1,999,99.9999999)} = zeros(1,0)
        end_falign_y {mustBeGLASMatrix(end_falign_y,1,999,99.9999999)} = zeros(1,0)
        field_angle_type {mustBeMetadata(field_angle_type,0,1,1)} = NaN
        fa_interp {mustBeMetadata(fa_interp,0,1,1)} = NaN
        fa_grids {mustBeGLASObjects(fa_grids,'nfx.FieldAlignmentGrid')} = nfx.FieldAlignmentGrid.empty(1,0)
        fiducial_transform {mustBeGLASObjects(fiducial_transform,'nfx.FiducialTransform')} = nfx.FiducialTransform.empty(1,0)
        iop {mustBeGLASObjects(iop,'nfx.InteriorOrientation')} = nfx.InteriorOrientation.empty(1,0)
        telescope {mustBeGLASObjects(telescope,'nfx.TelescopeOptics')} = nfx.TelescopeOptics.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        n_bands
        num_fl_pts
        num_fa_pairs
        num_sets_fa_data
        telescope_optics_flag
        byte_length
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data, header) %#codegen
            %deserialize - Restore supplied field-alignment metadata
            %   [OBJ, OK, STATUS] = nfx.CSSFAB.deserialize(DATA, HEADER)
            %   validates the bytes and associations. Failure returns a
            %   default scalar descriptor with an explicit diagnostic.
            %
            %   See also CSSFAB, SensorDES.segment
            arguments
                data
                header
            end
            obj = nfx.CSSFAB();
            [obj, reader] = nfx.SensorDES.readHeader(obj, header);
            if reader.ok && obj.desver ~= 2
                reader = reader.fail('UnsupportedVersion', 'Unsupported CSSFAB version.');
            end
            if ~reader.ok
                ok = false; status = decodeStatus(reader.code, reader.message, reader.position);
                obj = nfx.CSSFAB(); return
            end
            reader = nfx.internal.TREReader(data, 999999998);
            [kind, reader] = reader.choice('SF');
            if reader.ok, obj.sensor_type = kind; end
            [value, reader] = reader.text(1, false);
            if reader.ok, obj.band_type = value; end
            [value, reader] = reader.number(11, 0, 99.99999999, false);
            if reader.ok, obj.band_wavelength = value; end
            [count, reader] = reader.count(5, 13, 99999);
            for k = 1:count
                band = nfx.SensorBand();
                [id, reader] = reader.number(5, 1, 99999, true);
                [rep, reader] = reader.text(2);
                [subcat, reader] = reader.number(6, 0, 999999, false, true);
                if ~reader.ok, break, end
                band.band_index = id; band.irepband = rep; band.isubcat = subcat;
                obj.bands(end + 1) = band;
            end
            [count, reader] = reader.count(3, 26, 999);
            [value, reader] = reader.number(1, 0, 1, true);
            if reader.ok, obj.fl_interp = value; end
            [value, reader] = reader.text(8, false);
            if reader.ok, obj.foc_length_date = value; end
            times = zeros(1, count); lengths = zeros(1, count);
            for k = 1:count
                [times(k), reader] = reader.number(15, 0, 99999.999999999);
                [lengths(k), reader] = reader.number(11, 0, 99.99999999);
            end
            if reader.ok, obj.foc_length_time = times; obj.foc_length = lengths; end
            [value, reader] = reader.number(10, -99.999999, 99.999999, false);
            if reader.ok, obj.ppoff_x = value; end
            [value, reader] = reader.number(10, -99.999999, 99.999999, false);
            if reader.ok, obj.ppoff_y = value; end
            [value, reader] = reader.number(10, -99.999999, 99.999999, false);
            if reader.ok, obj.ppoff_z = value; end
            [value, reader] = reader.number(10, -3.1415927, 3.1415927, false);
            if reader.ok, obj.angoff_x = value; end
            [value, reader] = reader.number(10, -3.1415927, 3.1415927, false);
            if reader.ok, obj.angoff_y = value; end
            [value, reader] = reader.number(10, -3.1415927, 3.1415927, false);
            if reader.ok, obj.angoff_z = value; end
            if reader.ok && kind == 'S'
                [value, reader] = reader.number(12, -99999.99999, 99999.99999, false);
                if reader.ok, obj.smpl_num_first = value; end
                [value, reader] = reader.number(11, 0, 99999.99999, false);
                if reader.ok, obj.delta_smpl_pairs = value; end
                [count, reader] = reader.count(3, 44, 999);
                [values, reader] = reader.numbers(count * 4, 11, -99.9999999, 99.9999999);
                if reader.ok
                    obj.start_falign_x = values(1:4:end);
                    obj.start_falign_y = values(2:4:end);
                    obj.end_falign_x = values(3:4:end);
                    obj.end_falign_y = values(4:4:end);
                end
            elseif reader.ok
                [count, reader] = reader.count(1, 63, 9);
                [value, reader] = reader.number(1, 0, 1, true);
                if reader.ok, obj.field_angle_type = value; end
                [value, reader] = reader.number(1, 0, 1, true);
                if reader.ok, obj.fa_interp = value; end
                if reader.ok && obj.field_angle_type == 0
                    for k = 1:count
                        [grid, reader] = readFieldAlignmentGrid(reader);
                        if ~reader.ok, break, end
                        obj.fa_grids(end + 1) = grid;
                    end
                elseif reader.ok
                    [transform, reader] = readFiducialTransform(reader);
                    if reader.ok, obj.fiducial_transform = transform; end
                    for k = 1:count
                        [lens, reader] = readInteriorOrientation(reader);
                        if ~reader.ok, break, end
                        obj.iop(end + 1) = lens;
                    end
                end
                [flag, reader] = reader.number(1, 0, 2, true);
                if reader.ok && flag ~= 0
                    [telescope, reader] = readTelescopeOptics(reader, flag);
                    if reader.ok, obj.telescope = telescope; end
                end
            end
            reader = reader.literal('000000000');
            [obj, ok, status] = finishDESDecode(obj, reader, header, nfx.CSSFAB());
        end
    end
    methods
        function obj = CSSFAB(options) %#codegen
            %CSSFAB - Construct editable sensor field-alignment metadata
            arguments
                options.?nfx.CSSFAB
            end
            if isfield(options,'uuid'), obj.uuid = options.uuid; end
            if isfield(options,'aisdlvl'), obj.aisdlvl = options.aisdlvl; end
            if isfield(options,'all_images'), obj.all_images = options.all_images; end
            if isfield(options,'assoc_elem_uuid'), obj.assoc_elem_uuid = options.assoc_elem_uuid; end
            if isfield(options,'desver'), obj.desver = options.desver; end
            if isfield(options,'desclas'), obj.desclas = options.desclas; end
            if isfield(options,'sensor_type'), obj.sensor_type = options.sensor_type; end
            if isfield(options,'band_type'), obj.band_type = options.band_type; end
            if isfield(options,'band_wavelength'), obj.band_wavelength = options.band_wavelength; end
            if isfield(options,'bands'), obj.bands = options.bands; end
            if isfield(options,'fl_interp'), obj.fl_interp = options.fl_interp; end
            if isfield(options,'foc_length_date'), obj.foc_length_date = options.foc_length_date; end
            if isfield(options,'foc_length_time'), obj.foc_length_time = options.foc_length_time; end
            if isfield(options,'foc_length'), obj.foc_length = options.foc_length; end
            if isfield(options,'ppoff_x'), obj.ppoff_x = options.ppoff_x; end
            if isfield(options,'ppoff_y'), obj.ppoff_y = options.ppoff_y; end
            if isfield(options,'ppoff_z'), obj.ppoff_z = options.ppoff_z; end
            if isfield(options,'angoff_x'), obj.angoff_x = options.angoff_x; end
            if isfield(options,'angoff_y'), obj.angoff_y = options.angoff_y; end
            if isfield(options,'angoff_z'), obj.angoff_z = options.angoff_z; end
            if isfield(options,'smpl_num_first'), obj.smpl_num_first = options.smpl_num_first; end
            if isfield(options,'delta_smpl_pairs'), obj.delta_smpl_pairs = options.delta_smpl_pairs; end
            if isfield(options,'start_falign_x'), obj.start_falign_x = options.start_falign_x; end
            if isfield(options,'start_falign_y'), obj.start_falign_y = options.start_falign_y; end
            if isfield(options,'end_falign_x'), obj.end_falign_x = options.end_falign_x; end
            if isfield(options,'end_falign_y'), obj.end_falign_y = options.end_falign_y; end
            if isfield(options,'field_angle_type'), obj.field_angle_type = options.field_angle_type; end
            if isfield(options,'fa_interp'), obj.fa_interp = options.fa_interp; end
            if isfield(options,'fa_grids'), obj.fa_grids = options.fa_grids; end
            if isfield(options,'fiducial_transform'), obj.fiducial_transform = options.fiducial_transform; end
            if isfield(options,'iop'), obj.iop = options.iop; end
            if isfield(options,'telescope'), obj.telescope = options.telescope; end
        end
        function value = get.n_bands(obj) %#codegen
            %get.n_bands - Derive the explicit band count, zero for all bands
            value = numel(obj.bands);
        end
        function value = get.num_fl_pts(obj) %#codegen
            %get.num_fl_pts - Derive the supplied focal length count
            value = numel(obj.foc_length);
        end
        function value = get.num_fa_pairs(obj) %#codegen
            %get.num_fa_pairs - Derive the scanner field-alignment pair count
            value = numel(obj.start_falign_x);
        end
        function value = get.num_sets_fa_data(obj) %#codegen
            %get.num_sets_fa_data - Derive the selected framing model set count
            value = 0;
            if obj.field_angle_type == 0, value = numel(obj.fa_grids); end
            if obj.field_angle_type == 1, value = numel(obj.iop); end
        end
        function value = get.telescope_optics_flag(obj) %#codegen
            %get.telescope_optics_flag - Derive optional telescope correction mode
            value = 0;
            if ~isempty(obj.telescope)
                if ~isscalar(obj.telescope), error('nfx:TelescopeCount','Supply at most one telescope descriptor.'); end
                value = obj.telescope.telescope_optics_flag;
            end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count all fields without allocating DESDATA
            value = 99+13*obj.n_bands+26*obj.num_fl_pts;
            if strcmp(obj.sensor_type,'S')
                value = value+26+44*obj.num_fa_pairs;
            elseif strcmp(obj.sensor_type,'F')
                value = value+4;
                for k = 1:numel(obj.fa_grids), value = value+obj.fa_grids(k).byte_length; end
                for k = 1:numel(obj.fiducial_transform), value = value+obj.fiducial_transform(k).byte_length; end
                value = value+263*numel(obj.iop);
                for k = 1:numel(obj.telescope), value = value+obj.telescope(k).byte_length; end
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check complete scanner/framer conditionals and lengths
            report = headerReport(obj); reference = 'STDI-0002-2 Appendix M, Table M.6-7 and M.9-1';
            report = addIssue(report,obj.desver ~= 2,'FieldAlignmentVersion','desver', ...
                'New CSSFAB products require version two.',reference);
            scanner = strcmp(obj.sensor_type,'S'); framer = strcmp(obj.sensor_type,'F');
            report = addIssue(report,~scanner && ~framer,'SensorType','sensor_type','Select S or F.',reference);
            report = addIssue(report,~any(strcmp(obj.band_type,{'',' ','M','R','G','B','N','S','I','L'})), ...
                'BandType','band_type','Use a published band category or blank.',reference);
            report = addIssue(report,any(isnan([obj.band_wavelength obj.fl_interp obj.ppoff_x obj.ppoff_y obj.ppoff_z ...
                obj.angoff_x obj.angoff_y obj.angoff_z])),'Required','wavelength/interpolation/offsets', ...
                'Supply the reference wavelength, focal interpolation and every offset.',reference);
            report = addIssue(report,obj.n_bands > 99999,'BandCount','bands','At most 99999 explicit bands are allowed.',reference);
            ids = zeros(1,obj.n_bands);
            for k = 1:obj.n_bands
                report = mergeReport(report,validate(obj.bands(k)),sprintf('bands(%.0f)',k)); ids(k) = obj.bands(k).band_index;
            end
            report = addIssue(report,numel(unique(ids)) ~= obj.n_bands,'DuplicateBandIndex','bands.band_index', ...
                'Each explicit band index must identify a different associated band.',reference);
            focal = obj.num_fl_pts >= 1 && obj.num_fl_pts <= 999 && numel(obj.foc_length_time) == obj.num_fl_pts && ...
                all(isfinite(obj.foc_length)) && all(isfinite(obj.foc_length_time)) && ...
                all(diff(obj.foc_length_time) > 0) && all(diff(round(obj.foc_length_time*1e9)) > 0);
            report = addIssue(report,~focal || ~knownDate(obj.foc_length_date,8),'FocalLengthSamples','foc_length_date/time/foc_length', ...
                'Supply the UTC date and 1-999 matched focal length samples with increasing nanosecond-distinct times.',reference);
            pairs = {obj.start_falign_x,obj.start_falign_y,obj.end_falign_x,obj.end_falign_y};
            if scanner
                valid = obj.num_fa_pairs >= 1 && obj.num_fa_pairs <= 999;
                for k = 1:4, valid = valid && numel(pairs{k}) == obj.num_fa_pairs && all(isfinite(pairs{k})); end
                report = addIssue(report,~valid || any(isnan([obj.smpl_num_first obj.delta_smpl_pairs])), ...
                    'ScannerAlignment','scanner alignment fields','Supply known start/end XY pairs, first sample and spacing.',reference);
                report = addIssue(report,any(~isnan([obj.field_angle_type obj.fa_interp])) || ...
                    ~isempty(obj.fa_grids) || ~isempty(obj.fiducial_transform) || ~isempty(obj.iop) || ~isempty(obj.telescope), ...
                    'UnusedFramingAlignment','framing fields','Scanner metadata omits all frame and telescope fields.',reference);
            elseif framer
                report = addIssue(report,any(~isnan([obj.smpl_num_first obj.delta_smpl_pairs])) || ...
                    any([numel(obj.start_falign_x) numel(obj.start_falign_y) numel(obj.end_falign_x) numel(obj.end_falign_y)] > 0), ...
                    'UnusedScannerAlignment','scanner fields','Framing metadata omits scanner alignment pairs.',reference);
                report = addIssue(report,any(isnan([obj.field_angle_type obj.fa_interp])) || ...
                    obj.num_sets_fa_data < 1 || obj.num_sets_fa_data > 9,'FrameAlignmentSets','field_angle_type/fa_interp/model sets', ...
                    'Supply the alignment type, interpolation and 1-9 sets of the chosen form.',reference);
                if obj.field_angle_type == 0
                    report = addIssue(report,~isempty(obj.fiducial_transform) || ~isempty(obj.iop), ...
                        'UnusedCalibration','fiducial_transform/iop','A direct grid omits calibration parameters.',reference);
                elseif obj.field_angle_type == 1
                    report = addIssue(report,~isempty(obj.fa_grids) || numel(obj.fiducial_transform) ~= 1, ...
                        'FiducialPresence','fa_grids/fiducial_transform','Calibration sets require exactly one focal-array transform descriptor and no direct grids.',reference);
                end
                report = addIssue(report,numel(obj.telescope) > 1,'TelescopeCount','telescope', ...
                    'Supply at most one telescope correction descriptor.',reference);
            end
            for k = 1:numel(obj.fa_grids), report = mergeReport(report,validate(obj.fa_grids(k)),sprintf('fa_grids(%.0f)',k)); end
            for k = 1:numel(obj.fiducial_transform), report = mergeReport(report,validate(obj.fiducial_transform(k)),'fiducial_transform'); end
            for k = 1:numel(obj.iop), report = mergeReport(report,validate(obj.iop(k)),sprintf('iop(%.0f)',k)); end
            for k = 1:numel(obj.telescope), report = mergeReport(report,validate(obj.telescope(k)),'telescope'); end
            report = addIssue(report,obj.byte_length > 999999998,'DESLength','CSSFAB', ...
                'The complete field-alignment payload must fit the DES byte limit.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode the selected geometry and optional telescope data
            requireValid(validate(obj));
            value = zeros(1,obj.byte_length,'uint8');
            prefix = [textField(obj.sensor_type,1) textField(obj.band_type,1) ...
                decimalField(obj.band_wavelength,11,8,false) decimalField(obj.n_bands,5,0,false)];
            at = numel(prefix); value(1:at) = prefix;
            for k = 1:obj.n_bands, value(at+(1:13)) = bytes(obj.bands(k)); at = at+13; end
            value(at+(1:12)) = [decimalField(obj.num_fl_pts,3,0,false) decimalField(obj.fl_interp,1,0,false) textField(obj.foc_length_date,8)];
            at = at+12;
            for k = 1:obj.num_fl_pts
                value(at+(1:26)) = [decimalField(obj.foc_length_time(k),15,9,false) decimalField(obj.foc_length(k),11,8,false)]; at = at+26;
            end
            value(at+(1:60)) = [decimalField(obj.ppoff_x,10,6,true) decimalField(obj.ppoff_y,10,6,true) ...
                decimalField(obj.ppoff_z,10,6,true) decimalField(obj.angoff_x,10,7,true) ...
                decimalField(obj.angoff_y,10,7,true) decimalField(obj.angoff_z,10,7,true)];
            at = at+60;
            if strcmp(obj.sensor_type,'S')
                value(at+(1:26)) = [decimalField(obj.smpl_num_first,12,5,true) decimalField(obj.delta_smpl_pairs,11,5,false) ...
                    decimalField(obj.num_fa_pairs,3,0,false)]; at = at+26;
                for k = 1:obj.num_fa_pairs
                    value(at+(1:44)) = [decimalField(obj.start_falign_x(k),11,7,true) decimalField(obj.start_falign_y(k),11,7,true) ...
                        decimalField(obj.end_falign_x(k),11,7,true) decimalField(obj.end_falign_y(k),11,7,true)]; at = at+44;
                end
            else
                value(at+(1:3)) = [decimalField(obj.num_sets_fa_data,1,0,false) decimalField(obj.field_angle_type,1,0,false) ...
                    decimalField(obj.fa_interp,1,0,false)]; at = at+3;
                if obj.field_angle_type == 0
                    for k = 1:numel(obj.fa_grids)
                        data = bytes(obj.fa_grids(k)); value(at+(1:numel(data))) = data; at = at+numel(data);
                    end
                else
                    data = bytes(obj.fiducial_transform); value(at+(1:numel(data))) = data; at = at+numel(data);
                    for k = 1:numel(obj.iop), value(at+(1:263)) = bytes(obj.iop(k)); at = at+263; end
                end
                value(at+1) = decimalField(obj.telescope_optics_flag,1,0,false); at = at+1;
                if ~isempty(obj.telescope)
                    data = bytes(obj.telescope); value(at+(1:numel(data))) = data; at = at+numel(data);
                end
            end
            value(at+(1:9)) = uint8('000000000');
        end
    end
end

function mustBeFocalRow(value,maximum) %#codegen
    %mustBeFocalRow - Preserve nonnegative double rows without conversion
    mustBeGLASMatrix(value,1,999,maximum);
    if any(value < 0), error('nfx:FocalSamples','Focal lengths and their date-relative times must be nonnegative.'); end
end
