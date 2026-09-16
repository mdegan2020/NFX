classdef MotionTRETest < NfxTest
    methods (Test)
        function cameraDefinitionHasLiteralFieldsAndDerivedCounts(t)
            camera = fixtureCamera();
            value = nfx.CAMSDA(camera_sets=struct('cameras',camera));
            t.verifyEqual(value.num_camera_sets,1);
            t.verifyEqual(value.num_camera_sets_in_tre,1);
            t.verifyEqual(value.num_cameras_in_set,1);
            t.verifyEqual(value.cel,196);
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:12)),'001001001001');
            t.verifyEqual(char(encoded(13:48)),camera.camera_id);
            t.verifyEqual(char(encoded(165:196)),'00100000000000000000000200000003');
            value.first_camera_set_in_tre = 4;
            value.num_camera_sets = 7;
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:9)),'007001004');
        end
        function cameraRangeAndUUIDConsistency(t)
            camera = fixtureCamera();
            sets = struct('cameras',camera);
            value = nfx.CAMSDA(camera_sets=[sets sets]);
            t.verifyFalse(value.validate().valid);
            value.camera_sets(2).cameras.camera_id = '11234567-89ab-4def-8123-456789abcdef';
            t.verifyTrue(value.validate().valid);
            value.num_camera_sets = 1;
            t.verifyFalse(value.validate().valid);
            value.num_camera_sets = NaN;
            value.camera_sets(2).cameras.layer_id = '';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.CAMSDA().validate().valid);
            camera.camera_id = 'invalid';
            t.verifyFalse(nfx.CAMSDA(camera_sets=struct('cameras',camera)).validate().valid);
            camera.nrows = uint16(2);
            t.verifyError(@() nfx.CAMSDA(camera_sets=struct('cameras',camera)), 'nfx:Metadata');
        end
        function timeIntervalsPreserveNanosecondsAndUnknownPrecision(t)
            item = struct('time_interval_index',17,'start_timestamp','20260915120000.000000001', ...
                'end_timestamp','20260915120000.123------');
            value = nfx.TMINTA(item);
            t.verifyEqual(value.cel,58);
            t.verifyEqual(char(value.payload()),'000100001720260915120000.00000000120260915120000.123------');
            value.intervals.end_timestamp = '20260915120000.000000000';
            t.verifyFalse(value.validate().valid);
            value.intervals.end_timestamp = value.intervals.start_timestamp;
            t.verifyTrue(value.validate().valid);
        end
        function emptyAndIgnoredTimeIntervalsAreDistinct(t)
            empty = struct('time_interval_index',7,'start_timestamp','','end_timestamp','');
            ignored = empty; ignored.time_interval_index = 0;
            value = nfx.TMINTA([empty ignored ignored]);
            t.verifyTrue(value.validate().valid);
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:10)), '0003000007');
            t.verifyEqual(char(encoded(11:58)), repmat(' ',1,48));
            value.intervals(1).start_timestamp = '20260915120000.123------';
            t.verifyFalse(value.validate().valid);
            value.intervals(1).end_timestamp = value.intervals(1).start_timestamp;
            t.verifyTrue(value.validate().valid);
            value.intervals(1).time_interval_index = 0;
            t.verifyFalse(value.validate().valid);
        end
        function intervalCountAndDuplicateIndices(t)
            item = struct('time_interval_index',1,'start_timestamp','','end_timestamp','');
            t.verifyFalse(nfx.TMINTA([item item]).validate().valid);
            item.time_interval_index = 0;
            value = nfx.TMINTA(repmat(item,1,1851));
            t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.cel,99958);
            value.intervals(1852) = item;
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.TMINTA().validate().valid);
        end
        function summaryLiteralFieldsAndUnknownRates(t)
            value = nfx.MIMCSA(layer_id='LAYER',nominal_frame_rate=29.97, ...
                mi_req_decoder='NC',mi_req_profile='Not Applicable',mi_req_level='N/A');
            encoded = value.payload();
            t.verifyEqual(value.cel, 121);
            t.verifyEqual(char(encoded(37:75)), ['2.9970000E+01NaN          NaN          ']);
            t.verifyEqual(char(encoded(76:79)), '00NC');
            t.verifyEqual(char(encoded(80:115)), ['Not Applicable' repmat(' ',1,22)]);
            t.verifyEqual(char(encoded(116:121)), 'N/A   ');
            file = fixtureFile()+value;
            name = fullfile(t.folder,'summary.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.tres(1).tag, 'MIMCSA');
            t.verifyEqual(parsed.tres(1).payload, encoded);
        end
        function summaryValidatesPrecisionAndDecoder(t)
            value = nfx.MIMCSA(layer_id='LAYER',mi_req_decoder='NC', ...
                mi_req_profile='Not Applicable',mi_req_level='N/A');
            t.verifyTrue(value.validate().valid);
            value.nominal_frame_rate = 1e-100;
            t.verifyFalse(value.validate().valid);
            value.nominal_frame_rate = 0;
            value.min_frame_rate = 10; value.max_frame_rate = 9;
            t.verifyFalse(value.validate().valid);
            value.max_frame_rate = 11;
            value.mi_req_level = 'Wrong';
            t.verifyFalse(value.validate().valid);
            value.mi_req_decoder = 'XX';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.MIMCSA().validate().valid);
            t.verifyError(@() nfx.MIMCSA(min_frame_rate=single(1)), 'nfx:Metadata');
        end
        function summaryAllowsKnownCompressedDeclarations(t)
            value = nfx.MIMCSA(layer_id='LAYER',min_frame_rate=1e-99, ...
                max_frame_rate=3.4028234E38,mi_req_decoder='C8', ...
                mi_req_profile='ISO/IEC 15444-1',mi_req_level='class2');
            t.verifyTrue(value.validate().valid);
            encoded = value.payload();
            t.verifyEqual(char(encoded(50:75)), '1.0000000E-993.4028234E+38');
            [~,image] = fixtureFile();
            t.verifyError(@() plus(image,value), 'nfx:TREPlacement');
        end
    end
end
