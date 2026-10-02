classdef MotionBlockTest < NfxTest
    methods (Test)
        function countsAndIndicesAreDerivedWithoutMutatingInput(t)
            block = fixtureBlock(); block.timing.number_frames = NaN; block.timing.image_seg_index = NaN;
            block.timing.camera_set_index = NaN; block.timing.temp_block_index = NaN; block.timing.layer_id = '';
            t.verifyTrue(block.validate().valid);
            t.verifyTrue(isnan(block.timing.number_frames)); t.verifyEmpty(block.timing.layer_id);
        end
        function perFrameDeltasAreCumulativeAndMotionEndIsExclusive(t)
            block = fixtureBlock(); block.timing.dt = uint64([0 40 40]);
            block.end_timestamp = '20260915120000.080000001'; t.verifyTrue(block.validate().valid);
            block.end_timestamp = '20260915120000.080000000'; issue(t,block,'FrameBounds');
            block.end_timestamp = '20260915120000.081000000'; block.start_timestamp = '20260915120000.000000001';
            issue(t,block,'FrameBounds');
        end
        function constantDeltaAlsoOffsetsTheFirstFrame(t)
            block = fixtureBlock(); block.timing.dt = uint64(40);
            block.start_timestamp = '20260915120000.040000000'; block.end_timestamp = '20260915120000.120000001';
            t.verifyTrue(block.validate().valid);
            block.start_timestamp = '20260915120000.040000001'; issue(t,block,'FrameBounds');
            block.start_timestamp = '20260915120000.040000000'; block.end_timestamp = '20260915120000.120000000';
            issue(t,block,'FrameBounds');
        end
        function fullUINT64ProductsRetainTheirLowBits(t)
            % Expected UTC literals were computed with Python integer divmod.
            deltas = [bitshift(uint64(1),53)+1 intmax('uint64') bitshift(uint64(1),63)+1 intmax('uint64')];
            multipliers = uint64([1 2 2 10]); frames = [1 1 2 1];
            last = {'20000414055959.254740993','31690208230907.419103230', ...
                '31690208230907.419103236','78450716194537.095516150'};
            after = {'20000414055959.254740994','31690208230907.419103231', ...
                '31690208230907.419103237','78450716194537.095516151'};
            for k = 1:4
                block = fixtureBlock(); block.image.data = zeros(1,1,2,frames(k),'uint16');
                block.timing.base_timestamp = '20000101000000.000000000'; block.start_timestamp = block.timing.base_timestamp;
                block.timing.dt = deltas(k); block.timing.dt_multiplier = multipliers(k);
                block.end_timestamp = after{k}; t.verifyTrue(block.validate().valid);
                block.end_timestamp = last{k}; issue(t,block,'FrameBounds');
            end
        end
        function calendarCarryUsesExactNanoseconds(t)
            block = fixtureBlock(); block.image.data = zeros(1,1,2,2,'uint8');
            block.timing.base_timestamp = '20240229235959.999999999'; block.start_timestamp = block.timing.base_timestamp;
            block.timing.dt = uint64([0 1]); block.timing.dt_multiplier = uint64(1);
            block.end_timestamp = '20240301000000.000000001'; t.verifyTrue(block.validate().valid);
            block.end_timestamp = '20240301000000.000000000'; issue(t,block,'FrameBounds');
            block.timing.base_timestamp = '19991231235959.999999999'; block.start_timestamp = block.timing.base_timestamp;
            block.end_timestamp = '20000101000000.000000001'; t.verifyTrue(block.validate().valid);
        end
        function outOfCalendarRangeFailsBeforeAnySaturatingArithmetic(t)
            block = fixtureBlock(); block.timing.dt = intmax('uint64'); block.timing.dt_multiplier = intmax('uint64');
            issue(t,block,'TimeRange');
            block.image.data = zeros(1,1,2,2,'uint8'); block.timing.dt = uint64([0 1]); block.timing.dt_multiplier = uint64(1);
            block.timing.base_timestamp = '99991231235959.999999999';
            block.start_timestamp = block.timing.base_timestamp; block.end_timestamp = block.timing.base_timestamp;
            issue(t,block,'TimeRange');
        end
        function equalTimeAndInsufficientBoundaryPrecisionAreRejected(t)
            block = fixtureBlock(); block.timing.dt = uint64([0 0 1]); issue(t,block,'FrameOrder');
            block.timing.dt = uint64(40); block.end_timestamp = '20260915120000.120------';
            issue(t,block,'FrameBounds');
            block.end_timestamp = '20260915120001.---------'; block.timing.base_timestamp = '20260915120000.000------';
            t.verifyTrue(block.validate().valid);
        end
        function stillTimestampMayEqualBothBoundaries(t)
            block = fixtureBlock(); block.image.data = zeros(1,1,2,'uint8'); block.timing.dt = zeros(1,0,'uint64');
            block.timing.nominal_frame_rate = 0; block.end_timestamp = block.start_timestamp;
            t.verifyTrue(block.validate().valid);
            block.timing.nominal_frame_rate = 1; issue(t,block,'FrameBounds');
        end
        function unavailableBlocksHaveNoPixelsOrFrameTiming(t)
            block = fixtureBlock(); block.available = false; issue(t,block,'UnavailablePixels');
            block.image = nfx.ImageSegment(); block.timing.base_timestamp = ''; block.timing.dt = zeros(1,0,'uint64');
            t.verifyTrue(block.validate().valid);
            block.end_timestamp = '20260915115959.000000000'; issue(t,block,'TimeOrder');
        end
        function incompleteAndDuplicateTimingInputsFail(t)
            issue(t,nfx.MotionBlock(),'PixelsRequired');
            block = fixtureBlock(); block.image = block.image+block.timing; issue(t,block,'DerivedTiming');
            block = fixtureBlock(); block.start_timestamp = 'invalid'; issue(t,block,'Timestamp');
            block = fixtureBlock(); block.timing.camera_id = ''; issue(t,block,'CameraUUID');
            block = fixtureBlock(); block.timing.time_interval_index = 0; issue(t,block,'TimeInterval');
            block = fixtureBlock(); block.timing.dt = uint64([0 1]); issue(t,block,'DeltaCount');
        end
    end
end

function block = fixtureBlock()
    [~,image,timing] = fixtureMotion(); image = image.removeTRE(image.tre_ids(1));
    block = nfx.MotionBlock(image,timing=timing,start_timestamp='20260915120000.000000000', ...
        end_timestamp='20260915120000.200000000');
end

function issue(t,block,id)
    report = block.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end
