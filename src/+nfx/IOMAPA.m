classdef (Sealed) IOMAPA < nfx.TRE
    %IOMAPA - Input/output mapping metadata for methods zero through three
    %   OBJ = IOMAPA(Name=VALUE) stores mapping parameters. Method 1 uses
    %   4096 OUTPUT_MAP values. Method 2 uses R_WHOLE and R_FRACTION.
    %   Method 3 uses two XOB boundaries and a 6-by-3 OUT_B matrix, with
    %   one column per polynomial segment. Numeric metadata uses double;
    %   coefficients encode as IEEE binary32. Unused fields remain unset.
    %   This TRE describes a mapping; it does not apply it to image pixels.
    %
    %   See also TRE, ImageSegment

    properties (Constant)
        cetag = 'IOMAPA'
    end
    properties
        band_number {mustBeMetadata(band_number, 0, 999, 1)} = 0
        map_select {mustBeMetadata(map_select, 0, 3, 1)} = 0
        table_id {mustBeMetadata(table_id, 0, 99, 1)} = NaN
        s1 {mustBeMetadata(s1, 0, 11, 1)} = NaN
        s2 {mustBeMetadata(s2, 0, 11, 1)} = 0
        output_map {mustBeMetadataArray(output_map, 0, 4095, 1)} = zeros(1, 0)
        r_whole {mustBeMetadata(r_whole, 0, 999, 1)} = NaN
        r_fraction {mustBeMetadata(r_fraction, 0, 255, 1)} = NaN
        xob {mustBeMetadataArray(xob, 0, 4095, 1)} = zeros(1, 0)
        out_b {mustBeMetadataArray(out_b, -3.4028234663852886e38, ...
            3.4028234663852886e38, 0)} = zeros(6, 0)
    end
    methods
        function obj = IOMAPA(options) %#codegen
            arguments
                options.?nfx.IOMAPA
            end
            if isfield(options, 'band_number'), obj.band_number = options.band_number; end
            if isfield(options, 'map_select'), obj.map_select = options.map_select; end
            if isfield(options, 'table_id'), obj.table_id = options.table_id; end
            if isfield(options, 's1'), obj.s1 = options.s1; end
            if isfield(options, 's2'), obj.s2 = options.s2; end
            if isfield(options, 'output_map'), obj.output_map = options.output_map; end
            if isfield(options, 'r_whole'), obj.r_whole = options.r_whole; end
            if isfield(options, 'r_fraction'), obj.r_fraction = options.r_fraction; end
            if isfield(options, 'xob'), obj.xob = options.xob; end
            if isfield(options, 'out_b'), obj.out_b = options.out_b; end
        end
        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix F, Tables F-1 through F-4';
            report = newReport(reference);
            report = addIssue(report, ...
                any(isnan([obj.band_number obj.map_select obj.s2])), ...
                'Required', 'band_number/map_select/s2', ...
                'Supply the common mapping fields.', reference);
            if obj.map_select == 0
                bad = ~isnan(obj.table_id) || ~isnan(obj.s1);
            else
                bad = isnan(obj.s1) || obj.s2 >= 12 - obj.s1;
            end
            report = addIssue(report, bad, 'Scaling', 's1/s2/table_id', ...
                'Method zero omits S1/TABLE_ID; other methods need S2 < 12-S1.', ...
                reference);
            if obj.map_select == 1
                bad = ~isequal(size(obj.output_map), [1 4096]) || ...
                    any(isnan(obj.output_map(:)));
            else
                bad = ~isempty(obj.output_map);
            end
            report = addIssue(report, bad, 'MappingTable', 'output_map', ...
                'Only method one uses a row of 4096 finite mapping values.', ...
                reference);
            ratio = [obj.r_whole obj.r_fraction];
            bad = (obj.map_select == 2 && any(isnan(ratio))) || ...
                (obj.map_select ~= 2 && any(~isnan(ratio)));
            report = addIssue(report, bad, 'Ratio', 'r_whole/r_fraction', ...
                'Supply both ratio fields only for method two.', reference);
            if obj.map_select == 3
                bad = ~isequal(size(obj.xob), [1 2]) || ...
                    any(isnan(obj.xob(:))) || ...
                    ~isequal(size(obj.out_b), [6 3]) || ...
                    any(isnan(obj.out_b(:)));
                if ~bad
                    bad = obj.xob(1) >= obj.xob(2);
                end
            else
                bad = ~isempty(obj.xob) || ~isempty(obj.out_b);
            end
            report = addIssue(report, bad, 'Polynomial', 'xob/out_b', ...
                'Method three requires ordered boundaries and 6-by-3 coefficients.', ...
                reference);
        end
        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = [decimalField(obj.band_number, 3, 0, false) ...
                decimalField(obj.map_select, 1, 0, false)];
            if obj.map_select == 0
                data = [data decimalField(obj.s2, 2, 0, false)];
                return
            end
            data = [data treNumber(obj.table_id, 2, 0, false, true, false) ...
                decimalField(obj.s1, 2, 0, false) ...
                decimalField(obj.s2, 2, 0, false)];
            switch obj.map_select
                case 1
                    data = [data unsignedBytes(uint64(obj.output_map), 2)];
                case 2
                    data = [data decimalField(obj.r_whole, 3, 0, false) ...
                        decimalField(obj.r_fraction, 3, 0, false)];
                case 3
                    data = [data uint8('3') ...
                        decimalField(obj.xob(1), 4, 0, false) ...
                        decimalField(obj.xob(2), 4, 0, false) ...
                        float32Bytes(reshape(obj.out_b, 1, []))];
            end
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode a mapping table or polynomial description
            %   [OBJ, OK, STATUS] = deserialize(DATA) returns a default
            %   scalar object and diagnostic on malformed input.
            obj = nfx.IOMAPA();
            reader = nfx.internal.TREReader(data);
            [band, reader] = reader.number(3, 0, 999, true);
            [method, reader] = reader.number(1, 0, 3, true);
            if reader.ok
                obj.band_number = band;
                obj.map_select = method;
                if method ~= 0
                    [table, reader] = reader.number(2, 0, 99, true, true);
                    [scale, reader] = reader.number(2, 0, 11, true);
                    if reader.ok
                        obj.table_id = table; obj.s1 = scale;
                    end
                end
                [scale, reader] = reader.number(2, 0, 11, true);
                if reader.ok, obj.s2 = scale; end
                switch method
                    case 1
                        [values, reader] = reader.unsigned(2, 4096);
                        if reader.ok && any(values > 4095)
                            reader = reader.fail('MappingTable', ...
                                'Output mapping values cannot exceed 4095.');
                        end
                        if reader.ok, obj.output_map = double(values); end
                    case 2
                        [whole, reader] = reader.number(3, 0, 999, true);
                        [fraction, reader] = reader.number(3, 0, 255, true);
                        if reader.ok
                            obj.r_whole = whole; obj.r_fraction = fraction;
                        end
                    case 3
                        reader = reader.literal('3');
                        [bounds, reader] = reader.numbers(2, 4, 0, 4095, true);
                        [coefficients, reader] = reader.float32(18);
                        if reader.ok
                            obj.xob = bounds;
                            obj.out_b = reshape(coefficients, 6, 3);
                        end
                end
            end
            [obj, ok, status] = finishTREDecode(obj, reader, nfx.IOMAPA());
        end
    end
end
