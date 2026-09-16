classdef (Sealed) TelescopeOptics
    %TelescopeOptics - Supply frame-based or time-based telescope corrections
    %   OBJ = TelescopeOptics(Name=VALUE) uses TELESCOPE_OPTICS_FLAG=1 for
    %   per-frame transforms or =2 for transforms at supplied TELE_DATE/TIME.
    %   TELE_TRANS_T0 through T7 are matching chronological double rows.
    %
    %   Time-based corrections may include TIME_VARYING_IO_PARM_ID, an ordered
    %   row of distinct IDs 1-11. TIME_VARYING_IO_M has one row per ID and one
    %   column per time. TELE_IOP holds zero or one InteriorOrientation value
    %   for the corresponding _TELE lens parameters. NFX derives all counts.
    %
    %   See also CSSFAB, InteriorOrientation

    properties
        telescope_optics_flag {mustBeMetadata(telescope_optics_flag,1,2,1)} = NaN
        tele_trans_t0 {mustBeGLASMatrix(tele_trans_t0,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t1 {mustBeGLASMatrix(tele_trans_t1,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t2 {mustBeGLASMatrix(tele_trans_t2,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t3 {mustBeGLASMatrix(tele_trans_t3,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t4 {mustBeGLASMatrix(tele_trans_t4,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t5 {mustBeGLASMatrix(tele_trans_t5,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t6 {mustBeGLASMatrix(tele_trans_t6,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_trans_t7 {mustBeGLASMatrix(tele_trans_t7,1,4294967295,9.99999999999999e99)} = zeros(1,0)
        tele_date {mustBeAscii(tele_date,8)} = ''
        tele_time {mustBeTelescopeTimes} = zeros(1,0)
        time_varying_io_parm_id {mustBeVaryingIDs} = zeros(1,0)
        time_varying_io_m {mustBeGLASMatrix(time_varying_io_m,11,4294967295,9.99999999999999e99)} = zeros(0,0)
        tele_iop {mustBeGLASObjects(tele_iop,'nfx.InteriorOrientation')} = nfx.InteriorOrientation.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        n_frames
        n_frame_times
        n_varying_io
        num_tele_sets_fa_data
        byte_length
    end
    methods
        function obj = TelescopeOptics(options) %#codegen
            %TelescopeOptics - Construct supplied telescope transformation data
            arguments
                options.?nfx.TelescopeOptics
            end
            if isfield(options,'telescope_optics_flag'), obj.telescope_optics_flag = options.telescope_optics_flag; end
            if isfield(options,'tele_trans_t0'), obj.tele_trans_t0 = options.tele_trans_t0; end
            if isfield(options,'tele_trans_t1'), obj.tele_trans_t1 = options.tele_trans_t1; end
            if isfield(options,'tele_trans_t2'), obj.tele_trans_t2 = options.tele_trans_t2; end
            if isfield(options,'tele_trans_t3'), obj.tele_trans_t3 = options.tele_trans_t3; end
            if isfield(options,'tele_trans_t4'), obj.tele_trans_t4 = options.tele_trans_t4; end
            if isfield(options,'tele_trans_t5'), obj.tele_trans_t5 = options.tele_trans_t5; end
            if isfield(options,'tele_trans_t6'), obj.tele_trans_t6 = options.tele_trans_t6; end
            if isfield(options,'tele_trans_t7'), obj.tele_trans_t7 = options.tele_trans_t7; end
            if isfield(options,'tele_date'), obj.tele_date = options.tele_date; end
            if isfield(options,'tele_time'), obj.tele_time = options.tele_time; end
            if isfield(options,'time_varying_io_parm_id'), obj.time_varying_io_parm_id = options.time_varying_io_parm_id; end
            if isfield(options,'time_varying_io_m'), obj.time_varying_io_m = options.time_varying_io_m; end
            if isfield(options,'tele_iop'), obj.tele_iop = options.tele_iop; end
        end
        function value = get.n_frames(obj) %#codegen
            %get.n_frames - Derive the number of supplied frame transformations
            value = numel(obj.tele_trans_t0);
        end
        function value = get.n_frame_times(obj) %#codegen
            %get.n_frame_times - Derive the time-indexed transformation count
            value = numel(obj.tele_trans_t0);
        end
        function value = get.n_varying_io(obj) %#codegen
            %get.n_varying_io - Derive the number of varying parameter identities
            value = numel(obj.time_varying_io_parm_id);
        end
        function value = get.num_tele_sets_fa_data(obj) %#codegen
            %get.num_tele_sets_fa_data - Derive the optional lens-set count
            value = numel(obj.tele_iop);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count fields following TELESCOPE_OPTICS_FLAG
            value = 5+168*obj.n_frames+263*obj.num_tele_sets_fa_data;
            if obj.telescope_optics_flag == 2
                value = value+10+2*obj.n_varying_io+obj.n_frames*(15+21*obj.n_varying_io);
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check conditional fields, aligned transforms and lengths
            report = newReport('CSSFAB TelescopeOptics');
            reference = 'STDI-0002-2 Appendix M, Table M.6-7';
            report = addIssue(report,isnan(obj.telescope_optics_flag),'Required','telescope_optics_flag', ...
                'Select frame-based (1) or time-based (2) telescope corrections.',reference);
            values = {obj.tele_trans_t0,obj.tele_trans_t1,obj.tele_trans_t2,obj.tele_trans_t3,obj.tele_trans_t4,obj.tele_trans_t5,obj.tele_trans_t6,obj.tele_trans_t7};
            valid = true; count = obj.n_frames;
            for k = 1:8
                valid = valid && numel(values{k}) == count && glasScientificValid(values{k});
            end
            report = addIssue(report,~valid,'TelescopeTransformShape','tele_trans_t0/.../t7', ...
                'Supply eight equally sized rows of known encodable transform parameters.',reference);
            report = addIssue(report,obj.num_tele_sets_fa_data > 1,'TelescopeLensCount','tele_iop', ...
                'Telescope corrections permit at most one lens calibration set.',reference);
            for k = 1:obj.num_tele_sets_fa_data
                report = mergeReport(report,validate(obj.tele_iop(k)),'tele_iop');
            end
            if obj.telescope_optics_flag == 2
                report = addIssue(report,~knownDate(obj.tele_date,8) || numel(obj.tele_time) ~= count || ...
                    any(isnan(obj.tele_time)) || any(diff(obj.tele_time) <= 0) || ...
                    any(diff(round(obj.tele_time*1e9)) <= 0),'TelescopeTimes','tele_date/tele_time', ...
                    'Supply the UTC date and one increasing, nanosecond-distinct time per transform.',reference);
                report = addIssue(report,numel(unique(obj.time_varying_io_parm_id)) ~= obj.n_varying_io, ...
                    'VaryingParameterIdentity','time_varying_io_parm_id','Use each varying parameter identity at most once.',reference);
                if obj.n_varying_io == 0
                    shape = isempty(obj.time_varying_io_m);
                else
                    shape = isequal(size(obj.time_varying_io_m),[obj.n_varying_io count]);
                end
                report = addIssue(report,~shape || ~glasScientificValid(obj.time_varying_io_m), ...
                    'VaryingParameterShape','time_varying_io_m','Supply an encodable parameter-by-time value matrix.',reference);
            else
                report = addIssue(report,~isempty(char(obj.tele_date)) || ~isempty(obj.tele_time) || ...
                    ~isempty(obj.time_varying_io_parm_id) || ~isempty(obj.time_varying_io_m), ...
                    'UnusedTelescopeTime','time-based fields','Frame-based corrections omit all explicit time and varying-parameter fields.',reference);
            end
            report = addIssue(report,obj.byte_length > 999999998,'DESLength','telescope', ...
                'Telescope data must fit the DES byte limit.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode transforms and optional lens data after the flag
            requireValid(validate(obj));
            prefix = [decimalField(obj.num_tele_sets_fa_data,1,0,false) unsignedBytes(uint64(obj.n_frames),4)];
            timed = obj.telescope_optics_flag == 2;
            if timed
                prefix = [prefix decimalField(obj.n_varying_io,2,0,false)];
                for k = 1:obj.n_varying_io
                    prefix = [prefix decimalField(obj.time_varying_io_parm_id(k),2,0,false)]; %#ok<AGROW>
                end
                prefix = [prefix textField(obj.tele_date,8)];
            end
            value = zeros(1,obj.byte_length,'uint8'); at = numel(prefix); value(1:at) = prefix;
            for frame = 1:obj.n_frames
                if timed
                    value(at+(1:15)) = decimalField(obj.tele_time(frame),15,9,false); at = at+15;
                end
                terms = [obj.tele_trans_t0(frame) obj.tele_trans_t1(frame) obj.tele_trans_t2(frame) obj.tele_trans_t3(frame) obj.tele_trans_t4(frame) obj.tele_trans_t5(frame) obj.tele_trans_t6(frame) obj.tele_trans_t7(frame)];
                for k = 1:8, value(at+(1:21)) = rsmNumber(terms(k),false); at = at+21; end
                if timed
                    for k = 1:obj.n_varying_io
                        value(at+(1:21)) = rsmNumber(obj.time_varying_io_m(k,frame),false); at = at+21;
                    end
                end
            end
            if ~isempty(obj.tele_iop), value(at+(1:263)) = bytes(obj.tele_iop); end
        end
    end
end

function mustBeTelescopeTimes(value) %#codegen
    %mustBeTelescopeTimes - Validate unconverted nonnegative UTC-offset rows
    mustBeGLASMatrix(value,1,4294967295,99999.999999999);
    if any(value < 0), error('nfx:TelescopeTimes','Times must be nonnegative seconds from TELE_DATE.'); end
end

function mustBeVaryingIDs(value) %#codegen
    %mustBeVaryingIDs - Require the specified 1-11 calibration parameter IDs
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 11 || ...
            any(~isfinite(value) | fix(value) ~= value | value < 1 | value > 11)
        error('nfx:VaryingIDs','Expected a double row of calibration parameter IDs 1-11.');
    end
end
