classdef MIEQuicklookTest < NfxTest
    methods (Test)
        function cameraAndBlockScopesResolveTogether(t)
            [c,image,timing] = quicklookFixture(); c.quicklooks = image+timing;
            t.verifyTrue(c.validate().valid); files = c.plan(); records = files(1).file.images.tre_records;
            t.verifyEqual(char(records.payload(42:44)),'001'); t.verifyEqual(char(records.payload(81:89)),'000001001');
            timing.camera_set_index = 2; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
            timing.camera_set_index = 1; timing.layer_id = 'IR'; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
        end
        function layerAndIntervalScopesUseBlankCameraIdentifiers(t)
            [c,image,timing] = quicklookFixture(); timing.camera_id = ''; timing.camera_set_index = 0; timing.temp_block_index = 0;
            c.quicklooks = image+timing; t.verifyTrue(c.validate().valid);
            timing.time_interval_index = 0; c.quicklooks = image+timing; t.verifyTrue(c.validate().valid);
            timing.layer_id = 'UNKNOWN'; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
        end
        function missingCamerasIntervalsAndBlocksAreRejected(t)
            [c,image,timing] = quicklookFixture(); timing.camera_id = 'FFFFFFFF-0000-4000-8000-000000000001';
            c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
            [c,image,timing] = quicklookFixture(); timing.time_interval_index = 3; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
            [c,image,timing] = quicklookFixture(); timing.temp_block_index = 3; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
            timing.camera_id = ''; timing.temp_block_index = 1; c.quicklooks = image+timing; issue(t,c,'QuicklookReference');
        end
        function timestampsMustFitTheReferencedBlockOrCollection(t)
            [c,image,timing] = quicklookFixture(); timing.base_timestamp = '20260915120000.400000000';
            c.quicklooks = image+timing; issue(t,c,'QuicklookBounds');
            timing.temp_block_index = 0; c.quicklooks = image+timing; t.verifyTrue(c.validate().valid);
            timing.time_interval_index = 0; timing.base_timestamp = '20260915120003.000000000';
            c.quicklooks = image+timing; issue(t,c,'QuicklookBounds');
            timing.base_timestamp = '99991231235959.999999999'; timing.dt = uint64(1);
            c.quicklooks = image+timing; issue(t,c,'TimeRange');
        end
        function missingAndMultiframeTimingFailsWithoutMutation(t)
            [c,image,timing] = quicklookFixture(); c.quicklooks = image; issue(t,c,'QuicklookTiming');
            timing.number_frames = 2; timing.nominal_frame_rate = 25; timing.dt = uint64(1);
            c.quicklooks = image+timing; issue(t,c,'QuicklookTiming');
            t.verifyEqual(c.quicklooks.tre_records.payload(end),uint8(1));
            c.quicklooks.data = repmat(c.quicklooks.data,1,1,1,2); issue(t,c,'QuicklookTiming');
        end
        function quicklooksRequireAManifestAndPreserveNativeTypes(t)
            [c,image,timing] = quicklookFixture(); c.quicklooks = image+timing; c.manifest = false;
            issue(t,c,'ManifestRequired'); c.manifest = true;
            second = c.blocks(3).image; second.data = second.data(:,:,1,1); second.header.icom = 'Selected infrared view for comparison.';
            timing.camera_id = c.blocks(3).timing.camera_id; timing.layer_id = 'IR';
            c.quicklooks(2) = second+timing; files = c.plan();
            t.verifyClass(files(1).file.images(1).data,'uint16'); t.verifyClass(files(1).file.images(2).data,'uint8');
            images = files(1).file.images; headers = [images.header];
            t.verifyEqual([headers.idlvl],[1 2]);
        end
    end
end

function [c,image,timing] = quicklookFixture()
    c = fixtureMIECollection(); image = c.blocks(1).image; image.data = image.data(:,:,:,1);
    image.header.icom = 'First visible frame selected for overview.';
    timing = c.blocks(1).timing; timing.layer_id = 'VIS'; timing.number_frames = 1;
    timing.nominal_frame_rate = 0; timing.dt = zeros(1,0,'uint64'); timing.base_timestamp = '20260915120000.040000000';
end

function issue(t,c,id)
    report = c.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end
