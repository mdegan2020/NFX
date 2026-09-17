classdef (Sealed) CSRLSB < nfx.TRE
    %CSRLSB - Supplied rolling-shutter corner times for a framing sensor
    %   OBJ = CSRLSB(Name=VALUE) takes RS_DT_1 through RS_DT_4 as matching
    %   row-block-by-column-block double matrices of delta milliseconds.
    %   Corners are upper left, upper right, lower right, and lower left.
    %   Block counts derive from the matrices; each axis permits 1-99 blocks.
    %
    %   Delta times reference the frame time supplied by CSEXRB or MTIMSA.
    %   NFX preserves the supplied values at the field's decimal precision;
    %   it does not estimate rolling-shutter timing or interpolate samples.
    %
    %   See also TRE, CSEXRB, ImageSegment

    properties (Constant)
        cetag = 'CSRLSB'
    end
    properties
        rs_dt_1 {mustBeGLASMatrix(rs_dt_1,99,99,9999999999)} = []
        rs_dt_2 {mustBeGLASMatrix(rs_dt_2,99,99,9999999999)} = []
        rs_dt_3 {mustBeGLASMatrix(rs_dt_3,99,99,9999999999)} = []
        rs_dt_4 {mustBeGLASMatrix(rs_dt_4,99,99,9999999999)} = []
    end
    properties (Dependent, SetAccess = private)
        n_rs_row_blocks
        m_rs_column_blocks
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable CSRLSB value
            %   [OBJ, OK, STATUS] = nfx.CSRLSB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also CSRLSB, CSRLSB.payload
            arguments
                data
            end
            obj = nfx.CSRLSB();
            reader = nfx.internal.TREReader(data);
            [rows, reader] = reader.number(2, 1, 99, true);
            [columns, reader] = reader.number(2, 1, 99, true);
            [values, reader] = reader.numbers(4 * rows * columns, 12, ...
                -9999999999, 9999999999);
            if reader.ok
                obj.rs_dt_1 = reshape(values(1:4:end), columns, rows).';
                obj.rs_dt_2 = reshape(values(2:4:end), columns, rows).';
                obj.rs_dt_3 = reshape(values(3:4:end), columns, rows).';
                obj.rs_dt_4 = reshape(values(4:4:end), columns, rows).';
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSRLSB());
        end
    end
    methods
        function obj = CSRLSB(options) %#codegen
            %CSRLSB - Construct editable rolling-shutter time blocks
            arguments
                options.?nfx.CSRLSB
            end
            if isfield(options,'rs_dt_1'), obj.rs_dt_1 = options.rs_dt_1; end
            if isfield(options,'rs_dt_2'), obj.rs_dt_2 = options.rs_dt_2; end
            if isfield(options,'rs_dt_3'), obj.rs_dt_3 = options.rs_dt_3; end
            if isfield(options,'rs_dt_4'), obj.rs_dt_4 = options.rs_dt_4; end
        end
        function value = get.n_rs_row_blocks(obj) %#codegen
            %get.n_rs_row_blocks - Derive the number of block rows
            value = size(obj.rs_dt_1,1);
        end
        function value = get.m_rs_column_blocks(obj) %#codegen
            %get.m_rs_column_blocks - Derive the number of block columns
            value = size(obj.rs_dt_1,2);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check corner matrices and encoded decimal precision
            report = newReport('GLAS/GFM CSRLSB');
            reference = 'STDI-0002-2 Appendix M, Table M.6-2';
            shape = size(obj.rs_dt_1);
            report = addIssue(report,isempty(obj.rs_dt_1) || ...
                ~isequal(shape,size(obj.rs_dt_2),size(obj.rs_dt_3),size(obj.rs_dt_4)), ...
                'RollingShutterShape','rs_dt_1/2/3/4', ...
                'Supply four nonempty matrices with matching row-block and column-block dimensions.',reference);
            report = addIssue(report,4+48*numel(obj.rs_dt_1) > 99940,'TRELength','rs_dt_1/2/3/4', ...
                'The CSRLSB payload cannot exceed 99940 bytes.',reference);
            arrays = {obj.rs_dt_1,obj.rs_dt_2,obj.rs_dt_3,obj.rs_dt_4};
            for k = 1:4
                valid = true;
                for n = 1:numel(arrays{k})
                    [~,fits] = glasDecimal(arrays{k}(n),12); valid = valid && fits;
                end
                report = addIssue(report,~valid,'RollingShutterPrecision',sprintf('rs_dt_%.0f',k), ...
                    'Every time must be known and fit its 12-byte decimal field without rounding a nonzero value to zero.',reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode row blocks, column blocks and four corner times
            requireValid(validate(obj)); rows = obj.n_rs_row_blocks; columns = obj.m_rs_column_blocks;
            value = zeros(1,4+48*rows*columns,'uint8');
            value(1:4) = [decimalField(rows,2,0,false) decimalField(columns,2,0,false)]; offset = 4;
            for row = 1:rows
                for col = 1:columns
                    times = [obj.rs_dt_1(row,col) obj.rs_dt_2(row,col) obj.rs_dt_3(row,col) obj.rs_dt_4(row,col)];
                    for corner = 1:4
                        value(offset+(1:12)) = glasDecimal(times(corner),12); offset = offset+12;
                    end
                end
            end
        end
    end
end
