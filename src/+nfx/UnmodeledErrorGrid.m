classdef (Sealed) UnmodeledErrorGrid
    %UnmodeledErrorGrid - Supply CSCSDB unmodeled image covariance samples
    %   OBJ = UnmodeledErrorGrid(Name=VALUE) holds matching URR, URC and UCC
    %   double matrices in line-by-sample order. Each grid point supplies a
    %   symmetric 2-by-2 covariance in squared pixels. The matrices refer to
    %   the unwarped image when CSWRPB is present. No covariance is estimated.
    %
    %   LINE_SPDCF and SAMPLE_SPDCF identify the correlation functions in
    %   the containing CSCSDB. Grid dimensions derive from URR.
    %
    %   See also CSCSDB, SPDCF, CSWRPB

    properties
        urr {mustBeGLASMatrix(urr,999,99,9.99999999999999e99)} = []
        urc {mustBeGLASMatrix(urc,999,99,9.99999999999999e99)} = []
        ucc {mustBeGLASMatrix(ucc,999,99,9.99999999999999e99)} = []
        line_spdcf {mustBeMetadata(line_spdcf,1,99,1)} = NaN
        sample_spdcf {mustBeMetadata(sample_spdcf,1,99,1)} = NaN
    end
    properties (Dependent, SetAccess = private)
        line_dimension
        sample_dimension
        byte_length
    end
    methods
        function obj = UnmodeledErrorGrid(options) %#codegen
            %UnmodeledErrorGrid - Construct editable image error covariance
            arguments
                options.?nfx.UnmodeledErrorGrid
            end
            if isfield(options,'urr'), obj.urr = options.urr; end
            if isfield(options,'urc'), obj.urc = options.urc; end
            if isfield(options,'ucc'), obj.ucc = options.ucc; end
            if isfield(options,'line_spdcf'), obj.line_spdcf = options.line_spdcf; end
            if isfield(options,'sample_spdcf'), obj.sample_spdcf = options.sample_spdcf; end
        end
        function value = get.line_dimension(obj) %#codegen
            %get.line_dimension - Derive the number of line grid points
            value = size(obj.urr,1);
        end
        function value = get.sample_dimension(obj) %#codegen
            %get.sample_dimension - Derive the number of sample grid points
            value = size(obj.urr,2);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count dimension, covariance and reference fields
            value = 9+63*numel(obj.urr);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check grid shape, correlations and every covariance
            report = newReport('CSCSDB UnmodeledErrorGrid');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            shape = ~isempty(obj.urr) && isequal(size(obj.urr),size(obj.urc),size(obj.ucc));
            report = addIssue(report,~shape,'UnmodeledGrid','urr/urc/ucc', ...
                'Supply matching 1-999 by 1-99 covariance grids.',reference);
            valid = shape;
            if shape
                for k = 1:numel(obj.urr)
                    if ~glasCovariance([obj.urr(k) obj.urc(k);obj.urc(k) obj.ucc(k)],false), valid = false; break; end
                end
            end
            report = addIssue(report,~valid,'UnmodeledCovariance','urr/urc/ucc', ...
                'Every grid covariance must be known, encodable and positive semidefinite.',reference);
            report = addIssue(report,any(isnan([obj.line_spdcf obj.sample_spdcf])),'Required','line_spdcf/sample_spdcf', ...
                'Supply both correlation function references.',reference);
        end
        function value = references(obj) %#codegen
            %REFERENCES - Return line and sample correlation IDs
            value = [obj.line_spdcf obj.sample_spdcf];
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode each line followed by its samples in row order
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1:5) = [decimalField(obj.line_dimension,3,0,false) decimalField(obj.sample_dimension,2,0,false)]; at = 5;
            for row = 1:obj.line_dimension
                for col = 1:obj.sample_dimension
                    [~,data] = glasCovariance([obj.urr(row,col) obj.urc(row,col);obj.urc(row,col) obj.ucc(row,col)],true);
                    value(at+(1:63)) = data; at = at+63;
                end
            end
            value(at+(1:4)) = [decimalField(obj.line_spdcf,2,0,false) decimalField(obj.sample_spdcf,2,0,false)];
        end
    end
end
