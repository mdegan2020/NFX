classdef (Sealed) SECTGA < nfx.TRE
    %SECTGA - Secondary target identification
    %   OBJ = SECTGA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   SECTGA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   SECTGA properties:
    %       cetag - Constant tag identifier
    %       sec_id - SEC_ID metadata
    %       sec_be - SEC_BE metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'SECTGA' % Registered tag identifier
    end
    properties
        sec_id {mustBeAscii(sec_id, 12)} = '' % SEC_ID metadata
        sec_be {mustBeAscii(sec_be, 15)} = '' % SEC_BE metadata
    end
    methods
        function obj = SECTGA(options) %#codegen
            arguments
                options.?nfx.SECTGA
            end
            if isfield(options, 'sec_id')
                obj.sec_id = options.sec_id;
            end
            if isfield(options, 'sec_be')
                obj.sec_be = options.sec_be;
            end
        end

        function report = validate(~) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-23 (2025-02)';
            report = newReport(reference);
            payloadLength = 12 + ...
                15 + ...
                1;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.sec_id, 12)];
            data = [data textField(obj.sec_be, 15)];
            data = [data uint8('0')];
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
            obj = nfx.SECTGA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.sec_id = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.sec_be = value; end
            reader = reader.literal('0');
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.SECTGA());
        end
    end
end
