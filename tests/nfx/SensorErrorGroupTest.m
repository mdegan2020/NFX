classdef SensorErrorGroupTest < NfxTest
    methods (Test)
        function basicCovarianceUsesUpperTriangleInRowOrder(t)
            value = fixtureSensorErrorGroup(); data = value.bytes();
            expected = uint8(['20260915120000.1234567892121' ...
                '+4.00000000000000E+00+1.00000000000000E+00+9.00000000000000E+00' '0000']);
            t.verifyEqual(data,expected); t.verifyEqual(value.byte_length,95);
            t.verifyEqual([value.num_adj_parm value.basic_sub_alloc value.post_sub_alloc value.parameter_count],[2 1 0 2]);
        end
        function allBasicAndPostPairingFormsHaveDerivedFlags(t)
            value = fixtureSensorErrorGroup();
            value.basic_pf = nfx.CorrelationPairing(spdcf_id=1,sensor_id={'SEN001','SEN002'});
            value.basic_pl = nfx.CorrelationPairing(spdcf_id=2,sensor_id={'ALL'}); value.basic_sr_spdcf = 3;
            value = posts(value); value.post_pf = nfx.CorrelationPairing(spdcf_id=4,sensor_id={'OTHER'});
            value.post_pl = nfx.CorrelationPairing(spdcf_id=5,sensor_id={'ALL'});
            value.post_sr_spdcf = 6; value.post_corr = 1; data = value.bytes();
            t.verifyEqual(value.references(),[1 2 4 5 3 6]); t.verifyEqual(numel(data),value.byte_length);
            t.verifyEqual(char(data(92:127)),'1010102SEN001SEN0021010201ALL   1031');
            t.verifyEqual(char(data(end-29:end)),'1010401OTHER 1010501ALL   1061');
            t.verifyEqual(value.parameter_count,8);
        end
        function commonAndPerPostCovariances(t)
            value = posts(fixtureSensorErrorGroup()); data = value.bytes();
            t.verifyEqual(value.common_posts_cov,1); t.verifyEqual(numel(data),202);
            t.verifyEqual(char(data(96:135)),'2026091500001.250000000000.5000000000031');
            value.errcov_c2 = cat(3,eye(2),2*eye(2),3*eye(2)); data = value.bytes();
            t.verifyEqual(value.common_posts_cov,0); t.verifyEqual(numel(data),328);
            numbers = reshape(str2double(cellstr(reshape(char(data(136:324)),21,[]).')),3,[]);
            t.verifyEqual(numbers,[1 2 3;0 0 0;1 2 3]);
            t.verifyEqual(value.byte_length,328); t.verifyEqual(value.parameter_count,8);
        end
        function covarianceMustBeKnownSymmetricAndPSD(t)
            value = fixtureSensorErrorGroup();
            for matrix = {[1 2;2 1],[1 0;1 1],[0 1;1 1],[1 NaN;NaN 1],eye(3),[1e-114 0;0 1]}
                value.errcov_c1 = matrix{1}; t.verifyFalse(value.validate().valid);
            end
            value.errcov_c1 = zeros(2); t.verifyTrue(value.validate().valid);
            value.errcov_c1 = [1 1;1 1]; t.verifyTrue(value.validate().valid);
            value = posts(fixtureSensorErrorGroup()); value.errcov_c2 = cat(3,eye(2),eye(2)); t.verifyFalse(value.validate().valid);
            value.errcov_c2 = [1 2;2 1]; t.verifyFalse(value.validate().valid);
            value.errcov_c2 = eye(3); t.verifyFalse(value.validate().valid);
        end
        function absentAllocationsCannotDiscardDependentMetadata(t)
            value = fixtureSensorErrorGroup(); value.errcov_c1 = []; t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.parameter_count,0); t.verifyEqual(numel(value.bytes()),29);
            value.basic_sr_spdcf = 1; t.verifyFalse(value.validate().valid);
            value = fixtureSensorErrorGroup(); value.post_dt = 1; t.verifyFalse(value.validate().valid);
            value = posts(fixtureSensorErrorGroup()); value.post_sr_spdcf = 1; t.verifyFalse(value.validate().valid);
            value.post_corr = 0; t.verifyTrue(value.validate().valid);
            value.post_sr_spdcf = NaN; t.verifyFalse(value.validate().valid);
        end
        function requiredEpochsCountsAndTypes(t)
            t.verifyFalse(nfx.SensorErrorGroup().validate().valid); value = fixtureSensorErrorGroup();
            value.adj_parm_id = [1 1]; t.verifyFalse(value.validate().valid);
            value = fixtureSensorErrorGroup(); value.corr_ref_time = ''; t.verifyFalse(value.validate().valid);
            value = posts(fixtureSensorErrorGroup()); value.post_start_date = '20260230'; t.verifyFalse(value.validate().valid);
            value = posts(fixtureSensorErrorGroup()); value.num_posts = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.SensorErrorGroup(adj_parm_id=uint8(1)),'nfx:FundamentalIDs');
            t.verifyError(@() nfx.SensorErrorGroup(adj_parm_id=8),'nfx:FundamentalIDs');
            t.verifyError(@() nfx.SensorErrorGroup(errcov_c1=single(1)),'nfx:GLASCovariance');
            t.verifyError(@() nfx.SensorErrorGroup(errcov_c1=ones(8)),'nfx:GLASCovariance');
            t.verifyError(@() nfx.SensorErrorGroup(errcov_c1=cat(3,1,1)),'nfx:GLASCovariance');
        end
        function pairingNamesAndAmbiguousMappingsAreRejected(t)
            p = nfx.CorrelationPairing(spdcf_id=1,sensor_id={'A','B'}); t.verifyEqual(char(p.bytes()),'0102A     B     ');
            p.sensor_id = {'A','A '}; t.verifyFalse(p.validate().valid);
            p.sensor_id = {'ALL','A'}; t.verifyFalse(p.validate().valid);
            p.sensor_id = {''}; t.verifyFalse(p.validate().valid);
            p.sensor_id = repmat({'A'},1,100); t.verifyFalse(p.validate().valid);
            t.verifyFalse(nfx.CorrelationPairing().validate().valid);
            value = fixtureSensorErrorGroup(); p = nfx.CorrelationPairing(spdcf_id=1,sensor_id={'A'});
            value.basic_pf = [p p]; t.verifyFalse(value.validate().valid);
            p.sensor_id = {'ALL'}; value.basic_pf(2) = p; t.verifyFalse(value.validate().valid);
            value.basic_pf = [p value.basic_pf(1)]; t.verifyFalse(value.validate().valid);
            value.basic_pf = repmat(p,1,100); t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.CorrelationPairing(sensor_id='A'),'nfx:SensorNames');
        end
        function coreFramesGroupOrderAndCounts(t)
            first = fixtureSensorErrorGroup(); second = posts(first);
            value = nfx.SensorErrorCore(ref_frame_position=1,ref_frame_attitude=2,groups=[first second]);
            t.verifyEqual(value.bytes(),[uint8('122') first.bytes() second.bytes()]);
            t.verifyEqual(value.num_groups,2); t.verifyEqual(value.parameter_count,10);
            t.verifyEqual(value.byte_length,300); t.verifyEmpty(value.references());
            value.groups(1).basic_sr_spdcf = 3; value.groups(2).basic_sr_spdcf = 4;
            t.verifyEqual(value.references(),[3 4]);
            value.groups = repmat(first,1,7); t.verifyTrue(value.validate().valid);
            value.groups(8) = first; t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.SensorErrorCore().validate().valid);
        end
    end
end

function value = posts(value)
    value.errcov_c2 = eye(2); value.post_start_date = '20260915'; value.post_start_time = 1.25;
    value.post_dt = 0.5; value.num_posts = 3; value.post_interp = 0;
end
