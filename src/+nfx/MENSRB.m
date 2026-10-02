classdef (Sealed) MENSRB < nfx.TRE
    %MENSRB - Airborne radar mensuration metadata
    %   OBJ = MENSRB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   MENSRB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   MENSRB properties:
    %       cetag - Constant tag identifier
    %       acft_loc - ACFT_LOC metadata
    %       acft_loc_accy - ACFT_LOC_ACCY metadata
    %       acft_alt - ACFT_ALT metadata
    %       rp_loc - RP_LOC metadata
    %       rp_loc_accy - RP_LOC_ACCY metadata
    %       rp_elv - RP_ELV metadata
    %       of_pc_r - OF_PC_R metadata
    %       of_pc_a - OF_PC_A metadata
    %       cosgrz - COSGRZ metadata
    %       rgcrp - RGCRP metadata
    %       rlmap - RLMAP metadata
    %       rp_row - RP_ROW metadata
    %       rp_col - RP_COL metadata
    %       c_r_nc - C_R_NC metadata
    %       c_r_ec - C_R_EC metadata
    %       c_r_dc - C_R_DC metadata
    %       c_az_nc - C_AZ_NC metadata
    %       c_az_ec - C_AZ_EC metadata
    %       c_az_dc - C_AZ_DC metadata
    %       c_al_nc - C_AL_NC metadata
    %       c_al_ec - C_AL_EC metadata
    %       c_al_dc - C_AL_DC metadata
    %       total_tiles_cols - TOTAL_TILES_COLS metadata
    %       total_tiles_rows - TOTAL_TILES_ROWS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'MENSRB' % Registered tag identifier
    end
    properties
        acft_loc {mustBeAscii(acft_loc, 25)} = '' % ACFT_LOC metadata
        % ACFT_LOC_ACCY metadata
        acft_loc_accy {mustBeMetadata(acft_loc_accy, ...
            0, 999.99, 0)} = NaN
        % ACFT_ALT metadata
        acft_alt {mustBeMetadata(acft_alt, ...
            0, 999999, 1)} = NaN
        rp_loc {mustBeAscii(rp_loc, 25)} = '' % RP_LOC metadata
        % RP_LOC_ACCY metadata
        rp_loc_accy {mustBeMetadata(rp_loc_accy, ...
            0, 999.99, 0)} = NaN
        % RP_ELV metadata
        rp_elv {mustBeMetadata(rp_elv, ...
            -1000, 30000, 1)} = NaN
        % OF_PC_R metadata
        of_pc_r {mustBeMetadata(of_pc_r, ...
            -9999.9, 9999.9, 0)} = NaN
        % OF_PC_A metadata
        of_pc_a {mustBeMetadata(of_pc_a, ...
            -9999.9, 9999.9, 0)} = NaN
        % COSGRZ metadata
        cosgrz {mustBeMetadata(cosgrz, ...
            0, 1, 0)} = NaN
        % RGCRP metadata
        rgcrp {mustBeMetadata(rgcrp, ...
            0, 3000000, 1)} = NaN
        rlmap {mustBeAscii(rlmap, 1)} = '' % RLMAP metadata
        % RP_ROW metadata
        rp_row {mustBeMetadata(rp_row, ...
            1, 99999, 1)} = NaN
        % RP_COL metadata
        rp_col {mustBeMetadata(rp_col, ...
            1, 99999, 1)} = NaN
        % C_R_NC metadata
        c_r_nc {mustBeMetadata(c_r_nc, ...
            -1, 1, 0)} = NaN
        % C_R_EC metadata
        c_r_ec {mustBeMetadata(c_r_ec, ...
            -1, 1, 0)} = NaN
        % C_R_DC metadata
        c_r_dc {mustBeMetadata(c_r_dc, ...
            -1, 1, 0)} = NaN
        % C_AZ_NC metadata
        c_az_nc {mustBeMetadata(c_az_nc, ...
            -1, 1, 0)} = NaN
        % C_AZ_EC metadata
        c_az_ec {mustBeMetadata(c_az_ec, ...
            -1, 1, 0)} = NaN
        % C_AZ_DC metadata
        c_az_dc {mustBeMetadata(c_az_dc, ...
            -1, 1, 0)} = NaN
        % C_AL_NC metadata
        c_al_nc {mustBeMetadata(c_al_nc, ...
            -1, 1, 0)} = NaN
        % C_AL_EC metadata
        c_al_ec {mustBeMetadata(c_al_ec, ...
            -1, 1, 0)} = NaN
        % C_AL_DC metadata
        c_al_dc {mustBeMetadata(c_al_dc, ...
            -1, 1, 0)} = NaN
        % TOTAL_TILES_COLS metadata
        total_tiles_cols {mustBeMetadata(total_tiles_cols, ...
            1, 999, 1)} = NaN
        % TOTAL_TILES_ROWS metadata
        total_tiles_rows {mustBeMetadata(total_tiles_rows, ...
            1, 99999, 1)} = NaN
    end
    methods
        function obj = MENSRB(options) %#codegen
            arguments
                options.?nfx.MENSRB
            end
            if isfield(options, 'acft_loc')
                obj.acft_loc = options.acft_loc;
            end
            if isfield(options, 'acft_loc_accy')
                obj.acft_loc_accy = options.acft_loc_accy;
            end
            if isfield(options, 'acft_alt')
                obj.acft_alt = options.acft_alt;
            end
            if isfield(options, 'rp_loc')
                obj.rp_loc = options.rp_loc;
            end
            if isfield(options, 'rp_loc_accy')
                obj.rp_loc_accy = options.rp_loc_accy;
            end
            if isfield(options, 'rp_elv')
                obj.rp_elv = options.rp_elv;
            end
            if isfield(options, 'of_pc_r')
                obj.of_pc_r = options.of_pc_r;
            end
            if isfield(options, 'of_pc_a')
                obj.of_pc_a = options.of_pc_a;
            end
            if isfield(options, 'cosgrz')
                obj.cosgrz = options.cosgrz;
            end
            if isfield(options, 'rgcrp')
                obj.rgcrp = options.rgcrp;
            end
            if isfield(options, 'rlmap')
                obj.rlmap = options.rlmap;
            end
            if isfield(options, 'rp_row')
                obj.rp_row = options.rp_row;
            end
            if isfield(options, 'rp_col')
                obj.rp_col = options.rp_col;
            end
            if isfield(options, 'c_r_nc')
                obj.c_r_nc = options.c_r_nc;
            end
            if isfield(options, 'c_r_ec')
                obj.c_r_ec = options.c_r_ec;
            end
            if isfield(options, 'c_r_dc')
                obj.c_r_dc = options.c_r_dc;
            end
            if isfield(options, 'c_az_nc')
                obj.c_az_nc = options.c_az_nc;
            end
            if isfield(options, 'c_az_ec')
                obj.c_az_ec = options.c_az_ec;
            end
            if isfield(options, 'c_az_dc')
                obj.c_az_dc = options.c_az_dc;
            end
            if isfield(options, 'c_al_nc')
                obj.c_al_nc = options.c_al_nc;
            end
            if isfield(options, 'c_al_ec')
                obj.c_al_ec = options.c_al_ec;
            end
            if isfield(options, 'c_al_dc')
                obj.c_al_dc = options.c_al_dc;
            end
            if isfield(options, 'total_tiles_cols')
                obj.total_tiles_cols = options.total_tiles_cols;
            end
            if isfield(options, 'total_tiles_rows')
                obj.total_tiles_rows = options.total_tiles_rows;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-14 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.acft_loc))), ...
                'Required', 'acft_loc', 'Supply ACFT_LOC.', reference);
            [~, valid] = treNumber(obj.acft_loc_accy, 6, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'acft_loc_accy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.acft_alt, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'acft_alt', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.rp_loc))), ...
                'Required', 'rp_loc', 'Supply RP_LOC.', reference);
            [~, valid] = treNumber(obj.rp_loc_accy, 6, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'rp_loc_accy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rp_elv, 6, 0, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'rp_elv', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.of_pc_r, 7, 1, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'of_pc_r', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.of_pc_a, 7, 1, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'of_pc_a', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.cosgrz, 7, 5, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'cosgrz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rgcrp, 7, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'rgcrp', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.rlmap, {'L', 'R'})), ...
                'Enumeration', 'rlmap', 'Use a defined RLMAP value.', reference);
            [~, valid] = treNumber(obj.rp_row, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rp_row', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.rp_col, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'rp_col', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_r_nc, 10, 7, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_r_nc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_r_ec, 10, 7, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_r_ec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_r_dc, 10, 7, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_r_dc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_az_nc, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_az_nc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_az_ec, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_az_ec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_az_dc, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_az_dc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_al_nc, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_al_nc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_al_ec, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_al_ec', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.c_al_dc, 9, 6, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'c_al_dc', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.total_tiles_cols, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'total_tiles_cols', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.total_tiles_rows, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'total_tiles_rows', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ~validMensurationLocation(obj.acft_loc) || ...
                ~validMensurationLocation(obj.rp_loc), ...
                'Metadata', 'acft_loc/rp_loc', 'Supply valid precise geographic coordinates.', reference);
            report = addIssue(report, any(isnan([obj.of_pc_r obj.of_pc_a])) && ...
                any(isnan([obj.rp_row obj.rp_col])), ...
                'Metadata', 'of_pc_r/of_pc_a/rp_row/rp_col', 'Supply a complete offset pair or reference row and column.', reference);
            payloadLength = 25 + ...
                6 + ...
                6 + ...
                25 + ...
                6 + ...
                6 + ...
                7 + ...
                7 + ...
                7 + ...
                7 + ...
                1 + ...
                5 + ...
                5 + ...
                10 + ...
                10 + ...
                10 + ...
                9 + ...
                9 + ...
                9 + ...
                9 + ...
                9 + ...
                9 + ...
                3 + ...
                5;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.acft_loc, 25)];
            data = [data treNumber(obj.acft_loc_accy, 6, 2, false, false, false)];
            data = [data treNumber(obj.acft_alt, 6, 0, false, false, false)];
            data = [data textField(obj.rp_loc, 25)];
            data = [data treNumber(obj.rp_loc_accy, 6, 2, false, false, false)];
            data = [data treNumber(obj.rp_elv, 6, 0, true, false, false)];
            data = [data treNumber(obj.of_pc_r, 7, 1, true, true, false)];
            data = [data treNumber(obj.of_pc_a, 7, 1, true, true, false)];
            data = [data treNumber(obj.cosgrz, 7, 5, false, false, false)];
            data = [data treNumber(obj.rgcrp, 7, 0, false, false, false)];
            data = [data textField(obj.rlmap, 1)];
            data = [data treNumber(obj.rp_row, 5, 0, false, true, false)];
            data = [data treNumber(obj.rp_col, 5, 0, false, true, false)];
            data = [data treNumber(obj.c_r_nc, 10, 7, true, false, false)];
            data = [data treNumber(obj.c_r_ec, 10, 7, true, false, false)];
            data = [data treNumber(obj.c_r_dc, 10, 7, true, false, false)];
            data = [data treNumber(obj.c_az_nc, 9, 6, true, false, false)];
            data = [data treNumber(obj.c_az_ec, 9, 6, true, false, false)];
            data = [data treNumber(obj.c_az_dc, 9, 6, true, false, false)];
            data = [data treNumber(obj.c_al_nc, 9, 6, true, false, false)];
            data = [data treNumber(obj.c_al_ec, 9, 6, true, false, false)];
            data = [data treNumber(obj.c_al_dc, 9, 6, true, false, false)];
            data = [data treNumber(obj.total_tiles_cols, 3, 0, false, true, false)];
            data = [data treNumber(obj.total_tiles_rows, 5, 0, false, true, false)];
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
            obj = nfx.MENSRB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(25, true, false);
            if reader.ok, obj.acft_loc = value; end
            [value, reader] = reader.number(6, 0, 999.99, ...
                false, false);
            if reader.ok, obj.acft_loc_accy = value; end
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.acft_alt = value; end
            [value, reader] = reader.text(25, true, false);
            if reader.ok, obj.rp_loc = value; end
            [value, reader] = reader.number(6, 0, 999.99, ...
                false, false);
            if reader.ok, obj.rp_loc_accy = value; end
            [value, reader] = reader.number(6, -1000, 30000, ...
                true, false);
            if reader.ok, obj.rp_elv = value; end
            [value, reader] = reader.number(7, -9999.9, 9999.9, ...
                false, true);
            if reader.ok, obj.of_pc_r = value; end
            [value, reader] = reader.number(7, -9999.9, 9999.9, ...
                false, true);
            if reader.ok, obj.of_pc_a = value; end
            [value, reader] = reader.number(7, 0, 1, ...
                false, false);
            if reader.ok, obj.cosgrz = value; end
            [value, reader] = reader.number(7, 0, 3000000, ...
                true, false);
            if reader.ok, obj.rgcrp = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.rlmap = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, true);
            if reader.ok, obj.rp_row = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, true);
            if reader.ok, obj.rp_col = value; end
            [value, reader] = reader.number(10, -1, 1, ...
                false, false);
            if reader.ok, obj.c_r_nc = value; end
            [value, reader] = reader.number(10, -1, 1, ...
                false, false);
            if reader.ok, obj.c_r_ec = value; end
            [value, reader] = reader.number(10, -1, 1, ...
                false, false);
            if reader.ok, obj.c_r_dc = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_az_nc = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_az_ec = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_az_dc = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_al_nc = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_al_ec = value; end
            [value, reader] = reader.number(9, -1, 1, ...
                false, false);
            if reader.ok, obj.c_al_dc = value; end
            [value, reader] = reader.number(3, 1, 999, ...
                true, true);
            if reader.ok, obj.total_tiles_cols = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, true);
            if reader.ok, obj.total_tiles_rows = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MENSRB());
        end
    end
end
