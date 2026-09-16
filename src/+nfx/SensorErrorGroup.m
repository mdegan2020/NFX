classdef (Sealed) SensorErrorGroup
    %SensorErrorGroup - Supply one fundamental-parameter CSCSDB error group
    %   OBJ = SensorErrorGroup(Name=VALUE) defines ADJ_PARM_ID in parameter
    %   order (1-3 position, 4-6 attitude, 7 focal length). ERRCOV_C1 supplies
    %   optional basic covariance; ERRCOV_C2 supplies optional correction-post
    %   covariance. Both allocations may be present.
    %
    %   A single ERRCOV_C2 matrix applies to all NUM_POSTS. An N-by-N-by-P
    %   array supplies one covariance per post, where N is the parameter
    %   count and P equals NUM_POSTS. Matrices must be symmetric positive
    %   semidefinite before and after encoding. NFX never fits covariance.
    %
    %   BASIC_PF/PL and POST_PF/PL hold CorrelationPairing rows. Sensor-level
    %   *_SR_SPDCF identifiers use NaN when absent. POST_CORR is required only
    %   with POST_SR_SPDCF. Counts and presence flags derive from these values.
    %
    %   See also SensorErrorCore, CorrelationPairing, SPDCF, CSCSDB

    properties
        corr_ref_date {mustBeAscii(corr_ref_date,8)} = ''
        corr_ref_time {mustBeAscii(corr_ref_time,16)} = ''
        adj_parm_id {mustBeFundamentalIDs} = zeros(1,0)
        errcov_c1 {mustBeGLASCovariance(errcov_c1,7,1)} = []
        basic_pf {mustBeGLASObjects(basic_pf,'nfx.CorrelationPairing')} = nfx.CorrelationPairing.empty(1,0)
        basic_pl {mustBeGLASObjects(basic_pl,'nfx.CorrelationPairing')} = nfx.CorrelationPairing.empty(1,0)
        basic_sr_spdcf {mustBeMetadata(basic_sr_spdcf,1,99,1)} = NaN
        post_start_date {mustBeAscii(post_start_date,8)} = ''
        post_start_time {mustBeMetadata(post_start_time,0,86399.999999999,0)} = NaN
        post_dt {mustBeMetadata(post_dt,0,999.999999999,0)} = NaN
        num_posts {mustBeMetadata(num_posts,2,999,1)} = NaN
        errcov_c2 {mustBeGLASCovariance(errcov_c2,7,999)} = []
        post_interp {mustBeMetadata(post_interp,0,1,1)} = NaN
        post_pf {mustBeGLASObjects(post_pf,'nfx.CorrelationPairing')} = nfx.CorrelationPairing.empty(1,0)
        post_pl {mustBeGLASObjects(post_pl,'nfx.CorrelationPairing')} = nfx.CorrelationPairing.empty(1,0)
        post_sr_spdcf {mustBeMetadata(post_sr_spdcf,1,99,1)} = NaN
        post_corr {mustBeMetadata(post_corr,0,1,1)} = NaN
    end
    properties (Dependent, SetAccess = private)
        num_adj_parm
        basic_sub_alloc
        post_sub_alloc
        common_posts_cov
        parameter_count
        byte_length
    end
    methods
        function obj = SensorErrorGroup(options) %#codegen
            %SensorErrorGroup - Construct editable covariance and correlation data
            arguments
                options.?nfx.SensorErrorGroup
            end
            if isfield(options,'corr_ref_date'), obj.corr_ref_date = options.corr_ref_date; end
            if isfield(options,'corr_ref_time'), obj.corr_ref_time = options.corr_ref_time; end
            if isfield(options,'adj_parm_id'), obj.adj_parm_id = options.adj_parm_id; end
            if isfield(options,'errcov_c1'), obj.errcov_c1 = options.errcov_c1; end
            if isfield(options,'basic_pf'), obj.basic_pf = options.basic_pf; end
            if isfield(options,'basic_pl'), obj.basic_pl = options.basic_pl; end
            if isfield(options,'basic_sr_spdcf'), obj.basic_sr_spdcf = options.basic_sr_spdcf; end
            if isfield(options,'post_start_date'), obj.post_start_date = options.post_start_date; end
            if isfield(options,'post_start_time'), obj.post_start_time = options.post_start_time; end
            if isfield(options,'post_dt'), obj.post_dt = options.post_dt; end
            if isfield(options,'num_posts'), obj.num_posts = options.num_posts; end
            if isfield(options,'errcov_c2'), obj.errcov_c2 = options.errcov_c2; end
            if isfield(options,'post_interp'), obj.post_interp = options.post_interp; end
            if isfield(options,'post_pf'), obj.post_pf = options.post_pf; end
            if isfield(options,'post_pl'), obj.post_pl = options.post_pl; end
            if isfield(options,'post_sr_spdcf'), obj.post_sr_spdcf = options.post_sr_spdcf; end
            if isfield(options,'post_corr'), obj.post_corr = options.post_corr; end
        end
        function value = get.num_adj_parm(obj) %#codegen
            %get.num_adj_parm - Derive the fundamental parameter count
            value = numel(obj.adj_parm_id);
        end
        function value = get.basic_sub_alloc(obj) %#codegen
            %get.basic_sub_alloc - Derive basic covariance presence
            value = double(~isempty(obj.errcov_c1));
        end
        function value = get.post_sub_alloc(obj) %#codegen
            %get.post_sub_alloc - Derive correction-post covariance presence
            value = double(~isempty(obj.errcov_c2));
        end
        function value = get.common_posts_cov(obj) %#codegen
            %get.common_posts_cov - Derive whether one covariance serves all posts
            value = double(size(obj.errcov_c2,3) == 1);
        end
        function value = get.parameter_count(obj) %#codegen
            %get.parameter_count - Count basic and per-post adjustable parameters
            value = obj.num_adj_parm*obj.basic_sub_alloc;
            if obj.post_sub_alloc, value = value+obj.num_adj_parm*obj.num_posts; end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count conditional covariance and pairing fields
            n = obj.num_adj_parm; triangle = 21*n*(n+1)/2; value = 27+n;
            if obj.basic_sub_alloc
                value = value+triangle+pairingsLength(obj.basic_pf)+pairingsLength(obj.basic_pl)+1+2*~isnan(obj.basic_sr_spdcf);
            end
            if obj.post_sub_alloc
                value = value+41+triangle*size(obj.errcov_c2,3)+pairingsLength(obj.post_pf)+pairingsLength(obj.post_pl)+1+3*~isnan(obj.post_sr_spdcf);
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check allocation conditions, PSD matrices and pairing lists
            report = newReport('CSCSDB SensorErrorGroup');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,~validMieTimestamp([char(obj.corr_ref_date) char(obj.corr_ref_time)]), ...
                'CorrelationEpoch','corr_ref_date/time','Supply the exact UTC last decorrelation event.',reference);
            n = obj.num_adj_parm;
            report = addIssue(report,n < 1 || n > 7 || numel(unique(obj.adj_parm_id)) ~= n, ...
                'FundamentalParameters','adj_parm_id','Supply 1-7 distinct fundamental parameter IDs.',reference);
            if obj.basic_sub_alloc
                valid = isequal(size(obj.errcov_c1),[n n]);
                if valid, valid = glasCovariance(obj.errcov_c1,false); end
                report = addIssue(report,~valid,'BasicCovariance','errcov_c1', ...
                    'Supply an N-by-N symmetric positive semidefinite encodable basic covariance.',reference);
            else
                report = addIssue(report,~isempty(obj.basic_pf) || ~isempty(obj.basic_pl) || ~isnan(obj.basic_sr_spdcf), ...
                    'UnusedBasicCorrelation','basic correlations','Basic SPDCF associations require basic covariance.',reference);
            end
            if obj.post_sub_alloc
                report = addIssue(report,~knownDate(obj.post_start_date,8) || ...
                    any(isnan([obj.post_start_time obj.post_dt obj.num_posts obj.post_interp])), ...
                    'PostTiming','post_start_date/time/post_dt/num_posts/post_interp', ...
                    'Supply post timing, count and interpolation metadata.',reference);
                valid = size(obj.errcov_c2,1) == n && size(obj.errcov_c2,2) == n && ...
                    any(size(obj.errcov_c2,3) == [1 obj.num_posts]);
                if valid
                    for k = 1:size(obj.errcov_c2,3), valid = valid && glasCovariance(obj.errcov_c2(:,:,k),false); end
                end
                report = addIssue(report,~valid,'PostCovariance','errcov_c2', ...
                    'Supply one common N-by-N PSD covariance or one matrix for each correction post.',reference);
                report = addIssue(report,isnan(obj.post_sr_spdcf) ~= isnan(obj.post_corr), ...
                    'PostCorrelationFlag','post_sr_spdcf/post_corr','POST_CORR is present exactly when POST_SR_SPDCF is supplied.',reference);
            else
                report = addIssue(report,~isempty(char(obj.post_start_date)) || ...
                    any(~isnan([obj.post_start_time obj.post_dt obj.num_posts obj.post_interp obj.post_sr_spdcf obj.post_corr])) || ...
                    ~isempty(obj.post_pf) || ~isempty(obj.post_pl),'UnusedPostData','post metadata', ...
                    'Post metadata appears only with correction-post covariance.',reference);
            end
            report = mergeReport(report,pairingsReport(obj.basic_pf),'basic_pf');
            report = mergeReport(report,pairingsReport(obj.basic_pl),'basic_pl');
            report = mergeReport(report,pairingsReport(obj.post_pf),'post_pf');
            report = mergeReport(report,pairingsReport(obj.post_pl),'post_pl');
        end
        function value = references(obj) %#codegen
            %REFERENCES - Return the supplied correlation-definition identifiers
            lists = {obj.basic_pf,obj.basic_pl,obj.post_pf,obj.post_pl};
            value = zeros(1,0);
            for k = 1:4
                for j = 1:numel(lists{k}), value(end+1) = lists{k}(j).spdcf_id; end
            end
            if ~isnan(obj.basic_sr_spdcf), value(end+1) = obj.basic_sr_spdcf; end
            if ~isnan(obj.post_sr_spdcf), value(end+1) = obj.post_sr_spdcf; end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode base allocation followed by correction-post allocation
            requireValid(validate(obj));
            value = [textField(obj.corr_ref_date,8) textField(obj.corr_ref_time,16) decimalField(obj.num_adj_parm,1,0,false)];
            for k = 1:obj.num_adj_parm, value = [value decimalField(obj.adj_parm_id(k),1,0,false)]; end %#ok<AGROW>
            value = [value decimalField(obj.basic_sub_alloc,1,0,false)];
            if obj.basic_sub_alloc
                [~,covariance] = glasCovariance(obj.errcov_c1,true);
                value = [value covariance pairingsBytes(obj.basic_pf) pairingsBytes(obj.basic_pl) ...
                    decimalField(double(~isnan(obj.basic_sr_spdcf)),1,0,false)];
                if ~isnan(obj.basic_sr_spdcf), value = [value decimalField(obj.basic_sr_spdcf,2,0,false)]; end
            end
            value = [value decimalField(obj.post_sub_alloc,1,0,false)];
            if obj.post_sub_alloc
                value = [value textField(obj.post_start_date,8) decimalField(obj.post_start_time,15,9,false) ...
                    decimalField(obj.post_dt,13,9,false) decimalField(obj.num_posts,3,0,false) decimalField(obj.common_posts_cov,1,0,false)];
                for k = 1:size(obj.errcov_c2,3)
                    [~,covariance] = glasCovariance(obj.errcov_c2(:,:,k),true);
                    value = [value covariance]; %#ok<AGROW>
                end
                value = [value decimalField(obj.post_interp,1,0,false) pairingsBytes(obj.post_pf) ...
                    pairingsBytes(obj.post_pl) decimalField(double(~isnan(obj.post_sr_spdcf)),1,0,false)];
                if ~isnan(obj.post_sr_spdcf)
                    value = [value decimalField(obj.post_sr_spdcf,2,0,false) decimalField(obj.post_corr,1,0,false)];
                end
            end
        end
    end
