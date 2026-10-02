classdef FrameTimingTest < NfxTest
    properties (TestParameter)
        width = num2cell(1:8)
    end
    methods (Test)
        function timingUsesAllUnsignedWidthsWithoutRounding(t,width)
            value = fixtureTiming();
            pattern = bitor(bitshift(uint64(hex2dec('01020304')),32),uint64(hex2dec('05060708')));
            value.dt = bitshift(pattern,-8*(8-width));
            value.dt_multiplier = bitshift(uint64(1),53)+uint64(1);
            t.verifyEqual(value.dt_size,width);
            encoded = value.payload();
            t.verifyEqual(encoded(136:143),uint8([0 32 0 0 0 0 0 1]));
            t.verifyEqual(encoded(144:152),uint8([width 0 0 0 1 0 0 0 1]));
            t.verifyEqual(encoded(153:end),uint8(1:width));
            t.verifyEqual(value.cel,152+width);
        end
        function timingLiteralAsciiAndFullUint64(t)
            value = fixtureTiming();
            value.geocoords_static = 99;
            value.dt_multiplier = intmax('uint64');
            value.dt = intmax('uint64');
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:5)),'00199');
            t.verifyEqual(char(encoded(81:111)),['000007001NaN          ' repmat(' ',1,9)]);
            t.verifyEqual(char(encoded(112:135)),'20260915120000.123456789');
            t.verifyEqual(encoded(136:143),repmat(uint8(255),1,8));
            t.verifyEqual(encoded(153:160),repmat(uint8(255),1,8));
            value.reference_frame_num = 123456789;
            encoded = value.payload();
            t.verifyEqual(char(encoded(103:111)),'123456789');
        end
        function timingSupportsUniformAndIndividualDeltas(t)
            value = fixtureTiming();
            t.verifyEqual(value.cel,152);
            value.number_frames = 3;
            t.verifyFalse(value.validate().valid);
            value.dt = uint64(10);
            t.verifyTrue(value.validate().valid);
            value.dt = uint64([0 10 11]);
            t.verifyTrue(value.validate().valid);
            value.dt = uint64([0 10]);
            t.verifyFalse(value.validate().valid);
            value.nominal_frame_rate = 0;
            value.dt = uint64(1);
            t.verifyFalse(value.validate().valid);
            value.number_frames = 1;
            t.verifyTrue(value.validate().valid);
            value.number_frames = 4294967295;
            value.nominal_frame_rate = NaN;
            encoded = value.payload();
            t.verifyEqual(encoded(145:148),repmat(uint8(255),1,4));
        end
        function timingHonorsExplicitDeltaWidthAndByteLimit(t)
            value = fixtureTiming();
            value.dt = uint64(256);
            value.dt_size = 1;
            t.verifyFalse(value.validate().valid);
            value.dt_size = 3;
            encoded = value.payload();
            t.verifyEqual(encoded(153:155),uint8([0 1 0]));
            value.dt_size = NaN;
            t.verifyEqual(value.dt_size,2);
            value.dt = ones(1,99833,'uint64');
            value.number_frames = 99833;
            t.verifyEqual(value.cel,99985);
            value.dt(99834) = uint64(1);
            value.number_frames = 99834;
            t.verifyFalse(value.validate().valid);
        end
        function timingRejectsInvalidMetadataAndImplicitConversions(t)
            value = fixtureTiming();
            value.base_timestamp = '20260915120000.12-3-----';
            t.verifyFalse(value.validate().valid);
            value.base_timestamp = '20260230120000.123456789';
            t.verifyFalse(value.validate().valid);
            value.base_timestamp = '20260915120000.---------';
            value.geocoords_static = 1;
            t.verifyFalse(value.validate().valid);
            value.geocoords_static = 0;
            value.camera_id = 'invalid';
            t.verifyFalse(value.validate().valid);
            value.camera_id = '';
            t.verifyTrue(value.validate().valid);
            value.nominal_frame_rate = 1e-100;
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.MTIMSA().validate().valid);
            t.verifyError(@() nfx.MTIMSA(dt_multiplier=1),'nfx:TimeMultiplier');
            t.verifyError(@() nfx.MTIMSA(dt_multiplier=uint64(0)),'nfx:TimeMultiplier');
            t.verifyError(@() nfx.MTIMSA(dt=[1 2]),'nfx:TimeDeltas');
            t.verifyError(@() nfx.MTIMSA(dt=uint64([1;2])),'nfx:TimeDeltas');
            t.verifyError(@() nfx.MTIMSA(dt_size=uint8(3)),'nfx:Metadata');
        end
        function mappingHasLiteralFieldsAndEmptyCameraSet(t)
            value = fixtureTemporalMapping();
            encoded = value.payload();
            t.verifyEqual(value.cel,138);
            t.verifyEqual(char(encoded(37:48)),'001000007001');
            t.verifyEqual(char(encoded(49:87)),[value.cameras.camera_id '001']);
            t.verifyEqual(char(encoded(88:end)), ...
                '20260915120000.00000000120260915120001.000000001001');
            value.cameras = value.cameras([]);
            encoded = value.payload();
            t.verifyEqual(numel(encoded),48);
            t.verifyEqual(char(encoded(46:48)),'000');
        end
        function mappingDistinguishesUnavailableAndUnusedBlocks(t)
            value = fixtureTemporalMapping();
            unavailable = value.cameras.temporal_blocks;
            unavailable.image_seg_index = NaN;
            unused = struct('start_timestamp','','end_timestamp','','image_seg_index',NaN);
            value.cameras.temporal_blocks = [unavailable unused];
            encoded = value.payload();
            t.verifyEqual(char(encoded(136:189)),repmat(' ',1,54));
            t.verifyTrue(value.validate().valid);
            value.cameras.temporal_blocks = [unused unavailable];
            t.verifyFalse(value.validate().valid);
            unused.image_seg_index = 1;
            value.cameras.temporal_blocks = unused;
            t.verifyFalse(value.validate().valid);
        end
        function mappingChecksIdentityAndTemporalOrder(t)
            value = fixtureTemporalMapping();
            block = value.cameras.temporal_blocks;
            value.cameras.temporal_blocks = [block block];
            t.verifyFalse(value.validate().valid);
            value.cameras.temporal_blocks(2).image_seg_index = 2;
            t.verifyFalse(value.validate().valid);
            value.cameras.temporal_blocks(2).start_timestamp = block.end_timestamp;
            t.verifyTrue(value.validate().valid);
            value.cameras = [value.cameras value.cameras];
            t.verifyFalse(value.validate().valid);
            value.cameras(2) = [];
            value.cameras.camera_id = 'bad';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.MTIMFA().validate().valid);
        end
        function mappingChecksCountsAndCompletePayloadLimit(t)
            value = fixtureTemporalMapping();
            unused = struct('start_timestamp','','end_timestamp','','image_seg_index',NaN);
            value.cameras.temporal_blocks = repmat(unused,1,999);
            t.verifyEqual(value.cel,51036);
            value.cameras.temporal_blocks(1000) = unused;
            t.verifyFalse(value.validate().valid);
            value.cameras.temporal_blocks = repmat(unused,1,999);
            value.cameras(2) = value.cameras;
            value.cameras(2).camera_id = '11234567-89ab-4def-8123-456789abcdef';
            t.verifyFalse(value.validate().valid);
            value.cameras = value.cameras(1);
            value.cameras.temporal_blocks = value.cameras.temporal_blocks([]);
            t.verifyFalse(value.validate().valid);
        end
        function mappingAndTimingSnapshotsHaveCorrectOwners(t)
            [file,image] = fixtureFile();
            mapping = fixtureTemporalMapping();
            timing = fixtureTiming();
            attached = image+timing;
            timing.dt = uint64(3);
            file = nfx.File(header=file.header)+mapping+attached;
            name = fullfile(t.folder,'motion-metadata.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.allTRE(1).tag,'MTIMFA');
            t.verifyEqual(parsed.images(1).allTRE(2).tag,'MTIMSA');
            t.verifyEqual(numel(parsed.images(1).allTRE(2).payload),152);
            t.verifyError(@() plus(image,mapping),'nfx:TREPlacement');
            t.verifyError(@() plus(file,timing),'nfx:TREPlacement');
        end
    end
end
