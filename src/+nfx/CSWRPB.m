classdef (Sealed) CSWRPB < nfx.TRE
    %CSWRPB - Supplied warping polynomials for line scanners and framers
    %   OBJ = CSWRPB(sensor_type=TYPE,warp_data=SETS) takes a row of
    %   WarpingSet values. TYPE='S' requires one set; TYPE='F' permits 1-9
    %   sets and requires WRP_INTERP (0 nearest neighbor or 1 linear).
    %   Framing sets also require their supplied FL_WARP focal lengths.
    %
    %   Counts and polynomial orders derive automatically. NFX preserves
    %   set order and encodes the supplied mapping; it does not warp pixels.
    %
    %   See also WarpingSet, CSEXRB, ImageSegment

    properties (Constant)
        cetag = 'CSWRPB'
    end
    properties
        sensor_type {mustBeAscii(sensor_type,1)} = ''
        wrp_interp {mustBeMetadata(wrp_interp,0,1,1)} = NaN
        warp_data {mustBeWarpingSets} = nfx.WarpingSet.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        num_sets_warp_data
    end
    methods
        function obj = CSWRPB(options) %#codegen
            %CSWRPB - Construct editable warping data
            arguments
                options.?nfx.CSWRPB
            end
            if isfield(options,'sensor_type'), obj.sensor_type = options.sensor_type; end
            if isfield(options,'wrp_interp'), obj.wrp_interp = options.wrp_interp; end
            if isfield(options,'warp_data'), obj.warp_data = options.warp_data; end
        end
        function value = get.num_sets_warp_data(obj) %#codegen
            %get.num_sets_warp_data - Count supplied warping sets
            value = numel(obj.warp_data);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check sensor-specific fields and polynomial sets
            report = newReport('GLAS/GFM CSWRPB');
            reference = 'STDI-0002-2 Appendix M, Table M.6-3';
            framer = strcmp(obj.sensor_type,'F'); scanner = strcmp(obj.sensor_type,'S');
            count = obj.num_sets_warp_data;
            report = addIssue(report,~framer && ~scanner,'SensorType','sensor_type', ...
                'Supply S for a line scanner or F for a framer.',reference);
            report = addIssue(report,count < 1 || count > 9 || (scanner && count ~= 1), ...
                'WarpingSetCount','warp_data','Supply one scanner set or one to nine framing sets.',reference);
            report = addIssue(report,(framer && isnan(obj.wrp_interp)) || (~framer && ~isnan(obj.wrp_interp)), ...
                'WarpingInterpolation','wrp_interp','Supply interpolation only for a framing sensor.',reference);
            for k = 1:count
                data = obj.warp_data(k); field = sprintf('warp_data(%.0f).',k);
                report = mergeReport(report,validate(data),field);
                report = addIssue(report,(framer && isnan(data.fl_warp)) || (~framer && ~isnan(data.fl_warp)), ...
                    'WarpingFocalLength',[field 'fl_warp'],'Supply focal length only for a framing sensor.',reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode sensor conditionals and complete polynomial sets
            requireValid(validate(obj)); count = obj.num_sets_warp_data;
            framer = strcmp(obj.sensor_type,'F'); length = 7+framer;
            for k = 1:count, length = length+60+11*framer+21*(numel(obj.warp_data(k).a)+numel(obj.warp_data(k).b)); end
            value = zeros(1,length,'uint8'); value(1:2) = [uint8('0')+uint8(count) uint8(char(obj.sensor_type))]; offset = 2;
            if framer, value(3) = uint8('0')+uint8(obj.wrp_interp); offset = 3; end
            for k = 1:count
                data = bytes(obj.warp_data(k),obj.sensor_type); value(offset+(1:numel(data))) = data; offset = offset+numel(data);
            end
            value(offset+(1:5)) = uint8('00000');
        end
    end
end

function mustBeWarpingSets(value) %#codegen
    %mustBeWarpingSets - Preserve a homogeneous row of supplied set values
    if ~isa(value,'nfx.WarpingSet') || ~(isrow(value) || isempty(value))
        error('nfx:WarpingSets','Supply a row of nfx.WarpingSet values.');
    end
end
