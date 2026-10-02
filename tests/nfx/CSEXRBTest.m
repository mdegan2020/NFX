classdef CSEXRBTest < NfxTest
    methods (Test)
        function genericMinimumHasExactBytes(t)
            value = fixtureCSEXRB(); data = value.payload();
            expected = [uint8('10000000-0000-4000-8000-000000000001000PLAT  PAYLD SENSOR ') ...
                repmat(uint8(' '),1,130) uint8('000003200064') repmat(uint8(' '),1,20) ...
                uint8('0099') repmat(uint8(' '),1,31) uint8('00000')];
            t.verifyEqual(data,expected); t.verifyEqual(value.cel,260);
            t.verifyEqual(value.bytes(),[uint8('CSEXRB00260') expected]);
            parsed = inspectCSEXRB(data); t.verifyEqual(parsed.num_samples,64); t.verifyEqual(parsed.flags,[0 0 9 9]);
        end
        function scannerFieldsAndAllBaseMetadataRoundTrip(t)
            value = fixtureCSEXRB('S'); value.ground_ref_point_x = -123.45; value.ground_ref_point_y = 0;
            value.ground_ref_point_z = 987.65; value.max_gsd = 1.1; value.along_scan_gsd = 2.2;
            value.cross_scan_gsd = 3.3; value.geo_mean_gsd = 4.4; value.a_s_vert_gsd = 5.5;
            value.c_s_vert_gsd = 6.6; value.geo_mean_vert_gsd = 7.7; value.gsd_beta_angle = 45.6;
            value.dynamic_range = 1023; value.angle_to_north = 359.999; value.obliquity_angle = 90;
            value.az_of_obliquity = 12.345; value.atm_refr_flag = 1; value.vel_aber_flag = 1;
            value.grd_cover = 1; value.snow_depth_category = 3; value.sun_azimuth = 100;
            value.sun_elevation = -12.345; value.predicted_niirs = 8.9; value.circl_err = 123.4;
            value.linear_err = 345.6; value.cloud_cover = 999; value.ue_time_flag = 1;
            p = inspectCSEXRB(value.payload()); t.verifyEqual(value.cel,443);
            t.verifyEqual(p.ground_ref_point,[-123.45 0 987.65]); t.verifyEqual(p.gsd,(1:7)*1.1,'AbsTol',1e-14);
            t.verifyEqual(p.day_first_line_image,'20260915'); t.verifyEqual(p.time_first_line_image,1.25);
            t.verifyEqual(p.time_image_duration,-0.5); t.verifyEqual(p.angles,[359.999 90 12.345]);
            t.verifyEqual(p.flags,[1 1 1 3]); t.verifyEqual(p.sun,[100 -12.345]);
            t.verifyEqual(p.niirs,8.9); t.verifyEqual(p.errors,[123.4 345.6]); t.verifyEqual(p.cloud_cover,999);
        end
        function framerRetainsNativeIntegersAtEveryWidth(t)
            value = fixtureCSEXRB('F'); value.dt_multiplier = intmax('uint64');
            value.number_frames = 2; value.reference_frame_num = 999999999;
            for width = 1:8
                maximum = bitshift(intmax('uint64'),-8*(8-width));
                value.dt = [maximum uint64(1)]; t.verifyEqual(value.dt_size,width);
                p = inspectCSEXRB(value.payload()); t.verifyEqual(p.dt,value.dt);
                t.verifyEqual(p.dt_multiplier,intmax('uint64')); t.verifyEqual(p.dt_size,width);
                t.verifyEqual(p.base_timestamp,'20260915235959.123456789'); t.verifyEqual(p.number_frames,2);
                t.verifyEqual(p.reference_frame_num,999999999); t.verifyEqual(value.cel,456+2*width);
            end
        end
        function externalTimingOmitsTheLocalBlock(t)
            value = fixtureCSEXRB('F'); value.time_stamp_loc = 1; value.base_timestamp = '';
            value.number_frames = NaN; value.rolling_shutter_flag = 1;
            p = inspectCSEXRB(value.payload()); t.verifyEqual(p.time_stamp_loc,1);
            t.verifyFalse(isfield(p,'dt')); t.verifyEqual(p.rolling_shutter_flag,1); t.verifyEqual(value.cel,406);
        end
        function singleUniformAndPerFrameDeltaCounts(t)
            value = fixtureCSEXRB('F'); t.verifyTrue(value.validate().valid);
            value.dt = uint64(3); t.verifyTrue(value.validate().valid); value.number_frames = 10;
            t.verifyTrue(value.validate().valid); value.dt = uint64(1:10); t.verifyTrue(value.validate().valid);
            value.dt = uint64(1:9); t.verifyFalse(value.validate().valid);
            value.dt = zeros(1,0,'uint64'); t.verifyFalse(value.validate().valid);
            value.number_frames = NaN; t.verifyFalse(value.validate().valid);
        end
        function selectedDeltaWidthsAndTimestampSyntaxAreChecked(t)
            value = fixtureCSEXRB('F'); value.dt = uint64(256); value.dt_size = 1;
            t.verifyFalse(value.validate().valid); value.dt_size = 8; t.verifyTrue(value.validate().valid);
            value.dt_size = NaN; t.verifyEqual(value.dt_size,2);
            value.base_timestamp = '20260230000000.000000000'; t.verifyFalse(value.validate().valid);
            value.base_timestamp = ''; t.verifyFalse(value.validate().valid);
        end
        function exactMaximumAndOversizedPayloads(t)
            value = fixtureCSEXRB('F'); value.number_frames = 99985-456;
            value.dt = zeros(1,value.number_frames,'uint64'); t.verifyEqual(value.cel,99985);
            t.verifyEqual(numel(value.bytes()),99996);
            value.dt(end+1) = uint64(0); value.number_frames = value.number_frames+1;
            t.verifyFalse(value.validate().valid); t.verifyError(@() value.payload(),'nfx:Invalid');
        end
        function reservedAreaLengthsAndFieldsAreDerived(t)
            value = fixtureCSEXRB(); area = nfx.ExploitationInfo(num_img_ops=2,tgt_id='ABCDEFGHIJKLMNOUS', ...
                tgt_name='Example',tgt_type='Point',tgt_lat=-45,tgt_lon=123,tgt_ht=123.4, ...
                tgt_date_time='20260915120000',tgt_az=100,tgt_elev_ang=-12,tgt_bidec_ang=90, ...
                coll_req_id='request',collect_strat='Sensor Unique',collect_type='IMG',coll_code='code');
            area.collect_criteria = nfx.CollectionCriterion(collect_criteria_name='Spectral Radiance',collect_criteria_value=1.25);
            op = nfx.ImagingOperation(cm_id='mode',sensor_config='config',img_op_id='op1',num_exp=2, ...
                index_in_img_op_id=[intmax('uint64')-uint64(1) intmax('uint64')]);
            op.quality_metrics = nfx.QualityMetric(quality_metric_name='CE90',quality_metric_value=1.25,quality_metric_type='M');
            area.img_ops_data = op; value.exploitation = area; p = inspectCSEXRB(value.payload());
            t.verifyEqual(p.reserved_len,8+p.reserved_len_area1); t.verifyEqual(p.num_img_ops,2);
            t.verifyEqual(p.tgt_name,'Example'); t.verifyEqual(p.target,[-45 123 123.4]);
            t.verifyEqual(p.target_angles,[100 -12 90]); t.verifyEqual(p.collect_strat,'Sensor Unique');
            t.verifyEqual(p.criteria{1}.unit,['W/(m m sr ' char(181) 'm)']);
            t.verifyEqual(p.operations{1}.indices,op.index_in_img_op_id);
            t.verifyEqual(p.operations{1}.metrics{1}.value,'1.25');
            area.num_img_ops = 3; t.verifyEqual(value.exploitation.num_img_ops,2);
        end
        function minimalReservedAreaHasAllCurrentFields(t)
            value = fixtureCSEXRB(); value.exploitation = nfx.ExploitationInfo(num_img_ops=1);
            p = inspectCSEXRB(value.payload()); t.verifyEqual(p.reserved_len_area1,83);
            t.verifyEqual(value.reserved_len,91); t.verifyEqual(value.cel,351);
        end
        function measuredCloudCoverMustMatchThePrimaryField(t)
            value = fixtureCSEXRB(); value.cloud_cover = 5;
            metric = nfx.QualityMetric(quality_metric_name='Cloud Cover',quality_metric_value=6,quality_metric_type='M');
            area = nfx.ExploitationInfo(num_img_ops=1,img_ops_data=nfx.ImagingOperation(num_exp=1,quality_metrics=metric));
            value.exploitation = area; t.verifyFalse(value.validate().valid); value.cloud_cover = 6;
            t.verifyTrue(value.validate().valid); value.cloud_cover = NaN; t.verifyFalse(value.validate().valid);
            value.cloud_cover = 999; t.verifyFalse(value.validate().valid);
            area.img_ops_data.quality_metrics.quality_metric_type = 'P'; value.exploitation = area;
            t.verifyTrue(value.validate().valid);
        end
        function requiredAndCodeFailuresProduceReports(t)
            t.verifyFalse(nfx.CSEXRB().validate().valid); value = fixtureCSEXRB();
            names = {'image_uuid','platform_id','payload_id','sensor_id'};
            for k = 1:numel(names)
                invalid = value; invalid.(names{k}) = ''; t.verifyFalse(invalid.validate().valid);
            end
            names = {'num_lines','num_samples','atm_refr_flag','vel_aber_flag'};
            for k = 1:numel(names)
                invalid = value; invalid.(names{k}) = NaN; t.verifyFalse(invalid.validate().valid);
            end
            invalid = value; invalid.grd_cover = 2; t.verifyFalse(invalid.validate().valid);
            invalid = value; invalid.snow_depth_category = 4; t.verifyFalse(invalid.validate().valid);
            invalid = value; invalid.cloud_cover = 101; t.verifyFalse(invalid.validate().valid);
            invalid = value; invalid.sensor_type = 'X'; t.verifyFalse(invalid.validate().valid);
            invalid = value; invalid.ground_ref_point_x = 1; t.verifyFalse(invalid.validate().valid);
        end
        function sensorAndAssociationConditionsAreEnforced(t)
            value = fixtureCSEXRB('S'); value.assoc_des_uuid = {}; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.assoc_des_uuid = {'bad'}; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB('S'); value.assoc_des_uuid{2} = upper(value.assoc_des_uuid{1});
            t.verifyFalse(value.validate().valid); value = fixtureCSEXRB('S');
            value.assoc_des_uuid = repmat(value.assoc_des_uuid,1,250); t.verifyFalse(value.validate().valid);
        end
        function hiddenConditionalDataCannotDisappearSilently(t)
            value = fixtureCSEXRB(); value.time_first_line_image = 0; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.time_stamp_loc = 0; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.rolling_shutter_flag = 0; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.number_frames = 1; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.dt_size = 1; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB(); value.dt_multiplier = uint64(2); t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB('S'); value.day_first_line_image = ''; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB('F'); value.time_stamp_loc = NaN; t.verifyFalse(value.validate().valid);
            value = fixtureCSEXRB('F'); value.time_stamp_loc = 1; t.verifyFalse(value.validate().valid);
        end
        function strictPropertyTypesAndAreaMultiplicity(t)
            t.verifyError(@() nfx.CSEXRB(dt=1),'nfx:GLASIntegers');
            t.verifyError(@() nfx.CSEXRB(dt_multiplier=1),'nfx:TimeMultiplier');
            t.verifyError(@() nfx.CSEXRB(dt_multiplier=uint64(0)),'nfx:TimeMultiplier');
            t.verifyError(@() nfx.CSEXRB(assoc_des_uuid='x'),'nfx:AssociatedUUIDs');
            t.verifyError(@() nfx.CSEXRB(num_lines=uint32(1)),'nfx:Metadata');
            t.verifyError(@() nfx.CSEXRB(exploitation=struct()),'nfx:GLASObjects');
            value = fixtureCSEXRB(); value.exploitation = repmat(nfx.ExploitationInfo(num_img_ops=1),1,2);
            t.verifyFalse(value.validate().valid); t.verifyError(@() value.reserved_len,'nfx:ExploitationCount');
        end
    end
end
