classdef (Sealed) MTIMFA < nfx.TRE
    %MTIMFA - Map camera temporal blocks to NITF image segments
    %   OBJ = MTIMFA(Name=VALUE) accepts CAMERAS row structs containing
    %   camera_id and temporal_blocks. Each block has start_timestamp,
    %   end_timestamp, and image_seg_index. NaN encodes a blank segment index.
    %
    %   Known times with a blank segment index describe unavailable imagery.
    %   Completely unused blocks have blank times and a NaN segment index;
    %   these entries must follow every used block for the camera.
    %
    %   See also TRE, MTIMSA, CAMSDA

    properties (Constant)
        cetag = 'MTIMFA'
    end
    properties
        layer_id {mustBeAscii(layer_id,36)} = ''
        camera_set_index {mustBeMetadata(camera_set_index,1,999,1)} = NaN
        time_interval_index {mustBeMetadata(time_interval_index,1,999999,1)} = NaN
        cameras {mustBeCameras} = struct('camera_id',{},'temporal_blocks',{})
    end
    properties (Dependent, SetAccess = private)
        num_cameras_defined
        num_temp_blocks
    end
    methods
        function obj = MTIMFA(options) %#codegen
            %MTIMFA - Construct editable camera-to-block mappings
            arguments
                options.?nfx.MTIMFA
            end
            if isfield(options,'layer_id'), obj.layer_id = options.layer_id; end
            if isfield(options,'camera_set_index'), obj.camera_set_index = options.camera_set_index; end
            if isfield(options,'time_interval_index'), obj.time_interval_index = options.time_interval_index; end
            if isfield(options,'cameras'), obj.cameras = options.cameras; end
        end
        function value = get.num_cameras_defined(obj) %#codegen
            %get.num_cameras_defined - Derive the number of camera definitions
            value = numel(obj.cameras);
        end
        function value = get.num_temp_blocks(obj) %#codegen
            %get.num_temp_blocks - Derive each camera's temporal block count
            value = zeros(1,obj.num_cameras_defined);
            for k = 1:numel(value), value(k) = numel(obj.cameras(k).temporal_blocks); end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check identifiers, unused entries and temporal ordering
            report = newReport('STDI-0002 Appendix AF MTIMFA');
            reference = 'STDI-0002-1 Appendix AF, AF5.5 and Table AF-6';
            report = addIssue(report,isempty(strtrim(char(obj.layer_id))) || ...
                any(isnan([obj.camera_set_index obj.time_interval_index])), ...
                'Required','layer_id/indices','Supply a layer, camera set and interval index.',reference);
            counts = obj.num_temp_blocks;
            report = addIssue(report,obj.num_cameras_defined > 999 || any(counts < 1 | counts > 999), ...
                'CameraBlockCount','cameras','Allow 0 to 999 cameras and 1 to 999 blocks per camera.',reference);
            report = addIssue(report,48+39*obj.num_cameras_defined+51*sum(counts) > 99985, ...
                'TRELength','cameras','The complete mapping must fit 99985 bytes.',reference);
            identifiers = repmat(' ',obj.num_cameras_defined,36);
            indices = NaN(1,sum(counts));
            at = 0;
            for k = 1:obj.num_cameras_defined
                camera = obj.cameras(k);
                identifiers(k,:) = lower(char(textField(camera.camera_id,36)));
                report = addIssue(report,~validUUID(camera.camera_id),'CameraUUID', ...
                    sprintf('cameras(%d).camera_id',k),'Supply a valid 8-4-4-4-12 UUID.',reference);
                unusedSeen = false;
                previousEnd = '';
                for m = 1:numel(camera.temporal_blocks)
                    block = camera.temporal_blocks(m);
                    field = sprintf('cameras(%d).temporal_blocks(%d)',k,m);
                    blank = isempty(strtrim(char(block.start_timestamp))) && ...
                        isempty(strtrim(char(block.end_timestamp))) && isnan(block.image_seg_index);
                    known = validMieTimestamp(block.start_timestamp) && validMieTimestamp(block.end_timestamp);
                    report = addIssue(report,~blank && ~known,'TemporalBlock',field, ...
                        'Supply both valid times, or a completely blank unused entry.',reference);
                    report = addIssue(report,unusedSeen && ~blank,'UnusedBlockOrder',field, ...
                        'Completely unused temporal blocks must come last.',reference);
                    unusedSeen = unusedSeen || blank;
                    if known
                        report = addIssue(report,mieTimeEarlier(block.end_timestamp,block.start_timestamp) || ...
                            (~isempty(previousEnd) && mieTimeEarlier(block.start_timestamp,previousEnd)), ...
                            'TimeOrder',field,'Blocks must be ordered without known temporal overlap.',reference);
                        previousEnd = block.end_timestamp;
                    end
                    at = at+1;
                    indices(at) = block.image_seg_index;
                end
            end
            report = addIssue(report,size(unique(identifiers,'rows'),1) ~= obj.num_cameras_defined, ...
                'DuplicateCamera','cameras','Each camera has one definition per instance.',reference);
            knownIndices = indices(~isnan(indices));
            report = addIssue(report,numel(unique(knownIndices)) ~= numel(knownIndices), ...
                'DuplicateImage','cameras','Each image segment represents one camera and temporal block.', ...
                'NGA.STND.0044, requirement 1.2-06');
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode mappings and retain unavailable/unused distinctions
            requireValid(validate(obj));
            counts = obj.num_temp_blocks;
            value = zeros(1,48+39*obj.num_cameras_defined+51*sum(counts),'uint8');
            value(1:48) = [textField(obj.layer_id,36) decimalField(obj.camera_set_index,3,0,false) ...
                decimalField(obj.time_interval_index,6,0,false) decimalField(obj.num_cameras_defined,3,0,false)];
            at = 48;
            for k = 1:obj.num_cameras_defined
                value(at+1:at+39) = [textField(obj.cameras(k).camera_id,36) decimalField(counts(k),3,0,false)];
                at = at+39;
                for m = 1:counts(k)
                    block = obj.cameras(k).temporal_blocks(m);
                    index = repmat(uint8(' '),1,3);
                    if ~isnan(block.image_seg_index), index = decimalField(block.image_seg_index,3,0,false); end
                    value(at+1:at+51) = [textField(block.start_timestamp,24) textField(block.end_timestamp,24) index];
                    at = at+51;
                end
            end
        end
    end
end

function mustBeCameras(value) %#codegen
    %mustBeCameras - Validate concrete camera and block structs without coercion
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~all(isfield(value,{'camera_id','temporal_blocks'})) || numel(fieldnames(value)) ~= 2
        error('nfx:TemporalCameras','Supply camera_id/temporal_blocks row structs.');
    end
    for k = 1:numel(value)
        mustBeAscii(value(k).camera_id,36);
        blocks = value(k).temporal_blocks;
        if ~isstruct(blocks) || ~(isrow(blocks) || isempty(blocks)) || ...
                ~all(isfield(blocks,{'start_timestamp','end_timestamp','image_seg_index'})) || numel(fieldnames(blocks)) ~= 3
            error('nfx:TemporalBlocks','Supply start_timestamp/end_timestamp/image_seg_index row structs.');
        end
        for m = 1:numel(blocks)
            mustBeAscii(blocks(m).start_timestamp,24);
            mustBeAscii(blocks(m).end_timestamp,24);
            mustBeMetadata(blocks(m).image_seg_index,1,999,true);
        end
    end
end
