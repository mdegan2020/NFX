classdef (Sealed) MAPLOB < nfx.TRE
    %MAPLOB - Local map coordinate grid
    %   OBJ = MAPLOB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   MAPLOB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   MAPLOB properties:
    %       cetag - Constant tag identifier
    %       uniloa - UNILOA metadata
    %       lod - LOD metadata
    %       lad - LAD metadata
    %       lso - LSO metadata
    %       pso - PSO metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'MAPLOB' % Registered tag identifier
    end
    properties
        uniloa {mustBeAscii(uniloa, 3)} = 'M' % UNILOA metadata
        % LOD metadata
        lod {mustBeMetadata(lod, ...
            1, 99999, 1)} = NaN
        % LAD metadata
        lad {mustBeMetadata(lad, ...
            1, 99999, 1)} = NaN
        % LSO metadata
        lso {mustBeMetadata(lso, ...
            -999999999999.9, 999999999999.9, 0)} = NaN
        % PSO metadata
        pso {mustBeMetadata(pso, ...
            -999999999999.9, 999999999999.9, 0)} = NaN
    end
    methods
        function obj = MAPLOB(options) %#codegen
            arguments
                options.?nfx.MAPLOB
            end
            if isfield(options, 'uniloa')
                obj.uniloa = options.uniloa;
            end
            if isfield(options, 'lod')
                obj.lod = options.lod;
            end
            if isfield(options, 'lad')
                obj.lad = options.lad;
            end
            if isfield(options, 'lso')
                obj.lso = options.lso;
            end
            if isfield(options, 'pso')
                obj.pso = options.pso;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-6 (2024-04)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.lod, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'lod', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.lad, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'lad', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.lso, 15, 1, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'lso', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.pso, 15, 1, true, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'pso', ...
                'Supply a value fitting the encoded precision.', reference);
            payloadLength = 3 + ...
                5 + ...
                5 + ...
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
            data = [data textField(obj.uniloa, 3)];
            data = [data treNumber(obj.lod, 5, 0, false, false, false)];
            data = [data treNumber(obj.lad, 5, 0, false, false, false)];
            data = [data treNumber(obj.lso, 15, 1, true, false, false)];
            data = [data treNumber(obj.pso, 15, 1, true, false, false)];
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
            obj = nfx.MAPLOB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.uniloa = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.lod = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.lad = value; end
            [value, reader] = reader.number(15, -999999999999.9, 999999999999.9, ...
                false, false);
            if reader.ok, obj.lso = value; end
            [value, reader] = reader.number(15, -999999999999.9, 999999999999.9, ...
                false, false);
            if reader.ok, obj.pso = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MAPLOB());
        end
    end
end
