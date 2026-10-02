classdef (Sealed) ISATPA < nfx.TRE
    %ISATPA - Inverse radar target parameters
    %   OBJ = ISATPA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ISATPA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ISATPA properties:
    %       cetag - Constant tag identifier
    %       tgt_det - TGT_DET metadata
    %       tgt_len - TGT_LEN metadata
    %       tgt_len_uncy - TGT_LEN_UNCY metadata
    %       tgt_strt_rng - TGT_STRT_RNG metadata
    %       tgt_strt_dop - TGT_STRT_DOP metadata
    %       tgt_end_rng - TGT_END_RNG metadata
    %       tgt_end_dop - TGT_END_DOP metadata
    %       tgt_info - TGT_INFO metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ISATPA' % Registered tag identifier
    end
    properties
        tgt_det {mustBeAscii(tgt_det, 1)} = '' % TGT_DET metadata
        % TGT_LEN metadata
        tgt_len {mustBeMetadata(tgt_len, ...
            0, 9999.999, 0)} = NaN
        % TGT_LEN_UNCY metadata
        tgt_len_uncy {mustBeMetadata(tgt_len_uncy, ...
            0, 100, 0)} = NaN
        % TGT_STRT_RNG metadata
        tgt_strt_rng {mustBeMetadata(tgt_strt_rng, ...
            0, 99999999, 1)} = NaN
        % TGT_STRT_DOP metadata
        tgt_strt_dop {mustBeMetadata(tgt_strt_dop, ...
            0, 99999999, 1)} = NaN
        % TGT_END_RNG metadata
        tgt_end_rng {mustBeMetadata(tgt_end_rng, ...
            0, 99999999, 1)} = NaN
        % TGT_END_DOP metadata
        tgt_end_dop {mustBeMetadata(tgt_end_dop, ...
            0, 99999999, 1)} = NaN
        tgt_info {mustBeAscii(tgt_info, 32)} = '' % TGT_INFO metadata
    end
    methods
        function obj = ISATPA(options) %#codegen
            arguments
                options.?nfx.ISATPA
            end
            if isfield(options, 'tgt_det')
                obj.tgt_det = options.tgt_det;
            end
            if isfield(options, 'tgt_len')
                obj.tgt_len = options.tgt_len;
            end
            if isfield(options, 'tgt_len_uncy')
                obj.tgt_len_uncy = options.tgt_len_uncy;
            end
            if isfield(options, 'tgt_strt_rng')
                obj.tgt_strt_rng = options.tgt_strt_rng;
            end
            if isfield(options, 'tgt_strt_dop')
                obj.tgt_strt_dop = options.tgt_strt_dop;
            end
            if isfield(options, 'tgt_end_rng')
                obj.tgt_end_rng = options.tgt_end_rng;
            end
            if isfield(options, 'tgt_end_dop')
                obj.tgt_end_dop = options.tgt_end_dop;
            end
            if isfield(options, 'tgt_info')
                obj.tgt_info = options.tgt_info;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AX, Table AX-3 (2024-02)';
            report = newReport(reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.tgt_det, {'T', 'F'})), ...
                'Enumeration', 'tgt_det', 'Use a defined TGT_DET value.', reference);
            [~, valid] = treNumber(obj.tgt_len, 8, 3, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_len', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.tgt_len_uncy, 6, 2, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_len_uncy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.tgt_strt_rng, 8, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_strt_rng', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.tgt_strt_dop, 8, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_strt_dop', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.tgt_end_rng, 8, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_end_rng', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.tgt_end_dop, 8, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'tgt_end_dop', ...
                'Supply a value fitting the encoded precision.', reference);
            payloadLength = 1 + ...
                8 + ...
                6 + ...
                8 + ...
                8 + ...
                8 + ...
                8 + ...
                32;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.tgt_det, 1)];
            data = [data treNumber(obj.tgt_len, 8, 3, false, true, false)];
            data = [data treNumber(obj.tgt_len_uncy, 6, 2, false, true, false)];
            data = [data treNumber(obj.tgt_strt_rng, 8, 0, false, true, false)];
            data = [data treNumber(obj.tgt_strt_dop, 8, 0, false, true, false)];
            data = [data treNumber(obj.tgt_end_rng, 8, 0, false, true, false)];
            data = [data treNumber(obj.tgt_end_dop, 8, 0, false, true, false)];
            data = [data textField(obj.tgt_info, 32)];
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
            obj = nfx.ISATPA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.tgt_det = value; end
            [value, reader] = reader.number(8, 0, 9999.999, ...
                false, true);
            if reader.ok, obj.tgt_len = value; end
            [value, reader] = reader.number(6, 0, 100, ...
                false, true);
            if reader.ok, obj.tgt_len_uncy = value; end
            [value, reader] = reader.number(8, 0, 99999999, ...
                true, true);
            if reader.ok, obj.tgt_strt_rng = value; end
            [value, reader] = reader.number(8, 0, 99999999, ...
                true, true);
            if reader.ok, obj.tgt_strt_dop = value; end
            [value, reader] = reader.number(8, 0, 99999999, ...
                true, true);
            if reader.ok, obj.tgt_end_rng = value; end
            [value, reader] = reader.number(8, 0, 99999999, ...
                true, true);
            if reader.ok, obj.tgt_end_dop = value; end
            [value, reader] = reader.text(32, true, false);
            if reader.ok, obj.tgt_info = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ISATPA());
        end
    end
end
