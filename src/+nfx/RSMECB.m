classdef (Sealed) RSMECB < nfx.TRE
    %RSMECB - Store supplied indirect and unmodeled RSM error covariance
    %   OBJ = RSMECB(Name=VALUE) accepts PARAMETERS, SUBGROUPS and MAP for
    %   indirect covariance. Construct subgroup structs with
    %   nfx.RSMECB.subgroup(ERRCVG,TCDF,CORRELATION). ERRCVG is a full
    %   symmetric positive definite original-parameter covariance matrix.
    %   Subgroups are independent and remain in supplied parameter order.
    %
    %   MAP has one row per active RSM parameter and one column per original
    %   parameter. Original covariance matrices serialize as upper triangles
    %   in row-major order; MAP serializes as a full row-major matrix.
    %   All subgroups use the same correlation functional form.
    %
    %   URR, URC and UCC optionally supply an unmodeled 2-by-2 positive
    %   semidefinite covariance. Supply ROW_CORRELATION and COLUMN_CORRELATION
    %   together using nfx.RSMCorrelation; their distances are in pixels.
    %   Covariance flags and counts derive from the supplied metadata.
    %
    %   This class writes supplied models. It does not estimate covariance,
    %   compute geolocation uncertainty or evaluate inter-image correlation.
    %
    %   See also RSMParameters, RSMCorrelation, RSMDCB, RSMAPB

    properties (Constant)
        cetag = 'RSMECB'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        tid {mustBeAscii(tid,40)} = ''
        cvdate {mustBeAscii(cvdate,8)} = ''
        parameters {mustBeOptionalRSMParameters} = nfx.RSMParameters.empty(1,0)
        subgroups {mustBeCovarianceSubgroups} = struct('errcvg',{},'tcdf',{},'correlation',{})
        map {mustBeMappingMatrix} = zeros(0,0)
        urr {mustBeRSMNumber} = NaN
        urc {mustBeRSMNumber} = NaN
        ucc {mustBeRSMNumber} = NaN
        row_correlation {mustBeOptionalRSMCorrelation} = nfx.RSMCorrelation.empty(1,0)
        column_correlation {mustBeOptionalRSMCorrelation} = nfx.RSMCorrelation.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        inclic
        incluc
        nparo
        ign
        npar
    end
    methods
        function obj = RSMECB(options) %#codegen
            %RSMECB - Construct editable covariance metadata
            arguments
                options.?nfx.RSMECB
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'tid'), obj.tid = options.tid; end
            if isfield(options,'cvdate'), obj.cvdate = options.cvdate; end
            if isfield(options,'parameters'), obj.parameters = options.parameters; end
            if isfield(options,'subgroups'), obj.subgroups = options.subgroups; end
            if isfield(options,'map'), obj.map = options.map; end
            if isfield(options,'urr'), obj.urr = options.urr; end
            if isfield(options,'urc'), obj.urc = options.urc; end
            if isfield(options,'ucc'), obj.ucc = options.ucc; end
            if isfield(options,'row_correlation'), obj.row_correlation = options.row_correlation; end
            if isfield(options,'column_correlation'), obj.column_correlation = options.column_correlation; end
        end
        function value = get.inclic(obj) %#codegen
            %get.inclic - Derive whether indirect-covariance fields are supplied
            if ~isempty(obj.parameters) || ~isempty(obj.subgroups) || ~isempty(obj.map) || ~isempty(strtrim(char(obj.cvdate)))
                value = 'Y';
            else, value = 'N';
            end
        end
        function value = get.incluc(obj) %#codegen
            %get.incluc - Derive whether unmodeled-error fields are supplied
            if any(~isnan([obj.urr obj.urc obj.ucc])) || ~isempty(obj.row_correlation) || ~isempty(obj.column_correlation)
                value = 'Y';
            else, value = 'N';
            end
        end
        function value = get.nparo(obj) %#codegen
            %get.nparo - Derive the original-parameter count across subgroups
            value = 0;
            for k = 1:numel(obj.subgroups), value = value+size(obj.subgroups(k).errcvg,1); end
        end
        function value = get.ign(obj) %#codegen
            %get.ign - Derive the independent subgroup count
            value = numel(obj.subgroups);
        end
        function value = get.npar(obj) %#codegen
            %get.npar - Derive the active parameter count
            value = 0;
            if ~isempty(obj.parameters), value = obj.parameters.npar; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check covariance, mapping and correlation relationships
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode supplied covariance in the defined matrix order
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Static)
        function value = subgroup(errcvg,tcdf,correlation) %#codegen
            %SUBGROUP - Pair original-parameter covariance and time correlation
            %   TCDF=0 correlates within and between images, 1 correlates
            %   between images, and 2 correlates within each image only.
            arguments
                errcvg
                tcdf
                correlation
            end
            value = struct('errcvg',errcvg,'tcdf',tcdf,'correlation',correlation);
            mustBeCovarianceSubgroups(value);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Combine independently conditional covariance modules
            value = zeros(1,0,'uint8'); report = newReport('RSM indirect covariance');
            report = rsmIssue(report,isempty(strtrim(char(obj.edition))) || isempty(strtrim(char(obj.tid))), ...
                'Required','edition/tid','Supply the common RSM edition and covariance process identifier.');
            report = rsmIssue(report,obj.inclic == 'N' && obj.incluc == 'N','EmptyCovariance','covariance', ...
                'Supply indirect covariance, unmodeled error covariance, or both.');
            [indirect,child] = indirectBytes(obj); report = mergeReport(report,child,'indirect.');
            [unmodeled,child] = unmodeledBytes(obj); report = mergeReport(report,child,'unmodeled.');
            report = rsmIssue(report,162+numel(indirect)+numel(unmodeled) > 98487, ...
                'CovarianceLength','covariance','The complete RSMECB payload must fit 98487 bytes.');
            if ~report.valid, return; end
            value = [textField(obj.iid,80) textField(obj.edition,40) textField(obj.tid,40) ...
                uint8(obj.inclic) uint8(obj.incluc) indirect unmodeled];
        end
        function [value,report] = indirectBytes(obj) %#codegen
            %indirectBytes - Encode original covariance subgroups and mapping
            value = zeros(1,0,'uint8'); report = newReport('RSM indirect covariance');
            if obj.inclic == 'N', return; end
            report = rsmIssue(report,isempty(obj.parameters) || obj.ign < 1 || obj.nparo > 53, ...
                'OriginalParameters','subgroups','Supply parameter definitions and 1 to 53 original parameters across 1 to 36 independent subgroups.');
            date = char(obj.cvdate); dateOK = isempty(strtrim(date));
            if ~dateOK
                dateOK = numel(date) == 8 && all(date >= '0' & date <= '9');
                if dateOK, dateOK = rsmDate(date); end
            end
            report = rsmIssue(report,~dateOK,'CovarianceDate','cvdate','Supply a valid YYYYMMDD version date or leave it blank.');
            if ~isempty(obj.parameters), report = mergeReport(report,obj.parameters.validate(),'parameters.'); end
            report = rsmIssue(report,size(obj.map,1) ~= obj.npar || size(obj.map,2) ~= obj.nparo, ...
                'MappingSize','map','MAP must have one row per active and one column per original parameter.');
            if ~report.valid, return; end
            definition = obj.parameters.bytes();
            value = [uint8(sprintf('%02.0f%02.0f',obj.nparo,obj.ign)) textField(obj.cvdate,8) definition];
            form = obj.subgroups(1).correlation.acsmc;
            for k = 1:obj.ign
                item = obj.subgroups(k);
                report = mergeReport(report,item.correlation.validate(),'correlation.');
                report = rsmIssue(report,isnan(item.tcdf) || item.correlation.acsmc ~= form, ...
                    'CorrelationDomain','tcdf/acsmc','Supply each time-correlation domain and one common functional form across subgroups.');
                [~,ok,rounded] = rsmNumbers(item.errcvg,false);
                encodedMatrix = triu(rounded)+triu(rounded,1)';
                report = rsmIssue(report,~ok || ~rsmCovariance(item.errcvg,true) || ~rsmCovariance(encodedMatrix,true), ...
                    'OriginalCovariance','errcvg','Original-parameter covariance must be symmetric positive definite before and after encoding.');
                if ~report.valid, continue; end
                count = size(item.errcvg,1); triangular = zeros(1,count*(count+1)/2); at = 0;
                for row = 1:count
                    width = count-row+1; triangular(at+(1:width)) = item.errcvg(row,row:count); at = at+width;
                end
                value = [value uint8(sprintf('%02.0f',count)) rsmNumbers(triangular,false) ...
                    uint8(sprintf('%.0f',item.tcdf)) item.correlation.bytes()]; %#ok<AGROW>
            end
            [mapping,ok] = rsmNumbers(obj.map',false);
            report = rsmIssue(report,~ok,'MappingElement','map','Every mapping element must be known and representable.');
            value = [value mapping];
        end
        function [value,report] = unmodeledBytes(obj) %#codegen
            %unmodeledBytes - Encode spatially correlated unmodeled image error
            value = zeros(1,0,'uint8'); report = newReport('RSM unmodeled covariance');
            if obj.incluc == 'N', return; end
            [covariance,ok,rounded] = rsmNumbers([obj.urr obj.urc obj.ucc],false);
            ok = ok && rsmCovariance([obj.urr obj.urc;obj.urc obj.ucc]) && ...
                rsmCovariance([rounded(1) rounded(2);rounded(2) rounded(3)]);
            report = rsmIssue(report,~ok,'UnmodeledCovariance','urr/urc/ucc', ...
                'Supply a known positive semidefinite 2-by-2 unmodeled covariance.');
            report = rsmIssue(report,isempty(obj.row_correlation) || isempty(obj.column_correlation), ...
                'UnmodeledCorrelation','row_correlation/column_correlation','Supply both spatial correlation functions.');
            if ~report.valid, return; end
            report = mergeReport(report,obj.row_correlation.validate(),'row.');
            report = mergeReport(report,obj.column_correlation.validate(),'column.');
            report = rsmIssue(report,obj.row_correlation.acsmc ~= obj.column_correlation.acsmc, ...
                'UnmodeledForm','uacsmc','The row and column spatial correlation functions must use the same functional form.');
            if ~report.valid, return; end
            rowBytes = obj.row_correlation.bytes(); colBytes = obj.column_correlation.bytes();
            value = [covariance rowBytes colBytes(2:end)];
        end
    end
end

function mustBeCovarianceSubgroups(value) %#codegen
    %mustBeCovarianceSubgroups - Require ordered original-parameter groups
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || numel(value) > 36 || ...
            ~all(isfield(value,{'errcvg','tcdf','correlation'})) || numel(fieldnames(value)) ~= 3
        error('nfx:RSMSubgroups','Supply up to 36 errcvg/tcdf/correlation row structs.');
    end
    for k = 1:numel(value)
        mustBeRSMMatrix(value(k).errcvg,53,53); mustBeMetadata(value(k).tcdf,0,2,true);
        if ~isa(value(k).correlation,'nfx.RSMCorrelation') || ~isscalar(value(k).correlation)
            error('nfx:RSMCorrelation','Supply one nfx.RSMCorrelation value per subgroup.');
        end
        if size(value(k).errcvg,1) ~= size(value(k).errcvg,2)
            error('nfx:RSMCovarianceShape','Each original-parameter covariance must be square.');
        end
    end
end

function mustBeMappingMatrix(value) %#codegen
    %mustBeMappingMatrix - Permit an absent map or a bounded metadata matrix
    if isa(value,'double') && isreal(value) && ~issparse(value) && isequal(size(value),[0 0]), return; end
    mustBeRSMMatrix(value,36,53);
end

function valid = rsmDate(date) %#codegen
    %rsmDate - Validate the complete calendar date without date coercion
    year = str2double(date(1:4)); month = str2double(date(5:6)); day = str2double(date(7:8));
    valid = year >= 1 && month >= 1 && month <= 12 && day >= 1;
    if ~valid, return; end
    days = [31 28 31 30 31 30 31 31 30 31 30 31];
    if mod(year,4) == 0 && (mod(year,100) ~= 0 || mod(year,400) == 0), days(2) = 29; end
    valid = day <= days(month);
end
