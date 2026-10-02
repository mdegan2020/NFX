classdef (Sealed) CSPROA < nfx.TRE
    %CSPROA - Commercial image processing indicators
    %   OBJ = CSPROA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   CSPROA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   CSPROA properties:
    %       cetag - Constant tag identifier
    %       reserved_6 - RESERVED_6 metadata
    %       bwc - BWC metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'CSPROA' % Registered tag identifier
    end
    properties
        reserved_6 {mustBeAscii(reserved_6, 12)} = '' % RESERVED_6 metadata
        bwc {mustBeAscii(bwc, 12)} = 'UNCOMPRESSED' % BWC metadata
    end
    methods
        function obj = CSPROA(options) %#codegen
            arguments
                options.?nfx.CSPROA
            end
            if isfield(options, 'reserved_6')
                obj.reserved_6 = options.reserved_6;
            end
            if isfield(options, 'bwc')
                obj.bwc = options.bwc;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix D, Table D-5 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.reserved_6, {'', 'CORR'})), ...
                'Enumeration', 'reserved_6', 'Use a defined RESERVED_6 value.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.bwc, {'VISUAL', 'NUMERICAL', 'UNCOMPRESSED'})), ...
                'Enumeration', 'bwc', 'Use a defined BWC value.', reference);
            payloadLength = 12 + ...
                24 + ...
                13 + ...
                12 + ...
                12 + ...
                12 + ...
                12 + ...
                12 + ...
                12;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data uint8('LATESTCAL   ')];
            data = [data uint8('                        ')];
            data = [data uint8('MARKANDFIX   ')];
            data = [data uint8('            ')];
            data = [data textField(obj.reserved_6, 12)];
            data = [data uint8('SKIPAGM     ')];
            data = [data uint8('INTERP      ')];
            data = [data uint8('            ')];
            data = [data textField(obj.bwc, 12)];
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
            obj = nfx.CSPROA();
            reader = nfx.internal.TREReader(data);
            reader = reader.literal('LATESTCAL   ');
            reader = reader.literal('                        ');
            reader = reader.literal('MARKANDFIX   ');
            reader = reader.literal('            ');
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.reserved_6 = value; end
            reader = reader.literal('SKIPAGM     ');
            reader = reader.literal('INTERP      ');
            reader = reader.literal('            ');
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.bwc = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSPROA());
        end
    end
end
