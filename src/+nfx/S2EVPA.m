classdef (Sealed) S2EVPA < nfx.TRE
    %S2EVPA - Stored-pixel to engineering-value polynomial
    %   OBJ = S2EVPA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   S2EVPA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   S2EVPA properties:
    %       cetag - Constant tag identifier
    %       quantity_name - QUANTITY_NAME metadata
    %       uom - UOM metadata
    %       first_band - FIRST_BAND metadata
    %       last_band - LAST_BAND metadata
    %       coef - COEF metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'S2EVPA' % Registered tag identifier
    end
    properties
        quantity_name {mustBeECS(quantity_name, 999)} = '' % QUANTITY_NAME metadata
        uom {mustBeECS(uom, 999)} = '' % UOM metadata
        % FIRST_BAND metadata
        first_band {mustBeMetadata(first_band, ...
            1, 99999, 1)} = 1
        % LAST_BAND metadata
        last_band {mustBeMetadata(last_band, ...
            1, 99999, 1)} = 1
        % COEF metadata
        coef {mustBeMetadataArray(coef, ...
            -1.7976931348623157e308, 1.7976931348623157e308, 0)} = [0 1]
    end
    methods
        function obj = S2EVPA(options) %#codegen
            arguments
                options.?nfx.S2EVPA
            end
            if isfield(options, 'quantity_name')
                obj.quantity_name = options.quantity_name;
            end
            if isfield(options, 'uom')
                obj.uom = options.uom;
            end
            if isfield(options, 'first_band')
                obj.first_band = options.first_band;
            end
            if isfield(options, 'last_band')
                obj.last_band = options.last_band;
            end
            if isfield(options, 'coef')
                obj.coef = options.coef;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AT, Table AT.5-1 (2025-06)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.first_band, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'first_band', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.last_band, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'last_band', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~(isrow(obj.coef) || isempty(obj.coef)) || ...
                numel(obj.coef) < 1 || numel(obj.coef) > 9, ...
                'Count', 'coef', 'Supply a row within the defined count limits.', reference);
            for k = 1:numel(obj.coef)
                [~, valid] = treNumber(obj.coef(k), 15, 8, true, false, true);
                report = addIssue(report, ~valid, 'Encoding', 'coef', ...
                    'Supply finite values fitting the encoded precision.', reference);
            end
            report = addIssue(report, obj.last_band < obj.first_band, ...
                'BandRange', 'last_band', 'LAST_BAND must cover FIRST_BAND.', reference);
            payloadLength = 3 + numel(char(obj.quantity_name)) + ...
                3 + numel(char(obj.uom)) + ...
                5 + ...
                5 + ...
                1 + 15 * numel(obj.coef);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(char(obj.quantity_name)), 3, 0, false) ...
                uint8(char(obj.quantity_name))];
            data = [data decimalField(numel(char(obj.uom)), 3, 0, false) ...
                uint8(char(obj.uom))];
            data = [data treNumber(obj.first_band, 5, 0, false, false, false)];
            data = [data treNumber(obj.last_band, 5, 0, false, false, false)];
            data = [data decimalField(numel(obj.coef), 1, 0, false)];
            for k = 1:numel(obj.coef)
                data = [data treNumber(obj.coef(k), 15, 8, true, false, true)]; %#ok<AGROW>
            end
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
            obj = nfx.S2EVPA();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(3, 1, 999);
            [value, reader] = reader.text(count, false, true);
            if reader.ok, obj.quantity_name = value; end
            [count, reader] = reader.count(3, 1, 999);
            [value, reader] = reader.text(count, false, true);
            if reader.ok, obj.uom = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.first_band = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.last_band = value; end
            [count, reader] = reader.count(1, 15, 9);
            [value, reader] = reader.numbers(count, 15, -Inf, Inf, ...
                false, false);
            if reader.ok, obj.coef = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.S2EVPA());
        end
    end
end
