classdef (Sealed) CSEXRB < nfx.TRE
    %CSEXRB - Describe an image plane and its GLAS/GFM model associations
    %   OBJ = CSEXRB(Name=VALUE) stores supplied image and acquisition data.
    %   ASSOC_DES_UUID is a cell row of DES identifiers. SENSOR_TYPE is S for
    %   a line scanner, F for a framing model, or blank for exploitation-only
    %   metadata without DES associations. IDs are supplied, never generated.
    %
    %   A framer's TIME_STAMP_LOC selects local timing (0) or MTIMSA (1).
    %   Local DT and DT_MULTIPLIER retain uint64 values, BASE_TIMESTAMP keeps
    %   its 24-character UTC representation, and DT_SIZE derives by default.
    %   Scanners use the acquisition day and double seconds from midnight.
    %   NUM_LINES/NUM_SAMPLES describe the original complete image plane.
    %
    %   Optional EXPLOITATION holds one nfx.ExploitationInfo value describing
    %   the current reserved field area. NaN optional numeric fields encode
    %   spaces. Required platform/payload/sensor IDs must be registered by the
    %   provider; syntax validation cannot establish registry provenance.
    %
    %   See also TRE, CSRLSB, CSWRPB, ExploitationInfo, MTIMSA

    properties (Constant)
        cetag = 'CSEXRB'
    end
    properties
        image_uuid {mustBeAscii(image_uuid,36)} = ''
        assoc_des_uuid {mustBeAssociatedUUIDs} = cell(1,0)
        platform_id {mustBeAscii(platform_id,6)} = ''
        payload_id {mustBeAscii(payload_id,6)} = ''
        sensor_id {mustBeAscii(sensor_id,6)} = ''
        sensor_type {mustBeAscii(sensor_type,1)} = ''
        ground_ref_point_x {mustBeMetadata(ground_ref_point_x,-99999999.99,99999999.99,0)} = NaN
        ground_ref_point_y {mustBeMetadata(ground_ref_point_y,-99999999.99,99999999.99,0)} = NaN
        ground_ref_point_z {mustBeMetadata(ground_ref_point_z,-99999999.99,99999999.99,0)} = NaN
        day_first_line_image {mustBeAscii(day_first_line_image,8)} = ''
        time_first_line_image {mustBeMetadata(time_first_line_image,0,86399.999999999,0)} = NaN
        time_image_duration {mustBeMetadata(time_image_duration,-86399.999999999,86399.999999999,0)} = NaN
        time_stamp_loc {mustBeMetadata(time_stamp_loc,0,1,1)} = NaN
        reference_frame_num {mustBeMetadata(reference_frame_num,1,999999999,1)} = NaN
        base_timestamp {mustBeAscii(base_timestamp,24)} = ''
        dt_multiplier {mustBeGLASMultiplier} = uint64(1)
        number_frames {mustBeMetadata(number_frames,1,4294967295,1)} = NaN
        dt {mustBeGLASIntegers} = zeros(1,0,'uint64')
        max_gsd {mustBeMetadata(max_gsd,0,9999999999.9,0)} = NaN
        along_scan_gsd {mustBeMetadata(along_scan_gsd,0,9999999999.9,0)} = NaN
        cross_scan_gsd {mustBeMetadata(cross_scan_gsd,0,9999999999.9,0)} = NaN
        geo_mean_gsd {mustBeMetadata(geo_mean_gsd,0,9999999999.9,0)} = NaN
        a_s_vert_gsd {mustBeMetadata(a_s_vert_gsd,0,9999999999.9,0)} = NaN
        c_s_vert_gsd {mustBeMetadata(c_s_vert_gsd,0,9999999999.9,0)} = NaN
        geo_mean_vert_gsd {mustBeMetadata(geo_mean_vert_gsd,0,9999999999.9,0)} = NaN
        gsd_beta_angle {mustBeMetadata(gsd_beta_angle,0,180,0)} = NaN
        dynamic_range {mustBeMetadata(dynamic_range,0,99999,1)} = NaN
        num_lines {mustBeMetadata(num_lines,0,9999999,1)} = NaN
        num_samples {mustBeMetadata(num_samples,0,99999,1)} = NaN
        angle_to_north {mustBeMetadata(angle_to_north,0,359.999,0)} = NaN
        obliquity_angle {mustBeMetadata(obliquity_angle,0,90,0)} = NaN
        az_of_obliquity {mustBeMetadata(az_of_obliquity,0,359.999,0)} = NaN
        atm_refr_flag {mustBeMetadata(atm_refr_flag,0,1,1)} = 0
        vel_aber_flag {mustBeMetadata(vel_aber_flag,0,1,1)} = 0
        grd_cover {mustBeMetadata(grd_cover,0,9,1)} = 9
        snow_depth_category {mustBeMetadata(snow_depth_category,0,9,1)} = 9
        sun_azimuth {mustBeMetadata(sun_azimuth,0,359.999,0)} = NaN
        sun_elevation {mustBeMetadata(sun_elevation,-90,90,0)} = NaN
        predicted_niirs {mustBeMetadata(predicted_niirs,0,9,0)} = NaN
        circl_err {mustBeMetadata(circl_err,0,999.9,0)} = NaN
        linear_err {mustBeMetadata(linear_err,0,999.9,0)} = NaN
        cloud_cover {mustBeMetadata(cloud_cover,0,999,1)} = NaN
        rolling_shutter_flag {mustBeMetadata(rolling_shutter_flag,0,1,1)} = NaN
        ue_time_flag {mustBeMetadata(ue_time_flag,0,1,1)} = NaN
        exploitation {mustBeGLASObjects(exploitation,'nfx.ExploitationInfo')} = nfx.ExploitationInfo.empty(1,0)
    end
    properties (Dependent)
        dt_size
    end
    properties (Dependent, SetAccess = private)
        num_assoc_des
        number_dt
        reserved_len
    end
    properties (Access = private)
        deltaWidth = NaN
    end
    methods
        function obj = CSEXRB(options) %#codegen
            %CSEXRB - Construct editable image-plane metadata without coercion
            arguments
                options.?nfx.CSEXRB
            end
            if isfield(options,'image_uuid'), obj.image_uuid = options.image_uuid; end
            if isfield(options,'assoc_des_uuid'), obj.assoc_des_uuid = options.assoc_des_uuid; end
            if isfield(options,'platform_id'), obj.platform_id = options.platform_id; end
            if isfield(options,'payload_id'), obj.payload_id = options.payload_id; end
            if isfield(options,'sensor_id'), obj.sensor_id = options.sensor_id; end
            if isfield(options,'sensor_type'), obj.sensor_type = options.sensor_type; end
            if isfield(options,'ground_ref_point_x'), obj.ground_ref_point_x = options.ground_ref_point_x; end
            if isfield(options,'ground_ref_point_y'), obj.ground_ref_point_y = options.ground_ref_point_y; end
            if isfield(options,'ground_ref_point_z'), obj.ground_ref_point_z = options.ground_ref_point_z; end
            if isfield(options,'day_first_line_image'), obj.day_first_line_image = options.day_first_line_image; end
            if isfield(options,'time_first_line_image'), obj.time_first_line_image = options.time_first_line_image; end
            if isfield(options,'time_image_duration'), obj.time_image_duration = options.time_image_duration; end
            if isfield(options,'time_stamp_loc'), obj.time_stamp_loc = options.time_stamp_loc; end
            if isfield(options,'reference_frame_num'), obj.reference_frame_num = options.reference_frame_num; end
            if isfield(options,'base_timestamp'), obj.base_timestamp = options.base_timestamp; end
            if isfield(options,'dt_multiplier'), obj.dt_multiplier = options.dt_multiplier; end
            if isfield(options,'number_frames'), obj.number_frames = options.number_frames; end
            if isfield(options,'dt'), obj.dt = options.dt; end
            if isfield(options,'max_gsd'), obj.max_gsd = options.max_gsd; end
            if isfield(options,'along_scan_gsd'), obj.along_scan_gsd = options.along_scan_gsd; end
            if isfield(options,'cross_scan_gsd'), obj.cross_scan_gsd = options.cross_scan_gsd; end
            if isfield(options,'geo_mean_gsd'), obj.geo_mean_gsd = options.geo_mean_gsd; end
            if isfield(options,'a_s_vert_gsd'), obj.a_s_vert_gsd = options.a_s_vert_gsd; end
            if isfield(options,'c_s_vert_gsd'), obj.c_s_vert_gsd = options.c_s_vert_gsd; end
            if isfield(options,'geo_mean_vert_gsd'), obj.geo_mean_vert_gsd = options.geo_mean_vert_gsd; end
            if isfield(options,'gsd_beta_angle'), obj.gsd_beta_angle = options.gsd_beta_angle; end
            if isfield(options,'dynamic_range'), obj.dynamic_range = options.dynamic_range; end
            if isfield(options,'num_lines'), obj.num_lines = options.num_lines; end
            if isfield(options,'num_samples'), obj.num_samples = options.num_samples; end
            if isfield(options,'angle_to_north'), obj.angle_to_north = options.angle_to_north; end
            if isfield(options,'obliquity_angle'), obj.obliquity_angle = options.obliquity_angle; end
            if isfield(options,'az_of_obliquity'), obj.az_of_obliquity = options.az_of_obliquity; end
            if isfield(options,'atm_refr_flag'), obj.atm_refr_flag = options.atm_refr_flag; end
            if isfield(options,'vel_aber_flag'), obj.vel_aber_flag = options.vel_aber_flag; end
            if isfield(options,'grd_cover'), obj.grd_cover = options.grd_cover; end
            if isfield(options,'snow_depth_category'), obj.snow_depth_category = options.snow_depth_category; end
            if isfield(options,'sun_azimuth'), obj.sun_azimuth = options.sun_azimuth; end
            if isfield(options,'sun_elevation'), obj.sun_elevation = options.sun_elevation; end
            if isfield(options,'predicted_niirs'), obj.predicted_niirs = options.predicted_niirs; end
            if isfield(options,'circl_err'), obj.circl_err = options.circl_err; end
            if isfield(options,'linear_err'), obj.linear_err = options.linear_err; end
            if isfield(options,'cloud_cover'), obj.cloud_cover = options.cloud_cover; end
            if isfield(options,'rolling_shutter_flag'), obj.rolling_shutter_flag = options.rolling_shutter_flag; end
            if isfield(options,'ue_time_flag'), obj.ue_time_flag = options.ue_time_flag; end
            if isfield(options,'exploitation'), obj.exploitation = options.exploitation; end
            if isfield(options,'dt_size'), obj.dt_size = options.dt_size; end
        end
        function value = get.dt_size(obj) %#codegen
            %get.dt_size - Derive a sufficient unsigned one-to-eight byte width
            value = obj.deltaWidth;
            if isnan(value)
                value = 1;
                for k = 1:7
                    if any(bitshift(obj.dt,-8*k) > 0), value = k+1; end
                end
            end
        end
        function obj = set.dt_size(obj,value) %#codegen
            %set.dt_size - Set a byte width or restore automatic NaN sizing
            mustBeMetadata(value,1,8,true); obj.deltaWidth = value;
        end
        function value = get.num_assoc_des(obj) %#codegen
            %get.num_assoc_des - Derive the associated DES count
            value = numel(obj.assoc_des_uuid);
        end
        function value = get.number_dt(obj) %#codegen
            %get.number_dt - Derive the stored frame-delta count
            value = numel(obj.dt);
        end
        function value = get.reserved_len(obj) %#codegen
            %get.reserved_len - Derive the complete optional reserved-area size
            value = 0;
            if ~isempty(obj.exploitation)
                if ~isscalar(obj.exploitation), error('nfx:ExploitationCount','Supply at most one reserved area.'); end
                value = 8+numel(bytes(obj.exploitation));
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check identifiers, timing conditions and nested metadata
            report = newReport('GLAS/GFM CSEXRB');
            reference = 'STDI-0002-2 Appendix M, Table M.6-1';
            report = addIssue(report,~validUUID(obj.image_uuid),'ImageUUID','image_uuid', ...
                'Supply the canonical UUID assigned to the complete image plane.',reference);
            report = addIssue(report,obj.num_assoc_des > 999,'AssociationCount','assoc_des_uuid', ...
                'At most 999 DES associations fit the count field.',reference);
            for k = 1:obj.num_assoc_des
                id = obj.assoc_des_uuid{k};
                report = addIssue(report,~validUUID(id),'DESUUID','assoc_des_uuid','Supply canonical DES UUIDs.',reference);
                for j = 1:k-1
                    report = addIssue(report,strcmpi(id,obj.assoc_des_uuid{j}),'DuplicateDES','assoc_des_uuid', ...
                        'Each DES is associated at most once with the image plane.',reference);
                end
            end
            report = addIssue(report,isempty(strtrim(char(obj.platform_id))) || ...
                isempty(strtrim(char(obj.payload_id))) || isempty(strtrim(char(obj.sensor_id))), ...
                'Required','platform_id/payload_id/sensor_id','Supply the registered identification triple.',reference);
            scanner = strcmp(obj.sensor_type,'S'); framer = strcmp(obj.sensor_type,'F');
            generic = any(strcmp(obj.sensor_type,{'',' '}));
            report = addIssue(report,~scanner && ~framer && ~generic,'SensorType','sensor_type', ...
                'Use S, F, or blank for exploitation-only metadata.',reference);
            report = addIssue(report,(generic && obj.num_assoc_des ~= 0) || ...
                ((scanner || framer) && obj.num_assoc_des == 0),'ModelAssociations','sensor_type/assoc_des_uuid', ...
                'A model references its DESs; exploitation-only metadata has no DES associations.',reference);
            ground = [obj.ground_ref_point_x obj.ground_ref_point_y obj.ground_ref_point_z];
            report = addIssue(report,any(isnan(ground)) && ~all(isnan(ground)),'GroundPoint','ground_ref_point_x/y/z', ...
                'Supply all three reference coordinates or leave the complete point unspecified.',reference);
            if scanner
                report = addIssue(report,~knownDate(obj.day_first_line_image,8) || ...
                    any(isnan([obj.time_first_line_image obj.time_image_duration])),'ScannerTime', ...
                    'day_first_line_image/time_first_line_image/time_image_duration','Supply the scanner date and both times.',reference);
            else
                report = addIssue(report,~isempty(char(obj.day_first_line_image)) || ...
                    any(~isnan([obj.time_first_line_image obj.time_image_duration])), ...
                    'UnusedScannerTime','scanner timing','Scanner timing is present only for sensor type S.',reference);
            end
            report = addIssue(report,(framer && isnan(obj.time_stamp_loc)) || ...
                (~framer && (~isnan(obj.time_stamp_loc) || ~isnan(obj.rolling_shutter_flag))), ...
                'FramingFields','time_stamp_loc/rolling_shutter_flag','A framer requires the timing selector; framing-only fields must be omitted otherwise.',reference);
            localTiming = framer && obj.time_stamp_loc == 0;
            if localTiming
                report = addIssue(report,~validMieTimestamp(obj.base_timestamp),'Timestamp','base_timestamp', ...
                    'Supply a known 24-character UTC timestamp.',reference);
                countValid = (obj.number_frames == 1 && any(obj.number_dt == [0 1])) || ...
                    (obj.number_frames > 1 && any(obj.number_dt == [1 obj.number_frames]));
                report = addIssue(report,~countValid,'DeltaCount','number_frames/dt', ...
                    'Use one delta for every frame, one per frame, or none for a single frame.',reference);
                maximum = bitshift(intmax('uint64'),-8*(8-obj.dt_size));
                report = addIssue(report,any(obj.dt > maximum),'DeltaWidth','dt_size', ...
                    'Each delta must fit the chosen unsigned byte width.',reference);
            else
                report = addIssue(report,~isempty(char(obj.base_timestamp)) || ...
                    any(~isnan([obj.reference_frame_num obj.number_frames obj.deltaWidth])) || ...
                    ~isempty(obj.dt) || obj.dt_multiplier ~= uint64(1),'UnusedFrameTime','frame timing', ...
                    'Local timing values are present only for an F sensor with TIME_STAMP_LOC=0.',reference);
            end
            report = addIssue(report,any(isnan([obj.num_lines obj.num_samples obj.atm_refr_flag obj.vel_aber_flag])), ...
                'Required','dimensions/correction flags','Supply full-image dimensions and both correction flags.',reference);
            report = addIssue(report,~any(obj.grd_cover == [0 1 9]) || ~any(obj.snow_depth_category == [0 1 2 3 9]), ...
                'SnowCode','grd_cover/snow_depth_category','Use the published snow presence and depth codes.',reference);
            report = addIssue(report,~isnan(obj.cloud_cover) && obj.cloud_cover > 100 && obj.cloud_cover ~= 999, ...
                'CloudCover','cloud_cover','Use 0-100, unknown 999, or NaN for not applicable.',reference);
            report = addIssue(report,numel(obj.exploitation) > 1,'ExploitationCount','exploitation', ...
                'Supply at most one current reserved-area descriptor.',reference);
            for k = 1:numel(obj.exploitation)
                report = mergeReport(report,validate(obj.exploitation(k)),'exploitation');
                operations = obj.exploitation(k).img_ops_data;
                for j = 1:numel(operations)
                    metrics = operations(j).quality_metrics;
                    for m = 1:numel(metrics)
                        q = metrics(m);
                        if strcmp(q.quality_metric_name,'Cloud Cover') && strcmp(q.quality_metric_type,'M')
                            report = addIssue(report,~isequal(q.quality_metric_value,obj.cloud_cover) || ...
                                isnan(obj.cloud_cover) || obj.cloud_cover > 100,'MeasuredCloudCover', ...
                                'exploitation.img_ops_data.quality_metrics','Measured cloud-cover metrics must equal the primary CLOUD_COVER field.',reference);
                        end
                    end
                end
            end
            if report.valid
                report = addIssue(report,payloadSize(obj) > 99985,'TRELength','CSEXRB', ...
                    'The complete CSEXRB payload must fit 99985 bytes.',reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode ASCII, exact frame integers and defined area one
            requireValid(validate(obj));
            value = [textField(obj.image_uuid,36) decimalField(obj.num_assoc_des,3,0,false)];
            for k = 1:obj.num_assoc_des
                value = [value textField(obj.assoc_des_uuid{k},36)]; %#ok<AGROW>
            end
            value = [value textField(obj.platform_id,6) textField(obj.payload_id,6) textField(obj.sensor_id,6) ...
                textField(obj.sensor_type,1) blankDecimal(obj.ground_ref_point_x,12,2,true) ...
                blankDecimal(obj.ground_ref_point_y,12,2,true) blankDecimal(obj.ground_ref_point_z,12,2,true)];
            if strcmp(obj.sensor_type,'S')
                value = [value textField(obj.day_first_line_image,8) decimalField(obj.time_first_line_image,15,9,false) ...
                    decimalField(obj.time_image_duration,16,9,true)];
            elseif strcmp(obj.sensor_type,'F')
                value = [value decimalField(obj.time_stamp_loc,1,0,false)];
                if obj.time_stamp_loc == 0
                    value = [value blankDecimal(obj.reference_frame_num,9,0,false) textField(obj.base_timestamp,24) ...
                        unsignedBytes(obj.dt_multiplier,8) uint8(obj.dt_size) unsignedBytes(uint64(obj.number_frames),4) ...
                        unsignedBytes(uint64(obj.number_dt),4) unsignedBytes(obj.dt,obj.dt_size)];
                end
            end
            value = [value ...
                blankDecimal(obj.max_gsd,12,1,false) ...
                blankDecimal(obj.along_scan_gsd,12,1,false) ...
                blankDecimal(obj.cross_scan_gsd,12,1,false) ...
                blankDecimal(obj.geo_mean_gsd,12,1,false) ...
                blankDecimal(obj.a_s_vert_gsd,12,1,false) ...
                blankDecimal(obj.c_s_vert_gsd,12,1,false) ...
                blankDecimal(obj.geo_mean_vert_gsd,12,1,false) ...
                blankDecimal(obj.gsd_beta_angle,5,1,false) blankDecimal(obj.dynamic_range,5,0,false) ...
                decimalField(obj.num_lines,7,0,false) decimalField(obj.num_samples,5,0,false) ...
                blankDecimal(obj.angle_to_north,7,3,false) blankDecimal(obj.obliquity_angle,6,3,false) ...
                blankDecimal(obj.az_of_obliquity,7,3,false) decimalField(obj.atm_refr_flag,1,0,false) ...
                decimalField(obj.vel_aber_flag,1,0,false) decimalField(obj.grd_cover,1,0,false) ...
                decimalField(obj.snow_depth_category,1,0,false) blankDecimal(obj.sun_azimuth,7,3,false) ...
                blankDecimal(obj.sun_elevation,7,3,true) blankDecimal(obj.predicted_niirs,3,1,false) ...
                blankDecimal(obj.circl_err,5,1,false) blankDecimal(obj.linear_err,5,1,false) ...
                blankDecimal(obj.cloud_cover,3,0,false)];
            if strcmp(obj.sensor_type,'F'), value = [value blankDecimal(obj.rolling_shutter_flag,1,0,false)]; end
            value = [value blankDecimal(obj.ue_time_flag,1,0,false) decimalField(obj.reserved_len,5,0,false)];
            if ~isempty(obj.exploitation)
                data = bytes(obj.exploitation);
                value = [value uint8('011') decimalField(numel(data),5,0,false) data];
            end
        end
    end
end

function value = payloadSize(obj) %#codegen
    %payloadSize - Count all conditionals without allocating the full payload
    value = 260+36*obj.num_assoc_des+obj.reserved_len;
    if strcmp(obj.sensor_type,'S')
        value = value+39;
    elseif strcmp(obj.sensor_type,'F')
        value = value+2;
        if obj.time_stamp_loc == 0, value = value+50+obj.dt_size*obj.number_dt; end
    end
end

function mustBeAssociatedUUIDs(value) %#codegen
    %mustBeAssociatedUUIDs - Require an unconverted cell row of UUID text
    if ~iscell(value) || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:AssociatedUUIDs','Expected a cell row of DES UUID text.');
    end
    for k = 1:numel(value), mustBeAscii(value{k},36); end
end

function mustBeGLASMultiplier(value) %#codegen
    %mustBeGLASMultiplier - Preserve a positive uint64 nanosecond multiplier
    if ~isa(value,'uint64') || ~isscalar(value) || value == 0
        error('nfx:TimeMultiplier','DT_MULTIPLIER must be a positive uint64 scalar.');
    end
end
