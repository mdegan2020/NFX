classdef SensorTest < NfxTest
    properties (TestParameter)
        angularUnit = {'DEG','RAD','SMC'}
        transformCount = {0,2,4,5,6,8}
        contentLevel = num2cell(0:9)
    end
    methods (Test)
        function minimalLiteralAndPhysicalContract(t)
            value = fixtureSensor(); data = value.payload(); out = inspectSENSRB(data);
            t.verifyEqual(numel(data),309);
            t.verifyEqual(out.flags,'YNNNYYNNNN');
            t.verifyEqual(char(data(1:26)),['YTEST SENSOR' repmat(' ',1,14)]);
            t.verifyEqual(out.general.sensor_uri,repmat('-',1,32));
            t.verifyEqual(out.general.generation_date,repmat('-',1,8));
            t.verifyEqual(out.fields.i06a,'+40.0000000');
            t.verifyEqual(out.fields.i06b,'-105.0000000');
            t.verifyEqual(out.fields.i05b,'--------');
            t.verifyEqual(value.physicalRecords(),struct('tag','SENSRB','payload',data));
            framed = value.bytes(); t.verifyEqual(char(framed(1:11)),'SENSRB00309');
            t.verifyFalse(nfx.SENSRB().validate().valid);
        end
        function allModulesDecodeWithKnownSizes(t)
            value = fullSensor(); out = inspectSENSRB(value.payload());
            t.verifyEqual(value.cel,1177);
            t.verifyEqual(out.flags,'YYYYYYYYYY');
            t.verifyEqual(out.transform_count,6);
            t.verifyEqual(str2double(out.fields.i03d),1e-8);
            t.verifyEqual(str2double(out.fields.i03f),-3e-12);
            t.verifyEqual(out.points(1).data,[1.5;2;40;-105;0;1000]);
            t.verifyEqual(out.series(1).time,[0 1]);
            t.verifyEqual(str2double(string(out.series(1).value)),[40;40.001]);
            t.verifyEqual(out.pixels(1).row,[1 2]);
            t.verifyEqual(out.pixels(1).column,[1 3]);
            t.verifyEqual(out.uncertainties(1).value,0.25);
            t.verifyEqual(out.additional(1).value,['ONE  ';'TWO  ']);
        end
        function definedTransformClassesRoundTrip(t,transformCount)
            value = fullSensor(); value.transform_param = 1:transformCount;
            out = inspectSENSRB(value.payload());
            t.verifyEqual(out.transform_count,transformCount);
            t.verifyEqual(value.cel,1105+12*transformCount);
        end
        function contentPrerequisitesAreEnforced(t,contentLevel)
            value = fullSensor(); value.content_level = contentLevel;
            t.verifyTrue(value.validate().valid);
            value.point_data = value.point_data([]);
            t.verifyEqual(value.validate().valid,mod(contentLevel,2) == 0);
            value = fixtureSensor(); value.content_level = contentLevel;
            t.verifyEqual(value.validate().valid,contentLevel == 0);
        end
        function angularUnitsDoNotChangeGeographicLatitude(t,angularUnit)
            value = fullSensor(); value.angular_unit = angularUnit;
            half = 180;
            if strcmp(angularUnit,'RAD'), half = pi; elseif strcmp(angularUnit,'SMC'), half = 1; end
            value.row_fov = half; value.column_fov = half;
            value.row_metric = []; value.column_metric = []; value.focal_length = [];
            value.sensor_angle_1 = half; value.sensor_angle_2 = half/2; value.sensor_angle_3 = -half;
            value.platform_heading = 2*half; value.platform_pitch = -half/2; value.platform_roll = half;
            out = inspectSENSRB(value.payload());
            t.verifyEqual(out.fields.i06a,'+40.0000000');
            t.verifyEqual(str2double(out.fields.i07b),half,'AbsTol',1e-7);
            value.sensor_angle_2 = half/2+0.1; t.verifyFalse(value.validate().valid);
        end
        function referenceAndOptionalUnknowns(t)
            value = fixtureSensor(); value.reference_time = []; t.verifyFalse(value.validate().valid);
            value.reference_row = -1.5; value.reference_column = 200.25;
            t.verifyTrue(value.validate().valid);
            value.calibration_unit = 'px'; value.principal_point_offset_x = NaN;
            out = inspectSENSRB(value.payload());
            t.verifyEqual(out.fields.i03b,'---------');
            t.verifyEqual(out.fields.i03l,'--------');
            value.sensor_angle_model = 1; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.platform_relative = 'Y'; value.platform_heading = NaN;
            t.verifyFalse(value.validate().valid);
            value.platform_relative = 'N'; t.verifyTrue(value.validate().valid);
        end
        function cartesianSignedValuesAndFieldBounds(t)
            value = fixtureSensor(); value.geodetic_type = 'C'; value.length_unit = 'EE';
            value.latitude_or_x = -12345678.25; value.longitude_or_y = 23456789.5;
            value.altitude_or_z = 3456789.25;
            out = inspectSENSRB(value.payload());
            t.verifyEqual(str2double(out.fields.i06a),-12345678.2);
            t.verifyEqual(str2double(out.fields.i06b),23456789.5);
            value.latitude_or_x = 1e20; t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.sensor_x_offset = 1e-20;
            t.verifyFalse(value.validate().valid);
        end
        function datesAndGenerationUseDistinctFormats(t)
            value = fixtureSensor(); value.start_date = '20260229'; t.verifyFalse(value.validate().valid);
            value.start_date = '20260915'; value.end_time = 43199; t.verifyFalse(value.validate().valid);
            value.end_date = '20260916'; t.verifyTrue(value.validate().valid);
            value.start_date = '20260---'; value.end_date = '20261---'; t.verifyTrue(value.validate().valid);
            value.end_date = '2025----'; t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.generation_count = 1; t.verifyFalse(value.validate().valid);
            value.generation_date = '20260915'; value.generation_time = '235959.999'; t.verifyTrue(value.validate().valid);
            value.generation_time = '240000.000'; t.verifyFalse(value.validate().valid);
            value.generation_time = '23:59:59.9'; t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.start_time = 86399.99999999;
            value.end_time = value.start_time; t.verifyTrue(value.validate().valid);
        end
        function attitudeAndFormationRelationships(t)
            value = fullSensor(); value.icx_north_or_x = 0.5; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.icz_down_or_z = -1; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.attitude_q4 = 0.5; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.row_set = 3; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.first_pixel_column = 4; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.method = 'Pushbroom';
            value.velocity_north_or_x = []; value.velocity_east_or_y = []; value.velocity_down_or_z = [];
            t.verifyFalse(value.validate().valid);
        end
        function strictInputsRejectCoercionAndMalformedGroups(t)
            t.verifyError(@() nfx.SENSRB(latitude_or_x=single(40)),'nfx:SensorNumber');
            t.verifyError(@() nfx.SENSRB(latitude_or_x=[40 41]),'nfx:SensorNumber');
            t.verifyError(@() nfx.SENSRB(transform_param=[1 2 3]),'nfx:SensorTransform');
            t.verifyError(@() nfx.SENSRB.timeSeries('06a',[0;1],[40 41]),'nfx:SensorRow');
            t.verifyError(@() nfx.SENSRB.timeSeries('01a',0,40),'nfx:SensorIndex');
            t.verifyError(@() nfx.SENSRB.timeSeries('06a',[0 1],40),'nfx:SensorSamples');
            t.verifyError(@() nfx.SENSRB.pixelSeries('06a',[1 2],1,[40 41]),'nfx:SensorSamples');
            t.verifyError(@() nfx.SENSRB.pointSet('Image Center',[1 2],1),'nfx:SensorSamples');
            t.verifyError(@() nfx.SENSRB(point_data=struct('wrong',1)),'nfx:SensorGroup');
            t.verifyError(@() nfx.SENSRB.uncertainty('06a',[]),'nfx:SensorNumber');
            t.verifyError(@() nfx.SENSRB.additionalParameter('TEST',"TOO LONG",2),'nfx:MetadataRows');
        end
        function uncertaintiesResolveLoopsAndConserveMeaning(t)
            value = fullSensor();
            value.uncertainty_data = [nfx.SENSRB.uncertainty('11e01.001',0.5) ...
                nfx.SENSRB.uncertainty('12d1.2',0.1) nfx.SENSRB.uncertainty('13e1.2',0.2) ...
                nfx.SENSRB.uncertainty('04l',0.3,'04m')];
            out = inspectSENSRB(value.payload());
            t.verifyEqual(strtrim(out.uncertainties(1).first),'11e1.1');
            t.verifyEqual(strtrim(out.uncertainties(2).first),'12d1.2');
            value.uncertainty_data(1).uncertainty_first_type = '11e2.1'; t.verifyFalse(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('02a',1); t.verifyFalse(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('15d1.1',1); t.verifyFalse(value.validate().valid);
            value.additional_parameter_data = nfx.SENSRB.additionalParameter('TEST NUMERIC',"1.25",4);
            t.verifyTrue(value.validate().valid);
        end
        function uncertaintyExtremesUseSpecifiedSubstitutions(t)
            value = fixtureSensor(); value.uncertainty_data = [nfx.SENSRB.uncertainty('06a',1e200) ...
                nfx.SENSRB.uncertainty('06b',1e-200) nfx.SENSRB.uncertainty('06c',1e-99) ...
                nfx.SENSRB.uncertainty('06a',-1,'06b')];
            out = inspectSENSRB(value.payload());
            t.verifyEqual([out.uncertainties.value],[9.99999e99 0 1e-99 -1]);
            for k = 1:4, t.verifyNotEmpty(regexp(strtrim(out.uncertainties(k).literal),'^-?\d(?:\.\d+)?E-?\d{1,2}$','once')); end
            value.uncertainty_data = nfx.SENSRB.uncertainty('06a',0); t.verifyFalse(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('06a',1.01,'06b'); t.verifyFalse(value.validate().valid);
        end
        function pointsPreserveUnknownLocationsAndValidateTypes(t)
            value = fixtureSensor(); value.point_data = nfx.SENSRB.pointSet('Point of Interest',0.5,-0.25);
            out = inspectSENSRB(value.payload()); t.verifyEqual(out.points.data,[0.5;-0.25;NaN;NaN;NaN;NaN]);
            value.point_data.p_latitude = 91; t.verifyFalse(value.validate().valid);
            value.point_data.p_latitude = NaN; value.point_data.p_range = 0; t.verifyFalse(value.validate().valid);
            value.point_data.p_range = NaN; value.point_data.point_set_type = 'UNREGISTERED'; t.verifyFalse(value.validate().valid);
        end
        function fullSensorReaderRoundTrip(t)
            [base,image] = fixtureFile(); image = image.removeTRE(1)+fullSensor();
            file = nfx.File(header=base.header)+image;
            path = fullfile(t.folder,'sensor.ntf'); file.write(path);
            parsed = inspectContainer(path); out = inspectSENSRB(parsed.images(1).allTRE(1).payload);
            t.verifyEqual(out.flags,'YYYYYYYYYY');
            t.verifyEqual(nitfread(path),image.data); t.verifyTrue(isnitf(path));
            info = nitfinfo(path); t.verifyEqual(double(info.FileLength),parsed.fl);
        end
        function numericUncertaintiesCoverEveryStaticModule(t)
            value = fullSensor(); out = inspectSENSRB(value.payload());
            fields = fieldnames(out.fields); groups = value.uncertainty_data([]);
            for k = 1:numel(fields)
                type = fields{k}(2:end);
                if ~any(strcmp(type,{'02a','02i','03a','03l','04a','04b','07e'}))
                    groups(end+1) = nfx.SENSRB.uncertainty(type,0.01); %#ok<AGROW>
                end
            end
            for type = ["11c" "11d" "11e" "11f" "11g" "11h" "12c" "13c" "13d"]
                groups(end+1) = nfx.SENSRB.uncertainty(type+"1.1",0.01); %#ok<AGROW>
            end
            value.uncertainty_data = groups;
            out = inspectSENSRB(value.payload());
            t.verifyEqual(numel(out.uncertainties),numel(groups));
            t.verifyEqual([out.uncertainties.value],repmat(0.01,1,numel(groups)));
        end
        function malformedAndUnknownUncertaintyTargets(t)
            value = fullSensor();
            targets = ["0" "01a" "04k" "11e1" "11e0.1" "11e1.0" "11e1.x" "11e1..1" ...
                "11e1.2" "13e2.1" "13e1.3" "15d2.1" "15d1.3" "12d2.1" "12d1.3" "14c1.1"];
            for target = targets
                value.uncertainty_data = nfx.SENSRB.uncertainty(target,0.1);
                t.verifyFalse(value.validate().valid,char(target));
            end
            value.uncertainty_data = nfx.SENSRB.uncertainty('03b',0.1); value.principal_point_offset_x = NaN;
            t.verifyFalse(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('06a',0.1,'06a'); t.verifyTrue(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('06a',0.1,'-----------'); t.verifyTrue(value.validate().valid);
        end
        function optionalStringEmptiesAndCounterLimits(t)
            value = fixtureSensor(); value.detection = ""; value.calibration_unit = "";
            value.method = ""; value.platform_relative = "";
            t.verifyEqual(value.payload(),fixtureSensor().payload());
            value.point_data = repmat(nfx.SENSRB.pointSet('Image Center',1,1),1,100);
            t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.point_data = nfx.SENSRB.pointSet('Image Center',1:1000,1:1000);
            t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.pixel_referenced_data = repmat(nfx.SENSRB.pixelSeries('06a',1,1,40),1,100);
            t.verifyFalse(value.validate().valid);
            value.pixel_referenced_data = nfx.SENSRB.pixelSeries('06a',1:10000,1:10000,repmat(40,1,10000));
            t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.uncertainty_data = repmat(nfx.SENSRB.uncertainty('06a',1),1,1000);
            t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.additional_parameter_data = repmat(nfx.SENSRB.additionalParameter('TEST','1',1),1,1000);
            t.verifyFalse(value.validate().valid);
        end
        function invalidScienceFormatsAndRowShapes(t)
            value = fullSensor(); value.radial_distort_1 = 1e100; t.verifyFalse(value.validate().valid);
            value.radial_distort_1 = 1e-100; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.row_set = 1; t.verifyFalse(value.validate().valid);
            value = fixtureSensor(); value.time_stamped_data = nfx.SENSRB.timeSeries('06a',NaN,40);
            t.verifyFalse(value.validate().valid);
            value.time_stamped_data.time_stamp_type = '20a'; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.SENSRB.timeSeries('06a',[0 1],[40;41]),'nfx:SensorValues');
            group = nfx.SENSRB.additionalParameter('TEST','1',1); group.parameter_value = '12';
            t.verifyError(@() nfx.SENSRB(additional_parameter_data=group),'nfx:SensorAdditional');
            t.verifyError(@() physicalRecords(SyntheticTRE(zeros(1,0,'uint8'))),'nfx:TRELength');
        end
        function opticalGeometryUsesAllPublishedSufficientCombinations(t)
            patterns = [0 0 0 1 1;1 1 1 0 0;1 1 0 1 0;1 1 0 0 1; ...
                0 0 1 1 1;1 0 0 1 1;0 1 0 1 1;1 0 1 0 1;0 1 1 1 0];
            fields = {'row_metric','column_metric','focal_length','row_fov','column_fov'};
            for k = 1:size(patterns,1)
                value = fullSensor();
                for j = 1:5, if ~patterns(k,j), value.(fields{j}) = []; end, end
                t.verifyTrue(value.validate().valid,sprintf('Combination %d',k));
            end
            value = fullSensor();
            for j = 1:5, value.(fields{j}) = []; end
            t.verifyFalse(value.validate().valid);
            value.content_level = 0; t.verifyTrue(value.validate().valid);
            value = fullSensor(); value.row_fov = 20; value.column_fov = 30;
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'SensorArrayConsistency')));
            value.content_level = 0; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.focal_length = []; value.column_fov = 30;
            t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.row_fov = 180; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.row_metric = 1e-20; t.verifyFalse(value.validate().valid);
            value = fullSensor(); value.focal_length = value.focal_length*(1+5e-5);
            t.verifyTrue(value.validate().valid);
        end
        function complexAdditionalUncertaintyTargetIsRejected(t)
            value = fixtureSensor(); value.additional_parameter_data = nfx.SENSRB.additionalParameter('Complex','1+2i',4);
            t.verifyTrue(value.validate().valid);
            value.uncertainty_data = nfx.SENSRB.uncertainty('15d1.1',0.2);
            t.verifyFalse(value.validate().valid);
            value.additional_parameter_data.parameter_value = '1.25'; t.verifyTrue(value.validate().valid);
        end
    end
end
