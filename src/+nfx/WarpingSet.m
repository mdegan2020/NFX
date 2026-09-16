classdef WarpingSet
    %WarpingSet - Supplied normalization and de-warping polynomial metadata
    %   OBJ = WarpingSet(Name=VALUE) supplies one CSWRPB polynomial pair.
    %   A and B are double matrices with line powers along rows and sample
    %   powers along columns. Each axis has 1-10 coefficients. Orders derive
    %   from matrix dimensions; line powers change fastest in the payload.
    %
    %   Supply FL_WARP in meters for framing sensors. Leave it NaN for a
    %   line scanner. Offsets and scales use the specification's positive
    %   integer range. Values describe a supplied mapping; no fit is made.
    %
    %   See also CSWRPB

    properties
        fl_warp {mustBeMetadata(fl_warp,0,99.99999999,0)} = NaN
        offset_line {mustBeMetadata(offset_line,1,9999999,1)} = NaN
        offset_samp {mustBeMetadata(offset_samp,1,9999999,1)} = NaN
        scale_line {mustBeMetadata(scale_line,1,9999999,1)} = NaN
        scale_samp {mustBeMetadata(scale_samp,1,9999999,1)} = NaN
        offset_line_unwrp {mustBeMetadata(offset_line_unwrp,1,9999999,1)} = NaN
        offset_samp_unwrp {mustBeMetadata(offset_samp_unwrp,1,9999999,1)} = NaN
        scale_line_unwrp {mustBeMetadata(scale_line_unwrp,1,9999999,1)} = NaN
        scale_samp_unwrp {mustBeMetadata(scale_samp_unwrp,1,9999999,1)} = NaN
        a {mustBeGLASMatrix(a,10,10,9.99999999999999e99)} = []
        b {mustBeGLASMatrix(b,10,10,9.99999999999999e99)} = []
    end
    properties (Dependent, SetAccess = private)
        line_poly_order_m1
        line_poly_order_m2
        samp_poly_order_n1
        samp_poly_order_n2
    end
    methods
        function obj = WarpingSet(options) %#codegen
            %WarpingSet - Construct one editable polynomial definition
            arguments
                options.?nfx.WarpingSet
            end
            if isfield(options,'fl_warp'), obj.fl_warp = options.fl_warp; end
            if isfield(options,'offset_line'), obj.offset_line = options.offset_line; end
            if isfield(options,'offset_samp'), obj.offset_samp = options.offset_samp; end
            if isfield(options,'scale_line'), obj.scale_line = options.scale_line; end
            if isfield(options,'scale_samp'), obj.scale_samp = options.scale_samp; end
            if isfield(options,'offset_line_unwrp'), obj.offset_line_unwrp = options.offset_line_unwrp; end
            if isfield(options,'offset_samp_unwrp'), obj.offset_samp_unwrp = options.offset_samp_unwrp; end
            if isfield(options,'scale_line_unwrp'), obj.scale_line_unwrp = options.scale_line_unwrp; end
            if isfield(options,'scale_samp_unwrp'), obj.scale_samp_unwrp = options.scale_samp_unwrp; end
            if isfield(options,'a'), obj.a = options.a; end
            if isfield(options,'b'), obj.b = options.b; end
        end
        function value = get.line_poly_order_m1(obj) %#codegen
            %get.line_poly_order_m1 - Derive the line polynomial's line order
            value = size(obj.a,1)-1;
        end
        function value = get.line_poly_order_m2(obj) %#codegen
            %get.line_poly_order_m2 - Derive the line polynomial's sample order
            value = size(obj.a,2)-1;
        end
        function value = get.samp_poly_order_n1(obj) %#codegen
            %get.samp_poly_order_n1 - Derive the sample polynomial's line order
            value = size(obj.b,1)-1;
        end
        function value = get.samp_poly_order_n2(obj) %#codegen
            %get.samp_poly_order_n2 - Derive the sample polynomial's sample order
            value = size(obj.b,2)-1;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check known normalization and encodable coefficients
            report = newReport('GLAS/GFM warping data');
            reference = 'STDI-0002-2 Appendix M, Table M.6-3';
            report = addIssue(report,any(isnan(normalization(obj))),'Required','normalization', ...
                'Supply all eight coordinate normalization offsets and scales.',reference);
            report = addIssue(report,isempty(obj.a) || isempty(obj.b),'Required','a/b', ...
                'Supply both nonempty polynomial coefficient matrices.',reference);
            [~,validA] = rsmNumbers(obj.a,false); [~,validB] = rsmNumbers(obj.b,false);
            report = addIssue(report,~validA || ~validB,'WarpingCoefficients','a/b', ...
                'Every coefficient must fit a signed 21-byte scientific field without losing a nonzero value.',reference);
        end
        function value = bytes(obj,sensor_type) %#codegen
            %BYTES - Encode one set for the declared scanner or framer
            arguments
                obj (1,1) nfx.WarpingSet
                sensor_type {mustBeAscii(sensor_type,1)}
            end
            requireValid(validate(obj));
            if ~any(strcmp(sensor_type,{'S','F'}))
                error('nfx:SensorType','Supply S for a line scanner or F for a framer.');
            end
            if strcmp(sensor_type,'S') && ~isnan(obj.fl_warp)
                error('nfx:WarpingFocalLength','A scanner warping set cannot include FL_WARP.');
            end
            if strcmp(sensor_type,'F') && isnan(obj.fl_warp)
                error('nfx:WarpingFocalLength','A framing warping set requires FL_WARP.');
            end
            value = zeros(1,60+21*(numel(obj.a)+numel(obj.b))+11*strcmp(sensor_type,'F'),'uint8'); offset = 0;
            if strcmp(sensor_type,'F'), value(1:11) = decimalField(obj.fl_warp,11,8,false); offset = 11; end
            values = normalization(obj);
            for k = 1:8, value(offset+(1:7)) = decimalField(values(k),7,0,false); offset = offset+7; end
            orders = [obj.line_poly_order_m1 obj.line_poly_order_m2 obj.samp_poly_order_n1 obj.samp_poly_order_n2];
            value(offset+(1:4)) = uint8(orders)+uint8('0'); offset = offset+4;
            coefficients = [obj.a(:);obj.b(:)];
            for k = 1:numel(coefficients), value(offset+(1:21)) = rsmNumber(coefficients(k),false); offset = offset+21; end
        end
    end
end

function values = normalization(obj) %#codegen
    %normalization - Return the eight fields in their fixed wire order
    values = [obj.offset_line obj.offset_samp obj.scale_line obj.scale_samp ...
        obj.offset_line_unwrp obj.offset_samp_unwrp obj.scale_line_unwrp obj.scale_samp_unwrp];
end
