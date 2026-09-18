classdef (Sealed) BLOCKA < nfx.TRE
    %BLOCKA - Image block information and precise parent corners
    %   OBJ = BLOCKA(Name=VALUE) supplies an editable metadata value.
    %   Field names follow the specification mnemonics. Numeric
    %   metadata uses double; omitted optional numbers use NaN.
    %
    %   See also ImageSegment, TRERecord

    properties (Constant)
        cetag = 'BLOCKA'
    end
    properties
        block_instance {mustBeMetadata(block_instance, 1, 99, 1)} = NaN
        n_gray {mustBeMetadata(n_gray, 0, 99999, 1)} = 0
        l_lines {mustBeMetadata(l_lines, 1, 99999, 1)} = NaN
        layover_angle {mustBeMetadata(layover_angle, 0, 359, 1)} = NaN
        shadow_angle {mustBeMetadata(shadow_angle, 0, 359, 1)} = NaN
        frlc_loc {mustBeAscii(frlc_loc, 21)} = ''
        lrlc_loc {mustBeAscii(lrlc_loc, 21)} = ''
        lrfc_loc {mustBeAscii(lrfc_loc, 21)} = ''
        frfc_loc {mustBeAscii(frfc_loc, 21)} = ''
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable BLOCKA value
            %   [OBJ, OK, STATUS] = nfx.BLOCKA.deserialize(PAYLOAD)
            %   accepts payload bytes without the tag/length envelope.
            %   Failure returns a default scalar object and OK=false.
            %
            %   See also BLOCKA, BLOCKA.payload
            arguments
                data
            end
            obj = nfx.BLOCKA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number( ...
                2, 1, 99, true, false);
            if reader.ok, obj.block_instance = value; end
            [value, reader] = reader.number( ...
                5, 0, 99999, true, false);
            if reader.ok, obj.n_gray = value; end
            [value, reader] = reader.number( ...
                5, 1, 99999, true, false);
            if reader.ok, obj.l_lines = value; end
            [value, reader] = reader.number( ...
                3, 0, 359, true, true);
            if reader.ok, obj.layover_angle = value; end
            [value, reader] = reader.number( ...
                3, 0, 359, true, true);
            if reader.ok, obj.shadow_angle = value; end
            reader = reader.literal(uint8('                '));
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.frlc_loc = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.lrlc_loc = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.lrfc_loc = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.frfc_loc = value; end
            reader = reader.literal(uint8('010.0'));
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.BLOCKA());
        end
    end
    methods
        function obj = BLOCKA(options) %#codegen
            %BLOCKA - Construct metadata from specification mnemonics
            arguments
                options.?nfx.BLOCKA
            end
            if isfield(options, 'block_instance')
                obj.block_instance = options.block_instance;
            end
            if isfield(options, 'n_gray')
                obj.n_gray = options.n_gray;
            end
            if isfield(options, 'l_lines')
                obj.l_lines = options.l_lines;
            end
            if isfield(options, 'layover_angle')
                obj.layover_angle = options.layover_angle;
            end
            if isfield(options, 'shadow_angle')
                obj.shadow_angle = options.shadow_angle;
            end
            if isfield(options, 'frlc_loc')
                obj.frlc_loc = options.frlc_loc;
            end
            if isfield(options, 'lrlc_loc')
                obj.lrlc_loc = options.lrlc_loc;
            end
            if isfield(options, 'lrfc_loc')
                obj.lrfc_loc = options.lrfc_loc;
            end
            if isfield(options, 'frfc_loc')
                obj.frfc_loc = options.frfc_loc;
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check required fields and encoded formats
            reference = 'STDI-0002-1 Appendix E, Table E-9 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isnan(obj.block_instance), ...
                'Required', 'block_instance', 'Supply BLOCK_INSTANCE.', reference);
            report = addIssue(report, isnan(obj.n_gray), ...
                'Required', 'n_gray', 'Supply N_GRAY.', reference);
            report = addIssue(report, isnan(obj.l_lines), ...
                'Required', 'l_lines', 'Supply L_LINES.', reference);
            corners = {obj.frlc_loc, obj.lrlc_loc, ...
                obj.lrfc_loc, obj.frfc_loc};
            for k = 1:4
                report = addIssue(report, ...
                    ~validLocation21(corners{k}, true, true, true), ...
                    'Location', 'corner_locations', ...
                    'Use decimal or hemisphere-first DMS coordinates.', ...
                    reference);
            end
        end
        function value = payload(obj) %#codegen
            %payload - Encode the fixed 123-byte record
            requireValid(obj.validate());
            value = [ ...
                decimalField(obj.block_instance, 2, 0, false) ...
                decimalField(obj.n_gray, 5, 0, false) ...
                decimalField(obj.l_lines, 5, 0, false) ...
                blankDecimal(obj.layover_angle, 3, 0, false) ...
                blankDecimal(obj.shadow_angle, 3, 0, false) ...
                uint8('                ') ...
                textField(obj.frlc_loc, 21) ...
                textField(obj.lrlc_loc, 21) ...
                textField(obj.lrfc_loc, 21) ...
                textField(obj.frfc_loc, 21) ...
                uint8('010.0')];
        end
    end
end
