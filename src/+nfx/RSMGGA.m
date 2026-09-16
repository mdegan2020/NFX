classdef (Sealed) RSMGGA < nfx.TRE
    %RSMGGA - Describe a supplied ground-to-image grid for one image section
    %   OBJ = RSMGGA(Name=VALUE) accepts a row of PLANES constructed with
    %   nfx.RSMGGA.plane. Each RCOORD and CCOORD matrix is X-by-Y and holds
    %   nonnegative offsets in pixels from REFROW and REFCOL. Use NaN for
    %   unavailable values. The encoded grid varies Y fastest, then X.
    %
    %   FNUMRD and FNUMCD select one to three fractional digits. Values are
    %   rounded to that precision; field widths and counts derive from the
    %   rounded data. IXO and IYO specify integer spacing offsets from the
    %   first plane, whose offsets must be zero. Plane shapes may differ.
    %
    %   This class writes supplied grids without interpolation or fitting.
    %   When polynomial sections are also supplied, grid values represent
    %   corrections to those polynomials. Payloads cannot exceed 99985
    %   bytes; supply separate image sections when a grid is too large.
    %
    %   See also RSMIDA, RSMGIA, RSMPCA, TRE

    properties (Constant)
        cetag = 'RSMGGA'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        ggrsn {mustBeMetadata(ggrsn,1,256,1)} = NaN
        ggcsn {mustBeMetadata(ggcsn,1,256,1)} = NaN
        ggrfep {mustBeRSMNumber} = NaN
        ggcfep {mustBeRSMNumber} = NaN
        intord {mustBeMetadata(intord,0,3,1)} = NaN
        deltaz {mustBeRSMNumber} = NaN
        deltax {mustBeRSMNumber} = NaN
        deltay {mustBeRSMNumber} = NaN
        zpln1 {mustBeRSMNumber} = NaN
        xipln1 {mustBeRSMNumber} = NaN
        yipln1 {mustBeRSMNumber} = NaN
        refrow {mustBeMetadata(refrow,-99999999,99999999,1)} = NaN
        refcol {mustBeMetadata(refcol,-99999999,99999999,1)} = NaN
        fnumrd {mustBeMetadata(fnumrd,1,3,1)} = 3
        fnumcd {mustBeMetadata(fnumcd,1,3,1)} = 3
        planes {mustBeRSMPlanes} = struct('ixo',{},'iyo',{},'rcoord',{},'ccoord',{})
    end
    properties (Dependent, SetAccess = private)
        npln
        tnumrd
        tnumcd
    end
    methods
        function obj = RSMGGA(options) %#codegen
            %RSMGGA - Construct editable grid metadata
            arguments
                options.?nfx.RSMGGA
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'ggrsn'), obj.ggrsn = options.ggrsn; end
            if isfield(options,'ggcsn'), obj.ggcsn = options.ggcsn; end
            if isfield(options,'ggrfep'), obj.ggrfep = options.ggrfep; end
            if isfield(options,'ggcfep'), obj.ggcfep = options.ggcfep; end
            if isfield(options,'intord'), obj.intord = options.intord; end
            if isfield(options,'deltaz'), obj.deltaz = options.deltaz; end
            if isfield(options,'deltax'), obj.deltax = options.deltax; end
            if isfield(options,'deltay'), obj.deltay = options.deltay; end
            if isfield(options,'zpln1'), obj.zpln1 = options.zpln1; end
            if isfield(options,'xipln1'), obj.xipln1 = options.xipln1; end
            if isfield(options,'yipln1'), obj.yipln1 = options.yipln1; end
            if isfield(options,'refrow'), obj.refrow = options.refrow; end
            if isfield(options,'refcol'), obj.refcol = options.refcol; end
            if isfield(options,'fnumrd'), obj.fnumrd = options.fnumrd; end
            if isfield(options,'fnumcd'), obj.fnumcd = options.fnumcd; end
            if isfield(options,'planes'), obj.planes = options.planes; end
        end
        function value = get.npln(obj) %#codegen
            %get.npln - Derive the grid plane count
            value = numel(obj.planes);
        end
        function value = get.tnumrd(obj) %#codegen
            %get.tnumrd - Derive the row-coordinate digit count
            value = rsmGridWidth(obj.planes,obj.fnumrd,true);
        end
        function value = get.tnumcd(obj) %#codegen
            %get.tnumcd - Derive the column-coordinate digit count
            value = rsmGridWidth(obj.planes,obj.fnumcd,false);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check grid geometry, precision, counts and byte limits
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize plane offsets followed by grid point pairs
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Static)
        function value = plane(rcoord,ccoord,options) %#codegen
            %PLANE - Construct X-by-Y pixel-offset arrays for one grid plane
            %   P = nfx.RSMGGA.plane(RCOORD,CCOORD,ixo=I,iyo=J) preserves
            %   double arrays and offsets. I and J default to zero.
            arguments
                rcoord
                ccoord
                options.ixo = 0
                options.iyo = 0
            end
            value = struct('ixo',options.ixo,'iyo',options.iyo, ...
                'rcoord',rcoord,'ccoord',ccoord);
            mustBeRSMPlanes(value);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Allocate only a fully validated bounded payload
            value = zeros(1,0,'uint8'); report = newReport('RSM ground-to-image grid');
            report = rsmIssue(report,isempty(strtrim(char(obj.edition))) || ...
                any(isnan([obj.ggrsn obj.ggcsn obj.refrow obj.refcol obj.fnumrd obj.fnumcd])), ...
                'Required','grid','Supply edition, section numbers, references and fractional digit counts.');
            [fit,ok] = rsmNumbers([obj.ggrfep obj.ggcfep],true);
            report = rsmIssue(report,~ok || obj.ggrfep < 0 || obj.ggcfep < 0 || ...
                (isnan(obj.intord) && any(~isnan([obj.ggrfep obj.ggcfep]))), ...
                'FittingError','ggrfep/ggcfep/intord','Fitting errors must be nonnegative and require an interpolation order.');
            geometry = [obj.deltaz obj.deltax obj.deltay obj.zpln1 obj.xipln1 obj.yipln1];
            [geometryBytes,ok] = rsmNumbers(geometry,false);
            report = rsmIssue(report,~ok || any(geometry(1:3) <= 0), ...
                'GridGeometry','geometry','Supply known initial coordinates and positive grid spacings.');
            report = rsmIssue(report,obj.npln < 2,'PlaneCount','planes','Supply at least two grid planes.');
            if ~report.valid, return; end
            [rowWidth,rowOK] = rsmGridWidth(obj.planes,obj.fnumrd,true);
            [colWidth,colOK] = rsmGridWidth(obj.planes,obj.fnumcd,false);
            report = rsmIssue(report,~rowOK || ~colOK,'GridPrecision','rcoord/ccoord', ...
                'Rounded nonnegative coordinate offsets must fit at most eleven digits.');
            report = rsmIssue(report,obj.planes(1).ixo ~= 0 || obj.planes(1).iyo ~= 0, ...
                'InitialPlaneOffset','planes(1)','The first plane has zero X and Y spacing offsets.');
            points = 0;
            for k = 1:obj.npln
                planeData = obj.planes(k); points = points+numel(planeData.rcoord);
                report = rsmIssue(report,any(isnan([planeData.ixo planeData.iyo])), ...
                    'PlaneOffset','planes','All plane spacing offsets must be known integers.');
            end
            length = 314+14*obj.npln+(rowWidth+colWidth)*points;
            report = rsmIssue(report,length > 99985,'GridLength','planes', ...
                'A complete grid payload must fit 99985 bytes; partition the supplied model into sections.');
            if ~report.valid, return; end
            value = zeros(1,length,'uint8');
            value(1:322) = [textField(obj.iid,80) textField(obj.edition,40) ...
                uint8(sprintf('%03.0f%03.0f',obj.ggrsn,obj.ggcsn)) fit ...
                rsmInteger(obj.intord,1,true,false) uint8(sprintf('%03.0f',obj.npln)) geometryBytes ...
                uint8(sprintf('%+09.0f%+09.0f%02.0f%02.0f%.0f%.0f', ...
                obj.refrow,obj.refcol,rowWidth,colWidth,obj.fnumrd,obj.fnumcd))];
            at = 322;
            for k = 2:obj.npln
                value(at+(1:8)) = uint8(sprintf('%+04.0f%+04.0f',obj.planes(k).ixo,obj.planes(k).iyo)); at = at+8;
            end
            for k = 1:obj.npln
                planeData = obj.planes(k);
                value(at+(1:6)) = uint8(sprintf('%03.0f%03.0f',size(planeData.rcoord))); at = at+6;
                for x = 1:size(planeData.rcoord,1)
                    for y = 1:size(planeData.rcoord,2)
                        value(at+(1:rowWidth)) = rsmInteger(round(planeData.rcoord(x,y)*10^obj.fnumrd),rowWidth,true,false);
                        at = at+rowWidth;
                        value(at+(1:colWidth)) = rsmInteger(round(planeData.ccoord(x,y)*10^obj.fnumcd),colWidth,true,false);
                        at = at+colWidth;
                    end
                end
            end
        end
    end