end

function mustBeFundamentalIDs(value) %#codegen
    %mustBeFundamentalIDs - Require a short unconverted fundamental-ID row
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 7 || ...
            any(~isfinite(value) | fix(value) ~= value | value < 1 | value > 7)
        error('nfx:FundamentalIDs','Expected a double row of fundamental parameter IDs 1-7.');
    end
end

function value = pairingsLength(items) %#codegen
    %pairingsLength - Count a presence flag and its conditional pairing list
    value = 1;
    if ~isempty(items)
        value = value+2;
        for k = 1:numel(items), value = value+items(k).byte_length; end
    end
end

function report = pairingsReport(items) %#codegen
    %pairingsReport - Validate count and unambiguous sensor-to-SPDCF associations
    report = newReport('CSCSDB pairing list'); reference = 'STDI-0002-2 Appendix M, Table M.6-5';
    report = addIssue(report,numel(items) > 99,'PairingCount','pairings','At most 99 SPDCF pairings are permitted per type.',reference);
    names = cell(1,0);
    for k = 1:numel(items)
        report = mergeReport(report,validate(items(k)),sprintf('(%.0f)',k));
        for j = 1:numel(items(k).sensor_id)
            id = strtrim(char(items(k).sensor_id{j}));
            report = addIssue(report,any(strcmp(id,names)) || ...
                (strcmp(id,'ALL') && (~isempty(names) || numel(items) > 1)) || any(strcmp('ALL',names)), ...
                'AmbiguousSensorCorrelation','sensor_id','A sensor pairing must select a single SPDCF within this type.',reference);
            names{end+1} = id;
        end
    end
end

function value = pairingsBytes(items) %#codegen
    %pairingsBytes - Encode a presence flag, count and ordered pairing list
    value = decimalField(double(~isempty(items)),1,0,false);
    if isempty(items), return; end
    value = [value decimalField(numel(items),2,0,false)];
    for k = 1:numel(items), value = [value bytes(items(k))]; end %#ok<AGROW>
end
