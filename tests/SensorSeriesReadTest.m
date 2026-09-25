classdef SensorSeriesReadTest < NfxTest
    properties (TestParameter)
        readAll = {false, true}
    end
    methods (Test)
        function sixTypesConsolidateAfterFileRead(t, readAll)
            sensor = sixSeries();
            [base, image] = fixtureFile();
            source = nfx.File(header=base.header) + ...
                (image.removeTRE(1) + sensor);
            path = fullfile(t.folder, 'series.ntf'); source.write(path);
            [file, ok, status] = nfx.File.read(path, readAll=readAll);
            t.assertTrue(ok, status.message);
            before = file.images.tre_records;
            [decoded, ok, status] = file.images.SENSRB;
            t.assertTrue(ok, status.message);
            t.verifyEqual(file.images.treCount('SENSRB'), 1);
            t.verifyGreaterThan(numel(before), 1);
            t.verifyNumElements(decoded.time_stamped_data, 6);
            verifyNumericSeries(t, decoded.time_stamped_data, sensor.time_stamped_data);
            t.verifyEqual(decoded.physicalRecords(), sensor.physicalRecords());
            t.verifyEqual(file.images.tre_records, before);
            output = fullfile(t.folder, 'copy.ntf'); file.write(output);
            t.verifyEqual(readBytes(output), readBytes(path));
        end

        function largeSingleTypePreservesNonmonotonicAndDuplicateTimes(t)
            sensor = fixtureSensor();
            time = [1:6000 5000 6002:13000];
            sensor.time_stamped_data = nfx.SENSRB.timeSeries( ...
                '07a', time, 1 + mod(1:13000, 3));
            records = sensor.physicalRecords();
            [decoded, ok, status] = nfx.SENSRB.deserializeRecords(records);
            t.assertTrue(ok, status.message);
            t.verifyNumElements(decoded.time_stamped_data, 1);
            verifyNumericSeries(t, decoded.time_stamped_data, sensor.time_stamped_data);
            t.verifyEqual(decoded.physicalRecords(), records);
        end

        function nonadjacentTextGroupsRetainRowValues(t)
            sensor = fixtureSensor();
            sensor.time_stamped_data = [ ...
                nfx.SENSRB.timeSeries('07e', [2 1], ['Y'; 'N']), ...
                nfx.SENSRB.timeSeries('10a', 1, 10), ...
                nfx.SENSRB.timeSeries('07e', [1 3], ['Y'; 'N'])];
            payload = sensor.payload();
            [decoded, ok, status] = nfx.SENSRB.deserialize(payload);
            t.assertTrue(ok, status.message);
            t.verifyEqual({decoded.time_stamped_data.time_stamp_type}, ...
                {'07e', '10a'});
            t.verifyEqual(decoded.time_stamped_data(1).time_stamp_time, ...
                [2 1 1 3], AbsTol=0);
            t.verifyEqual(decoded.time_stamped_data(1).time_stamp_value.text, ...
                ['Y'; 'N'; 'Y'; 'N']);
            t.verifyEmpty(decoded.time_stamped_data(1).time_stamp_value.numeric);
            t.verifyEqual(decoded.payload(), payload);
        end

        function uncertaintyReferencesAddressConsolidatedSamples(t)
            sensor = interleavedSensor(); payload = sensor.payload();
            [decoded, ok, status] = nfx.SENSRB.deserialize(payload);
            t.assertTrue(ok, status.message);
            t.verifyEqual({decoded.uncertainty_data.uncertainty_first_type}, ...
                {'12d1.4', '12c1.3', '06a'});
            t.verifyEqual({decoded.uncertainty_data.uncertainty_second_type}, ...
                {'12d2.1', '', ''});
            t.verifyEqual(decoded.time_stamped_data(1).time_stamp_value.numeric, ...
                [10 20 21 40], AbsTol=0);
            t.verifyTrue(decoded.validate().valid);
            t.verifyEqual(decoded.payload(), payload);
        end

        function editedMergedValueUpdatesOriginalChunkAndUncertainty(t)
            sensor = interleavedSensor(); payload = sensor.payload();
            decoded = nfx.SENSRB.deserialize(payload);
            decoded.time_stamped_data(1).time_stamp_value.numeric(4) = 41;
            edited = inspectSENSRB(decoded.payload());
            t.verifyEqual({edited.series.type}, {'10a', '10b', '10a'});
            t.verifyEqual(str2double(edited.series(3).value(2, :)), 41, AbsTol=0);
            t.verifyEqual(strtrim(edited.uncertainties(1).first), '12d3.2');
            t.verifyEqual(strtrim(edited.uncertainties(1).second), '12d2.1');
            t.verifyEqual(sensor.payload(), payload);
        end

        function uncertaintyReferencesSurvivePhysicalContinuations(t)
            sensor = interleavedSensor();
            sensor.time_stamped_data(3) = nfx.SENSRB.timeSeries( ...
                '10a', 1:6000, 101:6100);
            records = sensor.physicalRecords();
            [decoded, ok, status] = nfx.SENSRB.deserializeRecords(records);
            t.assertTrue(ok, status.message);
            t.verifyGreaterThan(numel(records), 1);
            t.verifyEqual(decoded.uncertainty_data(1).uncertainty_first_type, '12d1.4');
            t.verifyEqual(decoded.time_stamped_data(1).time_stamp_value.numeric(4), ...
                102, AbsTol=0);
            t.verifyEqual(decoded.physicalRecords(), records);
            decoded.time_stamped_data(1).time_stamp_value.numeric(4) = 999;
            [again, ok, status] = ...
                nfx.SENSRB.deserializeRecords(decoded.physicalRecords());
            t.assertTrue(ok, status.message);
            t.verifyEqual(again.time_stamped_data(1).time_stamp_value.numeric(4), ...
                999, AbsTol=0);
            t.verifyEqual(again.uncertainty_data, decoded.uncertainty_data);
        end

        function resizedSeriesUsesNewPackingAndPreservesReferences(t)
            decoded = nfx.SENSRB.deserialize(interleavedSensor().payload());
            decoded.time_stamped_data(1) = nfx.SENSRB.timeSeries( ...
                '10a', [1 2 2 4 5], [10 20 21 40 50]);
            payload = decoded.payload(); parsed = inspectSENSRB(payload);
            t.verifyNumElements(parsed.series, 2);
            t.verifyEqual(strtrim(parsed.uncertainties(1).first), '12d1.4');
            [again, ok, status] = nfx.SENSRB.deserialize(payload);
            t.assertTrue(ok, status.message);
            verifyNumericSeries(t, again.time_stamped_data, decoded.time_stamped_data);
        end

        function typeChangeInvalidatesImportedLayout(t)
            decoded = nfx.SENSRB.deserialize(interleavedSensor().payload());
            decoded.time_stamped_data(2).time_stamp_type = '10c';
            [again, ok, status] = nfx.SENSRB.deserialize(decoded.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual({again.time_stamped_data.time_stamp_type}, {'10a', '10c'});
            t.verifyEqual(again.time_stamped_data, decoded.time_stamped_data, AbsTol=0);
        end

        function typeReorderingInvalidatesImportedLayout(t)
            decoded = nfx.SENSRB.deserialize(interleavedSensor().payload());
            decoded.uncertainty_data = decoded.uncertainty_data([]);
            decoded.time_stamped_data = decoded.time_stamped_data([2 1]);
            [again, ok, status] = nfx.SENSRB.deserialize(decoded.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual({again.time_stamped_data.time_stamp_type}, {'10b', '10a'});
            t.verifyEqual(again.time_stamped_data, decoded.time_stamped_data, AbsTol=0);
        end

        function newlyAddedDuplicateTypeIsNotDropped(t)
            decoded = nfx.SENSRB.deserialize(interleavedSensor().payload());
            decoded.time_stamped_data(3) = nfx.SENSRB.timeSeries('10a', 6, 60);
            [again, ok, status] = nfx.SENSRB.deserialize(decoded.payload());
            t.assertTrue(ok, status.message);
            t.verifyNumElements(again.time_stamped_data, 2);
            t.verifyEqual(again.time_stamped_data(1).time_stamp_time, ...
                [1 2 2 4 6], AbsTol=0);
            t.verifyEqual(again.time_stamped_data(1).time_stamp_value.numeric, ...
                [10 20 21 40 60], AbsTol=0);
        end

        function removedSeriesDoesNotReuseStaleLayout(t)
            decoded = nfx.SENSRB.deserialize(interleavedSensor().payload());
            decoded.uncertainty_data = decoded.uncertainty_data([]);
            decoded.time_stamped_data = decoded.time_stamped_data([]);
            [again, ok, status] = nfx.SENSRB.deserialize(decoded.payload());
            t.assertTrue(ok, status.message);
            t.verifyEmpty(again.time_stamped_data);
        end

        function outerCounterChunksReencodeExactly(t)
            sensor = manyGroups(); records = sensor.physicalRecords();
            [decoded, ok, status] = nfx.SENSRB.deserializeRecords(records);
            t.assertTrue(ok, status.message);
            t.verifyNumElements(records, 2);
            t.verifyNumElements(decoded.time_stamped_data, 1);
            t.verifyEqual(decoded.time_stamped_data.time_stamp_time, 1:101, AbsTol=0);
            t.verifyEqual(decoded.physicalRecords(), records);
        end

        function distinctAttachmentsAreNeverMerged(t)
            first = manyGroups(); second = first;
            second.sensor = 'SECOND SENSOR';
            [~, image] = fixtureFile(); image = image.removeTRE(1) + first + second;
            a = image.SENSRB(1); b = image.SENSRB(2);
            t.verifyEqual(image.treCount('SENSRB'), 2);
            t.verifyEqual(a.sensor, first.sensor);
            t.verifyEqual(b.sensor, second.sensor);
            t.verifyNumElements(a.time_stamped_data, 1);
            t.verifyNumElements(b.time_stamped_data, 1);
            t.verifyEqual(a.physicalRecords(), first.physicalRecords());
            t.verifyEqual(b.physicalRecords(), second.physicalRecords());
        end
    end
end

function sensor = sixSeries()
    sensor = fixtureSensor();
    types = {'06a', '06b', '06c', '07b', '07c', '07d'};
    bases = [40 -105 1000 10 20 30];
    time = 1:5000; time(3333) = time(3332);
    for k = 1:numel(types)
        sensor.time_stamped_data(k) = nfx.SENSRB.timeSeries( ...
            types{k}, time, bases(k) + mod(1:numel(time), 2));
    end
end

function sensor = interleavedSensor()
    sensor = fixtureSensor();
    sensor.time_stamped_data = [ ...
        nfx.SENSRB.timeSeries('10a', [1 2], [10 20]), ...
        nfx.SENSRB.timeSeries('10b', 3, 30), ...
        nfx.SENSRB.timeSeries('10a', [2 4], [21 40])];
    sensor.uncertainty_data = [ ...
        nfx.SENSRB.uncertainty('12d3.2', 0.1, '12d2.1'), ...
        nfx.SENSRB.uncertainty('12c3.1', 0.5), ...
        nfx.SENSRB.uncertainty('06a', 0.25)];
end

function sensor = manyGroups()
    sensor = fixtureSensor();
    for k = 1:101
        sensor.time_stamped_data(k) = nfx.SENSRB.timeSeries('10a', k, k);
    end
end

function verifyNumericSeries(t, actual, expected)
    t.verifyEqual({actual.time_stamp_type}, {expected.time_stamp_type});
    t.verifyEqual({actual.time_stamp_time}, {expected.time_stamp_time}, AbsTol=0);
    a = [actual.time_stamp_value]; b = [expected.time_stamp_value];
    t.verifyEqual({a.numeric}, {b.numeric}, AbsTol=0);
    % Numeric samples have no text values; unused empty widths can differ.
    t.verifyTrue(all(cellfun(@isempty, {a.text})));
end
