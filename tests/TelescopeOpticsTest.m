classdef TelescopeOpticsTest < NfxTest
    methods (Test)
        function frameTransformsUseNativeBigEndianCountAndParameterOrder(t)
            value = fixtureTelescopeOptics(); data = value.bytes();
            t.verifyEqual(data(1:5),uint8([48 0 0 0 2])); t.verifyEqual(numel(data),341);
            numbers = reshape(str2double(cellstr(reshape(char(data(6:end)),21,[]).')),8,[]);
            t.verifyEqual(numbers,[0 0.1;1 1;0 0;0 0;0 0;0 0.2;0 0;1 1]);
            t.verifyEqual(value.n_frames,2); t.verifyEqual(value.n_frame_times,2);
        end
        function timeBasedVaryingParametersFollowDeclaredIdentityOrder(t)
            value = fixtureTelescopeOptics(2); value.time_varying_io_parm_id = [11 1];
            value.time_varying_io_m = [1 2;3 4]; value.tele_iop = fixtureInteriorOrientation();
            data = value.bytes(); t.verifyEqual(data(1:5),uint8([49 0 0 0 2]));
            t.verifyEqual(char(data(6:19)),'02110120260915');
            t.verifyEqual(char(data(20:34)),'00001.000000000');
            t.verifyEqual(str2double(cellstr(reshape(char(data(203:244)),21,[]).')).',[1 3]);
            t.verifyEqual(char(data(245:259)),'00002.000000000');
            t.verifyEqual(str2double(cellstr(reshape(char(data(428:469)),21,[]).')).',[2 4]);
            t.verifyEqual(data(470:end),value.tele_iop.bytes()); t.verifyEqual(numel(data),732);
            t.verifyEqual([value.n_varying_io value.num_tele_sets_fa_data],[2 1]);
        end
        function optionalStaticLensFieldsUseTheTelescopeContext(t)
            value = fixtureTelescopeOptics(); value.tele_iop = fixtureInteriorOrientation(); data = value.bytes();
            t.verifyEqual(char(data(1)),'1'); t.verifyEqual(data(342:end),value.tele_iop.bytes());
            t.verifyEqual(value.byte_length,604); value.tele_iop(2) = value.tele_iop(1);
            t.verifyFalse(value.validate().valid);
            value.tele_iop = nfx.InteriorOrientation(); t.verifyFalse(value.validate().valid);
        end
        function zeroCountDefinitionVariantsHaveExactLengths(t)
            value = nfx.TelescopeOptics(telescope_optics_flag=1); t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.bytes(),uint8([48 0 0 0 0])); value.telescope_optics_flag = 2;
            value.tele_date = '20260915'; t.verifyEqual(value.bytes(),[uint8([48 0 0 0 0]) uint8('0020260915')]);
            t.verifyEqual(value.byte_length,15);
        end
        function onlyTimeBasedCorrectionsUseExplicitTimesAndVaryingIO(t)
            value = fixtureTelescopeOptics(); value.tele_date = '20260915'; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(); value.tele_time = [1 2]; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(); value.time_varying_io_parm_id = 1; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(); value.time_varying_io_m = 1; t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.TelescopeOptics().validate().valid);
        end
        function timeBasedSamplesAndVaryingShapesAreValidated(t)
            value = fixtureTelescopeOptics(2); value.tele_date = '20260230'; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(2); value.tele_time = 1; t.verifyFalse(value.validate().valid);
            value.tele_time = [2 1]; t.verifyFalse(value.validate().valid);
            value.tele_time = [1 1+1e-12]; t.verifyFalse(value.validate().valid);
            value.tele_time = [1 NaN]; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(2); value.time_varying_io_parm_id = [1 1];
            value.time_varying_io_m = zeros(2,2); t.verifyFalse(value.validate().valid);
            value.time_varying_io_parm_id = [1 2]; t.verifyTrue(value.validate().valid);
            value.time_varying_io_m = [1 2]; t.verifyFalse(value.validate().valid);
            value.time_varying_io_m = [1 2;3 NaN]; t.verifyFalse(value.validate().valid);
            value.time_varying_io_parm_id = []; t.verifyFalse(value.validate().valid);
        end
        function transformShapesAndNumericEncodingAreValidated(t)
            value = fixtureTelescopeOptics(); value.tele_trans_t7 = 1; t.verifyFalse(value.validate().valid);
            value = fixtureTelescopeOptics(); value.tele_trans_t3(1) = 1e-114; t.verifyFalse(value.validate().valid);
            value.tele_trans_t3(1) = 1e-113; t.verifyTrue(value.validate().valid);
            value.tele_trans_t3(1) = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.TelescopeOptics(tele_trans_t0=single(1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.TelescopeOptics(tele_time=-1),'nfx:TelescopeTimes');
            t.verifyError(@() nfx.TelescopeOptics(time_varying_io_parm_id=12),'nfx:VaryingIDs');
            t.verifyError(@() nfx.TelescopeOptics(time_varying_io_parm_id=uint8(1)),'nfx:VaryingIDs');
            t.verifyError(@() nfx.TelescopeOptics(time_varying_io_parm_id=[1;2]),'nfx:VaryingIDs');
            t.verifyError(@() nfx.TelescopeOptics(time_varying_io_parm_id=ones(1,12)),'nfx:VaryingIDs');
        end
        function cssfabRetainsTimeCorrectionsAsAValueSnapshot(t)
            value = fixtureCSSFAB('F',1); telescope = fixtureTelescopeOptics(2); value.telescope = telescope;
            segment = value.segment(); t.verifyTrue(segment.verifiedSensor()); t.verifyEqual(value.telescope_optics_flag,2);
            t.verifyEqual(segment.data(558:end-9),telescope.bytes());
            telescope.tele_trans_t0(1) = 0.3; t.verifyNotEqual(telescope.bytes(),value.telescope.bytes());
        end
    end
end
