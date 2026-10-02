classdef CalibrationErrorTest < NfxTest
    methods (Test)
        function calibrationPageOrderAndIdentifiers(t)
            value = fixtureCalibrationErrorGroup(); data = value.bytes();
            t.verifyEqual(char(data(1:30)),'20260915120000.123456789020111');
            t.verifyEqual(char(data(31:93)),sprintf('%+.14E',[4 1 9]));
            t.verifyEqual(char(data(94:end)),'10102'); t.verifyEqual(value.byte_length,98);
            t.verifyEqual([value.n1cal value.num_sets_cal_ap value.parameter_count],[2 1 2]);
            value.errcov_c3 = cat(3,[4 1;1 9],eye(2)); data = value.bytes();
            t.verifyEqual(char(data(94:156)),sprintf('%+.14E',[1 0 1]));
            t.verifyEqual(value.byte_length,161); t.verifyEqual(value.parameter_count,4);
            t.verifyEqual(value.references(),[1 2]);
        end
        function calibrationRejectsUnknownOrInconsistentMetadata(t)
            t.verifyFalse(nfx.CalibrationErrorGroup().validate().valid);
            for covariance = {[],eye(3),[1 2;2 1],[1 0;1 1],[NaN 0;0 1],[1e-114 0;0 1]}
                value = fixtureCalibrationErrorGroup(); value.errcov_c3 = covariance{1}; t.verifyFalse(value.validate().valid);
            end
            value = fixtureCalibrationErrorGroup(); value.cal_ap_id = [1 1]; t.verifyFalse(value.validate().valid);
            value = fixtureCalibrationErrorGroup(); value.corr_ref_date_io = '20260230'; t.verifyFalse(value.validate().valid);
            value = fixtureCalibrationErrorGroup(); value.spdcf_id_fl = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.CalibrationErrorGroup(cal_ap_id=uint8(1)),'nfx:CalibrationIDs');
            t.verifyError(@() nfx.CalibrationErrorGroup(cal_ap_id=12),'nfx:CalibrationIDs');
            t.verifyError(@() nfx.CalibrationErrorGroup(errcov_c3=ones(2,2,100)),'nfx:GLASCovariance');
        end
        function allFiveTimeLayoutsHaveIndependentExpectedBytes(t)
            epoch = '20260915120000.123456789';
            expected = {['1' epoch sprintf('%+.14E',[4 1 9]) '01'], ...
                ['2' epoch sprintf('%+.14E',4) '02' epoch sprintf('%+.14E',9) '03'], ...
                ['3' epoch sprintf('%+.14E',[4 1 2 9 3 16]) '01'], ...
                ['4' epoch sprintf('%+.14E',[4 1 9]) '04' epoch sprintf('%+.14E',16) '05'], ...
                ['5' epoch sprintf('%+.14E',4) '02' epoch sprintf('%+.14E',9) '03' epoch sprintf('%+.14E',16) '05']};
            lengths = [90 95 153 137 142]; params = [2 2 3 3 3]; ids = {1,[2 3],1,[4 5],[2 3 5]};
            for layout = 1:5
                value = fixtureTimeSyncError(layout); t.verifyTrue(value.validate().valid);
                t.verifyEqual(value.bytes(),uint8(expected{layout})); t.verifyEqual(value.byte_length,lengths(layout));
                t.verifyEqual(value.parameter_count,params(layout)); t.verifyEqual(value.references(),ids{layout});
            end
        end
        function timeLayoutsCannotSilentlyDiscardFields(t)
            value = fixtureTimeSyncError(1); value.ts_pos_cov = 4; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(2); value.corr_ref_date_ts = '20260915'; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(3); value.ts_pos_spdcf = 1; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(4); value.corr_ref_time_tspa = ''; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(5); value.ts_fl_spdcf = NaN; t.verifyFalse(value.validate().valid);
            value = nfx.TimeSyncError(); t.verifyFalse(value.validate().valid);
            t.verifyEqual(value.byte_length,1); t.verifyEqual(value.parameter_count,0); t.verifyEmpty(value.references());
        end
        function timeCovariancesRequireKnownPSDValues(t)
            for layout = 1:5
                value = fixtureTimeSyncError(layout);
                if layout == 1, value.tsrr = -1; else, value.ts_pos_cov = -1; end
                t.verifyFalse(value.validate().valid);
            end
            value = fixtureTimeSyncError(1); value.tsrc = 7; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(3); value.ts_pos_fl_cov = 9; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(2); value.ts_pos_cov = 1e-114; t.verifyFalse(value.validate().valid);
            value = fixtureTimeSyncError(3); value.ts_att_cov = NaN; t.verifyFalse(value.validate().valid);
        end
        function unmodeledGridIsRowMajorWithUpperTriangles(t)
            value = nfx.UnmodeledErrorGrid(urr=[4 9;16 25],urc=[1 2;3 4],ucc=[10 11;12 13],line_spdcf=4,sample_spdcf=5);
            expected = ['00202' sprintf('%+.14E',[4 1 10 9 2 11 16 3 12 25 4 13]) '0405'];
            t.verifyEqual(value.bytes(),uint8(expected)); t.verifyEqual(value.byte_length,261);
            t.verifyEqual([value.line_dimension value.sample_dimension],[2 2]); t.verifyEqual(value.references(),[4 5]);
        end
        function unmodeledGridShapeValuesAndIDsAreValidated(t)
            t.verifyFalse(nfx.UnmodeledErrorGrid().validate().valid);
            value = nfx.UnmodeledErrorGrid(urr=1,urc=0,ucc=1,line_spdcf=1,sample_spdcf=2);
            t.verifyTrue(value.validate().valid); value.ucc = [1 1]; t.verifyFalse(value.validate().valid);
            value.ucc = 1; value.urc = 2; t.verifyFalse(value.validate().valid);
            value.urc = 0; value.urr = NaN; t.verifyFalse(value.validate().valid);
            value.urr = 1e-114; t.verifyFalse(value.validate().valid);
            value.urr = 0; t.verifyTrue(value.validate().valid);
            value.line_spdcf = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.UnmodeledErrorGrid(urr=ones(1,100)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.UnmodeledErrorGrid(urr=single(1)),'nfx:GLASMatrix');
        end
    end
end
