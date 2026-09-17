classdef (Sealed) MIMCSA < nfx.TRE
    %MIMCSA - Motion imagery collection summary for one layer
    %   OBJ = MIMCSA(Name=VALUE) supplies a layer identifier, frame rates,
    %   temporal reduction level, and decoder requirements. Unknown frame
    %   rates use NaN; they serialize using the specified UE/13 sentinel.
    %
    %   Uncompressed layers use MI_REQ_DECODER='NC' or 'NM',
    %   MI_REQ_PROFILE='Not Applicable', and MI_REQ_LEVEL='N/A'.
    %
    %   See also TRE, File

    properties (Constant)
        cetag = 'MIMCSA'
    end
    properties
        layer_id {mustBeAscii(layer_id, 36)} = ''
        nominal_frame_rate {mustBeMetadata(nominal_frame_rate, 0, 3.4028234E38, 0)} = NaN
        min_frame_rate {mustBeMetadata(min_frame_rate, 0, 3.4028234E38, 0)} = NaN
        max_frame_rate {mustBeMetadata(max_frame_rate, 0, 3.4028234E38, 0)} = NaN
        t_rset {mustBeMetadata(t_rset, 0, 99, 1), mustBeFinite} = 0
        mi_req_decoder {mustBeAscii(mi_req_decoder, 2)} = ''
        mi_req_profile {mustBeAscii(mi_req_profile, 36)} = ''
        mi_req_level {mustBeAscii(mi_req_level, 6)} = ''
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable MIMCSA value
            %   [OBJ, OK, STATUS] = nfx.MIMCSA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also MIMCSA, MIMCSA.payload
            arguments
                data
            end
            obj = nfx.MIMCSA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(36, true, false);
            if reader.ok
                obj.layer_id = value;
            end
            [value, reader] = reader.ue13();
            if reader.ok
                obj.nominal_frame_rate = value;
            end
            [value, reader] = reader.ue13();
            if reader.ok
                obj.min_frame_rate = value;
            end
            [value, reader] = reader.ue13();
            if reader.ok
                obj.max_frame_rate = value;
            end
            [value, reader] = reader.number( ...
                2, 0, 99, 1, false);
            if reader.ok
                obj.t_rset = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.mi_req_decoder = value;
            end
            [value, reader] = reader.text(36, true, false);
            if reader.ok
                obj.mi_req_profile = value;
            end
            [value, reader] = reader.text(6, true, false);
            if reader.ok
                obj.mi_req_level = value;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MIMCSA());
        end
    end
    methods
        function obj = MIMCSA(options) %#codegen
            %MIMCSA - Construct editable collection summary metadata
            arguments
                options.?nfx.MIMCSA
            end
            if isfield(options, 'layer_id'), obj.layer_id = options.layer_id; end
            if isfield(options, 'nominal_frame_rate'), obj.nominal_frame_rate = options.nominal_frame_rate; end
            if isfield(options, 'min_frame_rate'), obj.min_frame_rate = options.min_frame_rate; end
            if isfield(options, 'max_frame_rate'), obj.max_frame_rate = options.max_frame_rate; end
            if isfield(options, 't_rset'), obj.t_rset = options.t_rset; end
            if isfield(options, 'mi_req_decoder'), obj.mi_req_decoder = options.mi_req_decoder; end
            if isfield(options, 'mi_req_profile'), obj.mi_req_profile = options.mi_req_profile; end
            if isfield(options, 'mi_req_level'), obj.mi_req_level = options.mi_req_level; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check required identifiers, rates and decoder fields
            report = newReport('STDI-0002 Appendix AF MIMCSA');
            reference = 'STDI-0002-1 Appendix AF, AF5.1 and Table AF-2';
            report = addIssue(report, isempty(strtrim(char(obj.layer_id))), 'Required', ...
                'layer_id', 'Supply a nonblank layer identifier.', reference);
            report = addIssue(report, ~any(strcmp(obj.mi_req_decoder, ...
                {'C9','M9','CA','MA','CB','MB','NC','NM','C8','M8','CD','MD','CE','ME'})), ...
                'Decoder', 'mi_req_decoder', 'Supply a permitted decoder code.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.mi_req_profile))) || ...
                isempty(strtrim(char(obj.mi_req_level))), 'Required', 'mi_req_profile/mi_req_level', ...
                'Supply nonblank profile and level requirements.', reference);
            report = addIssue(report, any(strcmp(obj.mi_req_decoder, {'NC','NM'})) && ...
                (~strcmp(strtrim(char(obj.mi_req_profile)), 'Not Applicable') || ...
                ~strcmp(strtrim(char(obj.mi_req_level)), 'N/A')), 'DecoderProfile', ...
                'mi_req_profile/mi_req_level', 'Uncompressed data requires Not Applicable and N/A.', reference);
            report = addIssue(report, obj.min_frame_rate > obj.max_frame_rate, 'FrameRate', ...
                'min_frame_rate/max_frame_rate', 'Minimum frame rate must not exceed maximum.', reference);
            rates = [obj.nominal_frame_rate obj.min_frame_rate obj.max_frame_rate];
            for k = 1:3
                report = addIssue(report, ~isnan(rates(k)) && numel(sprintf('%.7E',rates(k))) ~= 13, ...
                    'FrameRatePrecision', 'frame rates', 'UE/13 requires a two-digit exponent.', reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the fixed 121-byte summary
            requireValid(validate(obj));
            value = [textField(obj.layer_id, 36) unsignedExponential13(obj.nominal_frame_rate) ...
                unsignedExponential13(obj.min_frame_rate) unsignedExponential13(obj.max_frame_rate) ...
                decimalField(obj.t_rset, 2, 0, false) textField(obj.mi_req_decoder, 2) ...
                textField(obj.mi_req_profile, 36) textField(obj.mi_req_level, 6)];
        end
    end
end
