classdef SensorVelocityCompatibilityTest < NfxTest
    %SensorVelocityCompatibilityTest - Bound the level-8 scanner exception
    properties (TestParameter)
        scanMethod = {'Pushbroom', 'Whiskbroom'}
        strictLevel = num2cell([4:7 9])
        frameMethod = {'Multi-Frame', 'Multi-MIDSI'}
        velocityField = {'velocity_north_or_x', ...
            'velocity_east_or_y', 'velocity_down_or_z'}
        requirement = {'calibration', 'synchronization', 'uncertainty'}
    end
    methods (Test)
        function writeAndReadWithoutVelocity(t, scanMethod)
            sensor = scannerWithoutVelocity(scanMethod);
            t.assertTrue(sensor.validate().valid);
            payload = sensor.payload();
            parsed = inspectSENSRB(payload);
            t.verifyEqual(parsed.flags(10), 'N');
            t.verifyEqual(parsed.general.content_level, '8');
            t.verifyFalse(isfield(parsed.fields, 'i10a'));
            t.verifyFalse(isfield(parsed.fields, 'i10b'));
            t.verifyFalse(isfield(parsed.fields, 'i10c'));
            t.verifyEmpty(parsed.pixels);

            [base, image] = fixtureFile(uint8(ones(2, 3)));
            file = nfx.File(header=base.header) + ...
                (image.removeTRE(1) + sensor);
            source = fullfile(t.folder, 'source.ntf');
            file.write(source);
            [copy, ok, status] = nfx.File.read(source, readAll=true);
            t.assertTrue(ok, status.message);
            [decoded, found] = copy.images(1).SENSRB;
            t.assertTrue(found);
            t.verifyEqual(decoded.method, scanMethod);
            t.verifyEqual(decoded.content_level, 8);
            t.verifyEmpty(decoded.velocity_north_or_x);
            t.verifyEmpty(decoded.velocity_east_or_y);
            t.verifyEmpty(decoded.velocity_down_or_z);
            t.verifyEqual(decoded.payload(), payload);
            destination = fullfile(t.folder, 'copy.ntf');
            copy.write(destination);
            t.verifyEqual(readBytes(destination), readBytes(source));
        end

        function readIndependentOmittedVelocityPayload(t, scanMethod)
            sensor = scannerWithVelocity(scanMethod);
            bytes = sensor.payload();
            % Appendix Z field widths place module 10 at byte 843 for
            % fullSensor's modules 1-9 and six transform coefficients.
            t.assertEqual(char(bytes(843)), 'Y');
            bytes = [bytes(1:842) uint8('N') bytes(871:end)];
            [decoded, ok, status] = nfx.SENSRB.deserialize(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.content_level, 8);
            t.verifyEmpty(decoded.velocity_north_or_x);
            t.verifyEmpty(decoded.velocity_east_or_y);
            t.verifyEmpty(decoded.velocity_down_or_z);
            t.verifyEqual(decoded.payload(), bytes);
        end

        function continuationsPreserveOmission(t, scanMethod)
            sensor = scannerWithoutVelocity(scanMethod);
            sensor.time_stamped_data = nfx.SENSRB.timeSeries( ...
                '06a', 0:4999, repmat(40, 1, 5000));
            records = sensor.physicalRecords();
            t.assertNumElements(records, 2);
            first = inspectSENSRB(records(1).payload);
            second = inspectSENSRB(records(2).payload);
            t.verifyEqual(first.flags(10), 'N');
            t.verifyEqual(second.flags, 'NNNNYYNNNN');
            [decoded, ok, status] = nfx.SENSRB.deserializeRecords(records);
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.physicalRecords(), records);
            t.verifyEqual([decoded.time_stamped_data.time_stamp_time], 0:4999);
        end

        function partialVelocityStillFails(t, scanMethod, velocityField)
            sensor = scannerWithVelocity(scanMethod);
            sensor.(velocityField) = [];
            report = sensor.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.field}, velocityField)));
        end

        function otherScannerLevelsStillRequireVelocity(t, scanMethod, strictLevel)
            sensor = scannerWithoutVelocity(scanMethod);
            sensor.content_level = strictLevel;
            report = sensor.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'ContentLevel')));
        end

        function multipleFrameLevelEightStillRequiresVelocity(t, frameMethod)
            sensor = scannerWithoutVelocity(frameMethod);
            report = sensor.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'ContentLevel')));
        end

        function otherLevelEightRequirementsRemain(t, scanMethod, requirement)
            sensor = withoutRequirement( ...
                scannerWithoutVelocity(scanMethod), requirement);
            report = sensor.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'ContentLevel')));
        end

        function suppliedVelocityRemainsIntact(t, scanMethod)
            sensor = scannerWithVelocity(scanMethod);
            payload = sensor.payload();
            parsed = inspectSENSRB(payload);
            t.verifyEqual(parsed.flags(10), 'Y');
            [decoded, ok, status] = nfx.SENSRB.deserialize(payload);
            t.assertTrue(ok, status.message);
            t.verifyEqual([decoded.velocity_north_or_x ...
                decoded.velocity_east_or_y decoded.velocity_down_or_z], ...
                [50 0 0]);
            t.verifyEqual(decoded.payload(), payload);
        end
    end
end

function sensor = scannerWithVelocity(method)
    %scannerWithVelocity - Supply every level-8 prerequisite
    sensor = fullSensor();
    sensor.method = method;
    sensor.content_level = 8;
    sensor.pixel_referenced_data = sensor.pixel_referenced_data([]);
end

function sensor = scannerWithoutVelocity(method)
    %scannerWithoutVelocity - Omit all velocity while retaining synchronization
    sensor = scannerWithVelocity(method);
    sensor.velocity_north_or_x = [];
    sensor.velocity_east_or_y = [];
    sensor.velocity_down_or_z = [];
end

function sensor = withoutRequirement(sensor, requirement)
    %withoutRequirement - Remove one independent level-8 prerequisite
    switch requirement
        case 'calibration'
            sensor.calibration_unit = '';
            sensor.principal_point_offset_x = [];
            sensor.principal_point_offset_y = [];
            sensor.radial_distort_1 = [];
            sensor.radial_distort_2 = [];
            sensor.radial_distort_3 = [];
            sensor.radial_distort_limit = [];
            sensor.decent_distort_1 = [];
            sensor.decent_distort_2 = [];
            sensor.affinity_distort_1 = [];
            sensor.affinity_distort_2 = [];
            sensor.calibration_date = '';
        case 'synchronization'
            sensor.time_stamped_data = sensor.time_stamped_data([]);
        case 'uncertainty'
            sensor.uncertainty_data = sensor.uncertainty_data([]);
    end
end
