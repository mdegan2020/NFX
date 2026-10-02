classdef CovarianceDESTest < NfxTest
    methods (Test)
        function emptyAllocationsAreValidLevelZeroMetadata(t)
            value = nfx.CSCSDB(uuid='20000000-0000-4000-8000-000000000004',aisdlvl=1,cov_version_date='20260915');
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.desver,1);
            t.verifyEqual(value.payload(),uint8(['20260915' '000000' '000000000']));
            t.verifyEqual(value.byte_length,23); t.verifyEqual(value.parameter_count,0);
            t.verifyTrue(isnan(value.dc_type)); t.verifyEqual(value.reserved_len,0);
            segment = value.segment(); t.verifyTrue(segment.verifiedSensor()); t.verifyEqual(segment.header.desver,1);
        end
        function coreAndCorrelationHaveIndependentExpectedBytes(t)
            value = fixtureCSCSDB();
            core = ['121' '20260915120000.1234567892121' sprintf('%+.14E',[4 1 9]) '001010'];
            correlation = '010101.0001.0000000.25000002.000000+3.00000000000000E+00';
            expected = ['202609151' core '000101' correlation '0000000000'];
            t.verifyEqual(value.payload(),uint8(expected)); t.verifyEqual(numel(expected),value.byte_length);
            t.verifyEqual([value.core_sets value.io_cal_ap value.ts_cal_ap value.ue_flag value.spdcf_flag value.num_spdcf],[1 0 0 0 1 1]);
            t.verifyEqual(value.references(),1); t.verifyEqual(value.parameter_count,2);
        end
        function allAllocationBranchesRetainSpecifiedOrder(t)
            value = fullFixture(); value.adj = 1:value.parameter_count; value.errcov_c4 = diag(1:value.parameter_count);
            data = value.payload(); parsed = inspectCovariance(data);
            t.verifyEqual(parsed.corePrefix,uint8('202609151121'));
            t.verifyEqual(parsed.focalLengths,[0.5 0.75]); t.verifyEqual(parsed.calibrationIds,[1 11]);
            t.verifyEqual(parsed.calibrationCovariances,[4 1 9;1 0 1]);
            t.verifyEqual(parsed.timeCovariance,[4 1 2 9 3 16]); t.verifyEqual(parsed.gridCovariance,[1 0 2]);
            t.verifyEqual(parsed.spdcfIds,1:2); t.verifyEqual(parsed.adj,1:9);
            t.verifyEqual(parsed.directCovariance,diag(1:9)); t.verifyEqual(parsed.reservedLength,0);
            t.verifyEqual(numel(data),value.byte_length); t.verifyEqual(value.num_para,9); t.verifyEqual(value.dc_type,0);
        end
        function reservedAreaUsesCountedDataBytesAndReferences(t)
            value = fullFixture(); value.adj = zeros(1,9); value.errcov_c4 = eye(9); value.spdcf_id_adj = [1 2 1 2 1 2 1 2 1];
            data = value.payload(); parsed = inspectCovariance(data);
            t.verifyEqual(parsed.reservedLength,30); t.verifyEqual(value.reserved_len,30);
            t.verifyEqual(char(data(end-38:end)),'000000030011000000018010201020102010201');
            t.verifyEqual(parsed.adjustmentIds,value.spdcf_id_adj);
            value.spdcf_id_adj(9) = []; t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.spdcf_id_adj = 1; t.verifyFalse(value.validate().valid);
        end
        function everyCorrelationReferenceMustResolveLocally(t)
            value = fixtureCSCSDB(); value.spdcf = nfx.SPDCF.empty(1,0); t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.spdcf(2) = []; t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.spdcf(2) = value.spdcf(1); t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.spdcf(1).spdcf_id = NaN; t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.adj = zeros(1,9); value.errcov_c4 = eye(9); value.spdcf_id_adj = repmat(3,1,9);
            t.verifyFalse(value.validate().valid);
        end
        function calibrationPagesAndPresenceMustAgree(t)
            value = fixtureCSCSDB(); value.focal_length_cal = 1; t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.focal_length_cal = []; t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.focal_length_cal = [0.5 NaN]; t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.focal_length_cal = [-0.5 0.75]; t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.calibration_groups.errcov_c3 = eye(2); t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.calibration_groups = repmat(value.calibration_groups,1,12); t.verifyFalse(value.validate().valid);
        end
        function adjustableVectorAndCovarianceMustCoverDescribedParameters(t)
            value = fixtureCSCSDB(); value.adj = [0 0]; value.errcov_c4 = eye(2); t.verifyTrue(value.validate().valid);
            value.errcov_c4 = []; t.verifyFalse(value.validate().valid);
            value.errcov_c4 = eye(2); value.adj = []; t.verifyFalse(value.validate().valid);
            value.adj = [0 0 0]; value.errcov_c4 = eye(3); t.verifyFalse(value.validate().valid);
            value.adj = [0 0]; value.errcov_c4 = [1 2;2 1]; t.verifyFalse(value.validate().valid);
            value.errcov_c4 = eye(2); value.adj = [0 NaN]; t.verifyFalse(value.validate().valid);
            value.adj = [0 1e-114]; t.verifyFalse(value.validate().valid);
        end
        function postCountsContributeEveryAdjustment(t)
            value = fixtureCSCSDB(); group = value.cores.groups;
            group.errcov_c2 = eye(2); group.post_start_date = '20260915'; group.post_start_time = 0;
            group.post_dt = 1; group.num_posts = 3; group.post_interp = 1; value.cores.groups = group;
            t.verifyEqual(value.parameter_count,8); value.adj = zeros(1,8); value.errcov_c4 = eye(8);
            t.verifyTrue(value.validate().valid); t.verifyEqual(numel(value.payload()),value.byte_length);
        end
        function oversizedCovarianceIsRejectedBeforeAllocation(t)
            value = fixtureCSCSDB(); value.adj = zeros(1,9999);
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'DESLength'))); t.verifyGreaterThan(value.byte_length,999999998);
        end
        function definitionVersionDatesAndBlockCounts(t)
            t.verifyFalse(nfx.CSCSDB().validate().valid);
            value = fixtureCSCSDB(); value.desver = 2; t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.cov_version_date = '20260230'; t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.cores = repmat(value.cores,1,7); t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.time_sync(2) = value.time_sync(1); t.verifyFalse(value.validate().valid);
            value = fullFixture(); value.unmodeled(2) = value.unmodeled(1); t.verifyFalse(value.validate().valid);
            value = fixtureCSCSDB(); value.spdcf = repmat(value.spdcf,1,100); t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.CSCSDB(spdcf_id_adj=uint8(1)),'nfx:AdjustmentReferences');
            t.verifyError(@() nfx.CSCSDB(spdcf_id_adj=100),'nfx:AdjustmentReferences');
        end
    end
