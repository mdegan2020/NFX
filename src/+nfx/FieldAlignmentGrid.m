classdef (Sealed) FieldAlignmentGrid
    %FieldAlignmentGrid - Supply one direct frame field-alignment grid
    %   OBJ = FieldAlignmentGrid(Name=VALUE) stores FA_X1/Y1 through FA_X4/Y4
    %   as matching block-row-by-block-column matrices of focal-plane meters.
    %   Corners run clockwise: upper left, upper right, lower right, lower left.
    %   NUM_FA_BLOCKS_LINE/SAMP derive from the common matrix shape.
    %
    %   FL_CAL identifies the focal length for this grid. NUM_FIR_LINE/SAMP
    %   and DELTA_LINE/SAMP describe the image coordinate grid. Values are
    %   supplied by the caller; NFX does not interpolate or fit geometry.
    %
    %   See also CSSFAB, InteriorOrientation

    properties
        fl_cal {mustBeMetadata(fl_cal,0,99.99999999,0)} = NaN
        num_fir_line {mustBeMetadata(num_fir_line,-99999.99999,99999.99999,0)} = NaN
        delta_line {mustBeMetadata(delta_line,0,99999.99999,0)} = NaN
        num_fir_samp {mustBeMetadata(num_fir_samp,-99999.99999,99999.99999,0)} = NaN
        delta_samp {mustBeMetadata(delta_samp,0,99999.99999,0)} = NaN
        fa_x1 {mustBeGLASMatrix(fa_x1,999,999,99.9999999)} = []
        fa_y1 {mustBeGLASMatrix(fa_y1,999,999,99.9999999)} = []
        fa_x2 {mustBeGLASMatrix(fa_x2,999,999,99.9999999)} = []
        fa_y2 {mustBeGLASMatrix(fa_y2,999,999,99.9999999)} = []
        fa_x3 {mustBeGLASMatrix(fa_x3,999,999,99.9999999)} = []
        fa_y3 {mustBeGLASMatrix(fa_y3,999,999,99.9999999)} = []
        fa_x4 {mustBeGLASMatrix(fa_x4,999,999,99.9999999)} = []
        fa_y4 {mustBeGLASMatrix(fa_y4,999,999,99.9999999)} = []
    end
    properties (Dependent, SetAccess = private)
        num_fa_blocks_line
        num_fa_blocks_samp
        byte_length
    end
    methods
        function obj = FieldAlignmentGrid(options) %#codegen
            %FieldAlignmentGrid - Construct editable corner-coordinate data
            arguments
                options.?nfx.FieldAlignmentGrid
            end
            if isfield(options,'fl_cal'), obj.fl_cal = options.fl_cal; end
            if isfield(options,'num_fir_line'), obj.num_fir_line = options.num_fir_line; end
            if isfield(options,'delta_line'), obj.delta_line = options.delta_line; end
            if isfield(options,'num_fir_samp'), obj.num_fir_samp = options.num_fir_samp; end
            if isfield(options,'delta_samp'), obj.delta_samp = options.delta_samp; end
            if isfield(options,'fa_x1'), obj.fa_x1 = options.fa_x1; end
            if isfield(options,'fa_y1'), obj.fa_y1 = options.fa_y1; end
            if isfield(options,'fa_x2'), obj.fa_x2 = options.fa_x2; end
            if isfield(options,'fa_y2'), obj.fa_y2 = options.fa_y2; end
            if isfield(options,'fa_x3'), obj.fa_x3 = options.fa_x3; end
            if isfield(options,'fa_y3'), obj.fa_y3 = options.fa_y3; end
            if isfield(options,'fa_x4'), obj.fa_x4 = options.fa_x4; end
            if isfield(options,'fa_y4'), obj.fa_y4 = options.fa_y4; end
        end
        function value = get.num_fa_blocks_line(obj) %#codegen
            %get.num_fa_blocks_line - Derive the number of block rows
            value = size(obj.fa_x1,1);
        end
        function value = get.num_fa_blocks_samp(obj) %#codegen
            %get.num_fa_blocks_samp - Derive the number of block columns
            value = size(obj.fa_x1,2);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count the fixed fields and all supplied corners
            value = 63+88*numel(obj.fa_x1);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check common block shape and known grid coordinates
            report = newReport('CSSFAB FieldAlignmentGrid');
            reference = 'STDI-0002-2 Appendix M, Table M.6-7';
            report = addIssue(report,any(isnan([obj.fl_cal obj.num_fir_line obj.delta_line obj.num_fir_samp obj.delta_samp])), ...
                'Required','field alignment grid','Supply the focal length, first coordinates and grid spacing.',reference);
            shape = size(obj.fa_x1);
            values = {obj.fa_x1,obj.fa_y1,obj.fa_x2,obj.fa_y2,obj.fa_x3,obj.fa_y3,obj.fa_x4,obj.fa_y4};
            valid = ~isempty(obj.fa_x1);
            for k = 1:8, valid = valid && isequal(shape,size(values{k})) && all(isfinite(values{k}),'all'); end
            report = addIssue(report,~valid,'AlignmentGridShape','fa_x1/y1/.../x4/y4', ...
                'Supply eight matching known matrices with 1-999 rows and columns.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode block rows, block columns and clockwise XY corners
            requireValid(validate(obj));
            value = zeros(1,obj.byte_length,'uint8');
            value(1:63) = [decimalField(obj.fl_cal,11,8,false) decimalField(obj.num_fir_line,12,5,true) ...
                decimalField(obj.delta_line,11,5,false) decimalField(obj.num_fa_blocks_line,3,0,false) ...
                decimalField(obj.num_fir_samp,12,5,true) decimalField(obj.delta_samp,11,5,false) ...
                decimalField(obj.num_fa_blocks_samp,3,0,false)];
            at = 63;
            for row = 1:obj.num_fa_blocks_line
                for col = 1:obj.num_fa_blocks_samp
                    coordinates = [obj.fa_x1(row,col) obj.fa_y1(row,col) obj.fa_x2(row,col) obj.fa_y2(row,col) obj.fa_x3(row,col) obj.fa_y3(row,col) obj.fa_x4(row,col) obj.fa_y4(row,col)];
                    for k = 1:8
                        value(at+(1:11)) = decimalField(coordinates(k),11,7,true); at = at+11;
                    end
                end
            end
        end
    end
end
