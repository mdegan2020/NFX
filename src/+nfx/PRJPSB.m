classdef (Sealed) PRJPSB < nfx.TRE
    %PRJPSB - Projection parameters and false origin
    %   OBJ = PRJPSB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PRJPSB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PRJPSB properties:
    %       cetag - Constant tag identifier
    %       prn - PRN metadata
    %       pco - PCO metadata
    %       prj - PRJ metadata
    %       xor - XOR metadata
    %       yor - YOR metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PRJPSB' % Registered tag identifier
    end
    properties
        prn {mustBeAscii(prn, 80)} = 'Transverse Mercator' % PRN metadata
        pco {mustBeAscii(pco, 2)} = 'TC' % PCO metadata
        % PRJ metadata
        prj {mustBeMetadataArray(prj, ...
            -1.7976931348623157e308, 1.7976931348623157e308, 0)} = zeros(1, 0)
        % XOR metadata
        xor {mustBeMetadata(xor, ...
            -99999999999999, 999999999999999, 0)} = 0
        % YOR metadata
        yor {mustBeMetadata(yor, ...
            -99999999999999, 999999999999999, 0)} = 0
    end
    methods
        function obj = PRJPSB(options) %#codegen
            arguments
                options.?nfx.PRJPSB
            end
            if isfield(options, 'prn')
                obj.prn = options.prn;
            end
            if isfield(options, 'pco')
                obj.pco = options.pco;
            end
            if isfield(options, 'prj')
                obj.prj = options.prj;
            end
            if isfield(options, 'xor')
                obj.xor = options.xor;
            end
            if isfield(options, 'yor')
                obj.yor = options.yor;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-3 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.prn))), ...
                'Required', 'prn', 'Supply PRN.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.pco))), ...
                'Required', 'pco', 'Supply PCO.', reference);
            report = addIssue(report, ...
                ~(isrow(obj.prj) || isempty(obj.prj)) || ...
                numel(obj.prj) < 0 || numel(obj.prj) > 9, ...
                'Count', 'prj', 'Supply a row within the defined count limits.', reference);
            for k = 1:numel(obj.prj)
                [~, valid] = variableDecimalNumber(obj.prj(k), 15);
                report = addIssue(report, ~valid, 'Encoding', 'prj', ...
                    'Supply finite values fitting the encoded precision.', reference);
            end
            [~, valid] = variableDecimalNumber(obj.xor, 15);
            report = addIssue(report, ~valid, 'Encoding', 'xor', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = variableDecimalNumber(obj.yor, 15);
            report = addIssue(report, ~valid, 'Encoding', 'yor', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(char(obj.pco)) ~= 2, ...
                'Metadata', 'pco', 'Supply the registered two-character projection code.', reference);
            payloadLength = 80 + ...
                2 + ...
                1 + 15 * numel(obj.prj) + ...
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
            data = [data textField(obj.prn, 80)];
            data = [data textField(obj.pco, 2)];
            data = [data decimalField(numel(obj.prj), 1, 0, false)];
            for k = 1:numel(obj.prj)
                data = [data variableDecimalNumber(obj.prj(k), 15)]; %#ok<AGROW>
            end
            data = [data variableDecimalNumber(obj.xor, 15)];
            data = [data variableDecimalNumber(obj.yor, 15)];
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
            obj = nfx.PRJPSB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.prn = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.pco = value; end
            [count, reader] = reader.count(1, 15, 9);
            [value, reader] = reader.numbers(count, 15, -Inf, Inf, ...
                false, false);
            if reader.ok, obj.prj = value; end
            [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
                false, false);
            if reader.ok, obj.xor = value; end
            [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
                false, false);
            if reader.ok, obj.yor = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PRJPSB());
        end
    end
end
