classdef (Sealed) PIAEQA < nfx.TRE
    %PIAEQA - Imagery access equipment metadata
    %   OBJ = PIAEQA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIAEQA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIAEQA properties:
    %       cetag - Constant tag identifier
    %       eqpcode - EQPCODE metadata
    %       eqpnomen - EQPNOMEN metadata
    %       eqpman - EQPMAN metadata
    %       obtype - OBTYPE metadata
    %       ordbat - ORDBAT metadata
    %       ctryprod - CTRYPROD metadata
    %       ctrydsn - CTRYDSN metadata
    %       objview - OBJVIEW metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIAEQA' % Registered tag identifier
    end
    properties
        eqpcode {mustBeAscii(eqpcode, 7)} = '' % EQPCODE metadata
        eqpnomen {mustBeAscii(eqpnomen, 45)} = '' % EQPNOMEN metadata
        eqpman {mustBeAscii(eqpman, 64)} = '' % EQPMAN metadata
        obtype {mustBeAscii(obtype, 1)} = '' % OBTYPE metadata
        ordbat {mustBeAscii(ordbat, 3)} = '' % ORDBAT metadata
        ctryprod {mustBeAscii(ctryprod, 2)} = '' % CTRYPROD metadata
        ctrydsn {mustBeAscii(ctrydsn, 2)} = '' % CTRYDSN metadata
        objview {mustBeAscii(objview, 6)} = '' % OBJVIEW metadata
    end
    methods
        function obj = PIAEQA(options) %#codegen
            arguments
                options.?nfx.PIAEQA
            end
            if isfield(options, 'eqpcode')
                obj.eqpcode = options.eqpcode;
            end
            if isfield(options, 'eqpnomen')
                obj.eqpnomen = options.eqpnomen;
            end
            if isfield(options, 'eqpman')
                obj.eqpman = options.eqpman;
            end
            if isfield(options, 'obtype')
                obj.obtype = options.obtype;
            end
            if isfield(options, 'ordbat')
                obj.ordbat = options.ordbat;
            end
            if isfield(options, 'ctryprod')
                obj.ctryprod = options.ctryprod;
            end
            if isfield(options, 'ctrydsn')
                obj.ctrydsn = options.ctrydsn;
            end
            if isfield(options, 'objview')
                obj.objview = options.objview;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-17 (2025-06)';
            report = newReport(reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.objview, {'', 'Right', 'Left', 'Top', 'Bottom', 'Front', 'Rear'})), ...
                'Enumeration', 'objview', 'Use a defined OBJVIEW value.', reference);
            payloadLength = 7 + ...
                45 + ...
                64 + ...
                1 + ...
                3 + ...
                2 + ...
                2 + ...
                6;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.eqpcode, 7)];
            data = [data textField(obj.eqpnomen, 45)];
            data = [data textField(obj.eqpman, 64)];
            data = [data textField(obj.obtype, 1)];
            data = [data textField(obj.ordbat, 3)];
            data = [data textField(obj.ctryprod, 2)];
            data = [data textField(obj.ctrydsn, 2)];
            data = [data textField(obj.objview, 6)];
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
            obj = nfx.PIAEQA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(7, true, false);
            if reader.ok, obj.eqpcode = value; end
            [value, reader] = reader.text(45, true, false);
            if reader.ok, obj.eqpnomen = value; end
            [value, reader] = reader.text(64, true, false);
            if reader.ok, obj.eqpman = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.obtype = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.ordbat = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.ctryprod = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.ctrydsn = value; end
            [value, reader] = reader.text(6, true, false);
            if reader.ok, obj.objview = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIAEQA());
        end
    end
end