end

function mustBeRSMPlanes(value) %#codegen
    %mustBeRSMPlanes - Require concrete plane structs with matching matrices
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || numel(value) > 999 || ...
            ~all(isfield(value,{'ixo','iyo','rcoord','ccoord'})) || numel(fieldnames(value)) ~= 4
        error('nfx:RSMPlanes','Supply up to 999 ixo/iyo/rcoord/ccoord row structs.');
    end
    for k = 1:numel(value)
        mustBeMetadata(value(k).ixo,-999,999,true); mustBeMetadata(value(k).iyo,-999,999,true);
        mustBeGridMatrix(value(k).rcoord); mustBeGridMatrix(value(k).ccoord);
        if ~isequal(size(value(k).rcoord),size(value(k).ccoord))
            error('nfx:RSMGridShape','Row and column coordinate arrays must have matching shapes.');
        end
    end
end

function mustBeGridMatrix(value) %#codegen
    %mustBeGridMatrix - Preserve full double matrices and explicit unknowns
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ~ismatrix(value) || ...
            any(size(value) < 2 | size(value) > 999) || any(isinf(value(:))) || any(value(:) < 0)
        error('nfx:RSMGridMatrix','Supply a full real double X-by-Y matrix, 2 to 999 points per axis, with nonnegative offsets or NaN.');
    end
end

function [width,valid] = rsmGridWidth(planes,fraction,row) %#codegen
    %rsmGridWidth - Derive widths after quantization, including carry digits
    width = 3; valid = isfinite(fraction);
    if ~valid, return; end
    maximum = 0;
    for k = 1:numel(planes)
        if row, values = planes(k).rcoord; else, values = planes(k).ccoord; end
        known = values(~isnan(values));
        if ~isempty(known), maximum = max(maximum,max(round(known*10^fraction))); end
    end
    valid = maximum < 1e11;
    while width < 11 && maximum >= 10^width, width = width+1; end
end
