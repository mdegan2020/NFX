classdef (Sealed) RSMParameters
    %RSMParameters - Define the ordered active parameters of an RSM model
    %   P = RSMParameters(Name=VALUE) defines image-space parameters with
    %   APTYP='I' and the XPWRR/YPWRR/ZPWRR and XPWRC/YPWRC/ZPWRC row
    %   vectors. Each corresponding triple identifies one parameter.
    %   Row-coordinate parameters precede column-coordinate parameters.
    %
    %   APTYP='G' instead uses an ordered cell row GSAPID containing the
    %   ground-parameter identifiers, and requires LOCTYP='R'. Supply the
    %   Local rectangular origin and orthonormal right-handed basis for R.
    %   LOCTYP='N' uses normalized image row, image column and height.
    %
    %   A nonempty AEL matrix enables the basis option. Its rows must be
    %   orthonormal, with at most 36 rows, 99 columns and 1296 elements.
    %   Columns correspond to the supplied parameter order; rows define
    %   the active parameter order. AEL serializes in row-major order.
    %   No basis fitting or parameter adjustment occurs in this class.
    %
    %   See also RSMAPB, RSMDCB, RSMECB

    properties
        aptyp {mustBeAscii(aptyp,1)} = 'I'
        loctyp {mustBeAscii(loctyp,1)} = 'N'
        nsfx {mustBeRSMNumber} = NaN
        nsfy {mustBeRSMNumber} = NaN
        nsfz {mustBeRSMNumber} = NaN
        noffx {mustBeRSMNumber} = NaN
        noffy {mustBeRSMNumber} = NaN
        noffz {mustBeRSMNumber} = NaN
        xuol {mustBeRSMNumber} = NaN
        yuol {mustBeRSMNumber} = NaN
        zuol {mustBeRSMNumber} = NaN
        xuxl {mustBeRSMNumber} = NaN
        xuyl {mustBeRSMNumber} = NaN
        xuzl {mustBeRSMNumber} = NaN
        yuxl {mustBeRSMNumber} = NaN
        yuyl {mustBeRSMNumber} = NaN
        yuzl {mustBeRSMNumber} = NaN
        zuxl {mustBeRSMNumber} = NaN
        zuyl {mustBeRSMNumber} = NaN
        zuzl {mustBeRSMNumber} = NaN
        xpwrr {mustBePowers} = zeros(1,0)
        ypwrr {mustBePowers} = zeros(1,0)
        zpwrr {mustBePowers} = zeros(1,0)
        xpwrc {mustBePowers} = zeros(1,0)
        ypwrc {mustBePowers} = zeros(1,0)
        zpwrc {mustBePowers} = zeros(1,0)
        gsapid {mustBeGroundIDs} = cell(1,0)
        ael {mustBeBasisMatrix} = zeros(0,0)
    end
    properties (Dependent, SetAccess = private)
        npar
        apbase
        nisap
        nisapr
        nisapc
        ngsap
        nbasis
    end
    methods
        function obj = RSMParameters(options) %#codegen
            %RSMParameters - Construct value metadata for reusable definitions
            arguments
                options.?nfx.RSMParameters
            end
            if isfield(options,'aptyp'), obj.aptyp = options.aptyp; end
            if isfield(options,'loctyp'), obj.loctyp = options.loctyp; end
            if isfield(options,'nsfx'), obj.nsfx = options.nsfx; end
            if isfield(options,'nsfy'), obj.nsfy = options.nsfy; end
            if isfield(options,'nsfz'), obj.nsfz = options.nsfz; end
            if isfield(options,'noffx'), obj.noffx = options.noffx; end
            if isfield(options,'noffy'), obj.noffy = options.noffy; end
            if isfield(options,'noffz'), obj.noffz = options.noffz; end
            if isfield(options,'xuol'), obj.xuol = options.xuol; end
            if isfield(options,'yuol'), obj.yuol = options.yuol; end
            if isfield(options,'zuol'), obj.zuol = options.zuol; end
            if isfield(options,'xuxl'), obj.xuxl = options.xuxl; end
            if isfield(options,'xuyl'), obj.xuyl = options.xuyl; end
            if isfield(options,'xuzl'), obj.xuzl = options.xuzl; end
            if isfield(options,'yuxl'), obj.yuxl = options.yuxl; end
            if isfield(options,'yuyl'), obj.yuyl = options.yuyl; end
            if isfield(options,'yuzl'), obj.yuzl = options.yuzl; end
            if isfield(options,'zuxl'), obj.zuxl = options.zuxl; end
            if isfield(options,'zuyl'), obj.zuyl = options.zuyl; end
            if isfield(options,'zuzl'), obj.zuzl = options.zuzl; end
            if isfield(options,'xpwrr'), obj.xpwrr = options.xpwrr; end
            if isfield(options,'ypwrr'), obj.ypwrr = options.ypwrr; end
            if isfield(options,'zpwrr'), obj.zpwrr = options.zpwrr; end
            if isfield(options,'xpwrc'), obj.xpwrc = options.xpwrc; end
            if isfield(options,'ypwrc'), obj.ypwrc = options.ypwrc; end
            if isfield(options,'zpwrc'), obj.zpwrc = options.zpwrc; end
            if isfield(options,'gsapid'), obj.gsapid = options.gsapid; end
            if isfield(options,'ael'), obj.ael = options.ael; end
        end
        function value = get.npar(obj) %#codegen
            %get.npar - Derive the active parameter count
            if isempty(obj.ael)
                if strcmp(obj.aptyp,'I'), value = obj.nisap; else, value = obj.ngsap; end
            else, value = size(obj.ael,1);
            end
        end
        function value = get.apbase(obj) %#codegen
            %get.apbase - Derive whether a basis mapping is supplied
            if isempty(obj.ael), value = 'N'; else, value = 'Y'; end
        end
        function value = get.nisap(obj) %#codegen
            %get.nisap - Derive the number of specified image parameters
            value = obj.nisapr+obj.nisapc;
        end
        function value = get.nisapr(obj) %#codegen
            %get.nisapr - Derive the row-coordinate parameter count
            value = numel(obj.xpwrr);
        end
        function value = get.nisapc(obj) %#codegen
            %get.nisapc - Derive the column-coordinate parameter count
            value = numel(obj.xpwrc);
        end
        function value = get.ngsap(obj) %#codegen
            %get.ngsap - Derive the ground-parameter count
            value = numel(obj.gsapid);
        end
        function value = get.nbasis(obj) %#codegen
            %get.nbasis - Derive the number of basis parameters
            value = size(obj.ael,2);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check ordered identifiers, frames and basis mappings
            [~,report] = encode(obj);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize NPAR and its complete conditional definition
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Use one layout for adjustment and both covariance TREs
            value = zeros(1,0,'uint8'); report = newReport('RSM parameter definitions');
            imageType = strcmp(obj.aptyp,'I'); groundType = strcmp(obj.aptyp,'G');
            rectangular = strcmp(obj.loctyp,'R'); nonrectangular = strcmp(obj.loctyp,'N');
            report = rsmIssue(report,~(imageType || groundType) || ~(rectangular || nonrectangular) || ...
                (groundType && ~rectangular),'ParameterType','aptyp/loctyp', ...
                'Choose image or ground parameters; ground parameters require Local rectangular coordinates.');
            scales = [obj.nsfx obj.nsfy obj.nsfz];
            [normalization,ok] = rsmNumbers([scales obj.noffx obj.noffy obj.noffz],false);
            report = rsmIssue(report,~ok || any(scales == 0),'Normalization','nsfx...noffz', ...
                'Supply three nonzero normalization scales and three known offsets.');
            frame = [obj.xuol obj.yuol obj.zuol obj.xuxl obj.xuyl obj.xuzl ...
                obj.yuxl obj.yuyl obj.yuzl obj.zuxl obj.zuyl obj.zuzl];
            frameBytes = zeros(1,0,'uint8');
            if rectangular
                [frameBytes,ok,rounded] = rsmNumbers(frame,false);
                ok = ok && rsmOrthonormal(reshape(frame(4:12),3,3),true) && ...
                    rsmOrthonormal(reshape(rounded(4:12),3,3),true);
                report = rsmIssue(report,~ok,'LocalFrame','xuol...zuzl', ...
                    'Supply a known origin and an orthonormal right-handed basis with components in [-1,1].');
            else
                report = rsmIssue(report,any(~isnan(frame)),'UnusedLocalFrame','xuol...zuzl', ...
                    'Leave Local rectangular frame fields unset for non-rectangular coordinates.');
            end
            rowLengths = [numel(obj.xpwrr) numel(obj.ypwrr) numel(obj.zpwrr)];
            colLengths = [numel(obj.xpwrc) numel(obj.ypwrc) numel(obj.zpwrc)];
            report = rsmIssue(report,any(rowLengths ~= rowLengths(1)) || any(colLengths ~= colLengths(1)), ...
                'PowerCount','xpwrr...zpwrc','Each row or column power vector must have the same number of elements.');
            if ~report.valid, return; end
            identifierBytes = zeros(1,0,'uint8'); suppliedCount = 0;
            if imageType
                suppliedCount = obj.nisap;
                triplesR = [obj.xpwrr;obj.ypwrr;obj.zpwrr]; triplesC = [obj.xpwrc;obj.ypwrc;obj.zpwrc];
                report = rsmIssue(report,obj.ngsap ~= 0,'UnusedGroundParameters','gsapid','Leave ground identifiers empty for image-space parameters.');
                report = rsmIssue(report,size(unique(triplesR','rows'),1) ~= obj.nisapr || ...
                    size(unique(triplesC','rows'),1) ~= obj.nisapc,'DuplicateParameter','powers', ...
                    'Each power triple must identify a unique parameter within its row or column group.');
                identifierBytes = [uint8(sprintf('%02.0f%02.0f',obj.nisap,obj.nisapr)) ...
                    uint8(sprintf('%.0f',triplesR)) uint8(sprintf('%02.0f',obj.nisapc)) uint8(sprintf('%.0f',triplesC))];
            elseif groundType
                suppliedCount = obj.ngsap;
                report = rsmIssue(report,any([rowLengths colLengths] ~= 0),'UnusedImageParameters','powers', ...
                    'Leave image-coordinate power vectors empty for ground-space parameters.');
                report = rsmIssue(report,numel(unique(obj.gsapid)) ~= obj.ngsap, ...
                    'DuplicateParameter','gsapid','Each ground-space parameter identifier must be unique.');
                identifierBytes = uint8(sprintf('%02.0f',obj.ngsap));
                for k = 1:obj.ngsap, identifierBytes = [identifierBytes uint8(obj.gsapid{k})]; end %#ok<AGROW>
            end
            report = rsmIssue(report,obj.npar < 1 || obj.npar > 36 || suppliedCount < 1 || suppliedCount > 99, ...
                'ParameterCount','parameters','Supply 1 to 36 active parameters and at most 99 basis parameters.');
            basisBytes = zeros(1,0,'uint8');
            if ~isempty(obj.ael)
                [matrixBytes,ok,rounded] = rsmNumbers(obj.ael',false);
                ok = ok && obj.nbasis == suppliedCount && obj.npar <= obj.nbasis && ...
                    rsmOrthonormal(obj.ael,false) && rsmOrthonormal(rounded',false);
                report = rsmIssue(report,~ok,'BasisMatrix','ael', ...
                    'The supplied matrix must have orthonormal rows and one column per specified parameter.');
                basisBytes = [uint8(sprintf('%02.0f',obj.nbasis)) matrixBytes];
            end
            if ~report.valid, return; end
            value = [uint8(sprintf('%02.0f',obj.npar)) uint8(char(obj.aptyp)) uint8(char(obj.loctyp)) ...
                normalization frameBytes uint8(obj.apbase) identifierBytes basisBytes];
        end
    end
end

function mustBePowers(value) %#codegen
    %mustBePowers - Require ordered ordinary double exponent vectors
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 99 || ...
            any(~isfinite(value) | value < 0 | value > 5 | fix(value) ~= value)
        error('nfx:RSMPowers','Supply a double row of up to 99 integer powers from zero through five.');
    end
end

function mustBeGroundIDs(value) %#codegen
    %mustBeGroundIDs - Validate the sixteen defined ground-space identifiers
    allowed = {'OFFX','OFFY','OFFZ','ROTX','ROTY','ROTZ','SCAL', ...
        'XRTX','XRTY','XRTZ','YRTX','YRTY','YRTZ','ZRTX','ZRTY','ZRTZ'};
    if ~iscell(value) || ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 16
        error('nfx:RSMGroundIDs','Supply a cell row of up to sixteen four-character ground parameter identifiers.');
    end
    for k = 1:numel(value)
        if ~ischar(value{k}) || ~isrow(value{k}) || ~any(strcmp(value{k},allowed))
            error('nfx:RSMGroundIDs','Use a defined four-character ground parameter identifier.');
        end
    end
end

function mustBeBasisMatrix(value) %#codegen
    %mustBeBasisMatrix - Limit supplied matrices without implicit coercion
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ~ismatrix(value) || ...
            size(value,1) > 36 || size(value,2) > 99 || numel(value) > 1296 || ...
            (isempty(value) && ~isequal(size(value),[0 0])) || any(~isfinite(value(:)))
        error('nfx:RSMBasis','Supply an empty matrix or a full finite double matrix with at most 36 rows, 99 columns and 1296 elements.');
    end
end
