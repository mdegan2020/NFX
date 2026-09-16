classdef DESSegment
    %DESSegment - Supplied DES bytes with a typed NITF container header
    %   OBJ = DESSegment(DATA,header=HEADER) captures uint8 row DATA without
    %   conversion. Callers are responsible for its declared DES format;
    %   generic validation checks header structure and byte limits.
    %
    %   TRE_OVERFLOW records are created automatically by File.
    %
    %   See also DESHeader, File

    properties
        data {mustBeByteRow} = zeros(1, 0, 'uint8')
        header (1,1) nfx.DESHeader = nfx.DESHeader()
    end
    properties (Dependent, SetAccess = private)
        ld % Payload length
        ldsh % Subheader length
    end
    properties (Access = private)
        sensorVerified = false
        sensorData = zeros(1,0,'uint8')
        sensorHeader = nfx.DESHeader()
    end
    methods
        function obj = DESSegment(data, options) %#codegen
            %DESSegment - Construct supplied support-data bytes
            arguments
                data {mustBeByteRow} = zeros(1, 0, 'uint8')
                options.header (1,1) nfx.DESHeader = nfx.DESHeader()
            end
            obj.data = data;
            obj.header = options.header;
        end
        function value = get.ld(obj) %#codegen
            %get.ld - Derive payload length
            value = numel(obj.data);
        end
        function value = get.ldsh(obj) %#codegen
            %get.ldsh - Derive the subheader length
            value = obj.header.ldsh;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the generic DES container and length fields
            report = newReport('NITF 2.1 DES segment');
            report = mergeReport(report, validate(obj.header), 'header.');
            report = addIssue(report, obj.ld < 1 || obj.ld > 999999998, 'DESLength', ...
                'data', 'DES payload must contain 1 to 999999998 bytes.', 'JBP 2025.1, Table 5.11-1');
            report = addIssue(report,obj.sensorVerified && ~obj.verifiedSensor(), ...
                'TypedDESChanged','data/header','Edit the typed sensor descriptor and capture a new segment after changing its bytes.', ...
                'NFX typed GLAS/GFM DES snapshot contract');
        end
        function value = verifiedSensor(obj) %#codegen
            %VERIFIEDSENSOR - Check that the typed serializer's proof is current
            value = obj.sensorVerified && isequal(obj.data,obj.sensorData) && isequal(obj.header,obj.sensorHeader);
        end
    end
    methods (Static, Access = ?nfx.SensorDES)
        function obj = fromSensor(data,header) %#codegen
            %fromSensor - Preserve the exact bytes validated by a typed model
            obj = nfx.DESSegment(data,header=header);
            obj.sensorVerified = true; obj.sensorData = data; obj.sensorHeader = header;
        end
    end
    methods (Static, Access = ?nfx.File)
        function obj = overflow(data, owner, item) %#codegen
            %OVERFLOW - Construct a file-owned whole-TRE overflow segment
            h = nfx.DESHeader(desid='TRE_OVERFLOW', desclas='U');
            h.desoflw = owner;
            h.desitem = item;
            obj = nfx.DESSegment(data, header=h);
        end
    end
end
