classdef SensorDESReadTest < NfxTest
    properties (TestParameter)
        kind = {'attitude', 'attitudeV1', 'attitudeECI', ...
            'attitudeLagrange', 'attitudeSpherical', 'attitudeLinear', ...
            'ephemeris', 'ephemerisV1', 'ephemerisECI', ...
            'ephemerisLagrange', 'velocity', 'acceleration', ...
            'scanner', 'scannerBands', 'grid', 'fiducial', ...
            'telescopeFrame', 'telescopeTime', ...
            'telescopeZeroFrame', 'telescopeZeroTime', ...
            'covariance', 'covarianceEmpty', 'covarianceFull', ...
            'postsCommon', 'postsDistinct', 'postsOnly', ...
            'correlationPiecewise', 'correlationCosine', ...
            'timeSync1', 'timeSync2', 'timeSync3', 'timeSync4', 'timeSync5'}
        sensor = {'CSATTB', 'CSEPHB', 'CSSFAB', 'CSCSDB'}
        type = {'S', 'F'}
    end
    methods (Test)
        function everyConditionalLayoutRoundTripsIndependently(t, kind)
            source = fixtureReaderDES(kind);
            [copy, ok, status] = decode(source, source.payload(), source.subheader());
            t.assertTrue(ok, status.message); t.verifyEqual(status.code, 'OK');
            t.verifyClass(copy, class(source));
            t.verifyEqual(copy.payload(), source.payload());
            t.verifyEqual(copy.subheader(), source.subheader());
            t.verifyTrue(copy.segment().verifiedSensor());
            copy.uuid = '99999999-0000-4000-8000-000000000001';
            t.verifyNotEqual(copy.uuid, source.uuid);
        end

        function truncationsAndTrailingBytesReturnDefaultValues(t, kind)
            source = fixtureReaderDES(kind); raw = source.payload();
            header = source.subheader();
            cuts = unique([0 1 4 9 12 floor(numel(raw) / 2) numel(raw) - 1]);
            for last = cuts
                [copy, ok, status] = decode(source, raw(1:last), header);
                t.verifyFalse(ok, sprintf('%s at %d', kind, last));
                t.verifyNotEqual(status.code, 'OK'); t.verifyEmpty(copy.uuid);
            end
            [copy, ok, status] = decode(source, [raw uint8('0')], header);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'TrailingData');
            t.verifyEmpty(copy.uuid);
        end

        function badHeaderAndInputDoNotThrowOrGrantProof(t, sensor)
            source = feval(['fixture' sensor]); header = source.subheader();
            invalid = {[], uint8([]), single(1), source.payload().'};
            for k = 1:numel(invalid)
                [copy, ok, status] = decode(source, invalid{k}, header);
                t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidPayload');
                t.verifyEmpty(copy.uuid);
            end
            bad = header; bad.desver = 9;
            [copy, ok, status] = decode(source, source.payload(), bad);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedVersion');
            t.verifyEmpty(copy.uuid);
            bad.desid = 'OTHER';
            [copy, ok, status] = decode(source, source.payload(), bad);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidHeader');
            t.verifyEmpty(copy.uuid);
            for k = [1 37 40 numel(header.desshf)]
                bad = header; bad.desshf(k) = uint8('!');
                [copy, ok, status] = decode(source, source.payload(), bad);
                t.verifyFalse(ok); t.verifyNotEqual(status.code, 'OK');
                t.verifyEmpty(copy.uuid);
            end
        end

        function associationsPreserveOrderAndAllSelector(t, sensor)
            source = feval(['fixture' sensor]); source.aisdlvl = [2 1 999];
            source.assoc_elem_uuid = { ...
                'AAAAAAAA-0000-4000-8000-000000000002', ...
                'BBBBBBBB-0000-4000-8000-000000000001'};
            [copy, ok] = decode(source, source.payload(), source.subheader());
            t.assertTrue(ok); t.verifyEqual(copy.aisdlvl, [2 1 999]);
            t.verifyEqual(copy.assoc_elem_uuid, source.assoc_elem_uuid);
            source.aisdlvl = []; source.all_images = true;
            [copy, ok] = decode(source, source.payload(), source.subheader());
            t.assertTrue(ok); t.verifyTrue(copy.all_images); t.verifyEmpty(copy.aisdlvl);
        end

        function literalCovarianceDefinesIndependentTriangleOrder(t)
            source = fixtureCSCSDB();
            core = ['121' '20260915120000.1234567892121' ...
                    sprintf('%+.14E', [4 1 9]) '001010'];
            correlation = '010101.0001.0000000.25000002.000000+3.00000000000000E+00';
            raw = uint8(['202609151' core '000101' correlation '0000000000']);
            [copy, ok, status] = nfx.CSCSDB.deserialize(raw, source.subheader());
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.cores.groups.errcov_c1, [4 1; 1 9]);
            t.verifyEqual(copy.cores.groups.corr_ref_time, '120000.123456789');
            t.verifyEqual(copy.spdcf.components.fp_t, 3);
        end

        function completeGLASProductRetainsTypedTrustAndBytes(t, type)
            source = fixtureGLASFile(type);
            before = fullfile(t.folder, 'source.ntf');
            after = fullfile(t.folder, 'copy.ntf'); source.write(before);
            [copy, ok, status] = nfx.File.read(before);
            t.assertTrue(ok, status.message); t.verifyTrue(copy.validate().valid);
            for k = 1:4
                t.verifyTrue(copy.des(k).verifiedSensor());
                t.verifyEqual(copy.des(k).data, source.des(k).data);
                t.verifyEqual(copy.des(k).header, source.des(k).header);
            end
            copy.write(after); t.verifyEqual(readBytes(after), readBytes(before));
            t.verifyEqual(copy.images.data, source.images.data);
        end

        function brokenReferencedSensorDataFailsFullRead(t, type)
            source = fixtureGLASFile(type); path = fullfile(t.folder, 'broken.ntf');
            source.write(path); raw = readBytes(path);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            raw(index.des(1).location.dataOffset + 1) = uint8('9');
            putBytes(path, raw); [copy, ok, status] = nfx.File.read(path);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(copy.images);
        end

        function genericKnownNameRemainsUnverifiedAndByteExact(t)
            source = fixtureFile() + nfx.DESSegment(uint8('arbitrary'), ...
                header=nfx.DESHeader(desid='CSATTB', desclas='U'));
            path = fullfile(t.folder, 'generic.ntf'); source.write(path);
            [copy, ok, status] = nfx.File.read(path);
            t.assertTrue(ok, status.message); t.verifyFalse(copy.des.verifiedSensor());
            t.verifyEqual(copy.des.data, uint8('arbitrary'));
            t.verifyEqual(copy.des.header, source.des.header);
        end

        function largeDESDoesNotChangePhysicalTRELimit(t)
            source = fixtureCSSFAB('F'); grid = source.fa_grids;
            names = {'fa_x1', 'fa_y1', 'fa_x2', 'fa_y2', ...
                     'fa_x3', 'fa_y3', 'fa_x4', 'fa_y4'};
            for k = 1:8, grid.(names{k}) = ones(36) * k; end
            source.fa_grids = grid; raw = source.payload();
            t.assertGreaterThan(numel(raw), 99985);
            [copy, ok, status] = nfx.CSSFAB.deserialize(raw, source.subheader());
            t.assertTrue(ok, status.message); t.verifyEqual(copy.fa_grids.fa_y4, ones(36) * 8);
            reader = nfx.internal.TREReader(raw); t.verifyFalse(reader.ok);
        end

        function invalidQuaternionAndNoncanonicalNumberAreDistinct(t)
            source = fixtureCSATTB(); raw = source.payload();
            raw(47:64) = uint8('+1.000000000000000');
            [copy, ok, status] = nfx.CSATTB.deserialize(raw, source.subheader());
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidMetadata');
            t.verifyEmpty(copy.uuid);
            raw = source.payload(); raw(47) = uint8(' ');
            [copy, ok, status] = nfx.CSATTB.deserialize(raw, source.subheader());
            t.verifyFalse(ok); t.verifyEqual(status.code, 'NoncanonicalPayload');
            t.verifyEmpty(copy.uuid);
        end

        function noncanonicalAssociationHeaderIsRejected(t)
            source = fixtureCSATTB(); header = source.subheader();
            header.desshf(40:42) = uint8('  1');
            [copy, ok, status] = nfx.CSATTB.deserialize(source.payload(), header);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'NoncanonicalHeader');
            t.verifyEmpty(copy.uuid);
        end

        function reservedLengthsMustDescribeTheirActualPayload(t)
            source = fixtureReaderDES('acceleration'); raw = source.payload();
            raw(119:127) = uint8('000000001');
            [copy, ok, status] = nfx.CSEPHB.deserialize(raw, source.subheader());
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidField');
            t.verifyEmpty(copy.uuid);
            source = fixtureReaderDES('covarianceFull'); raw = source.payload();
            first = numel(raw) - source.reserved_len - 8;
            raw(first:first + 8) = uint8('000000001');
            [copy, ok, status] = nfx.CSCSDB.deserialize(raw, source.subheader());
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidField');
            t.verifyEmpty(copy.uuid);
        end

        function binaryTelescopeCountIsBoundedBeforeAllocation(t)
            source = fixtureReaderDES('telescopeFrame'); raw = source.payload();
            raw(273:276) = uint8(255);
            [copy, ok, status] = nfx.CSSFAB.deserialize(raw, source.subheader());
            t.verifyFalse(ok); t.verifyEqual(status.code, 'TruncatedPayload');
            t.verifyEmpty(copy.uuid);
        end

        function sharedGLASDESsRetainBothImageAssociations(t)
            [base, image, first, attitude, ephemeris, alignment, covariance] = fixtureGLASFile();
            second = first; second.image_uuid = '10000000-0000-4000-8000-000000000002';
            ids = {first.image_uuid, second.image_uuid};
            attitude.aisdlvl = [1 2]; attitude.assoc_elem_uuid = ids;
            ephemeris.aisdlvl = [1 2]; ephemeris.assoc_elem_uuid = ids;
            alignment.aisdlvl = [1 2]; alignment.assoc_elem_uuid = ids;
            covariance.aisdlvl = [1 2]; covariance.assoc_elem_uuid = ids;
            other = image; other.header.idlvl = 2;
            source = nfx.File(header=base.header) + (image + first) + ...
                (other + second) + attitude + ephemeris + alignment + covariance;
            path = fullfile(t.folder, 'shared.ntf'); source.write(path);
            [copy, ok, status] = nfx.File.read(path);
            t.assertTrue(ok, status.message); t.verifyTrue(copy.validate().valid);
            for k = 1:2
                t.verifyEqual(copy.images(k).CSEXRB().assoc_des_uuid, first.assoc_des_uuid);
            end
            [restored, ok] = nfx.CSATTB.deserialize(copy.des(1).data, copy.des(1).header);
            t.assertTrue(ok); t.verifyEqual(restored.aisdlvl, [1 2]);
            t.verifyEqual(restored.assoc_elem_uuid, ids);
            output = fullfile(t.folder, 'shared-copy.ntf'); copy.write(output);
            t.verifyEqual(readBytes(output), readBytes(path));
        end

        function multiImageRSMCovarianceKeepsModelOwnership(t)
            base = fixtureFile(); source = nfx.File(header=base.header);
            for k = 1:2
                image = base.images.removeTRE(1);
                identifier = char('A' + k - 1); edition = [identifier ' EDITION'];
                identity = fixtureRSMIdentification();
                identity.iid = identifier; identity.edition = edition;
                polynomial = fixturePolynomial();
                polynomial.iid = identifier; polynomial.edition = edition;
                blocks = nfx.RSMDCB.block(identifier, eye(2));
                if k == 1, blocks(2) = nfx.RSMDCB.block('B', 0.25 * eye(2)); end
                covariance = nfx.RSMDCB(iid=identifier, edition=edition, ...
                    tid='SHARED', parameters=fixtureRSMParameters(), blocks=blocks);
                source = source + (image + identity + polynomial + covariance);
            end
            path = fullfile(t.folder, 'models.ntf'); source.write(path);
            [copy, ok, status] = nfx.File.read(path);
            t.assertTrue(ok, status.message); t.verifyTrue(copy.validate().valid);
            t.verifyEqual(copy.images(1).RSMIDA().iid, 'A');
            t.verifyEqual(copy.images(2).RSMIDA().iid, 'B');
            t.verifyEqual(copy.images(1).RSMDCB().blocks(2).crscov, 0.25 * eye(2));
            output = fullfile(t.folder, 'models-copy.ntf'); copy.write(output);
            t.verifyEqual(readBytes(output), readBytes(path));
        end
    end
end

function [value, ok, status] = decode(source, data, header)
    switch class(source)
        case 'nfx.CSATTB', [value, ok, status] = nfx.CSATTB.deserialize(data, header);
        case 'nfx.CSEPHB', [value, ok, status] = nfx.CSEPHB.deserialize(data, header);
        case 'nfx.CSSFAB', [value, ok, status] = nfx.CSSFAB.deserialize(data, header);
        case 'nfx.CSCSDB', [value, ok, status] = nfx.CSCSDB.deserialize(data, header);
    end
end
