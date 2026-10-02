classdef (Sealed) ISACPA < nfx.TRE
    %ISACPA - Inverse radar collection parameters
    %   OBJ = ISACPA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ISACPA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ISACPA properties:
    %       cetag - Constant tag identifier
    %       task_id - TASK_ID metadata
    %       frame_num - FRAME_NUM metadata
    %       date_time_utc - DATE_TIME_UTC metadata
    %       ref_pt_lat - REF_PT_LAT metadata
    %       ref_pt_lon - REF_PT_LON metadata
    %       ref_pt_hgt - REF_PT_HGT metadata
    %       ref_pt_hdg - REF_PT_HDG metadata
    %       ref_pt_spd - REF_PT_SPD metadata
    %       ref_pt_slt_rng - REF_PT_SLT_RNG metadata
    %       side - SIDE metadata
    %       rng_res - RNG_RES metadata
    %       fit - FIT metadata
    %       rng_spacing - RNG_SPACING metadata
    %       dop_spacing - DOP_SPACING metadata
    %       dop_scale - DOP_SCALE metadata
    %       db_res - DB_RES metadata
    %       prf - PRF metadata
    %       pol_tr - POL_TR metadata
    %       pol_re - POL_RE metadata
    %       wf_cenfrq - WF_CENFRQ metadata
    %       weight - WEIGHT metadata
    %       rng_sll - RNG_SLL metadata
    %       dop_sll - DOP_SLL metadata
    %       rng_tay_nbar - RNG_TAY_NBAR metadata
    %       dop_tay_nbar - DOP_TAY_NBAR metadata
    %       weight_norm - WEIGHT_NORM metadata
    %       img_fom - IMG_FOM metadata
    %       ref_trk - REF_TRK metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ISACPA' % Registered tag identifier
    end
    properties
        % TASK_ID metadata
        task_id {mustBeMetadata(task_id, ...
            0, 9999999999, 1)} = NaN
        % FRAME_NUM metadata
        frame_num {mustBeMetadata(frame_num, ...
            0, 9999999999, 1)} = NaN
        date_time_utc {mustBeAscii(date_time_utc, 18)} = '' % DATE_TIME_UTC metadata
        % REF_PT_LAT metadata
        ref_pt_lat {mustBeMetadata(ref_pt_lat, ...
            -90, 90, 0)} = NaN
        % REF_PT_LON metadata
        ref_pt_lon {mustBeMetadata(ref_pt_lon, ...
            -180, 180, 0)} = NaN
        % REF_PT_HGT metadata
        ref_pt_hgt {mustBeMetadata(ref_pt_hgt, ...
            -999.999, 99999.999, 0)} = NaN
        % REF_PT_HDG metadata
        ref_pt_hdg {mustBeMetadata(ref_pt_hdg, ...
            0, 359.999, 0)} = NaN
        % REF_PT_SPD metadata
        ref_pt_spd {mustBeMetadata(ref_pt_spd, ...
            0, 999.99, 0)} = NaN
        % REF_PT_SLT_RNG metadata
        ref_pt_slt_rng {mustBeMetadata(ref_pt_slt_rng, ...
            0.001, 999999.999, 0)} = NaN
        side {mustBeAscii(side, 1)} = '' % SIDE metadata
        % RNG_RES metadata
        rng_res {mustBeMetadata(rng_res, ...
            0.001, 99.999, 0)} = NaN
        % FIT metadata
        fit {mustBeMetadata(fit, ...
            0.001, 999.999, 0)} = NaN
        % RNG_SPACING metadata
        rng_spacing {mustBeMetadata(rng_spacing, ...
            0.001, 999.999, 0)} = NaN
        % DOP_SPACING metadata
        dop_spacing {mustBeMetadata(dop_spacing, ...
            0.001, 999.999, 0)} = NaN
        % DOP_SCALE metadata
        dop_scale {mustBeMetadata(dop_scale, ...
            0.01, 9999.99, 0)} = NaN
        % DB_RES metadata
        db_res {mustBeMetadata(db_res, ...
            0.001, 9.999, 0)} = NaN
        % PRF metadata
        prf {mustBeMetadata(prf, ...
            0.001, 99999.999, 0)} = NaN
        pol_tr {mustBeAscii(pol_tr, 1)} = '' % POL_TR metadata
        pol_re {mustBeAscii(pol_re, 1)} = '' % POL_RE metadata
        % WF_CENFRQ metadata
        wf_cenfrq {mustBeMetadata(wf_cenfrq, ...
            0, 99999999999.9, 0)} = NaN
        weight {mustBeAscii(weight, 3)} = '' % WEIGHT metadata
        % RNG_SLL metadata
        rng_sll {mustBeMetadata(rng_sll, ...
            0, 99, 1)} = NaN
        % DOP_SLL metadata
        dop_sll {mustBeMetadata(dop_sll, ...
            0, 99, 1)} = NaN
        % RNG_TAY_NBAR metadata
        rng_tay_nbar {mustBeMetadata(rng_tay_nbar, ...
            0, 99, 1)} = NaN
        % DOP_TAY_NBAR metadata
        dop_tay_nbar {mustBeMetadata(dop_tay_nbar, ...
            0, 99, 1)} = NaN
        weight_norm {mustBeAscii(weight_norm, 3)} = '' % WEIGHT_NORM metadata
        % IMG_FOM metadata
        img_fom {mustBeMetadata(img_fom, ...
            0, 9999999999, 1)} = NaN
        % REF_TRK metadata
        ref_trk {mustBeMetadata(ref_trk, ...
            0, 9999999999, 1)} = NaN
    end
    methods
        function obj = ISACPA(options) %#codegen
            arguments
                options.?nfx.ISACPA
            end
            if isfield(options, 'task_id')
                obj.task_id = options.task_id;
            end
            if isfield(options, 'frame_num')
                obj.frame_num = options.frame_num;
            end
            if isfield(options, 'date_time_utc')
                obj.date_time_utc = options.date_time_utc;
            end
            if isfield(options, 'ref_pt_lat')
                obj.ref_pt_lat = options.ref_pt_lat;
            end
            if isfield(options, 'ref_pt_lon')
                obj.ref_pt_lon = options.ref_pt_lon;
            end
            if isfield(options, 'ref_pt_hgt')
                obj.ref_pt_hgt = options.ref_pt_hgt;
            end
            if isfield(options, 'ref_pt_hdg')
                obj.ref_pt_hdg = options.ref_pt_hdg;
            end
            if isfield(options, 'ref_pt_spd')
                obj.ref_pt_spd = options.ref_pt_spd;
            end
            if isfield(options, 'ref_pt_slt_rng')
                obj.ref_pt_slt_rng = options.ref_pt_slt_rng;
            end
            if isfield(options, 'side')
                obj.side = options.side;
            end
            if isfield(options, 'rng_res')
                obj.rng_res = options.rng_res;
            end
            if isfield(options, 'fit')
                obj.fit = options.fit;
            end
            if isfield(options, 'rng_spacing')
                obj.rng_spacing = options.rng_spacing;
            end
            if isfield(options, 'dop_spacing')
                obj.dop_spacing = options.dop_spacing;
            end
            if isfield(options, 'dop_scale')
                obj.dop_scale = options.dop_scale;
            end
            if isfield(options, 'db_res')
                obj.db_res = options.db_res;
            end
            if isfield(options, 'prf')
                obj.prf = options.prf;
            end
            if isfield(options, 'pol_tr')
                obj.pol_tr = options.pol_tr;
            end
            if isfield(options, 'pol_re')
                obj.pol_re = options.pol_re;
            end
            if isfield(options, 'wf_cenfrq')
                obj.wf_cenfrq = options.wf_cenfrq;
            end
            if isfield(options, 'weight')
                obj.weight = options.weight;
            end
            if isfield(options, 'rng_sll')
                obj.rng_sll = options.rng_sll;
            end
            if isfield(options, 'dop_sll')
                obj.dop_sll = options.dop_sll;
            end
            if isfield(options, 'rng_tay_nbar')
                obj.rng_tay_nbar = options.rng_tay_nbar;
            end
            if isfield(options, 'dop_tay_nbar')
                obj.dop_tay_nbar = options.dop_tay_nbar;
            end
            if isfield(options, 'weight_norm')
                obj.weight_norm = options.weight_norm;
            end
            if isfield(options, 'img_fom')
                obj.img_fom = options.img_fom;
            end
            if isfield(options, 'ref_trk')
                obj.ref_trk = options.ref_trk;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AX, Table AX-1 (2024-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.task_id, 10, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'task_id', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.frame_num, 10, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'frame_num', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.date_time_utc))), ...
                'Required', 'date_time_utc', 'Supply DATE_TIME_UTC.', reference);
            [~, valid] = treNumber(obj.ref_pt_lat, 10, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_lat', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_pt_lon, 11, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_lon', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_pt_hgt, 10, 3, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_hgt', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_pt_hdg, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_hdg', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_pt_spd, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_spd', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_pt_slt_rng, 10, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_pt_slt_rng', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.side, {'', 'P', 'S'})), ...
                'Enumeration', 'side', 'Use a defined SIDE value.', reference);
            [~, valid] = treNumber(obj.rng_res, 6, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rng_res', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.fit, 7, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'fit', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rng_spacing, 7, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rng_spacing', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dop_spacing, 7, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'dop_spacing', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dop_scale, 7, 2, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'dop_scale', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.db_res, 5, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'db_res', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.prf, 9, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'prf', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.pol_tr, {'', 'H', 'V', 'L', 'R', 'T', 'P'})), ...
                'Enumeration', 'pol_tr', 'Use a defined POL_TR value.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.pol_re, {'', 'H', 'V', 'L', 'R', 'T', 'P'})), ...
                'Enumeration', 'pol_re', 'Use a defined POL_RE value.', reference);
            [~, valid] = treNumber(obj.wf_cenfrq, 13, 1, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'wf_cenfrq', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.weight, {'', 'UWT', 'SVA', 'TAY', 'HNW', 'HMW'})), ...
                'Enumeration', 'weight', 'Use a defined WEIGHT value.', reference);
            [~, valid] = treNumber(obj.rng_sll, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rng_sll', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dop_sll, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'dop_sll', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rng_tay_nbar, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rng_tay_nbar', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dop_tay_nbar, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'dop_tay_nbar', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.weight_norm, {'', 'AVG', 'RMS'})), ...
                'Enumeration', 'weight_norm', 'Use a defined WEIGHT_NORM value.', reference);
            [~, valid] = treNumber(obj.img_fom, 10, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'img_fom', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ref_trk, 10, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ref_trk', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ~knownPreciseDate(obj.date_time_utc, 3), ...
                'Metadata', 'date_time_utc', 'Supply a complete UTC timestamp with milliseconds.', reference);
            payloadLength = 10 + ...
                10 + ...
                18 + ...
                10 + ...
                11 + ...
                10 + ...
                7 + ...
                7 + ...
                10 + ...
                1 + ...
                6 + ...
                7 + ...
                7 + ...
                7 + ...
                7 + ...
                5 + ...
                9 + ...
                1 + ...
                1 + ...
                13 + ...
                3 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                3 + ...
                10 + ...
                10;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.task_id, 10, 0, false, false, false)];
            data = [data treNumber(obj.frame_num, 10, 0, false, false, false)];
            data = [data textField(obj.date_time_utc, 18)];
            data = [data treNumber(obj.ref_pt_lat, 10, 6, true, false, false)];
            data = [data treNumber(obj.ref_pt_lon, 11, 6, true, false, false)];
            data = [data treNumber(obj.ref_pt_hgt, 10, 3, true, false, false)];
            data = [data treNumber(obj.ref_pt_hdg, 7, 3, false, false, false)];
            data = [data treNumber(obj.ref_pt_spd, 7, 3, false, false, false)];
            data = [data treNumber(obj.ref_pt_slt_rng, 10, 3, false, false, false)];
            data = [data textField(obj.side, 1)];
            data = [data treNumber(obj.rng_res, 6, 3, false, true, false)];
            data = [data treNumber(obj.fit, 7, 3, false, true, false)];
            data = [data treNumber(obj.rng_spacing, 7, 3, false, true, false)];
            data = [data treNumber(obj.dop_spacing, 7, 3, false, true, false)];
            data = [data treNumber(obj.dop_scale, 7, 2, false, true, false)];
            data = [data treNumber(obj.db_res, 5, 3, false, true, false)];
            data = [data treNumber(obj.prf, 9, 3, false, true, false)];
            data = [data textField(obj.pol_tr, 1)];
            data = [data textField(obj.pol_re, 1)];
            data = [data treNumber(obj.wf_cenfrq, 13, 1, false, true, false)];
            data = [data textField(obj.weight, 3)];
            data = [data treNumber(obj.rng_sll, 2, 0, false, true, false)];
            data = [data treNumber(obj.dop_sll, 2, 0, false, true, false)];
            data = [data treNumber(obj.rng_tay_nbar, 2, 0, false, true, false)];
            data = [data treNumber(obj.dop_tay_nbar, 2, 0, false, true, false)];
            data = [data textField(obj.weight_norm, 3)];
            data = [data treNumber(obj.img_fom, 10, 0, false, true, false)];
            data = [data treNumber(obj.ref_trk, 10, 0, false, true, false)];
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.ISACPA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(10, 0, 9999999999, ...
                true, false);
            if reader.ok, obj.task_id = value; end
            [value, reader] = reader.number(10, 0, 9999999999, ...
                true, false);
            if reader.ok, obj.frame_num = value; end
            [value, reader] = reader.text(18, true, false);
            if reader.ok, obj.date_time_utc = value; end
            [value, reader] = reader.number(10, -90, 90, ...
                false, false);
            if reader.ok, obj.ref_pt_lat = value; end
            [value, reader] = reader.number(11, -180, 180, ...
                false, false);
            if reader.ok, obj.ref_pt_lon = value; end
            [value, reader] = reader.number(10, -999.999, 99999.999, ...
                false, false);
            if reader.ok, obj.ref_pt_hgt = value; end
            [value, reader] = reader.number(7, 0, 359.999, ...
                false, false);
            if reader.ok, obj.ref_pt_hdg = value; end
            [value, reader] = reader.number(7, 0, 999.99, ...
                false, false);
            if reader.ok, obj.ref_pt_spd = value; end
            [value, reader] = reader.number(10, 0.001, 999999.999, ...
                false, false);
            if reader.ok, obj.ref_pt_slt_rng = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.side = value; end
            [value, reader] = reader.number(6, 0.001, 99.999, ...
                false, true);
            if reader.ok, obj.rng_res = value; end
            [value, reader] = reader.number(7, 0.001, 999.999, ...
                false, true);
            if reader.ok, obj.fit = value; end
            [value, reader] = reader.number(7, 0.001, 999.999, ...
                false, true);
            if reader.ok, obj.rng_spacing = value; end
            [value, reader] = reader.number(7, 0.001, 999.999, ...
                false, true);
            if reader.ok, obj.dop_spacing = value; end
            [value, reader] = reader.number(7, 0.01, 9999.99, ...
                false, true);
            if reader.ok, obj.dop_scale = value; end
            [value, reader] = reader.number(5, 0.001, 9.999, ...
                false, true);
            if reader.ok, obj.db_res = value; end
            [value, reader] = reader.number(9, 0.001, 99999.999, ...
                false, true);
            if reader.ok, obj.prf = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.pol_tr = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.pol_re = value; end
            [value, reader] = reader.number(13, 0, 99999999999.9, ...
                false, true);
            if reader.ok, obj.wf_cenfrq = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.weight = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, true);
            if reader.ok, obj.rng_sll = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, true);
            if reader.ok, obj.dop_sll = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, true);
            if reader.ok, obj.rng_tay_nbar = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, true);
            if reader.ok, obj.dop_tay_nbar = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.weight_norm = value; end
            [value, reader] = reader.number(10, 0, 9999999999, ...
                true, true);
            if reader.ok, obj.img_fom = value; end
            [value, reader] = reader.number(10, 0, 9999999999, ...
                true, true);
            if reader.ok, obj.ref_trk = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ISACPA());
        end
    end
end
