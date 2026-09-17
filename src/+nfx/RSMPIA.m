classdef (Sealed) RSMPIA < nfx.TRE
    %RSMPIA - Identify polynomial sections in the original image domain
    %   OBJ = RSMPIA(Name=VALUE) accepts supplied quadratic coefficients,
    %   section counts and section sizes. The total count derives from the
    %   row and column counts and cannot exceed 256. Coordinates refer to
    %   the original full image identified by IID and the common EDITION.
    %
    %   Section sizes may be fractional. Complete-set validation checks them
    %   against RSMIDA's image domain. This class does not fit the model.
    %
    %   See also RSMIDA, RSMPCA, TRE

    properties (Constant)
        cetag = 'RSMPIA'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        r0 {mustBeRSMNumber} = NaN
        rx {mustBeRSMNumber} = NaN
        ry {mustBeRSMNumber} = NaN
        rz {mustBeRSMNumber} = NaN
        rxx {mustBeRSMNumber} = NaN
        rxy {mustBeRSMNumber} = NaN
        rxz {mustBeRSMNumber} = NaN
        ryy {mustBeRSMNumber} = NaN
        ryz {mustBeRSMNumber} = NaN
        rzz {mustBeRSMNumber} = NaN
        c0 {mustBeRSMNumber} = NaN
        cx {mustBeRSMNumber} = NaN
        cy {mustBeRSMNumber} = NaN
        cz {mustBeRSMNumber} = NaN
        cxx {mustBeRSMNumber} = NaN
        cxy {mustBeRSMNumber} = NaN
        cxz {mustBeRSMNumber} = NaN
        cyy {mustBeRSMNumber} = NaN
        cyz {mustBeRSMNumber} = NaN
        czz {mustBeRSMNumber} = NaN
        rnis {mustBeMetadata(rnis,1,256,1)} = NaN
        cnis {mustBeMetadata(cnis,1,256,1)} = NaN
        rssiz {mustBeRSMNumber} = NaN
        cssiz {mustBeRSMNumber} = NaN
    end
    properties (Dependent, SetAccess = private)
        tnis
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable RSMPIA value
            %   [OBJ, OK, STATUS] = nfx.RSMPIA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also RSMPIA, RSMPIA.payload
            arguments
                data
            end
            obj = nfx.RSMPIA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.iid = value;
            end
            [value, reader] = reader.text(40, true, false);
            if reader.ok
                obj.edition = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.r0 = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rx = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.ry = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rxx = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rxy = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rxz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.ryy = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.ryz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rzz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.c0 = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cx = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cy = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cxx = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cxy = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cxz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cyy = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cyz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.czz = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 256, 1, false);
            if reader.ok
                obj.rnis = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 256, 1, false);
            if reader.ok
                obj.cnis = value;
            end
            [~, reader] = reader.take(3);
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rssiz = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cssiz = value;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMPIA());
        end
    end
    methods
        function obj = RSMPIA(options) %#codegen
            %RSMPIA - Construct editable section metadata
            arguments
                options.?nfx.RSMPIA
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'r0'), obj.r0 = options.r0; end
            if isfield(options,'rx'), obj.rx = options.rx; end
            if isfield(options,'ry'), obj.ry = options.ry; end
            if isfield(options,'rz'), obj.rz = options.rz; end
            if isfield(options,'rxx'), obj.rxx = options.rxx; end
            if isfield(options,'rxy'), obj.rxy = options.rxy; end
            if isfield(options,'rxz'), obj.rxz = options.rxz; end
            if isfield(options,'ryy'), obj.ryy = options.ryy; end
            if isfield(options,'ryz'), obj.ryz = options.ryz; end
            if isfield(options,'rzz'), obj.rzz = options.rzz; end
            if isfield(options,'c0'), obj.c0 = options.c0; end
            if isfield(options,'cx'), obj.cx = options.cx; end
            if isfield(options,'cy'), obj.cy = options.cy; end
            if isfield(options,'cz'), obj.cz = options.cz; end
            if isfield(options,'cxx'), obj.cxx = options.cxx; end
            if isfield(options,'cxy'), obj.cxy = options.cxy; end
            if isfield(options,'cxz'), obj.cxz = options.cxz; end
            if isfield(options,'cyy'), obj.cyy = options.cyy; end
            if isfield(options,'cyz'), obj.cyz = options.cyz; end
            if isfield(options,'czz'), obj.czz = options.czz; end
            if isfield(options,'rnis'), obj.rnis = options.rnis; end
            if isfield(options,'cnis'), obj.cnis = options.cnis; end
            if isfield(options,'rssiz'), obj.rssiz = options.rssiz; end
            if isfield(options,'cssiz'), obj.cssiz = options.cssiz; end
        end
        function value = get.tnis(obj) %#codegen
            %get.tnis - Derive the total number of image sections
            value = obj.rnis*obj.cnis;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check coefficients, counts and positive section sizes
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize 591 bytes of section-identification data
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Serialize explicitly ordered quadratic coefficients
            coefficients = [obj.r0 obj.rx obj.ry obj.rz obj.rxx obj.rxy obj.rxz obj.ryy obj.ryz obj.rzz ...
                obj.c0 obj.cx obj.cy obj.cz obj.cxx obj.cxy obj.cxz obj.cyy obj.cyz obj.czz];
            [value,report] = rsmSectionData(obj.iid,obj.edition,coefficients, ...
                obj.rnis,obj.cnis,obj.rssiz,obj.cssiz);
        end
    end
end
