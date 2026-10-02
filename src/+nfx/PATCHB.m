classdef (Sealed) PATCHB < nfx.TRE
    %PATCHB - Radar image patch metadata
    %   OBJ = PATCHB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PATCHB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PATCHB properties:
    %       cetag - Constant tag identifier
    %       pat_no - PAT_NO metadata
    %       last_pat_flag - LAST_PAT_FLAG metadata
    %       lnstrt - LNSTRT metadata
    %       lnstop - LNSTOP metadata
    %       azl - AZL metadata
    %       nvl - NVL metadata
    %       fvl - FVL metadata
    %       npixel - NPIXEL metadata
    %       fvpix - FVPIX metadata
    %       frame - FRAME metadata
    %       utc - UTC metadata
    %       shead - SHEAD metadata
    %       gravity - GRAVITY metadata
    %       ins_v_nc - INS_V_NC metadata
    %       ins_v_ec - INS_V_EC metadata
    %       ins_v_dc - INS_V_DC metadata
    %       offlat - OFFLAT metadata
    %       offlong - OFFLONG metadata
    %       track - TRACK metadata
    %       gsweep - GSWEEP metadata
    %       shear - SHEAR metadata
    %       batch_no - BATCH_NO metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PATCHB' % Registered tag identifier
    end
    properties
        % PAT_NO metadata
        pat_no {mustBeMetadata(pat_no, ...
            1, 999, 1)} = NaN
        % LAST_PAT_FLAG metadata
        last_pat_flag {mustBeMetadata(last_pat_flag, ...
            0, 1, 1)} = NaN
        % LNSTRT metadata
        lnstrt {mustBeMetadata(lnstrt, ...
            1, 9999999, 1)} = NaN
        % LNSTOP metadata
        lnstop {mustBeMetadata(lnstop, ...
            20, 9999999, 1)} = NaN
        % AZL metadata
        azl {mustBeMetadata(azl, ...
            20, 99999, 1)} = NaN
        % NVL metadata
        nvl {mustBeMetadata(nvl, ...
            20, 99999, 1)} = NaN
        % FVL metadata
        fvl {mustBeMetadata(fvl, ...
            1, 681, 1)} = NaN
        % NPIXEL metadata
        npixel {mustBeMetadata(npixel, ...
            1, 99999, 1)} = NaN
        % FVPIX metadata
        fvpix {mustBeMetadata(fvpix, ...
            1, 99999, 1)} = NaN
        % FRAME metadata
        frame {mustBeMetadata(frame, ...
            1, 512, 1)} = NaN
        % UTC metadata
        utc {mustBeMetadata(utc, ...
            0, 86399.99, 0)} = NaN
        % SHEAD metadata
        shead {mustBeMetadata(shead, ...
            0, 359.999, 0)} = NaN
        % GRAVITY metadata
        gravity {mustBeMetadata(gravity, ...
            31, 33.9999, 0)} = NaN
        % INS_V_NC metadata
        ins_v_nc {mustBeMetadata(ins_v_nc, ...
            -9999, 9999, 1)} = NaN
        % INS_V_EC metadata
        ins_v_ec {mustBeMetadata(ins_v_ec, ...
            -9999, 9999, 1)} = NaN
        % INS_V_DC metadata
        ins_v_dc {mustBeMetadata(ins_v_dc, ...
            -9999, 9999, 1)} = NaN
        % OFFLAT metadata
        offlat {mustBeMetadata(offlat, ...
            -80, 80, 0)} = NaN
        % OFFLONG metadata
        offlong {mustBeMetadata(offlong, ...
            -80, 80, 0)} = NaN
        % TRACK metadata
        track {mustBeMetadata(track, ...
            0, 359, 1)} = NaN
        % GSWEEP metadata
        gsweep {mustBeMetadata(gsweep, ...
            0, 120, 0)} = NaN
        % SHEAR metadata
        shear {mustBeMetadata(shear, ...
            0.85, 1, 0)} = NaN
        % BATCH_NO metadata
        batch_no {mustBeMetadata(batch_no, ...
            1, 999999, 1)} = NaN
    end
    methods
        function obj = PATCHB(options) %#codegen
            arguments
                options.?nfx.PATCHB
            end
            if isfield(options, 'pat_no')
                obj.pat_no = options.pat_no;
            end
            if isfield(options, 'last_pat_flag')
                obj.last_pat_flag = options.last_pat_flag;
            end
            if isfield(options, 'lnstrt')
                obj.lnstrt = options.lnstrt;
            end
            if isfield(options, 'lnstop')
                obj.lnstop = options.lnstop;
            end
            if isfield(options, 'azl')
                obj.azl = options.azl;
            end
            if isfield(options, 'nvl')
                obj.nvl = options.nvl;
            end
            if isfield(options, 'fvl')
                obj.fvl = options.fvl;
            end
            if isfield(options, 'npixel')
                obj.npixel = options.npixel;
            end
            if isfield(options, 'fvpix')
                obj.fvpix = options.fvpix;
            end
            if isfield(options, 'frame')
                obj.frame = options.frame;
            end
            if isfield(options, 'utc')
                obj.utc = options.utc;
            end
            if isfield(options, 'shead')
                obj.shead = options.shead;
            end
            if isfield(options, 'gravity')
                obj.gravity = options.gravity;
            end
            if isfield(options, 'ins_v_nc')
                obj.ins_v_nc = options.ins_v_nc;
            end
            if isfield(options, 'ins_v_ec')
                obj.ins_v_ec = options.ins_v_ec;
            end
            if isfield(options, 'ins_v_dc')
                obj.ins_v_dc = options.ins_v_dc;
            end
            if isfield(options, 'offlat')
                obj.offlat = options.offlat;
            end
            if isfield(options, 'offlong')
                obj.offlong = options.offlong;
            end
            if isfield(options, 'track')
                obj.track = options.track;
            end
            if isfield(options, 'gsweep')
                obj.gsweep = options.gsweep;
            end
            if isfield(options, 'shear')
                obj.shear = options.shear;
            end
            if isfield(options, 'batch_no')
                obj.batch_no = options.batch_no;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-21 (2025-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.pat_no, 4, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'pat_no', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.last_pat_flag, 1, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'last_pat_flag', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.lnstrt, 7, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'lnstrt', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.lnstop, 7, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'lnstop', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.azl, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'azl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.nvl, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'nvl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.fvl, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'fvl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.npixel, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'npixel', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.fvpix, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'fvpix', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.frame, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'frame', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.utc, 8, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'utc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.shead, 7, 3, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'shead', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gravity, 7, 4, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gravity', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ins_v_nc, 5, 0, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ins_v_nc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ins_v_ec, 5, 0, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ins_v_ec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ins_v_dc, 5, 0, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'ins_v_dc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.offlat, 8, 4, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'offlat', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.offlong, 8, 4, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'offlong', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.track, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'track', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gsweep, 6, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'gsweep', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.shear, 8, 6, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'shear', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.batch_no, 6, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'batch_no', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, obj.lnstop < obj.lnstrt, ...
                'Metadata', 'lnstop', 'The ending line cannot precede the starting line.', reference);
            report = addIssue(report, obj.nvl > obj.azl || obj.fvl + obj.nvl - 1 > obj.azl, ...
                'Metadata', 'nvl/fvl', 'Valid lines must fit within the patch.', reference);
            payloadLength = 4 + ...
                1 + ...
                7 + ...
                7 + ...
                5 + ...
                5 + ...
                3 + ...
                5 + ...
                5 + ...
                3 + ...
                8 + ...
                7 + ...
                7 + ...
                5 + ...
                5 + ...
                5 + ...
                8 + ...
                8 + ...
                3 + ...
                6 + ...
                8 + ...
                6;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.pat_no, 4, 0, false, false, false)];
            data = [data treNumber(obj.last_pat_flag, 1, 0, false, true, false)];
            data = [data treNumber(obj.lnstrt, 7, 0, false, false, false)];
            data = [data treNumber(obj.lnstop, 7, 0, false, false, false)];
            data = [data treNumber(obj.azl, 5, 0, false, false, false)];
            data = [data treNumber(obj.nvl, 5, 0, false, true, false)];
            data = [data treNumber(obj.fvl, 3, 0, false, true, false)];
            data = [data treNumber(obj.npixel, 5, 0, false, false, false)];
            data = [data treNumber(obj.fvpix, 5, 0, false, false, false)];
            data = [data treNumber(obj.frame, 3, 0, false, true, false)];
            data = [data treNumber(obj.utc, 8, 2, false, false, false)];
            data = [data treNumber(obj.shead, 7, 3, false, false, false)];
            data = [data treNumber(obj.gravity, 7, 4, false, true, false)];
            data = [data treNumber(obj.ins_v_nc, 5, 0, true, false, false)];
            data = [data treNumber(obj.ins_v_ec, 5, 0, true, false, false)];
            data = [data treNumber(obj.ins_v_dc, 5, 0, true, false, false)];
            data = [data treNumber(obj.offlat, 8, 4, true, true, false)];
            data = [data treNumber(obj.offlong, 8, 4, true, true, false)];
            data = [data treNumber(obj.track, 3, 0, false, false, false)];
            data = [data treNumber(obj.gsweep, 6, 2, false, false, false)];
            data = [data treNumber(obj.shear, 8, 6, false, true, false)];
            data = [data treNumber(obj.batch_no, 6, 0, false, true, false)];
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
            obj = nfx.PATCHB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.number(4, 1, 999, ...
                true, false);
            if reader.ok, obj.pat_no = value; end
            [value, reader] = reader.number(1, 0, 1, ...
                true, true);
            if reader.ok, obj.last_pat_flag = value; end
            [value, reader] = reader.number(7, 1, 9999999, ...
                true, false);
            if reader.ok, obj.lnstrt = value; end
            [value, reader] = reader.number(7, 20, 9999999, ...
                true, false);
            if reader.ok, obj.lnstop = value; end
            [value, reader] = reader.number(5, 20, 99999, ...
                true, false);
            if reader.ok, obj.azl = value; end
            [value, reader] = reader.number(5, 20, 99999, ...
                true, true);
            if reader.ok, obj.nvl = value; end
            [value, reader] = reader.number(3, 1, 681, ...
                true, true);
            if reader.ok, obj.fvl = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.npixel = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.fvpix = value; end
            [value, reader] = reader.number(3, 1, 512, ...
                true, true);
            if reader.ok, obj.frame = value; end
            [value, reader] = reader.number(8, 0, 86399.99, ...
                false, false);
            if reader.ok, obj.utc = value; end
            [value, reader] = reader.number(7, 0, 359.999, ...
                false, false);
            if reader.ok, obj.shead = value; end
            [value, reader] = reader.number(7, 31, 33.9999, ...
                false, true);
            if reader.ok, obj.gravity = value; end
            [value, reader] = reader.number(5, -9999, 9999, ...
                true, false);
            if reader.ok, obj.ins_v_nc = value; end
            [value, reader] = reader.number(5, -9999, 9999, ...
                true, false);
            if reader.ok, obj.ins_v_ec = value; end
            [value, reader] = reader.number(5, -9999, 9999, ...
                true, false);
            if reader.ok, obj.ins_v_dc = value; end
            [value, reader] = reader.number(8, -80, 80, ...
                false, true);
            if reader.ok, obj.offlat = value; end
            [value, reader] = reader.number(8, -80, 80, ...
                false, true);
            if reader.ok, obj.offlong = value; end
            [value, reader] = reader.number(3, 0, 359, ...
                true, false);
            if reader.ok, obj.track = value; end
            [value, reader] = reader.number(6, 0, 120, ...
                false, false);
            if reader.ok, obj.gsweep = value; end
            [value, reader] = reader.number(8, 0.85, 1, ...
                false, true);
            if reader.ok, obj.shear = value; end
            [value, reader] = reader.number(6, 1, 999999, ...
                true, true);
            if reader.ok, obj.batch_no = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PATCHB());
        end
    end
end
