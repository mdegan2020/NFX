classdef (Sealed) PIAEVA < nfx.TRE
    %PIAEVA - Imagery access event metadata
    %   OBJ = PIAEVA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIAEVA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIAEVA properties:
    %       cetag - Constant tag identifier
    %       eventname - EVENTNAME metadata
    %       eventtype - EVENTTYPE metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIAEVA' % Registered tag identifier
    end
    properties
        eventname {mustBeAscii(eventname, 38)} = '' % EVENTNAME metadata
        eventtype {mustBeAscii(eventtype, 8)} = '' % EVENTTYPE metadata
    end
    methods
        function obj = PIAEVA(options) %#codegen
            arguments
                options.?nfx.PIAEVA
            end
            if isfield(options, 'eventname')
                obj.eventname = options.eventname;
            end
            if isfield(options, 'eventtype')
                obj.eventtype = options.eventtype;
            end
        end

        function report = validate(~) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-14 (2025-06)';
            report = newReport(reference);
            payloadLength = 38 + ...
                8;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.eventname, 38)];
            data = [data textField(obj.eventtype, 8)];
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
            obj = nfx.PIAEVA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(38, true, false);
            if reader.ok, obj.eventname = value; end
            [value, reader] = reader.text(8, true, false);
            if reader.ok, obj.eventtype = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIAEVA());
        end
    end
end
