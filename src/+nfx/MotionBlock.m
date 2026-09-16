classdef MotionBlock
    %MotionBlock - Supplied imagery and timing for one camera temporal block
    %   OBJ = MotionBlock(IMAGE,timing=TIMING,start_timestamp=START,
    %   end_timestamp=END) supplies pixels, frame timing and block boundaries.
    %   TIMING is an MTIMSA value identifying CAMERA_ID and TIME_INTERVAL_INDEX.
    %   The collection derives its remaining indices, layer and frame count.
    %
    %   Motion block boundaries use exact 24-character UTC text. END is
    %   exclusive for motion; a still block may have equal START and END.
    %   All comparisons respect the common stated fractional precision.
    %
    %   OBJ = MotionBlock(available=false,...) describes a scheduled block
    %   without stored imagery. Supply camera, interval and both boundaries.
    %   Such a block has no image segment and no frame-timing payload.
    %
    %   See also MTIMSA, ImageSegment, TMINTA

    properties
        image (1,1) nfx.ImageSegment = nfx.ImageSegment()
        timing (1,1) nfx.MTIMSA = nfx.MTIMSA()
        start_timestamp {mustBeAscii(start_timestamp,24)} = ''
        end_timestamp {mustBeAscii(end_timestamp,24)} = ''
        available {mustBeLogicalScalar} = true
    end
    methods
        function obj = MotionBlock(image,options) %#codegen
            %MotionBlock - Construct a value snapshot of supplied block data
            arguments
                image (1,1) nfx.ImageSegment = nfx.ImageSegment()
                options.timing (1,1) nfx.MTIMSA = nfx.MTIMSA()
                options.start_timestamp {mustBeAscii(options.start_timestamp,24)} = ''
                options.end_timestamp {mustBeAscii(options.end_timestamp,24)} = ''
                options.available {mustBeLogicalScalar} = true
            end
            obj.image = image; obj.timing = options.timing;
            obj.start_timestamp = options.start_timestamp; obj.end_timestamp = options.end_timestamp;
            obj.available = options.available;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check supplied boundaries and exact frame containment
            report = newReport('NFX uncompressed MIE temporal block');
            reference = 'NGA.STND.0044 1.3.3, 6.4; STDI Appendix AF, AF5.5 and AF5.7';
            report = addIssue(report,~validUUID(obj.timing.camera_id),'CameraUUID','timing.camera_id', ...
                'Supply the camera UUID for this temporal block.',reference);
            report = addIssue(report,isnan(obj.timing.time_interval_index) || obj.timing.time_interval_index == 0, ...
                'TimeInterval','timing.time_interval_index','Supply a positive collection interval index.',reference);
            timesValid = validMieTimestamp(obj.start_timestamp) && validMieTimestamp(obj.end_timestamp);
            report = addIssue(report,~timesValid,'Timestamp','start_timestamp/end_timestamp', ...
                'Supply valid block boundary timestamps.',reference);
            if timesValid
                start = mieTimeValue(obj.start_timestamp); finish = mieTimeValue(obj.end_timestamp);
                report = addIssue(report,mieTimeCompare(start,finish) > 0,'TimeOrder','end_timestamp', ...
                    'The block cannot end before it starts.',reference);
            end
            if ~obj.available
                report = addIssue(report,~isempty(obj.image.data),'UnavailablePixels','image', ...
                    'An unavailable block cannot contain pixels.',reference);
                return
            end
            report = mergeReport(report,validate(obj.image.header),'image.header.');
            report = addIssue(report,isempty(obj.image.data),'PixelsRequired','image.data', ...
                'An available block requires native pixels.',reference);
            report = addIssue(report,any(strcmp({obj.image.tre_records.tag},'MTIMSA')), ...
                'DerivedTiming','image.MTIMSA','The collection attaches the derived timing record.',reference);
            timing = obj.timing; timing.image_seg_index = 1; timing.camera_set_index = 1;
            timing.temp_block_index = 1; timing.number_frames = obj.image.number_frames;
            timing.layer_id = 'derived'; child = timing.validate();
            report = mergeReport(report,child,'timing.');
            if ~child.valid || ~timesValid, return; end
            [first,firstValid] = mieFrameTime(timing,1);
            [last,lastValid] = mieFrameTime(timing,timing.number_frames);
            report = addIssue(report,~firstValid || ~lastValid,'TimeRange','timing', ...
                'Computed frame timestamps must fit the four-digit UTC year range.',reference);
            if ~firstValid || ~lastValid, return; end
            deltas = timing.dt;
            if numel(deltas) > 1, deltas = deltas(2:end); end
            report = addIssue(report,timing.number_frames > 1 && any(deltas == 0), ...
                'FrameOrder','timing.dt','Successive motion frames require positive elapsed time.',reference);
            still = timing.nominal_frame_rate == 0;
            outside = mieTimeCompare(first,start) < 0 || mieTimeCompare(last,finish) > 0;
            if ~still, outside = outside || mieTimeCompare(last,finish) == 0; end
            report = addIssue(report,outside,'FrameBounds','timing', ...
                'Every frame must lie inside its block; the motion end boundary is exclusive.',reference);
        end
    end
end
