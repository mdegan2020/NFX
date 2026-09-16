classdef (Sealed) RSMGIA < nfx.TRE
    %RSMGIA - Identify grid sections in the original image domain
    %   OBJ = RSMGIA(Name=VALUE) accepts supplied quadratic coefficients,
    %   section counts and section sizes. The total count derives from the
    %   row and column counts and cannot exceed 256. Coordinates refer to
    %   the original full image identified by IID and the common EDITION.
    %
    %   Section sizes may be fractional. Complete-set validation checks them
    %   against RSMIDA's image domain. This class does not fit the model.
    %
    %   See also RSMIDA, RSMGGA, TRE

    properties (Constant)
        cetag = 'RSMGIA'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        gr0 {mustBeRSMNumber} = NaN
        grx {mustBeRSMNumber} = NaN
        gry {mustBeRSMNumber} = NaN
        grz {mustBeRSMNumber} = NaN
        grxx {mustBeRSMNumber} = NaN
        grxy {mustBeRSMNumber} = NaN
        grxz {mustBeRSMNumber} = NaN
        gryy {mustBeRSMNumber} = NaN
        gryz {mustBeRSMNumber} = NaN
        grzz {mustBeRSMNumber} = NaN
        gc0 {mustBeRSMNumber} = NaN
        gcx {mustBeRSMNumber} = NaN
        gcy {mustBeRSMNumber} = NaN
        gcz {mustBeRSMNumber} = NaN
        gcxx {mustBeRSMNumber} = NaN
        gcxy {mustBeRSMNumber} = NaN
        gcxz {mustBeRSMNumber} = NaN
        gcyy {mustBeRSMNumber} = NaN
        gcyz {mustBeRSMNumber} = NaN
        gczz {mustBeRSMNumber} = NaN
        grnis {mustBeMetadata(grnis,1,256,1)} = NaN
        gcnis {mustBeMetadata(gcnis,1,256,1)} = NaN
        grssiz {mustBeRSMNumber} = NaN
        gcssiz {mustBeRSMNumber} = NaN
    end
    properties (Dependent, SetAccess = private)
        gtnis
    end
    methods
        function obj = RSMGIA(options) %#codegen
            %RSMGIA - Construct editable section metadata
            arguments
                options.?nfx.RSMGIA
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'gr0'), obj.gr0 = options.gr0; end
            if isfield(options,'grx'), obj.grx = options.grx; end
            if isfield(options,'gry'), obj.gry = options.gry; end
            if isfield(options,'grz'), obj.grz = options.grz; end
            if isfield(options,'grxx'), obj.grxx = options.grxx; end
            if isfield(options,'grxy'), obj.grxy = options.grxy; end
            if isfield(options,'grxz'), obj.grxz = options.grxz; end
            if isfield(options,'gryy'), obj.gryy = options.gryy; end
            if isfield(options,'gryz'), obj.gryz = options.gryz; end
            if isfield(options,'grzz'), obj.grzz = options.grzz; end
            if isfield(options,'gc0'), obj.gc0 = options.gc0; end
            if isfield(options,'gcx'), obj.gcx = options.gcx; end
            if isfield(options,'gcy'), obj.gcy = options.gcy; end
            if isfield(options,'gcz'), obj.gcz = options.gcz; end
            if isfield(options,'gcxx'), obj.gcxx = options.gcxx; end
            if isfield(options,'gcxy'), obj.gcxy = options.gcxy; end
            if isfield(options,'gcxz'), obj.gcxz = options.gcxz; end
            if isfield(options,'gcyy'), obj.gcyy = options.gcyy; end
            if isfield(options,'gcyz'), obj.gcyz = options.gcyz; end
            if isfield(options,'gczz'), obj.gczz = options.gczz; end
            if isfield(options,'grnis'), obj.grnis = options.grnis; end
            if isfield(options,'gcnis'), obj.gcnis = options.gcnis; end
            if isfield(options,'grssiz'), obj.grssiz = options.grssiz; end
            if isfield(options,'gcssiz'), obj.gcssiz = options.gcssiz; end
        end
        function value = get.gtnis(obj) %#codegen
            %get.gtnis - Derive the total number of image sections
            value = obj.grnis*obj.gcnis;
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
            coefficients = [obj.gr0 obj.grx obj.gry obj.grz obj.grxx obj.grxy obj.grxz obj.gryy obj.gryz obj.grzz ...
                obj.gc0 obj.gcx obj.gcy obj.gcz obj.gcxx obj.gcxy obj.gcxz obj.gcyy obj.gcyz obj.gczz];
            [value,report] = rsmSectionData(obj.iid,obj.edition,coefficients, ...
                obj.grnis,obj.gcnis,obj.grssiz,obj.gcssiz);
        end
    end
end
