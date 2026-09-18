classdef (Sealed) CSCCGA < nfx.TRE
    %CSCCGA - Cloud cover grid registration metadata
    %   OBJ = CSCCGA(Name=VALUE) supplies an editable metadata value.
    %   Field names follow the specification mnemonics. Numeric
    %   metadata uses double; omitted optional numbers use NaN.
    %
    %   See also ImageSegment, TRERecord

    properties (Constant)
        cetag = 'CSCCGA'
    end
    properties
        ccg_source {mustBeAscii(ccg_source, 18)} = ''
        reg_sensor {mustBeAscii(reg_sensor, 6)} = ''
        origin_line {mustBeMetadata(origin_line, -999999, 9999999, 1)} = NaN
        origin_sample {mustBeMetadata(origin_sample, -9999, 99999, 1)} = NaN
        as_cell_size {mustBeMetadata(as_cell_size, 1, 9999999, 1)} = NaN
        cs_cell_size {mustBeMetadata(cs_cell_size, 1, 99999, 1)} = NaN
        ccg_max_line {mustBeMetadata(ccg_max_line, 2, 9999999, 1)} = NaN
        ccg_max_sample {mustBeMetadata(ccg_max_sample, 2, 99999, 1)} = NaN
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable CSCCGA value
            %   [OBJ, OK, STATUS] = nfx.CSCCGA.deserialize(PAYLOAD)
            %   accepts payload bytes without the tag/length envelope.
            %   Failure returns a default scalar object and OK=false.
            %
            %   See also CSCCGA, CSCCGA.payload
            arguments
                data
            end
            obj = nfx.CSCCGA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(18, true, false);
            if reader.ok, obj.ccg_source = value; end
            [value, reader] = reader.text(6, true, false);
            if reader.ok, obj.reg_sensor = value; end
            [value, reader] = reader.number( ...
                7, -999999, 9999999, true, false);
            if reader.ok, obj.origin_line = value; end
            [value, reader] = reader.number( ...
                5, -9999, 99999, true, false);
            if reader.ok, obj.origin_sample = value; end
            [value, reader] = reader.number( ...
                7, 1, 9999999, true, false);
            if reader.ok, obj.as_cell_size = value; end
            [value, reader] = reader.number( ...
                5, 1, 99999, true, false);
            if reader.ok, obj.cs_cell_size = value; end
            [value, reader] = reader.number( ...
                7, 2, 9999999, true, false);
            if reader.ok, obj.ccg_max_line = value; end
            [value, reader] = reader.number( ...
                5, 2, 99999, true, false);
            if reader.ok, obj.ccg_max_sample = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSCCGA());
        end
    end
    methods
        function obj = CSCCGA(options) %#codegen
            %CSCCGA - Construct metadata from specification mnemonics
            arguments
                options.?nfx.CSCCGA
            end
            if isfield(options, 'ccg_source')
                obj.ccg_source = options.ccg_source;
            end
            if isfield(options, 'reg_sensor')
                obj.reg_sensor = options.reg_sensor;
            end
            if isfield(options, 'origin_line')
                obj.origin_line = options.origin_line;
            end
            if isfield(options, 'origin_sample')
                obj.origin_sample = options.origin_sample;
            end
            if isfield(options, 'as_cell_size')
                obj.as_cell_size = options.as_cell_size;
            end
            if isfield(options, 'cs_cell_size')
                obj.cs_cell_size = options.cs_cell_size;
            end
            if isfield(options, 'ccg_max_line')
                obj.ccg_max_line = options.ccg_max_line;
            end
            if isfield(options, 'ccg_max_sample')
                obj.ccg_max_sample = options.ccg_max_sample;
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check required fields and encoded formats
            reference = 'STDI-0002-1 Appendix AV, Table AV.5-3 (2024-06)';
            report = newReport(reference);
            report = addIssue(report, isnan(obj.origin_line), ...
                'Required', 'origin_line', 'Supply ORIGIN_LINE.', reference);
            report = addIssue(report, isnan(obj.origin_sample), ...
                'Required', 'origin_sample', 'Supply ORIGIN_SAMPLE.', reference);
            report = addIssue(report, isnan(obj.as_cell_size), ...
                'Required', 'as_cell_size', 'Supply AS_CELL_SIZE.', reference);
            report = addIssue(report, isnan(obj.cs_cell_size), ...
                'Required', 'cs_cell_size', 'Supply CS_CELL_SIZE.', reference);
            report = addIssue(report, isnan(obj.ccg_max_line), ...
                'Required', 'ccg_max_line', 'Supply CCG_MAX_LINE.', reference);
            report = addIssue(report, isnan(obj.ccg_max_sample), ...
                'Required', 'ccg_max_sample', 'Supply CCG_MAX_SAMPLE.', reference);
            report = addIssue(report, ...
                ~validCloudSensor(obj.ccg_source, true, false), ...
                'CloudSource', 'ccg_source', ...
                'Supply registered comma-separated sensor codes.', reference);
            report = addIssue(report, ...
                ~validCloudSensor(obj.reg_sensor, false, true), ...
                'CloudReference', 'reg_sensor', ...
                'Supply a sensor code or three-digit display level.', ...
                reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode the fixed 60-byte record
            requireValid(obj.validate());
            value = [ ...
                textField(obj.ccg_source, 18) ...
                textField(obj.reg_sensor, 6) ...
                decimalField(obj.origin_line, 7, 0, false) ...
                decimalField(obj.origin_sample, 5, 0, false) ...
                decimalField(obj.as_cell_size, 7, 0, false) ...
                decimalField(obj.cs_cell_size, 5, 0, false) ...
                decimalField(obj.ccg_max_line, 7, 0, false) ...
                decimalField(obj.ccg_max_sample, 5, 0, false)];
        end
    end
end
