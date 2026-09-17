classdef (Sealed) MTIMSA < nfx.TRE
    %MTIMSA - Exact frame timing and camera identity for an image segment
    %   OBJ = MTIMSA(Name=VALUE) describes supplied frame timing. DT is a
    %   uint64 row of delta units; DT_MULTIPLIER is a positive uint64 scalar
    %   in nanoseconds. DT_SIZE derives from DT unless explicitly supplied.
    %
    %   A single DT applies to every frame. An empty DT is allowed for one
    %   frame whose timestamp equals BASE_TIMESTAMP. Unknown absolute frame
    %   numbering uses REFERENCE_FRAME_NUM=NaN. Times retain their exact text.
    %   Blank camera/layer identifiers or zero collection indices are legal
    %   only for a quick-look image; collection validation checks that context.
    %
    %   See also TRE, MTIMFA, TMINTA

    properties (Constant)
        cetag = 'MTIMSA'
    end
    properties
        image_seg_index {mustBeMetadata(image_seg_index,1,999,1)} = NaN
        geocoords_static {mustBeMetadata(geocoords_static,0,99,1)} = 0
        layer_id {mustBeAscii(layer_id,36)} = ''
        camera_set_index {mustBeMetadata(camera_set_index,0,999,1)} = NaN
        camera_id {mustBeAscii(camera_id,36)} = ''
        time_interval_index {mustBeMetadata(time_interval_index,0,999999,1)} = NaN
        temp_block_index {mustBeMetadata(temp_block_index,0,999,1)} = NaN
        nominal_frame_rate {mustBeMetadata(nominal_frame_rate,0,3.4028234E38,0)} = NaN
        reference_frame_num {mustBeMetadata(reference_frame_num,1,999999999,1)} = NaN
        base_timestamp {mustBeAscii(base_timestamp,24)} = ''
        dt_multiplier {mustBeMultiplier} = uint64(1)
        number_frames {mustBeMetadata(number_frames,1,4294967295,1)} = NaN
        dt {mustBeDeltas} = zeros(1,0,'uint64')
    end
    properties (Dependent)
        dt_size
    end
    properties (Dependent, SetAccess = private)
        number_dt
    end
    properties (Access = private)
        deltaWidth = NaN
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable MTIMSA value
            %   [OBJ, OK, STATUS] = nfx.MTIMSA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also MTIMSA, MTIMSA.payload
            arguments
                data
            end
            obj = nfx.MTIMSA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number( ...
                3, 1, 999, 1, false);
            if reader.ok
                obj.image_seg_index = value;
            end
            [value, reader] = reader.number( ...
                2, 0, 99, 1, false);
            if reader.ok
                obj.geocoords_static = value;
            end
            [value, reader] = reader.text(36, true, false);
            if reader.ok
                obj.layer_id = value;
            end
            [value, reader] = reader.number( ...
                3, 0, 999, 1, false);
            if reader.ok
                obj.camera_set_index = value;
            end
            [value, reader] = reader.text(36, true, false);
            if reader.ok
                obj.camera_id = value;
            end
            [value, reader] = reader.number( ...
                6, 0, 999999, 1, false);
            if reader.ok
                obj.time_interval_index = value;
            end
            [value, reader] = reader.number( ...
                3, 0, 999, 1, false);
            if reader.ok
                obj.temp_block_index = value;
            end
            [value, reader] = reader.ue13();
            if reader.ok
                obj.nominal_frame_rate = value;
            end
            [value, reader] = reader.number( ...
                9, 1, 999999999, 1, true);
            if reader.ok
                obj.reference_frame_num = value;
            end
            [value, reader] = reader.text(24, true, false);
            if reader.ok
                obj.base_timestamp = value;
            end
            [multiplier, reader] = reader.unsigned(8);
            [width, reader] = reader.unsigned(1);
            [frames, reader] = reader.unsigned(4);
            [count, reader] = reader.unsigned(4);
            if reader.ok
                if multiplier == 0 || frames == 0 || width < 1 || width > 8
                    reader = reader.fail('InvalidNumber', ...
                        'Timing multiplier, frame count and width must be valid.');
                else
                    [deltas, reader] = reader.unsigned(double(width), double(count));
                    if reader.ok
                        obj.dt_multiplier = multiplier;
                        obj.dt_size = double(width);
                        obj.number_frames = double(frames);
                        obj.dt = deltas;
                    end
                end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MTIMSA());
        end
    end
    methods
        function obj = MTIMSA(options) %#codegen
            %MTIMSA - Construct editable timing metadata without type conversion
            arguments
                options.?nfx.MTIMSA
            end
            if isfield(options,'image_seg_index'), obj.image_seg_index = options.image_seg_index; end
            if isfield(options,'geocoords_static'), obj.geocoords_static = options.geocoords_static; end
            if isfield(options,'layer_id'), obj.layer_id = options.layer_id; end
            if isfield(options,'camera_set_index'), obj.camera_set_index = options.camera_set_index; end
            if isfield(options,'camera_id'), obj.camera_id = options.camera_id; end
            if isfield(options,'time_interval_index'), obj.time_interval_index = options.time_interval_index; end
            if isfield(options,'temp_block_index'), obj.temp_block_index = options.temp_block_index; end
            if isfield(options,'nominal_frame_rate'), obj.nominal_frame_rate = options.nominal_frame_rate; end
            if isfield(options,'reference_frame_num'), obj.reference_frame_num = options.reference_frame_num; end
            if isfield(options,'base_timestamp'), obj.base_timestamp = options.base_timestamp; end
            if isfield(options,'dt_multiplier'), obj.dt_multiplier = options.dt_multiplier; end
            if isfield(options,'number_frames'), obj.number_frames = options.number_frames; end
            if isfield(options,'dt'), obj.dt = options.dt; end
            if isfield(options,'dt_size'), obj.dt_size = options.dt_size; end
        end
        function value = get.dt_size(obj) %#codegen
            %get.dt_size - Derive the smallest sufficient one-to-eight byte width
            value = obj.deltaWidth;
            if isnan(value)
                value = 1;
                for k = 1:7
                    if any(bitshift(obj.dt,-8*k) > 0), value = k+1; end
                end
            end
        end
        function obj = set.dt_size(obj,value) %#codegen
            %set.dt_size - Set an explicit width or restore automatic sizing
            mustBeMetadata(value,1,8,true);
            obj.deltaWidth = value;
        end
        function value = get.number_dt(obj) %#codegen
            %get.number_dt - Derive the supplied delta count
            value = numel(obj.dt);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check counts, exact integer widths and timestamp syntax
            report = newReport('STDI-0002 Appendix AF MTIMSA');
            reference = 'STDI-0002-1 Appendix AF, AF4.2, AF5.7 and Table AF-8';
            report = addIssue(report,any(isnan([obj.image_seg_index obj.camera_set_index ...
                obj.time_interval_index obj.temp_block_index obj.number_frames])), ...
                'Required','indices/number_frames','Supply segment, collection and frame counts.',reference);
            report = addIssue(report,~any(obj.geocoords_static == [0 99]), ...
                'GeocoordsStatic','geocoords_static','Use 0 or 99.',reference);
            report = addIssue(report,~isempty(strtrim(char(obj.camera_id))) && ~validUUID(obj.camera_id), ...
                'CameraUUID','camera_id','Supply a valid camera UUID or blank for quick-look imagery.',reference);
            report = addIssue(report,~validMieTimestamp(obj.base_timestamp), ...
                'Timestamp','base_timestamp','Supply a valid 24-byte UTC timestamp.',reference);
            report = addIssue(report,~isnan(obj.nominal_frame_rate) && ...
                numel(sprintf('%.7E',obj.nominal_frame_rate)) ~= 13, ...
                'FrameRatePrecision','nominal_frame_rate','UE/13 requires a two-digit exponent.',reference);
            report = addIssue(report,obj.nominal_frame_rate == 0 && obj.number_frames ~= 1, ...
                'StillFrameCount','number_frames','A still-image temporal block contains one frame.',reference);
            countValid = (obj.number_frames == 1 && any(obj.number_dt == [0 1])) || ...
                (obj.number_frames > 1 && any(obj.number_dt == [1 obj.number_frames]));
            report = addIssue(report,~countValid,'DeltaCount','dt', ...
                'Supply one delta for all frames, one per frame, or none for a single frame.',reference);
            maximum = bitshift(intmax('uint64'),-8*(8-obj.dt_size));
            report = addIssue(report,any(obj.dt > maximum),'DeltaWidth','dt_size', ...
                'Every delta must fit the selected unsigned byte width.',reference);
            report = addIssue(report,152+obj.dt_size*obj.number_dt > 99985, ...
                'TRELength','dt','The complete frame-timing payload must fit 99985 bytes.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize ASCII metadata and exact big-endian integers
            requireValid(validate(obj));
            frame = repmat(uint8(' '),1,9);
            if ~isnan(obj.reference_frame_num)
                frame = decimalField(obj.reference_frame_num,9,0,false);
            end
            value = [decimalField(obj.image_seg_index,3,0,false) ...
                decimalField(obj.geocoords_static,2,0,false) textField(obj.layer_id,36) ...
                decimalField(obj.camera_set_index,3,0,false) textField(obj.camera_id,36) ...
                decimalField(obj.time_interval_index,6,0,false) decimalField(obj.temp_block_index,3,0,false) ...
                unsignedExponential13(obj.nominal_frame_rate) frame textField(obj.base_timestamp,24) ...
                unsignedBytes(obj.dt_multiplier,8) uint8(obj.dt_size) ...
                unsignedBytes(uint64(obj.number_frames),4) unsignedBytes(uint64(obj.number_dt),4) ...
                unsignedBytes(obj.dt,obj.dt_size)];
        end
    end
end

function mustBeMultiplier(value) %#codegen
    %mustBeMultiplier - Require a positive native uint64 scalar
    if ~isa(value,'uint64') || ~isscalar(value) || value == 0
        error('nfx:TimeMultiplier','DT_MULTIPLIER must be a positive uint64 scalar.');
    end
end

function mustBeDeltas(value) %#codegen
    %mustBeDeltas - Require a uint64 row without precision-losing conversions
    if ~isa(value,'uint64') || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:TimeDeltas','DT must be a uint64 row vector.');
    end
end
