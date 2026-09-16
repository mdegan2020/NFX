classdef (Sealed) TimeSyncError
    %TimeSyncError - Supply CSCSDB time synchronization error groups
    %   OBJ = TimeSyncError(Name=VALUE) selects the published NUM_TS_GRP
    %   layout: 1 couples position/attitude, 2 separates them, 3 couples all
    %   three, 4 couples position/attitude and separates focal length, and
    %   5 separates all three. Covariances are in seconds squared.
    %
    %   Supply the exact UTC decorrelation epochs and SPDCF references for
    %   the selected layout. Unused fields must remain empty or NaN.
    %   No timing corrections or covariances are estimated.
    %
    %   See also CSCSDB, SPDCF, CalibrationErrorGroup

    properties
        num_ts_grp {mustBeMetadata(num_ts_grp,1,5,1)} = NaN
        corr_ref_date_ts {mustBeAscii(corr_ref_date_ts,8)} = ''
        corr_ref_time_ts {mustBeAscii(corr_ref_time_ts,16)} = ''
        corr_ref_date_tsp {mustBeAscii(corr_ref_date_tsp,8)} = ''
        corr_ref_time_tsp {mustBeAscii(corr_ref_time_tsp,16)} = ''
        corr_ref_date_tsa {mustBeAscii(corr_ref_date_tsa,8)} = ''
        corr_ref_time_tsa {mustBeAscii(corr_ref_time_tsa,16)} = ''
        corr_ref_date_tspa {mustBeAscii(corr_ref_date_tspa,8)} = ''
        corr_ref_time_tspa {mustBeAscii(corr_ref_time_tspa,16)} = ''
        corr_ref_date_tsfl {mustBeAscii(corr_ref_date_tsfl,8)} = ''
        corr_ref_time_tsfl {mustBeAscii(corr_ref_time_tsfl,16)} = ''
        tsrr {mustBeMetadata(tsrr,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        tsrc {mustBeMetadata(tsrc,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        tscc {mustBeMetadata(tscc,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_pos_cov {mustBeMetadata(ts_pos_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_pos_att_cov {mustBeMetadata(ts_pos_att_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_pos_fl_cov {mustBeMetadata(ts_pos_fl_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_att_cov {mustBeMetadata(ts_att_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_att_fl_cov {mustBeMetadata(ts_att_fl_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_fl_cov {mustBeMetadata(ts_fl_cov,-9.99999999999999e99,9.99999999999999e99,0)} = NaN
        ts_spdcf {mustBeMetadata(ts_spdcf,1,99,1)} = NaN
        ts_pos_spdcf {mustBeMetadata(ts_pos_spdcf,1,99,1)} = NaN
        ts_att_spdcf {mustBeMetadata(ts_att_spdcf,1,99,1)} = NaN
        ts_pa_spdcf {mustBeMetadata(ts_pa_spdcf,1,99,1)} = NaN
        ts_fl_spdcf {mustBeMetadata(ts_fl_spdcf,1,99,1)} = NaN
    end
    properties (Dependent, SetAccess = private)
        parameter_count
        byte_length
    end
    methods
        function obj = TimeSyncError(options) %#codegen
            %TimeSyncError - Construct editable synchronization covariance
            arguments
                options.?nfx.TimeSyncError
            end
            if isfield(options,'num_ts_grp'), obj.num_ts_grp = options.num_ts_grp; end
            if isfield(options,'corr_ref_date_ts'), obj.corr_ref_date_ts = options.corr_ref_date_ts; end
            if isfield(options,'corr_ref_time_ts'), obj.corr_ref_time_ts = options.corr_ref_time_ts; end
            if isfield(options,'corr_ref_date_tsp'), obj.corr_ref_date_tsp = options.corr_ref_date_tsp; end
            if isfield(options,'corr_ref_time_tsp'), obj.corr_ref_time_tsp = options.corr_ref_time_tsp; end
            if isfield(options,'corr_ref_date_tsa'), obj.corr_ref_date_tsa = options.corr_ref_date_tsa; end
            if isfield(options,'corr_ref_time_tsa'), obj.corr_ref_time_tsa = options.corr_ref_time_tsa; end
            if isfield(options,'corr_ref_date_tspa'), obj.corr_ref_date_tspa = options.corr_ref_date_tspa; end
            if isfield(options,'corr_ref_time_tspa'), obj.corr_ref_time_tspa = options.corr_ref_time_tspa; end
            if isfield(options,'corr_ref_date_tsfl'), obj.corr_ref_date_tsfl = options.corr_ref_date_tsfl; end
            if isfield(options,'corr_ref_time_tsfl'), obj.corr_ref_time_tsfl = options.corr_ref_time_tsfl; end
            if isfield(options,'tsrr'), obj.tsrr = options.tsrr; end
            if isfield(options,'tsrc'), obj.tsrc = options.tsrc; end
            if isfield(options,'tscc'), obj.tscc = options.tscc; end
            if isfield(options,'ts_pos_cov'), obj.ts_pos_cov = options.ts_pos_cov; end
            if isfield(options,'ts_pos_att_cov'), obj.ts_pos_att_cov = options.ts_pos_att_cov; end
            if isfield(options,'ts_pos_fl_cov'), obj.ts_pos_fl_cov = options.ts_pos_fl_cov; end
            if isfield(options,'ts_att_cov'), obj.ts_att_cov = options.ts_att_cov; end
            if isfield(options,'ts_att_fl_cov'), obj.ts_att_fl_cov = options.ts_att_fl_cov; end
            if isfield(options,'ts_fl_cov'), obj.ts_fl_cov = options.ts_fl_cov; end
            if isfield(options,'ts_spdcf'), obj.ts_spdcf = options.ts_spdcf; end
            if isfield(options,'ts_pos_spdcf'), obj.ts_pos_spdcf = options.ts_pos_spdcf; end
            if isfield(options,'ts_att_spdcf'), obj.ts_att_spdcf = options.ts_att_spdcf; end
            if isfield(options,'ts_pa_spdcf'), obj.ts_pa_spdcf = options.ts_pa_spdcf; end
            if isfield(options,'ts_fl_spdcf'), obj.ts_fl_spdcf = options.ts_fl_spdcf; end
        end
        function value = get.parameter_count(obj) %#codegen
            %get.parameter_count - Count position, attitude and optional focal APs
            value = 0;
            if any(obj.num_ts_grp == [1 2]), value = 2; end
            if any(obj.num_ts_grp == [3 4 5]), value = 3; end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count the selected covariance layout
            lengths = [90 95 153 137 142]; value = 1;
            if ~isnan(obj.num_ts_grp), value = lengths(obj.num_ts_grp); end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check active epochs, PSD covariance and absent fields
            report = newReport('CSCSDB TimeSyncError');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,isnan(obj.num_ts_grp),'Required','num_ts_grp','Select synchronization layout 1-5.',reference);
            [activeEpoch,activeCov] = activeFields(obj);
            [dates,times,ids] = epochs(obj);
            for k = 1:5
                if activeEpoch(k)
                    valid = validMieTimestamp([dates{k} times{k}]) && ~isnan(ids(k));
                else
                    valid = isempty(dates{k}) && isempty(times{k}) && isnan(ids(k));
                end
                report = addIssue(report,~valid,'TimeSyncEpoch','corr_ref_date/time/ts_spdcf', ...
                    'Supply exact UTC epochs and references only for groups in the selected layout.',reference);
            end
            values = [obj.tsrr obj.tsrc obj.tscc obj.ts_pos_cov obj.ts_pos_att_cov ...
                obj.ts_pos_fl_cov obj.ts_att_cov obj.ts_att_fl_cov obj.ts_fl_cov];
            report = addIssue(report,any(isnan(values(activeCov))) || any(~isnan(values(~activeCov))), ...
                'TimeSyncFields','covariance','Supply precisely the covariance fields used by the selected layout.',reference);
            [matrices,sizes] = covarianceGroups(obj);
            for k = 1:5
                if sizes(k) > 0
                    valid = glasCovariance(matrices(1:sizes(k),1:sizes(k),k),false);
                    report = addIssue(report,~valid,'TimeSyncCovariance','covariance', ...
                        'Each covariance must be known, encodable and positive semidefinite.',reference);
                end
            end
        end
        function value = references(obj) %#codegen
            %REFERENCES - Return correlation IDs in encoded group order
            [active,~] = activeFields(obj); [~,~,ids] = epochs(obj); value = ids(active);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the selected groups in Table M.6-5 order
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1) = decimalField(obj.num_ts_grp,1,0,false); at = 1;
            [dates,times,ids] = epochs(obj); [matrices,sizes] = covarianceGroups(obj);
            for k = 1:5
                if sizes(k) == 0, continue; end
                [~,covariance] = glasCovariance(matrices(1:sizes(k),1:sizes(k),k),true);
                data = [textField(dates{k},8) textField(times{k},16) covariance decimalField(ids(k),2,0,false)];
                value(at+(1:numel(data))) = data; at = at+numel(data);
            end
        end
    end
    methods (Access = private)
        function [activeEpoch,activeCov] = activeFields(obj) %#codegen
            %activeFields - Identify every conditional field without dropping data
            activeEpoch = false(1,5); activeCov = false(1,9);
            switch obj.num_ts_grp
                case 1, activeEpoch(1) = true; activeCov(1:3) = true;
                case 2, activeEpoch([2 3]) = true; activeCov([4 7]) = true;
                case 3, activeEpoch(1) = true; activeCov(4:9) = true;
                case 4, activeEpoch([4 5]) = true; activeCov([4 5 7 9]) = true;
                case 5, activeEpoch([2 3 5]) = true; activeCov([4 7 9]) = true;
            end
        end
        function [dates,times,ids] = epochs(obj) %#codegen
            %epochs - Retain exact UTC strings in the five named group slots
            dates = {char(obj.corr_ref_date_ts),char(obj.corr_ref_date_tsp),char(obj.corr_ref_date_tsa), ...
                char(obj.corr_ref_date_tspa),char(obj.corr_ref_date_tsfl)};
            times = {char(obj.corr_ref_time_ts),char(obj.corr_ref_time_tsp),char(obj.corr_ref_time_tsa), ...
                char(obj.corr_ref_time_tspa),char(obj.corr_ref_time_tsfl)};
            ids = [obj.ts_spdcf obj.ts_pos_spdcf obj.ts_att_spdcf obj.ts_pa_spdcf obj.ts_fl_spdcf];
        end
        function [matrices,sizes] = covarianceGroups(obj) %#codegen
            %covarianceGroups - Form bounded symmetric matrices for active groups
            matrices = zeros(3,3,5); sizes = zeros(1,5);
            switch obj.num_ts_grp
                case 1
                    sizes(1) = 2; matrices(1:2,1:2,1) = [obj.tsrr obj.tsrc;obj.tsrc obj.tscc];
                case 3
                    sizes(1) = 3;
                    matrices(:,:,1) = [obj.ts_pos_cov obj.ts_pos_att_cov obj.ts_pos_fl_cov; ...
                        obj.ts_pos_att_cov obj.ts_att_cov obj.ts_att_fl_cov;obj.ts_pos_fl_cov obj.ts_att_fl_cov obj.ts_fl_cov];
                case 4
                    sizes(4) = 2;
                    matrices(1:2,1:2,4) = [obj.ts_pos_cov obj.ts_pos_att_cov;obj.ts_pos_att_cov obj.ts_att_cov];
            end
            if any(obj.num_ts_grp == [2 5])
                sizes([2 3]) = 1; matrices(1,1,2) = obj.ts_pos_cov; matrices(1,1,3) = obj.ts_att_cov;
            end
            if any(obj.num_ts_grp == [4 5]), sizes(5) = 1; matrices(1,1,5) = obj.ts_fl_cov; end
        end
    end
end
