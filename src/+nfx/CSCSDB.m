classdef (Sealed) CSCSDB < nfx.SensorDES
    %CSCSDB - Encode supplied GLAS/GFM covariance and adjustment metadata
    %   OBJ = CSCSDB(Name=VALUE) contains ordered CORES, CALIBRATION_GROUPS,
    %   optional TIME_SYNC and UNMODELED blocks, and identified SPDCF values.
    %   Counts and flags derive from the supplied value descriptors. Version
    %   one is the supported definition. No error model is estimated.
    %
    %   FOCAL_LENGTH_CAL orders each calibration group's covariance pages.
    %   ADJ and ERRCOV_C4 optionally hold externally computed corrections
    %   and their covariance for all described adjustable parameters. Keep
    %   the original error metadata when supplying those results. Ordering is
    %   core/group (basic then posts), calibration group/focal set, then time
    %   synchronization position, attitude and optional focal length.
    %
    %   SPDCF_ID_ADJ optionally supplies current Table M.6-5 reserved area 1.
    %   Its defined byte counts are used; the older packing criteria retain
    %   contradictory zero-reserved requirements. This optional area carries
    %   no claim of profile conformance pending clarification of that conflict.
    %
    %   See also SensorErrorCore, CalibrationErrorGroup, TimeSyncError, SPDCF

    properties (Constant)
        desid = 'CSCSDB'
    end
    properties
        cov_version_date {mustBeAscii(cov_version_date,8)} = ''
        cores {mustBeGLASObjects(cores,'nfx.SensorErrorCore')} = nfx.SensorErrorCore.empty(1,0)
        focal_length_cal {mustBeGLASMatrix(focal_length_cal,1,99,99.99999999)} = zeros(1,0)
        calibration_groups {mustBeGLASObjects(calibration_groups,'nfx.CalibrationErrorGroup')} = nfx.CalibrationErrorGroup.empty(1,0)
        time_sync {mustBeGLASObjects(time_sync,'nfx.TimeSyncError')} = nfx.TimeSyncError.empty(1,0)
        unmodeled {mustBeGLASObjects(unmodeled,'nfx.UnmodeledErrorGrid')} = nfx.UnmodeledErrorGrid.empty(1,0)
        spdcf {mustBeGLASObjects(spdcf,'nfx.SPDCF')} = nfx.SPDCF.empty(1,0)
        adj {mustBeGLASMatrix(adj,1,9999,9.99999999999999e99)} = zeros(1,0)
        errcov_c4 {mustBeGLASCovariance(errcov_c4,9999,1)} = []
        spdcf_id_adj {mustBeAdjustmentReferences} = zeros(1,0)
    end
    properties (Dependent, SetAccess = private)
        core_sets
        io_cal_ap
        num_sets_cal_ap
        ncal_cpg
        ts_cal_ap
        ue_flag
        spdcf_flag
        num_spdcf
        direct_covariance_flag
        dc_type
        num_para
        parameter_count
        reserved_len
        byte_length
    end
    methods
        function obj = CSCSDB(options) %#codegen
            %CSCSDB - Construct editable sensor covariance and associations
            arguments
                options.?nfx.CSCSDB
            end
            obj.desver = 1;
            if isfield(options,'uuid'), obj.uuid = options.uuid; end
            if isfield(options,'aisdlvl'), obj.aisdlvl = options.aisdlvl; end
            if isfield(options,'all_images'), obj.all_images = options.all_images; end
            if isfield(options,'assoc_elem_uuid'), obj.assoc_elem_uuid = options.assoc_elem_uuid; end
            if isfield(options,'desver'), obj.desver = options.desver; end
            if isfield(options,'desclas'), obj.desclas = options.desclas; end
            if isfield(options,'cov_version_date'), obj.cov_version_date = options.cov_version_date; end
            if isfield(options,'cores'), obj.cores = options.cores; end
            if isfield(options,'focal_length_cal'), obj.focal_length_cal = options.focal_length_cal; end
            if isfield(options,'calibration_groups'), obj.calibration_groups = options.calibration_groups; end
            if isfield(options,'time_sync'), obj.time_sync = options.time_sync; end
            if isfield(options,'unmodeled'), obj.unmodeled = options.unmodeled; end
            if isfield(options,'spdcf'), obj.spdcf = options.spdcf; end
            if isfield(options,'adj'), obj.adj = options.adj; end
            if isfield(options,'errcov_c4'), obj.errcov_c4 = options.errcov_c4; end
            if isfield(options,'spdcf_id_adj'), obj.spdcf_id_adj = options.spdcf_id_adj; end
        end
        function value = get.core_sets(obj) %#codegen
            %get.core_sets - Derive the number of supplied core sets
            value = numel(obj.cores);
        end
        function value = get.io_cal_ap(obj) %#codegen
            %get.io_cal_ap - Derive the calibration block presence flag
            value = double(~isempty(obj.calibration_groups));
        end
        function value = get.num_sets_cal_ap(obj) %#codegen
            %get.num_sets_cal_ap - Derive the number of focal calibration sets
            value = numel(obj.focal_length_cal);
        end
        function value = get.ncal_cpg(obj) %#codegen
            %get.ncal_cpg - Derive the calibration correlation-group count
            value = numel(obj.calibration_groups);
        end
        function value = get.ts_cal_ap(obj) %#codegen
            %get.ts_cal_ap - Derive the time synchronization presence flag
            value = double(~isempty(obj.time_sync));
        end
        function value = get.ue_flag(obj) %#codegen
            %get.ue_flag - Derive the unmodeled error presence flag
            value = double(~isempty(obj.unmodeled));
        end
        function value = get.spdcf_flag(obj) %#codegen
            %get.spdcf_flag - Derive the correlation function presence flag
            value = double(~isempty(obj.spdcf));
        end
        function value = get.num_spdcf(obj) %#codegen
            %get.num_spdcf - Derive the number of correlation functions
            value = numel(obj.spdcf);
        end
        function value = get.direct_covariance_flag(obj) %#codegen
            %get.direct_covariance_flag - Derive adjustment data presence
            value = double(~isempty(obj.adj) || ~isempty(obj.errcov_c4));
        end
        function value = get.dc_type(obj) %#codegen
            %get.dc_type - Select the currently defined direct covariance layout
            value = NaN;
            if obj.direct_covariance_flag, value = 0; end
        end
        function value = get.num_para(obj) %#codegen
            %get.num_para - Derive the serialized adjustment count
            value = numel(obj.adj);
        end
        function value = get.parameter_count(obj) %#codegen
            %get.parameter_count - Count all adjustable values in model order
            value = 0;
            for k = 1:obj.core_sets, value = value+obj.cores(k).parameter_count; end
            for k = 1:obj.ncal_cpg, value = value+obj.calibration_groups(k).parameter_count; end
            for k = 1:numel(obj.time_sync), value = value+obj.time_sync(k).parameter_count; end
        end
        function value = get.reserved_len(obj) %#codegen
            %get.reserved_len - Count the defined adjustment correlation area
            value = 0;
            if ~isempty(obj.spdcf_id_adj), value = 12+2*numel(obj.spdcf_id_adj); end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Preflight the complete DES payload allocation
            value = 23+obj.reserved_len;
            for k = 1:obj.core_sets, value = value+obj.cores(k).byte_length; end
            if obj.io_cal_ap, value = value+4+11*obj.num_sets_cal_ap; end
            for k = 1:obj.ncal_cpg, value = value+obj.calibration_groups(k).byte_length; end
            for k = 1:numel(obj.time_sync), value = value+obj.time_sync(k).byte_length; end
            for k = 1:numel(obj.unmodeled), value = value+obj.unmodeled(k).byte_length; end
            if obj.spdcf_flag, value = value+2; end
            for k = 1:obj.num_spdcf, value = value+obj.spdcf(k).byte_length; end
            if obj.direct_covariance_flag, value = value+5+21*obj.num_para+21*obj.num_para*(obj.num_para+1)/2; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check all allocations, internal references and byte limits
            report = headerReport(obj);
            reference = 'STDI-0002-2 Appendix M, Table M.6-5 and M.8';
            report = addIssue(report,obj.desver ~= 1,'CovarianceVersion','desver','CSCSDB uses definition version one.',reference);
            report = addIssue(report,~validMieTimestamp([char(obj.cov_version_date) '000000.000000000']), ...
                'CovarianceDate','cov_version_date','Supply a valid covariance version date.',reference);
            report = addIssue(report,obj.core_sets > 6,'CoreCount','cores','At most six core sets are permitted.',reference);
            report = addIssue(report,obj.ncal_cpg > 11,'CalibrationCount','calibration_groups','At most eleven calibration groups are permitted.',reference);
            report = addIssue(report,numel(obj.time_sync) > 1 || numel(obj.unmodeled) > 1, ...
                'CovarianceBlocks','time_sync/unmodeled','Supply at most one time synchronization block and one unmodeled grid.',reference);
            for k = 1:obj.core_sets, report = mergeReport(report,validate(obj.cores(k)),sprintf('cores(%.0f)',k)); end
            valid = isempty(obj.focal_length_cal);
            if obj.io_cal_ap
                valid = obj.num_sets_cal_ap >= 1 && all(isfinite(obj.focal_length_cal)) && all(obj.focal_length_cal >= 0);
            end
            report = addIssue(report,~valid,'FocalCalibration','focal_length_cal', ...
                'Supply 1-99 known nonnegative focal lengths exactly when calibration groups are present.',reference);
            for k = 1:obj.ncal_cpg
                report = mergeReport(report,validate(obj.calibration_groups(k)),sprintf('calibration_groups(%.0f)',k));
                report = addIssue(report,obj.calibration_groups(k).num_sets_cal_ap ~= obj.num_sets_cal_ap, ...
                    'CalibrationPages','calibration_groups.errcov_c3','Each group needs one covariance page per focal-length set.',reference);
            end
            for k = 1:numel(obj.time_sync), report = mergeReport(report,validate(obj.time_sync(k)),'time_sync'); end
            for k = 1:numel(obj.unmodeled), report = mergeReport(report,validate(obj.unmodeled(k)),'unmodeled'); end
            ids = zeros(1,obj.num_spdcf);
            report = addIssue(report,obj.num_spdcf > 99,'SPDCFCount','spdcf','At most 99 SPDCF definitions are permitted.',reference);
            for k = 1:obj.num_spdcf
                report = mergeReport(report,validate(obj.spdcf(k)),sprintf('spdcf(%.0f)',k)); ids(k) = obj.spdcf(k).spdcf_id;
            end
            report = addIssue(report,numel(unique(ids)) ~= numel(ids),'DuplicateSPDCF','spdcf.spdcf_id', ...
                'Each correlation identifier must have one definition.',reference);
            used = references(obj);
            report = addIssue(report,any(~ismember(used,ids)),'MissingSPDCF','correlation references', ...
                'Every correlation reference must identify a SPDCF in this DES.',reference);
            fits = obj.byte_length <= 999999998;
            report = addIssue(report,~fits,'DESLength','covariance','The complete payload must fit 999999998 bytes.',reference);
            if obj.direct_covariance_flag
                n = obj.num_para;
                valid = n >= 1 && n <= 9999 && n == obj.parameter_count && ...
                    isequal(size(obj.errcov_c4),[n n]) && glasScientificValid(obj.adj);
                if valid && fits, valid = glasCovariance(obj.errcov_c4,false); end
                report = addIssue(report,~valid,'DirectCovariance','adj/errcov_c4', ...
                    'Supply one correction and a known PSD covariance for every described adjustable parameter.',reference);
            end
            report = addIssue(report,~isempty(obj.spdcf_id_adj) && ...
                (~obj.direct_covariance_flag || numel(obj.spdcf_id_adj) ~= obj.num_para), ...
                'AdjustmentCorrelations','spdcf_id_adj','Supply one correlation ID per direct adjustment, or omit the area.',reference);
        end
        function value = references(obj) %#codegen
            %REFERENCES - Collect all locally bound correlation identifiers
            value = obj.spdcf_id_adj;
            for k = 1:obj.core_sets, value = [value references(obj.cores(k))]; end %#ok<AGROW>
            for k = 1:obj.ncal_cpg, value = [value references(obj.calibration_groups(k))]; end %#ok<AGROW>
            for k = 1:numel(obj.time_sync), value = [value references(obj.time_sync(k))]; end %#ok<AGROW>
            for k = 1:numel(obj.unmodeled), value = [value references(obj.unmodeled(k))]; end %#ok<AGROW>
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode all defined allocations without changing their order
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8'); at = 0;
            [value,at] = put(value,at,[textField(obj.cov_version_date,8) decimalField(obj.core_sets,1,0,false)]);
            for k = 1:obj.core_sets, [value,at] = put(value,at,bytes(obj.cores(k))); end
            [value,at] = put(value,at,decimalField(obj.io_cal_ap,1,0,false));
            if obj.io_cal_ap
                [value,at] = put(value,at,decimalField(obj.num_sets_cal_ap,2,0,false));
                for k = 1:obj.num_sets_cal_ap, [value,at] = put(value,at,decimalField(obj.focal_length_cal(k),11,8,false)); end
                [value,at] = put(value,at,decimalField(obj.ncal_cpg,2,0,false));
                for k = 1:obj.ncal_cpg, [value,at] = put(value,at,bytes(obj.calibration_groups(k))); end
            end
            [value,at] = put(value,at,decimalField(obj.ts_cal_ap,1,0,false));
            if obj.ts_cal_ap, [value,at] = put(value,at,bytes(obj.time_sync)); end
            [value,at] = put(value,at,decimalField(obj.ue_flag,1,0,false));
            if obj.ue_flag, [value,at] = put(value,at,bytes(obj.unmodeled)); end
            [value,at] = put(value,at,decimalField(obj.spdcf_flag,1,0,false));
            if obj.spdcf_flag
                [value,at] = put(value,at,decimalField(obj.num_spdcf,2,0,false));
                for k = 1:obj.num_spdcf, [value,at] = put(value,at,bytes(obj.spdcf(k))); end
            end
            [value,at] = put(value,at,decimalField(obj.direct_covariance_flag,1,0,false));
            if obj.direct_covariance_flag
                [value,at] = put(value,at,[uint8('0') decimalField(obj.num_para,4,0,false)]);
                for k = 1:obj.num_para, [value,at] = put(value,at,rsmNumber(obj.adj(k),false)); end
                [~,covariance] = glasCovariance(obj.errcov_c4,true); [value,at] = put(value,at,covariance);
            end
            [value,at] = put(value,at,decimalField(obj.reserved_len,9,0,false));
            if obj.reserved_len > 0
                [value,at] = put(value,at,[uint8('011') decimalField(2*obj.num_para,9,0,false)]);
                for k = 1:obj.num_para, [value,at] = put(value,at,decimalField(obj.spdcf_id_adj(k),2,0,false)); end
            end
        end
    end
end

function [value,at] = put(value,at,data) %#codegen
    %put - Append within the preflighted payload allocation
    value(at+(1:numel(data))) = data; at = at+numel(data);
end

function mustBeAdjustmentReferences(value) %#codegen
    %mustBeAdjustmentReferences - Require a bounded row of known correlation IDs
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 9999 || ...
            any(~isfinite(value) | fix(value) ~= value | value < 1 | value > 99)
        error('nfx:AdjustmentReferences','Expected a double row of correlation IDs 1-99.');
    end
end
