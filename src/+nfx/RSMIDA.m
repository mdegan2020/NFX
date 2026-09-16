classdef (Sealed) RSMIDA < nfx.TRE
    %RSMIDA - Identify an RSM set and its original image and ground domains
    %   OBJ = RSMIDA(Name=VALUE) accepts specification-mnemonic metadata.
    %   GRNDD selects geographic G/H or local rectangular R coordinates.
    %   Geographic X is longitude in radians, Y is latitude in radians,
    %   and Z is ellipsoidal height in meters. H uses longitudes 0 to 2*pi.
    %
    %   Supply vertices V1X through V8Z in the standard's hexahedron order,
    %   the original-image domain MINR/MAXR/MINC/MAXC, and common EDITION.
    %   Original-image pixel centers start at row 0, column 0. Geographic
    %   forms leave the rectangular origin/basis fields unset.
    %
    %   NaN encodes an unavailable optional numeric field. Ground reference
    %   and illumination models are optional complete groups. Individual
    %   optional acquisition and trajectory fields retain their unknowns.
    %
    %   See also RSMPCA, RSMPIA, RSMGGA, TRE

    properties (Constant)
        cetag = 'RSMIDA'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        isid {mustBeAscii(isid,40)} = ''
        sid {mustBeAscii(sid,40)} = ''
        stid {mustBeAscii(stid,40)} = ''
        grndd {mustBeAscii(grndd,1)} = ''
        year {mustBeMetadata(year,0,9999,1)} = NaN
        month {mustBeMetadata(month,1,12,1)} = NaN
        day {mustBeMetadata(day,1,31,1)} = NaN
        hour {mustBeMetadata(hour,0,23,1)} = NaN
        minute {mustBeMetadata(minute,0,59,1)} = NaN
        second {mustBeMetadata(second,0,60.999999,0)} = NaN
        nrg {mustBeMetadata(nrg,1,99999999,1)} = NaN
        ncg {mustBeMetadata(ncg,1,99999999,1)} = NaN
        fullr {mustBeMetadata(fullr,1,99999999,1)} = NaN
        fullc {mustBeMetadata(fullc,1,99999999,1)} = NaN
        minr {mustBeMetadata(minr,0,99999999,1)} = NaN
        maxr {mustBeMetadata(maxr,0,99999999,1)} = NaN
        minc {mustBeMetadata(minc,0,99999999,1)} = NaN
        maxc {mustBeMetadata(maxc,0,99999999,1)} = NaN
        trg {mustBeRSMNumber} = NaN
        tcg {mustBeRSMNumber} = NaN
        xuor {mustBeRSMNumber} = NaN
        yuor {mustBeRSMNumber} = NaN
        zuor {mustBeRSMNumber} = NaN
        xuxr {mustBeRSMNumber} = NaN
        xuyr {mustBeRSMNumber} = NaN
        xuzr {mustBeRSMNumber} = NaN
        yuxr {mustBeRSMNumber} = NaN
        yuyr {mustBeRSMNumber} = NaN
        yuzr {mustBeRSMNumber} = NaN
        zuxr {mustBeRSMNumber} = NaN
        zuyr {mustBeRSMNumber} = NaN
        zuzr {mustBeRSMNumber} = NaN
        v1x {mustBeRSMNumber} = NaN
        v1y {mustBeRSMNumber} = NaN
        v1z {mustBeRSMNumber} = NaN
        v2x {mustBeRSMNumber} = NaN
        v2y {mustBeRSMNumber} = NaN
        v2z {mustBeRSMNumber} = NaN
        v3x {mustBeRSMNumber} = NaN
        v3y {mustBeRSMNumber} = NaN
        v3z {mustBeRSMNumber} = NaN
        v4x {mustBeRSMNumber} = NaN
        v4y {mustBeRSMNumber} = NaN
        v4z {mustBeRSMNumber} = NaN
        v5x {mustBeRSMNumber} = NaN
        v5y {mustBeRSMNumber} = NaN
        v5z {mustBeRSMNumber} = NaN
        v6x {mustBeRSMNumber} = NaN
        v6y {mustBeRSMNumber} = NaN
        v6z {mustBeRSMNumber} = NaN
        v7x {mustBeRSMNumber} = NaN
        v7y {mustBeRSMNumber} = NaN
        v7z {mustBeRSMNumber} = NaN
        v8x {mustBeRSMNumber} = NaN
        v8y {mustBeRSMNumber} = NaN
        v8z {mustBeRSMNumber} = NaN
        grpx {mustBeRSMNumber} = NaN
        grpy {mustBeRSMNumber} = NaN
        grpz {mustBeRSMNumber} = NaN
        ie0 {mustBeRSMNumber} = NaN
        ier {mustBeRSMNumber} = NaN
        iec {mustBeRSMNumber} = NaN
        ierr {mustBeRSMNumber} = NaN
        ierc {mustBeRSMNumber} = NaN
        iecc {mustBeRSMNumber} = NaN
        ia0 {mustBeRSMNumber} = NaN
        iar {mustBeRSMNumber} = NaN
        iac {mustBeRSMNumber} = NaN
        iarr {mustBeRSMNumber} = NaN
        iarc {mustBeRSMNumber} = NaN
        iacc {mustBeRSMNumber} = NaN
        spx {mustBeRSMNumber} = NaN
        svx {mustBeRSMNumber} = NaN
        sax {mustBeRSMNumber} = NaN
        spy {mustBeRSMNumber} = NaN
        svy {mustBeRSMNumber} = NaN
        say {mustBeRSMNumber} = NaN
        spz {mustBeRSMNumber} = NaN
        svz {mustBeRSMNumber} = NaN
        saz {mustBeRSMNumber} = NaN
    end
    methods
        function obj = RSMIDA(options) %#codegen
            %RSMIDA - Construct editable identification and domain metadata
            arguments
                options.?nfx.RSMIDA
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'isid'), obj.isid = options.isid; end
            if isfield(options,'sid'), obj.sid = options.sid; end
            if isfield(options,'stid'), obj.stid = options.stid; end
            if isfield(options,'grndd'), obj.grndd = options.grndd; end
            if isfield(options,'year'), obj.year = options.year; end
            if isfield(options,'month'), obj.month = options.month; end
            if isfield(options,'day'), obj.day = options.day; end
            if isfield(options,'hour'), obj.hour = options.hour; end
            if isfield(options,'minute'), obj.minute = options.minute; end
            if isfield(options,'second'), obj.second = options.second; end
            if isfield(options,'nrg'), obj.nrg = options.nrg; end
            if isfield(options,'ncg'), obj.ncg = options.ncg; end
            if isfield(options,'fullr'), obj.fullr = options.fullr; end
            if isfield(options,'fullc'), obj.fullc = options.fullc; end
            if isfield(options,'minr'), obj.minr = options.minr; end
            if isfield(options,'maxr'), obj.maxr = options.maxr; end
            if isfield(options,'minc'), obj.minc = options.minc; end
            if isfield(options,'maxc'), obj.maxc = options.maxc; end
            if isfield(options,'trg'), obj.trg = options.trg; end
            if isfield(options,'tcg'), obj.tcg = options.tcg; end
            if isfield(options,'xuor'), obj.xuor = options.xuor; end
            if isfield(options,'yuor'), obj.yuor = options.yuor; end
            if isfield(options,'zuor'), obj.zuor = options.zuor; end
            if isfield(options,'xuxr'), obj.xuxr = options.xuxr; end
            if isfield(options,'xuyr'), obj.xuyr = options.xuyr; end
            if isfield(options,'xuzr'), obj.xuzr = options.xuzr; end
            if isfield(options,'yuxr'), obj.yuxr = options.yuxr; end
            if isfield(options,'yuyr'), obj.yuyr = options.yuyr; end
            if isfield(options,'yuzr'), obj.yuzr = options.yuzr; end
            if isfield(options,'zuxr'), obj.zuxr = options.zuxr; end
            if isfield(options,'zuyr'), obj.zuyr = options.zuyr; end
            if isfield(options,'zuzr'), obj.zuzr = options.zuzr; end
            if isfield(options,'v1x'), obj.v1x = options.v1x; end
            if isfield(options,'v1y'), obj.v1y = options.v1y; end
            if isfield(options,'v1z'), obj.v1z = options.v1z; end
            if isfield(options,'v2x'), obj.v2x = options.v2x; end
            if isfield(options,'v2y'), obj.v2y = options.v2y; end
            if isfield(options,'v2z'), obj.v2z = options.v2z; end
            if isfield(options,'v3x'), obj.v3x = options.v3x; end
            if isfield(options,'v3y'), obj.v3y = options.v3y; end
            if isfield(options,'v3z'), obj.v3z = options.v3z; end
            if isfield(options,'v4x'), obj.v4x = options.v4x; end
            if isfield(options,'v4y'), obj.v4y = options.v4y; end
            if isfield(options,'v4z'), obj.v4z = options.v4z; end
            if isfield(options,'v5x'), obj.v5x = options.v5x; end
            if isfield(options,'v5y'), obj.v5y = options.v5y; end
            if isfield(options,'v5z'), obj.v5z = options.v5z; end
            if isfield(options,'v6x'), obj.v6x = options.v6x; end
            if isfield(options,'v6y'), obj.v6y = options.v6y; end
            if isfield(options,'v6z'), obj.v6z = options.v6z; end
            if isfield(options,'v7x'), obj.v7x = options.v7x; end
            if isfield(options,'v7y'), obj.v7y = options.v7y; end
            if isfield(options,'v7z'), obj.v7z = options.v7z; end
            if isfield(options,'v8x'), obj.v8x = options.v8x; end
            if isfield(options,'v8y'), obj.v8y = options.v8y; end
            if isfield(options,'v8z'), obj.v8z = options.v8z; end
            if isfield(options,'grpx'), obj.grpx = options.grpx; end
            if isfield(options,'grpy'), obj.grpy = options.grpy; end
            if isfield(options,'grpz'), obj.grpz = options.grpz; end
            if isfield(options,'ie0'), obj.ie0 = options.ie0; end
            if isfield(options,'ier'), obj.ier = options.ier; end
            if isfield(options,'iec'), obj.iec = options.iec; end
            if isfield(options,'ierr'), obj.ierr = options.ierr; end
            if isfield(options,'ierc'), obj.ierc = options.ierc; end
            if isfield(options,'iecc'), obj.iecc = options.iecc; end
            if isfield(options,'ia0'), obj.ia0 = options.ia0; end
            if isfield(options,'iar'), obj.iar = options.iar; end
            if isfield(options,'iac'), obj.iac = options.iac; end
            if isfield(options,'iarr'), obj.iarr = options.iarr; end
            if isfield(options,'iarc'), obj.iarc = options.iarc; end
            if isfield(options,'iacc'), obj.iacc = options.iacc; end
            if isfield(options,'spx'), obj.spx = options.spx; end
            if isfield(options,'svx'), obj.svx = options.svx; end
            if isfield(options,'sax'), obj.sax = options.sax; end
            if isfield(options,'spy'), obj.spy = options.spy; end
            if isfield(options,'svy'), obj.svy = options.svy; end
            if isfield(options,'say'), obj.say = options.say; end
            if isfield(options,'spz'), obj.spz = options.spz; end
            if isfield(options,'svz'), obj.svz = options.svz; end
            if isfield(options,'saz'), obj.saz = options.saz; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check domain geometry, optional groups and ranges
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the 1628-byte identification record
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Preserve fixed field offsets and optional blank values
            report = newReport('RSM identification');
            validForm = any(strcmp(obj.grndd,{'G','H','R'}));
            report = rsmIssue(report,~validForm || isempty(strtrim(char(obj.edition))), ...
                'Required','edition/grndd','Supply a common edition and G, H or R ground coordinates.');
            form = 'R';
            if validForm, form = char(obj.grndd); end
            [date,valid] = rsmAcquisition(obj.year,obj.month,obj.day,obj.hour,obj.minute,obj.second);
            report = rsmIssue(report,~valid,'AcquisitionDate','year/month/day/hour/minute/second', ...
                'Supplied UTC components must describe a possible calendar date and time.');
            [nrgBytes,a] = rsmInteger(obj.nrg,8,true,false); [ncgBytes,b] = rsmInteger(obj.ncg,8,true,false);
            [timing,c] = rsmNumbers([obj.trg obj.tcg],true);
            timeFields = [obj.nrg obj.ncg obj.trg obj.tcg];
            report = rsmIssue(report,~(a && b && c) || (any(isfinite(timeFields)) && ~all(isfinite(timeFields))), ...
                'TimeModel','nrg/ncg/trg/tcg','The optional relative time-of-image model requires all four fields.');
            frame = [obj.xuor obj.yuor obj.zuor ...
                obj.xuxr obj.xuyr obj.xuzr obj.yuxr obj.yuyr obj.yuzr obj.zuxr obj.zuyr obj.zuzr];
            [frameBytes,valid] = rsmNumbers(frame,form ~= 'R');
            if form == 'R'
                matrix = reshape(frame(4:12),3,3)';
                valid = valid && all(abs(frame(4:12)) <= 1) && ...
                    norm(matrix'*matrix-eye(3),'fro') <= 1e-10 && abs(det(matrix)-1) <= 1e-10;
            else
                valid = valid && all(isnan(frame));
            end
            report = rsmIssue(report,~valid,'RectangularFrame','xuor/yuor/zuor/xuxr...zuzr', ...
                'R requires a known origin and orthonormal right-handed basis; G/H require all twelve fields blank.');
            vertices = [obj.v1x obj.v2x obj.v3x obj.v4x obj.v5x obj.v6x obj.v7x obj.v8x; ...
                obj.v1y obj.v2y obj.v3y obj.v4y obj.v5y obj.v6y obj.v7y obj.v8y; ...
                obj.v1z obj.v2z obj.v3z obj.v4z obj.v5z obj.v6z obj.v7z obj.v8z];
            [vertexBytes,valid,roundedVertices] = rsmCoordinates(vertices,form,false);
            valid = valid && rsmGroundDomain(vertices) && rsmGroundDomain(roundedVertices);
            report = rsmIssue(report,~valid,'GroundDomain','v1x...v8z', ...
                'Supply a nondegenerate convex hexahedron with planar oriented faces in the defined vertex order.');
            ground = [obj.grpx;obj.grpy;obj.grpz];
            [groundBytes,valid] = rsmCoordinates(ground,form,true);
            valid = valid && (all(isnan(ground)) || all(isfinite(ground)));
            report = rsmIssue(report,~valid,'GroundReference','grpx/grpy/grpz','Supply all three reference coordinates or leave all unknown.');
            domain = [obj.minr obj.maxr obj.minc obj.maxc];
            report = rsmIssue(report,any(isnan(domain)) || obj.minr > obj.maxr || obj.minc > obj.maxc || ...
                obj.maxr >= obj.fullr || obj.maxc >= obj.fullc,'ImageDomain','minr/maxr/minc/maxc/fullr/fullc', ...
                'The inclusive image domain must be ordered and lie within any known original full-image dimensions.');
            [fullrBytes,a] = rsmInteger(obj.fullr,8,true,false); [fullcBytes,b] = rsmInteger(obj.fullc,8,true,false);
            [minrBytes,c] = rsmInteger(obj.minr,8,false,false); [maxrBytes,d] = rsmInteger(obj.maxr,8,false,false);
            [mincBytes,e] = rsmInteger(obj.minc,8,false,false); [maxcBytes,f] = rsmInteger(obj.maxc,8,false,false);
            report = rsmIssue(report,~(a && b && c && d && e && f),'ImageSize','image_domain','Image domain fields must fit their integer widths.');
            illumination = [obj.ie0 obj.ier obj.iec obj.ierr obj.ierc obj.iecc obj.ia0 obj.iar obj.iac obj.iarr obj.iarc obj.iacc];
            [illuminationBytes,valid] = rsmNumbers(illumination,true);
            report = rsmIssue(report,~valid || (any(isfinite(illumination)) && ~all(isfinite(illumination))), ...
                'IlluminationModel','ie0...iacc','Supply all twelve illumination coefficients or leave the model unknown.');
            trajectory = [obj.spx obj.svx obj.sax;obj.spy obj.svy obj.say;obj.spz obj.svz obj.saz];
            [trajectoryBytes,valid] = rsmNumbers(trajectory',true);
            [positionBytes,positionValid] = rsmCoordinates(trajectory(:,1),form,true);
            valid = valid && positionValid;
            trajectoryBytes([1:21 64:84 127:147]) = positionBytes;
            report = rsmIssue(report,~valid,'Trajectory','spx...saz','Known trajectory coefficients must fit the declared coordinate system and field format.');
            value = [textField(obj.iid,80) textField(obj.edition,40) textField(obj.isid,40) ...
                textField(obj.sid,40) textField(obj.stid,40) date nrgBytes ncgBytes timing textField(obj.grndd,1) ...
                frameBytes vertexBytes groundBytes fullrBytes fullcBytes minrBytes maxrBytes mincBytes maxcBytes illuminationBytes trajectoryBytes];
        end
    end
end
