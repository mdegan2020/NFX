classdef (Sealed) GEOLOB < nfx.TRE
    %GEOLOB - Local geographic coordinate grid
    %   OBJ = GEOLOB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   GEOLOB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   GEOLOB properties:
    %       cetag - Constant tag identifier
    %       arv - ARV metadata
    %       brv - BRV metadata
    %       lso - LSO metadata
    %       pso - PSO metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'GEOLOB' % Registered tag identifier
    end
    properties
        % ARV metadata
        arv {mustBeMetadata(arv, ...
            2, 999999999, 1)} = NaN
        % BRV metadata
        brv {mustBeMetadata(brv, ...
            2, 999999999, 1)} = NaN
        % LSO metadata
        lso {mustBeMetadata(lso, ...
            -180, 180, 0)} = NaN
        % PSO metadata
        pso {mustBeMetadata(pso, ...
            -90, 90, 0)} = NaN
    end
    methods
        function obj = GEOLOB(options) %#codegen
            arguments
                options.?nfx.GEOLOB
            end
            if isfield(options, 'arv')
                obj.arv = options.arv;
            end
            if isfield(options, 'brv')
                obj.brv = options.brv;
            end
            if isfield(options, 'lso')
                obj.lso = options.lso;
            end
            if isfield(options, 'pso')
                obj.pso = options.pso;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-5 (2024-04)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.arv, 9, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'arv', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.brv, 9, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'brv', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = variableDecimalNumber(obj.lso, 15);
            report = addIssue(report, ~valid, 'Encoding', 'lso', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = variableDecimalNumber(obj.pso, 15);
            report = addIssue(report, ~valid, 'Encoding', 'pso', ...
                'Supply a value fitting the encoded precision.', reference);
            payloadLength = 9 + ...
                9 + ...
                15 + ...
                15;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.arv, 9, 0, false, false, false)];
            data = [data treNumber(obj.brv, 9, 0, false, false, false)];
            data = [data variableDecimalNumber(obj.lso, 15)];
            data = [data variableDecimalNumber(obj.pso, 15)];
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
            obj = nfx.GEOLOB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.number(9, 2, 999999999, ...
                true, false);
            if reader.ok, obj.arv = value; end
            [value, reader] = reader.number(9, 2, 999999999, ...
                true, false);
            if reader.ok, obj.brv = value; end
            [value, reader] = reader.number(15, -180, 180, ...
                false, false);
            if reader.ok, obj.lso = value; end
            [value, reader] = reader.number(15, -90, 90, ...
                false, false);
            if reader.ok, obj.pso = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.GEOLOB());
        end
    end
end
