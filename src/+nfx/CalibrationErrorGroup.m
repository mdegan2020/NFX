classdef (Sealed) CalibrationErrorGroup
    %CalibrationErrorGroup - Supply CSCSDB interior-orientation error data
    %   OBJ = CalibrationErrorGroup(Name=VALUE) stores CAL_AP_ID in supplied
    %   parameter order and ERRCOV_C3 as N-by-N-by-F covariance pages, where
    %   N is the ID count and F is the number of focal-length calibration sets.
    %   CSCSDB binds page order to its FOCAL_LENGTH_CAL row.
    %
    %   Matrices must be symmetric positive semidefinite before and after
    %   encoding. SPDCF_ID_TIME and SPDCF_ID_FL reference correlation functions
    %   for the time and focal-length dimensions. No covariance is estimated.
    %
    %   See also CSCSDB, SPDCF

    properties
        corr_ref_date_io {mustBeAscii(corr_ref_date_io,8)} = ''
        corr_ref_time_io {mustBeAscii(corr_ref_time_io,16)} = ''
        cal_ap_id {mustBeCalibrationIDs} = zeros(1,0)
        errcov_c3 {mustBeGLASCovariance(errcov_c3,11,99)} = []
        cal_interp {mustBeMetadata(cal_interp,0,1,1)} = NaN
        spdcf_id_time {mustBeMetadata(spdcf_id_time,1,99,1)} = NaN
        spdcf_id_fl {mustBeMetadata(spdcf_id_fl,1,99,1)} = NaN
    end
    properties (Dependent, SetAccess = private)
        n1cal
        num_sets_cal_ap
        parameter_count
        byte_length
    end
    methods
        function obj = CalibrationErrorGroup(options) %#codegen
            %CalibrationErrorGroup - Construct editable calibration covariance
            arguments
                options.?nfx.CalibrationErrorGroup
            end
            if isfield(options,'corr_ref_date_io'), obj.corr_ref_date_io = options.corr_ref_date_io; end
            if isfield(options,'corr_ref_time_io'), obj.corr_ref_time_io = options.corr_ref_time_io; end
            if isfield(options,'cal_ap_id'), obj.cal_ap_id = options.cal_ap_id; end
            if isfield(options,'errcov_c3'), obj.errcov_c3 = options.errcov_c3; end
            if isfield(options,'cal_interp'), obj.cal_interp = options.cal_interp; end
            if isfield(options,'spdcf_id_time'), obj.spdcf_id_time = options.spdcf_id_time; end
            if isfield(options,'spdcf_id_fl'), obj.spdcf_id_fl = options.spdcf_id_fl; end
        end
        function value = get.n1cal(obj) %#codegen
            %get.n1cal - Derive the calibration parameter count
            value = numel(obj.cal_ap_id);
        end
        function value = get.num_sets_cal_ap(obj) %#codegen
            %get.num_sets_cal_ap - Derive the number of covariance pages
            value = 0;
            if ~isempty(obj.errcov_c3), value = size(obj.errcov_c3,3); end
        end
        function value = get.parameter_count(obj) %#codegen
            %get.parameter_count - Count adjustable values across all focal sets
            value = obj.n1cal*obj.num_sets_cal_ap;
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count epochs, IDs, covariance pages and references
            n = obj.n1cal; value = 31+2*n+21*n*(n+1)/2*obj.num_sets_cal_ap;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check calibration identities, covariance and correlations
            report = newReport('CSCSDB CalibrationErrorGroup');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,~validMieTimestamp([char(obj.corr_ref_date_io) char(obj.corr_ref_time_io)]), ...
                'CalibrationEpoch','corr_ref_date_io/time_io','Supply the exact UTC last decorrelation event.',reference);
            n = obj.n1cal;
            report = addIssue(report,n < 1 || n > 11 || numel(unique(obj.cal_ap_id)) ~= n, ...
                'CalibrationParameters','cal_ap_id','Supply 1-11 distinct calibration parameter IDs.',reference);
            valid = obj.num_sets_cal_ap >= 1 && obj.num_sets_cal_ap <= 99 && ...
                size(obj.errcov_c3,1) == n && size(obj.errcov_c3,2) == n;
            if valid
                for k = 1:obj.num_sets_cal_ap, valid = valid && glasCovariance(obj.errcov_c3(:,:,k),false); end
            end
            report = addIssue(report,~valid,'CalibrationCovariance','errcov_c3', ...
                'Supply 1-99 known N-by-N symmetric positive semidefinite covariance pages.',reference);
            report = addIssue(report,any(isnan([obj.cal_interp obj.spdcf_id_time obj.spdcf_id_fl])), ...
                'Required','cal_interp/spdcf_id_time/fl','Supply interpolation and both correlation references.',reference);
        end
        function value = references(obj) %#codegen
            %REFERENCES - Return time and focal-length correlation identifiers
            value = [obj.spdcf_id_time obj.spdcf_id_fl];
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode one group with covariance in focal-set order
            requireValid(validate(obj));
            prefix = [textField(obj.corr_ref_date_io,8) textField(obj.corr_ref_time_io,16) decimalField(obj.n1cal,2,0,false)];
            for k = 1:obj.n1cal, prefix = [prefix decimalField(obj.cal_ap_id(k),2,0,false)]; end %#ok<AGROW>
            value = zeros(1,obj.byte_length,'uint8'); at = numel(prefix); value(1:at) = prefix;
            for k = 1:obj.num_sets_cal_ap
                [~,data] = glasCovariance(obj.errcov_c3(:,:,k),true);
                value(at+(1:numel(data))) = data; at = at+numel(data);
            end
            value(at+(1:5)) = [decimalField(obj.cal_interp,1,0,false) decimalField(obj.spdcf_id_time,2,0,false) ...
                decimalField(obj.spdcf_id_fl,2,0,false)];
        end
    end
end

function mustBeCalibrationIDs(value) %#codegen
    %mustBeCalibrationIDs - Require an unconverted calibration-ID row
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 11 || ...
            any(~isfinite(value) | fix(value) ~= value | value < 1 | value > 11)
        error('nfx:CalibrationIDs','Expected a double row of calibration parameter IDs 1-11.');
    end
end