end

function value = fullFixture()
    value = fixtureCSCSDB(); value.calibration_groups = fixtureCalibrationErrorGroup();
    value.calibration_groups.errcov_c3 = cat(3,[4 1;1 9],eye(2)); value.focal_length_cal = [0.5 0.75];
    value.time_sync = fixtureTimeSyncError(3);
    value.unmodeled = nfx.UnmodeledErrorGrid(urr=1,urc=0,ucc=2,line_spdcf=1,sample_spdcf=2);
    value.spdcf(2) = value.spdcf(1); value.spdcf(2).spdcf_id = 2;
end

function result = inspectCovariance(data)
    % Independent offsets for the full fixture and cursor for direct covariance.
    result.corePrefix = data(1:12); at = 110;
    assert(strcmp(char(data(at:at+2)),'102')); at = at+3;
    result.focalLengths = numbers(data(at:at+21),11); at = at+22;
    assert(strcmp(char(data(at:at+1)),'01')); at = at+2+24;
    assert(strcmp(char(data(at:at+1)),'02')); at = at+2;
    result.calibrationIds = numbers(data(at:at+3),2); at = at+4;
    result.calibrationCovariances = reshape(numbers(data(at:at+125),21),3,2).'; at = at+126+5;
    assert(strcmp(char(data(at:at+1)),'13')); at = at+2+24;
    result.timeCovariance = numbers(data(at:at+125),21); at = at+126+2;
    assert(strcmp(char(data(at:at+5)),'100101')); at = at+6;
    result.gridCovariance = numbers(data(at:at+62),21); at = at+63+4;
    assert(strcmp(char(data(at:at+2)),'102')); at = at+3;
    result.spdcfIds = [numbers(data(at:at+1),2) numbers(data(at+56:at+57),2)]; at = at+112;
    assert(strcmp(char(data(at:at+1)),'10')); at = at+2;
    count = numbers(data(at:at+3),4); at = at+4;
    result.adj = numbers(data(at:at+21*count-1),21); at = at+21*count;
    result.directCovariance = zeros(count);
    for row = 1:count
        n = count-row+1; result.directCovariance(row,row:count) = numbers(data(at:at+21*n-1),21);
        result.directCovariance(row:count,row) = result.directCovariance(row,row:count).'; at = at+21*n;
    end
    result.reservedLength = numbers(data(at:at+8),9); at = at+9;
    result.adjustmentIds = [];
    if result.reservedLength > 0
        assert(strcmp(char(data(at:at+2)),'011')); at = at+3;
        length = numbers(data(at:at+8),9); at = at+9;
        result.adjustmentIds = numbers(data(at:at+length-1),2); at = at+length;
    end
    assert(at == numel(data)+1);
end

function value = numbers(data,width)
    value = str2double(cellstr(reshape(char(data),width,[]).')).';
end
