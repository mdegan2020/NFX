classdef (Sealed) ImagingOperation
    %ImagingOperation - Describe exposures and metrics in a CSEXRB operation
    %   OBJ = ImagingOperation(Name=VALUE) stores supplied operation IDs and
    %   NUM_EXP. INDEX_IN_IMG_OP_ID is a uint64 row: one initial index for
    %   sequential exposures, one per exposure, or empty to omit indexing.
    %   INDEX_SIZE derives from the full implied index range unless supplied.
    %   QUALITY_METRICS is an ordered row of nfx.QualityMetric value objects.
    %
    %   See also CSEXRB, ExploitationInfo, QualityMetric

    properties
        cm_id {mustBeAscii(cm_id,99)} = ''
        sensor_config {mustBeAscii(sensor_config,99)} = ''
        img_op_id {mustBeAscii(img_op_id,99)} = ''
        num_exp {mustBeMetadata(num_exp,1,99,1)} = NaN
        index_in_img_op_id {mustBeGLASIntegers} = zeros(1,0,'uint64')
        quality_metrics {mustBeGLASObjects(quality_metrics,'nfx.QualityMetric')} = nfx.QualityMetric.empty(1,0)
    end
    properties (Dependent)
        index_size
    end
    properties (Dependent, SetAccess = private)
        num_indices
        num_quality_metrics
    end
    properties (Access = private)
        indexWidth = NaN
    end
    methods
        function obj = ImagingOperation(options) %#codegen
            %ImagingOperation - Construct editable operation metadata
            arguments
                options.?nfx.ImagingOperation
            end
            if isfield(options,'cm_id'), obj.cm_id = options.cm_id; end
            if isfield(options,'sensor_config'), obj.sensor_config = options.sensor_config; end
            if isfield(options,'img_op_id'), obj.img_op_id = options.img_op_id; end
            if isfield(options,'num_exp'), obj.num_exp = options.num_exp; end
            if isfield(options,'index_in_img_op_id'), obj.index_in_img_op_id = options.index_in_img_op_id; end
            if isfield(options,'quality_metrics'), obj.quality_metrics = options.quality_metrics; end
            if isfield(options,'index_size'), obj.index_size = options.index_size; end
        end
        function value = get.index_size(obj) %#codegen
            %get.index_size - Derive sufficient bytes including implied indices
            value = obj.indexWidth;
            if ~isnan(value), return; end
            value = 0;
            if isempty(obj.index_in_img_op_id), return; end
            maximum = max(obj.index_in_img_op_id);
            if obj.num_indices == 1 && ~isnan(obj.num_exp)
                maximum = maximum+uint64(obj.num_exp-1);
            end
            value = 1;
            for k = 1:7
                if bitshift(maximum,-8*k) > 0, value = k+1; end
            end
        end
        function obj = set.index_size(obj,value) %#codegen
            %set.index_size - Select zero-to-eight bytes or automatic NaN
            mustBeMetadata(value,0,8,true); obj.indexWidth = value;
        end
        function value = get.num_indices(obj) %#codegen
            %get.num_indices - Derive the supplied index count
            value = numel(obj.index_in_img_op_id);
        end
        function value = get.num_quality_metrics(obj) %#codegen
            %get.num_quality_metrics - Derive the metric count
            value = numel(obj.quality_metrics);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check exposure counts, exact index bounds and metrics
            report = newReport('CSEXRB ImagingOperation');
            reference = 'STDI-0002-2 Appendix M, Table M.6-1';
            report = addIssue(report,isnan(obj.num_exp),'Required','num_exp','Supply the number of exposures.',reference);
            count = obj.num_indices; width = obj.index_size;
            report = addIssue(report,(width == 0 && count ~= 0) || ...
                (width > 0 && ~any(count == [1 obj.num_exp])), ...
                'ExposureIndices','index_in_img_op_id','Supply one index, one per exposure, or omit indexing with width zero.',reference);
            maximum = bitshift(intmax('uint64'),-8*(8-width));
            fits = all(obj.index_in_img_op_id <= maximum);
            if count == 1 && ~isnan(obj.num_exp)
                fits = fits && obj.index_in_img_op_id(1) <= maximum-uint64(obj.num_exp-1);
            end
            report = addIssue(report,~fits,'ExposureIndexWidth','index_size', ...
                'Stored and implied sequential indices must fit without unsigned overflow.',reference);
            report = addIssue(report,count > 1 && numel(unique(obj.index_in_img_op_id)) ~= count, ...
                'ExposureIndexIdentity','index_in_img_op_id','Each supplied index identifies a distinct exposure.',reference);
            report = addIssue(report,obj.num_quality_metrics > 99,'MetricCount','quality_metrics', ...
                'An imaging operation contains at most 99 quality metrics.',reference);
            for k = 1:obj.num_quality_metrics
                report = mergeReport(report,validate(obj.quality_metrics(k)),sprintf('quality_metrics(%.0f)',k));
            end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode operation fields, indices and ordered quality metrics
            requireValid(validate(obj));
            value = [sizedText(obj.cm_id) sizedText(obj.sensor_config) sizedText(obj.img_op_id) ...
                decimalField(obj.num_exp,2,0,false) decimalField(obj.index_size,1,0,false)];
            if obj.index_size > 0
                value = [value decimalField(obj.num_indices,2,0,false) unsignedBytes(obj.index_in_img_op_id,obj.index_size)];
            end
            value = [value decimalField(obj.num_quality_metrics,2,0,false)];
            for k = 1:obj.num_quality_metrics
                value = [value bytes(obj.quality_metrics(k))]; %#ok<AGROW>
            end
        end
    end
end

function value = sizedText(text) %#codegen
    %sizedText - Encode a two-digit length and unpadded ASCII data
    text = uint8(char(text)); value = [decimalField(numel(text),2,0,false) text];
end
