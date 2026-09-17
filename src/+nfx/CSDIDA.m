classdef (Sealed) CSDIDA < nfx.TRE
    %CSDIDA - Dataset identification and processing history
    %   OBJ = CSDIDA(Name=VALUE) supplies platform, collection, product, and
    %   processing metadata. DAY, MONTH, and YEAR derive from TIME, which
    %   requires a known collection date; unknown time-of-day pairs may use --.
    %   Code validation uses the published Appendix AS platform/sensor values.
    %
    %   See also TRE, File

    properties (Constant)
        cetag = 'CSDIDA'
    end
    properties
        platform_code {mustBeAscii(platform_code, 2)} = ''
        vehicle_id {mustBeMetadata(vehicle_id, 0, 99, 1), mustBeFinite} = 0
        pass {mustBeMetadata(pass, 0, 99, 1), mustBeFinite} = 0
        operation {mustBeMetadata(operation, 0, 999, 1), mustBeFinite} = 0
        sensor_id {mustBeAscii(sensor_id, 2)} = ''
        product_id {mustBeAscii(product_id, 2)} = ''
        time {mustBeAscii(time, 14)} = ''
        process_time {mustBeAscii(process_time, 14)} = ''
        software_version_number {mustBeAscii(software_version_number, 10)} = ''
    end
    properties (Dependent, SetAccess = private)
        day
        month
        year
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable CSDIDA value
            %   [OBJ, OK, STATUS] = nfx.CSDIDA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also CSDIDA, CSDIDA.payload
            arguments
                data
            end
            obj = nfx.CSDIDA();
            reader = nfx.internal.TREReader(data);
            [~, reader] = reader.take(9);
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.platform_code = value;
            end
            [value, reader] = reader.number( ...
                2, 0, 99, 1, false);
            if reader.ok
                obj.vehicle_id = value;
            end
            [value, reader] = reader.number( ...
                2, 0, 99, 1, false);
            if reader.ok
                obj.pass = value;
            end
            [value, reader] = reader.number( ...
                3, 0, 999, 1, false);
            if reader.ok
                obj.operation = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.sensor_id = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.product_id = value;
            end
            reader = reader.literal('0000');
            [value, reader] = reader.text(14, true, false);
            if reader.ok
                obj.time = value;
            end
            [value, reader] = reader.text(14, true, false);
            if reader.ok
                obj.process_time = value;
            end
            reader = reader.literal('0001NN');
            [value, reader] = reader.text(10, true, false);
            if reader.ok
                obj.software_version_number = value;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSDIDA());
        end
    end
    methods
        function obj = CSDIDA(options) %#codegen
            %CSDIDA - Construct editable dataset identification metadata
            arguments
                options.?nfx.CSDIDA
            end
            if isfield(options, 'platform_code'), obj.platform_code = options.platform_code; end
            if isfield(options, 'vehicle_id'), obj.vehicle_id = options.vehicle_id; end
            if isfield(options, 'pass'), obj.pass = options.pass; end
            if isfield(options, 'operation'), obj.operation = options.operation; end
            if isfield(options, 'sensor_id'), obj.sensor_id = options.sensor_id; end
            if isfield(options, 'product_id'), obj.product_id = options.product_id; end
            if isfield(options, 'time'), obj.time = options.time; end
            if isfield(options, 'process_time'), obj.process_time = options.process_time; end
            if isfield(options, 'software_version_number'), obj.software_version_number = options.software_version_number; end
        end
        function value = get.day(obj) %#codegen
            %get.day - Derive the collection day from TIME
            value = datePart(obj.time, 7, 2);
        end
        function value = get.month(obj) %#codegen
            %get.month - Derive the uppercase three-letter month
            index = datePart(obj.time, 5, 2);
            value = '';
            if isfinite(index) && index >= 1 && index <= 12 && fix(index) == index
                months = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC';
                value = months(3*index-2:3*index);
            end
        end
        function value = get.year(obj) %#codegen
            %get.year - Derive the four-digit collection year
            value = datePart(obj.time, 1, 4);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check published code values and identification metadata
            report = newReport('STDI-0002 Appendix AS CSDIDA');
            reference = 'STDI-0002-1 Appendix AS, AS5.2 and Table AS.5-9';
            platforms = {'DC','DR','DS','GE','GL','IK','LG','OV','QB','SK','WV','HP','GT','9I','AU'};
            sensors = {'AA','CA','EO','GA','HO','HP','IR','LW','MW','NA','NR','SW','UV','VN','VS'};
            report = addIssue(report, ~any(strcmp(obj.platform_code, platforms)), 'PlatformCode', ...
                'platform_code', 'Use a published Appendix AS platform code; additional registered values need verification.', reference);
            report = addIssue(report, ~any(strcmp(obj.sensor_id, sensors)), 'SensorCode', ...
                'sensor_id', 'Use a published Appendix AS sensor code.', reference);
            product = char(obj.product_id);
            report = addIssue(report, numel(product) ~= 2 || ...
                ~any(product(1) == 'PGRM') || ~any(product(2) == '12345'), ...
                'ProductCode', 'product_id', 'Use a rectification letter P/G/R/M and sensor type 1 through 5.', reference);
            report = addIssue(report, ~validDate(obj.time) || isnan(obj.day) || ...
                isempty(obj.month) || isnan(obj.year), 'Date', 'time', ...
                'Supply a valid UTC timestamp with a known collection date.', reference);
            report = addIssue(report, ~validDate(obj.process_time), 'Date', 'process_time', ...
                'Supply a valid processing UTC timestamp, with -- for unknown pairs.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.software_version_number))), ...
                'Required', 'software_version_number', 'Identify the software that created the dataset.', reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode the fixed 70-byte dataset identifier
            requireValid(validate(obj));
            value = [decimalField(obj.day, 2, 0, false) textField(obj.month, 3) ...
                decimalField(obj.year, 4, 0, false) textField(obj.platform_code, 2) ...
                decimalField(obj.vehicle_id, 2, 0, false) decimalField(obj.pass, 2, 0, false) ...
                decimalField(obj.operation, 3, 0, false) textField(obj.sensor_id, 2) ...
                textField(obj.product_id, 2) uint8('0000') textField(obj.time, 14) ...
                textField(obj.process_time, 14) uint8('0001NN') textField(obj.software_version_number, 10)];
        end
    end
end

function value = datePart(timestamp, first, count) %#codegen
    %datePart - Extract a numeric calendar field without inventing unknowns
    timestamp = char(timestamp);
    value = NaN;
    if numel(timestamp) == 14
        value = str2double(timestamp(first:first+count-1));
    end
end
