classdef ReaderMetadataTest < NfxTest
    properties (TestParameter)
        treType = {'RPC00B', 'ACFTB', 'AIMIDB', 'CSCRNA', 'FCRNSA', ...
            'ICHIPB', 'FREESA', 'MIMCSA', 'CAMSDA', 'MICIDA', ...
            'MTIMSA', 'MTIMFA', 'TMINTA', 'MATESA', 'CSRLSB', ...
            'RSMIDA', 'RSMPCA', 'RSMGGA', 'RSMAPB', 'RSMDCB', 'RSMECB', ...
            'BANDSB', 'ILLUMB', 'HISTOA', 'CSEXRB', 'CSWRPB', 'SENSRB', ...
            'CSDIDA', 'RSMPIA', 'RSMGIA', 'FSYNWA', 'FASYWA', 'CONTXA', ...
            'J2KLRA'}
        badEnvelope = {struct('at', 7, 'text', '00000', 'code', 'MalformedFile'), ...
            struct('at', 7, 'text', '99985', 'code', 'MalformedFile'), ...
            struct('at', 7, 'text', ' 0042', 'code', 'MalformedFile')}
    end
    methods (Test)
        function everySupportedTREPreservesPayload(t, treType)
            tre = fixtureDecodableTRE(treType);
            fileOwner = any(strcmp(treType, {'MIMCSA', 'CAMSDA', 'MICIDA', ...
                'MTIMFA', 'TMINTA', 'CSDIDA'}));
            bytes = recordFile(tre.bytes(), fileOwner);
            [parts, ok, status] = readMetadata(bytes);
            t.assertTrue(ok, status.message);
            selected = allRecords(parts);
            t.verifyEqual(selected.payload, tre.payload());
            t.verifyEqual(strtrim(selected.tag), treType);
            t.verifyEqual(selected.id, double(~strcmp(treType, 'J2KLRA')));
        end

        function textAndRawDESRoundTripWithRepeatedSnapshots(t)
            base = fixtureFile();
            text = fixtureText(sprintf('first\nsecond\fthird')) + ...
                nfx.FREESA(8) + nfx.FREESA(9800);
            source = nfx.DESSegment(uint8([0 128 255]), header= ...
                nfx.DESHeader(desid='GENERIC', desclas='U', ...
                desshf=uint8([1 0 254])));
            file = nfx.File(header=base.header) + text + source + nfx.FREESA(99985);
            filename = fullfile(t.folder, 'metadata.ntf'); file.write(filename);
            [read, ok, status] = nfx.internal.FileReader.readBytes(readBytes(filename));
            t.assertTrue(ok, status.message);
            t.verifyEqual(read.texts.data, text.data);
            t.verifyEqual(read.texts.header, text.header);
            t.verifyEqual(read.des(1).data, source.data);
            t.verifyEqual(read.des(1).header, source.header);
            t.verifyFalse(read.des(1).verifiedSensor());
            [copy, found] = read.texts.FREESA(2);
            t.verifyTrue(found); t.verifyEqual(copy.payload(), repmat(uint8(255), 1, 9800));
            reduced = read.texts.removeTRE(read.texts.tre_ids(1));
            t.verifyEqual(reduced.treCount('FREESA'), 1);
            output = fullfile(t.folder, 'copy.ntf'); read.write(output);
            t.verifyEqual(readBytes(output), readBytes(filename));
        end

        function logicalSensorGroupsSurviveOverflowWithNewIds(t)
            sensor = fixtureSensor();
            sensor.time_stamped_data = nfx.SENSRB.timeSeries('06a', 0:4333, ...
                40 + (0:4333) * 1e-7);
            [base, image] = fixtureFile(uint8(1));
            image = image.removeTRE(1) + nfx.FREESA(1) + sensor + ...
                fixtureSensor() + nfx.FREESA(2);
            file = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'sensor.ntf'); file.write(filename);
            [parts, ok, status] = readMetadata(readBytes(filename));
            t.assertTrue(ok, status.message);
            records = parts.imageRecords.records;
            t.verifyEqual([records.id], [1 2 2 3 4]);
            t.verifyEqual({records.payload}, {image.tre_records.payload});
            [decoded, ok, status] = nfx.SENSRB.deserializeRecords(records(2:3));
            t.assertTrue(ok, status.message);
            t.verifyEqual([decoded.time_stamped_data.time_stamp_time], 0:4333);
            store = nfx.internal.TREStore.fromSnapshots(records).remove(2);
            t.verifyEqual([store.records.id], [1 3 4]);
        end

        function userAreaRetainsNFXPackingOrder(t)
            [base, image] = fixtureFile(uint8(1));
            model = fixtureCSEXRB(); model.num_lines = 1; model.num_samples = 1;
            image = image.removeTRE(1) + nfx.FREESA(99974) + model + nfx.FREESA(99985);
            file = nfx.File(header=base.header) + image + ...
                nfx.FREESA(99974) + model + nfx.FREESA(99985);
            filename = fullfile(t.folder, 'areas.ntf'); file.write(filename);
            bytes = readBytes(filename);
            [parts, ok, status] = readMetadata(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual({parts.fileRecords.payload}, {file.tre_records.payload});
            t.verifyEqual({parts.imageRecords.records.payload}, {image.tre_records.payload});
            [index, ok] = nfx.internal.indexNITF(bytes); t.assertTrue(ok);
            t.verifyLessThan(index.user.offset, index.extended.offset);
            t.verifyLessThan(index.images.user.offset, index.images.extended.offset);
        end

        function invalidEnvelopeNeverBecomesWritableSnapshot(t, badEnvelope)
            bytes = recordFile(nfx.FREESA(42).bytes(), false);
            [index, ok] = nfx.internal.indexNITF(bytes); t.assertTrue(ok);
            at = index.images.extended.offset + badEnvelope.at;
            bytes(at:at + numel(badEnvelope.text) - 1) = uint8(badEnvelope.text);
            [parts, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, badEnvelope.code);
            t.verifyEqual(status.scope, 'image');
            t.verifyEmpty(parts.imageRecords);
        end

        function ownerPlacementAndOrphanContinuationAreChecked(t)
            bytes = recordFile(fixtureRPC().bytes(), true);
            [~, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            sensor = fixtureSensor();
            sensor.time_stamped_data = nfx.SENSRB.timeSeries('06a', 0:4333, ...
                repmat(40, 1, 4334));
            records = sensor.physicalRecords(); last = records(end).payload;
            frame = [uint8('SENSRB') uint8(sprintf('%05d', numel(last))) last];
            [~, ok, status] = readMetadata(recordFile(frame, false));
            t.verifyFalse(ok); t.verifySubstring(status.message, 'leading');
        end

        function overflowOwnerAndPointerFailuresAreExplicit(t)
            [base, image] = fixtureFile(uint8(1));
            file = nfx.File(header=base.header) + (image + nfx.FREESA(99985));
            filename = fullfile(t.folder, 'bad-overflow.ntf'); file.write(filename);
            original = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(original); t.assertTrue(ok);
            bytes = original;
            bytes(index.images.extended.offset + (-2:0)) = uint8('999');
            [~, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            bytes = original;
            bytes(index.des.location.headerOffset + (203:205)) = uint8('002');
            [~, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifySubstring(status.message, 'DES owner');
            bytes = original;
            bytes(index.images.extended.offset + (-2:0)) = uint8('000');
            [~, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifySubstring(status.message, 'unique');
        end

        function invalidTextBytesAndLineEndingsAreNotNormalizedSilently(t)
            base = fixtureFile(); file = nfx.File(header=base.header) + fixtureText('abcd');
            filename = fullfile(t.folder, 'text.ntf'); file.write(filename);
            original = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(original); t.assertTrue(ok);
            bytes = original; bytes(index.texts.location.dataOffset + 1) = 255;
            [~, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            bytes = original; bytes(index.texts.location.dataOffset + 1) = 10;
            [~, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedFeature');
        end

        function malformedConcretePayloadAndDuplicateJ2KLRAAreRejected(t)
            bytes = recordFile(fixtureRPC().bytes(), false);
            [index, ok] = nfx.internal.indexNITF(bytes); t.assertTrue(ok);
            bytes(index.images.extended.offset + 12) = uint8('X');
            [parts, ok, status] = readMetadata(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(parts.imageRecords);
            frame = fixtureDecodableTRE('J2KLRA').bytes();
            [~, ok, status] = readMetadata(recordFile([frame frame], false));
            t.verifyFalse(ok); t.verifySubstring(status.message, 'Duplicate');
        end

        function malformedHeaderReturnsDefaultFile(t)
            [file, ok, status] = nfx.internal.FileReader.readBytes(uint8('NITF'));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images); t.verifyEmpty(file.texts);
            [file, ok, status] = nfx.internal.FileReader.readBytes(literalReaderFile());
            t.assertTrue(ok, status.message);
            t.verifyEqual(file.images.data, uint8(197));
        end

        function contradictoryComplexityIsNotSilentlyRepaired(t)
            base = fixtureFile(); file = nfx.File(header=base.header) + fixtureText('abcd');
            filename = fullfile(t.folder, 'complexity.ntf'); file.write(filename);
            bytes = readBytes(filename); bytes(10:11) = uint8('09');
            [file, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.texts);
        end

        function validSensorPayloadRestoresVerification(t)
            base = fixtureFile(); source = fixtureCSCSDB().segment();
            file = base + source;
            filename = fullfile(t.folder, 'sensor-des.ntf'); file.write(filename);
            [parts, ok, status] = readMetadata(readBytes(filename));
            t.assertTrue(ok, status.message);
            t.verifyEqual(parts.des.header, source.header);
            t.verifyEqual(parts.des.data, source.data);
            t.verifyTrue(parts.des.verifiedSensor());
        end
    end
end

function [parts, ok, status] = readMetadata(bytes)
    [index, ok, status] = nfx.internal.indexNITF(bytes);
    assert(ok, status.message);
    [parts, ok, status] = nfx.internal.FileReader.metadata(bytes, index);
end

function records = allRecords(parts)
    records = parts.fileRecords;
    for k = 1:numel(parts.imageRecords)
        records = [records parts.imageRecords(k).records]; %#ok<AGROW>
    end
end

function bytes = recordFile(frame, fileOwner)
    % Insert independent TRE envelopes into the literal one-image fixture.
    bytes = literalReaderFile(); count = numel(frame) + 3;
    extension = [uint8(sprintf('%05d', count)) uint8('000') frame];
    if fileOwner
        bytes = [bytes(1:399) extension bytes(405:end)];
        bytes(355:360) = uint8(sprintf('%06d', 404 + count));
    else
        bytes = [bytes(1:838) extension bytes(844:end)];
        bytes(364:369) = uint8(sprintf('%06d', 439 + count));
    end
    bytes(343:354) = uint8(sprintf('%012d', numel(bytes)));
end
