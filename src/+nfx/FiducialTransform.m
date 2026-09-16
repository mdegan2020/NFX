classdef (Sealed) FiducialTransform
    %FiducialTransform - Supply image-to-fiducial parameters for focal arrays
    %   OBJ = FiducialTransform(Name=VALUE) stores LS_FID_TRANS_T0 through T7
    %   as matching array-row-by-array-column double matrices. Parameter
    %   order and units follow CSSFAB; no transformation is estimated.
    %
    %   See also CSSFAB, InteriorOrientation

    properties
        ls_fid_trans_t0 {mustBeGLASMatrix(ls_fid_trans_t0,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t1 {mustBeGLASMatrix(ls_fid_trans_t1,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t2 {mustBeGLASMatrix(ls_fid_trans_t2,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t3 {mustBeGLASMatrix(ls_fid_trans_t3,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t4 {mustBeGLASMatrix(ls_fid_trans_t4,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t5 {mustBeGLASMatrix(ls_fid_trans_t5,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t6 {mustBeGLASMatrix(ls_fid_trans_t6,999,999,9.99999999999999e99)} = []
        ls_fid_trans_t7 {mustBeGLASMatrix(ls_fid_trans_t7,999,999,9.99999999999999e99)} = []
    end
    properties (Dependent, SetAccess = private)
        num_fp_arrays_line
        num_fp_arrays_samp
        byte_length
    end
    methods
        function obj = FiducialTransform(options) %#codegen
            %FiducialTransform - Construct editable focal-array transformations
            arguments
                options.?nfx.FiducialTransform
            end
            if isfield(options,'ls_fid_trans_t0'), obj.ls_fid_trans_t0 = options.ls_fid_trans_t0; end
            if isfield(options,'ls_fid_trans_t1'), obj.ls_fid_trans_t1 = options.ls_fid_trans_t1; end
            if isfield(options,'ls_fid_trans_t2'), obj.ls_fid_trans_t2 = options.ls_fid_trans_t2; end
            if isfield(options,'ls_fid_trans_t3'), obj.ls_fid_trans_t3 = options.ls_fid_trans_t3; end
            if isfield(options,'ls_fid_trans_t4'), obj.ls_fid_trans_t4 = options.ls_fid_trans_t4; end
            if isfield(options,'ls_fid_trans_t5'), obj.ls_fid_trans_t5 = options.ls_fid_trans_t5; end
            if isfield(options,'ls_fid_trans_t6'), obj.ls_fid_trans_t6 = options.ls_fid_trans_t6; end
            if isfield(options,'ls_fid_trans_t7'), obj.ls_fid_trans_t7 = options.ls_fid_trans_t7; end
        end
        function value = get.num_fp_arrays_line(obj) %#codegen
            %get.num_fp_arrays_line - Derive the array row count
            value = size(obj.ls_fid_trans_t0,1);
        end
        function value = get.num_fp_arrays_samp(obj) %#codegen
            %get.num_fp_arrays_samp - Derive the array column count
            value = size(obj.ls_fid_trans_t0,2);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count the dimensions and transform parameters
            value = 6+168*numel(obj.ls_fid_trans_t0);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check transform shapes and scientific encoding
            report = newReport('CSSFAB FiducialTransform');
            values = {obj.ls_fid_trans_t0,obj.ls_fid_trans_t1,obj.ls_fid_trans_t2,obj.ls_fid_trans_t3,obj.ls_fid_trans_t4,obj.ls_fid_trans_t5,obj.ls_fid_trans_t6,obj.ls_fid_trans_t7};
            valid = ~isempty(obj.ls_fid_trans_t0); shape = size(obj.ls_fid_trans_t0);
            for k = 1:8
                valid = valid && isequal(shape,size(values{k})) && glasScientificValid(values{k});
            end
            report = addIssue(report,~valid,'FiducialTransformShape','ls_fid_trans_t0/.../t7', ...
                'Supply eight matching known, encodable matrices with 1-999 rows and columns.', ...
                'STDI-0002-2 Appendix M, Table M.6-7');
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode arrays in row, column and parameter order
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1:6) = [decimalField(obj.num_fp_arrays_line,3,0,false) decimalField(obj.num_fp_arrays_samp,3,0,false)];
            at = 6;
            for row = 1:obj.num_fp_arrays_line
                for col = 1:obj.num_fp_arrays_samp
                    terms = [obj.ls_fid_trans_t0(row,col) obj.ls_fid_trans_t1(row,col) obj.ls_fid_trans_t2(row,col) obj.ls_fid_trans_t3(row,col) obj.ls_fid_trans_t4(row,col) obj.ls_fid_trans_t5(row,col) obj.ls_fid_trans_t6(row,col) obj.ls_fid_trans_t7(row,col)];
                    for k = 1:8
                        value(at+(1:21)) = rsmNumber(terms(k),false); at = at+21;
                    end
                end
            end
        end
    end
end
