classdef (Sealed) ICHIPB < nfx.TRE
    %ICHIPB - Supplied mapping between chipped and original image coordinates
    %   OBJ = ICHIPB(Name=VALUE) supplies the OP and FI coordinates of four
    %   reference points, scale, anamorphic correction, scan block, and
    %   optional full-image dimensions. All numeric metadata is double.
    %
    %   XFRM_FLAG=1 signals that mapping data is unavailable; subsequent
    %   fields are zero-filled. Unset or zero metadata is accepted in that
    %   case, and conflicting nonzero metadata is rejected.
    %
    %   See also TRE, ImageSegment

    properties (Constant)
        cetag = 'ICHIPB'
    end
    properties
        xfrm_flag {mustBeMetadata(xfrm_flag, 0, 1, 1), mustBeFinite} = 0
        scale_factor {mustBeMetadata(scale_factor, 0, 9999.99999, 0)} = NaN
        anamrph_corr {mustBeMetadata(anamrph_corr, 0, 1, 1)} = 0
        scanblk_num {mustBeMetadata(scanblk_num, 0, 99, 1)} = 0
        op_row_11 {mustBeMetadata(op_row_11, 0, 99999999.999, 0)} = NaN
        op_col_11 {mustBeMetadata(op_col_11, 0, 99999999.999, 0)} = NaN
        op_row_12 {mustBeMetadata(op_row_12, 0, 99999999.999, 0)} = NaN
        op_col_12 {mustBeMetadata(op_col_12, 0, 99999999.999, 0)} = NaN
        op_row_21 {mustBeMetadata(op_row_21, 0, 99999999.999, 0)} = NaN
        op_col_21 {mustBeMetadata(op_col_21, 0, 99999999.999, 0)} = NaN
        op_row_22 {mustBeMetadata(op_row_22, 0, 99999999.999, 0)} = NaN
        op_col_22 {mustBeMetadata(op_col_22, 0, 99999999.999, 0)} = NaN
        fi_row_11 {mustBeMetadata(fi_row_11, 0, 99999999.999, 0)} = NaN
        fi_col_11 {mustBeMetadata(fi_col_11, 0, 99999999.999, 0)} = NaN
        fi_row_12 {mustBeMetadata(fi_row_12, 0, 99999999.999, 0)} = NaN
        fi_col_12 {mustBeMetadata(fi_col_12, 0, 99999999.999, 0)} = NaN
        fi_row_21 {mustBeMetadata(fi_row_21, 0, 99999999.999, 0)} = NaN
        fi_col_21 {mustBeMetadata(fi_col_21, 0, 99999999.999, 0)} = NaN
        fi_row_22 {mustBeMetadata(fi_row_22, 0, 99999999.999, 0)} = NaN
        fi_col_22 {mustBeMetadata(fi_col_22, 0, 99999999.999, 0)} = NaN
        fi_row {mustBeMetadata(fi_row, 0, 99999999, 1)} = 0
        fi_col {mustBeMetadata(fi_col, 0, 99999999, 1)} = 0
    end
    methods
        function obj = ICHIPB(options) %#codegen
            %ICHIPB - Construct editable chip mapping metadata
            arguments
                options.?nfx.ICHIPB
            end
            if isfield(options, 'xfrm_flag'), obj.xfrm_flag = options.xfrm_flag; end
            if isfield(options, 'scale_factor'), obj.scale_factor = options.scale_factor; end
            if isfield(options, 'anamrph_corr'), obj.anamrph_corr = options.anamrph_corr; end
            if isfield(options, 'scanblk_num'), obj.scanblk_num = options.scanblk_num; end
            if isfield(options, 'op_row_11'), obj.op_row_11 = options.op_row_11; end
            if isfield(options, 'op_col_11'), obj.op_col_11 = options.op_col_11; end
            if isfield(options, 'op_row_12'), obj.op_row_12 = options.op_row_12; end
            if isfield(options, 'op_col_12'), obj.op_col_12 = options.op_col_12; end
            if isfield(options, 'op_row_21'), obj.op_row_21 = options.op_row_21; end
            if isfield(options, 'op_col_21'), obj.op_col_21 = options.op_col_21; end
            if isfield(options, 'op_row_22'), obj.op_row_22 = options.op_row_22; end
            if isfield(options, 'op_col_22'), obj.op_col_22 = options.op_col_22; end
            if isfield(options, 'fi_row_11'), obj.fi_row_11 = options.fi_row_11; end
            if isfield(options, 'fi_col_11'), obj.fi_col_11 = options.fi_col_11; end
            if isfield(options, 'fi_row_12'), obj.fi_row_12 = options.fi_row_12; end
            if isfield(options, 'fi_col_12'), obj.fi_col_12 = options.fi_col_12; end
            if isfield(options, 'fi_row_21'), obj.fi_row_21 = options.fi_row_21; end
            if isfield(options, 'fi_col_21'), obj.fi_col_21 = options.fi_col_21; end
            if isfield(options, 'fi_row_22'), obj.fi_row_22 = options.fi_row_22; end
            if isfield(options, 'fi_col_22'), obj.fi_col_22 = options.fi_col_22; end
            if isfield(options, 'fi_row'), obj.fi_row = options.fi_row; end
            if isfield(options, 'fi_col'), obj.fi_col = options.fi_col; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check required mapping fields and nonmapping zero fill
            report = newReport('STDI-0002 Appendix B ICHIPB');
            reference = 'STDI-0002-1 Appendix B, Tables B-2 and B-3';
            values = [obj.scale_factor obj.anamrph_corr obj.scanblk_num ...
                obj.op_row_11 obj.op_col_11 obj.op_row_12 obj.op_col_12 ...
                obj.op_row_21 obj.op_col_21 obj.op_row_22 obj.op_col_22 ...
                obj.fi_row_11 obj.fi_col_11 obj.fi_row_12 obj.fi_col_12 ...
                obj.fi_row_21 obj.fi_col_21 obj.fi_row_22 obj.fi_col_22 ...
                obj.fi_row obj.fi_col];
            if obj.xfrm_flag == 1
                report = addIssue(report, any(~isnan(values) & values ~= 0), 'ZeroFill', ...
                    'mapping', 'XFRM_FLAG=1 cannot carry nonzero mapping values.', reference);
            else
                report = addIssue(report, any(isnan(values)), 'Required', ...
                    'mapping', 'Supply every applicable chip mapping value.', reference);
                report = addIssue(report, round(obj.scale_factor,5) <= 0, 'Scale', ...
                    'scale_factor', 'The encoded scale factor must be positive.', reference);
                rowValues = [obj.fi_row_11 obj.fi_row_12 obj.fi_row_21 obj.fi_row_22];
                colValues = [obj.fi_col_11 obj.fi_col_12 obj.fi_col_21 obj.fi_col_22];
                report = addIssue(report, (obj.fi_row > 0 && any(rowValues > obj.fi_row)) || ...
                    (obj.fi_col > 0 && any(colValues > obj.fi_col)), 'ChipExtent', 'fi_row/fi_col', ...
                    'Mapping points must fit the supplied full-image dimensions.', reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the fixed 224-byte chip mapping
            requireValid(validate(obj));
            if obj.xfrm_flag == 1
                value = uint8(['01' repmat('0',1,222)]);
                return
            end
            value = [uint8('00') ...
                decimalField(obj.scale_factor, 10, 5, false) ...
                decimalField(obj.anamrph_corr, 2, 0, false) ...
                decimalField(obj.scanblk_num, 2, 0, false) ...
                decimalField(obj.op_row_11, 12, 3, false) ...
                decimalField(obj.op_col_11, 12, 3, false) ...
                decimalField(obj.op_row_12, 12, 3, false) ...
                decimalField(obj.op_col_12, 12, 3, false) ...
                decimalField(obj.op_row_21, 12, 3, false) ...
                decimalField(obj.op_col_21, 12, 3, false) ...
                decimalField(obj.op_row_22, 12, 3, false) ...
                decimalField(obj.op_col_22, 12, 3, false) ...
                decimalField(obj.fi_row_11, 12, 3, false) ...
                decimalField(obj.fi_col_11, 12, 3, false) ...
                decimalField(obj.fi_row_12, 12, 3, false) ...
                decimalField(obj.fi_col_12, 12, 3, false) ...
                decimalField(obj.fi_row_21, 12, 3, false) ...
                decimalField(obj.fi_col_21, 12, 3, false) ...
                decimalField(obj.fi_row_22, 12, 3, false) ...
                decimalField(obj.fi_col_22, 12, 3, false) ...
                decimalField(obj.fi_row, 8, 0, false) ...
                decimalField(obj.fi_col, 8, 0, false)];
        end
    end
end
