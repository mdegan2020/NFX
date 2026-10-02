classdef (TestTags = {'OpenJPEG'}) CompressedCollectionTest < NfxTest
    properties (TestParameter)
        profile = {'NPJE', 'EPJE'}
        pixelType = {'uint8', 'uint16'}
        representation = {'MONO', 'RGB', 'MULTI'}
    end
    methods (Test)
        function paddedFormalProfileHasTheSameMeaning(t)
            source = fixtureCompressedCollection(getenv('NFX_OPENJPEG'), ...
                'NPJE', 'uint8', 'MONO');
            original = source.layers.payload();
            source.layers.mi_req_profile = pad('ISO/IEC 15444-1', 36);
            t.verifyEqual(source.layers.payload(), original);
            t.verifyTrue(source.layers.validate().valid);
            report = source.validate();
            t.verifyTrue(report.valid);
        end

        function deferredCompressionUsesItsWarningThreshold(t)
            [base, image] = fixtureMotion(zeros(32, 32, 'uint8'));
            image.header.nppbh = 1024; image.header.nppbv = 1024;
            file = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'deferred.ntf'); file.write(filename);
            deferred = nfx.File.read(filename, MemoryWarningBytes=5000);
            t.verifyWarningFree(@() deferred.images.compress(getenv('NFX_OPENJPEG'), ...
                MemoryWarningBytes=Inf));
            deferred = nfx.File.read(filename, MemoryWarningBytes=Inf);
            t.verifyWarning(@() deferred.images.compress(getenv('NFX_OPENJPEG'), ...
                MemoryWarningBytes=10000), 'nfx:MemoryUsage');
        end

        function differentLayersMayUseDifferentEncodings(t)
            source = fixtureCompressedCollection(getenv('NFX_OPENJPEG'), ...
                'NPJE', 'uint16', 'MONO');
            camera = source.camera_sets.camera_sets.cameras;
            camera.camera_id = '20000000-0000-4000-8000-000000000001';
            camera.layer_id = 'IR'; camera.idlvl = 2;
            camera.ialvl = 1; camera.iloc = [0 35];
            source.camera_sets.camera_sets.cameras(2) = camera;
            source.camera_ids.cameras(2) = nfx.MICIDA.camera(camera.camera_id, ...
                nfx.MICIDA.coreIdentifier(32, {camera.camera_id}));
            layer = source.layers; layer.layer_id = 'IR';
            layer.mi_req_decoder = 'NC'; layer.mi_req_profile = 'Not Applicable';
            layer.mi_req_level = 'N/A'; source.layers(2) = layer;
            block = source.blocks(1); block.image = block.image.uncompress();
            block.timing.camera_id = camera.camera_id;
            source = source + block;
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.blocks(1).image.header.ic, 'C8');
            t.verifyEqual(copy.blocks(3).image.header.ic, 'NC');
            t.verifyEqual(copy.blocks(3).image.data, source.blocks(3).image.data);
        end

        function publishedExampleCreatesReadableCollection(t)
            root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'examples')));
            collection = compressedCollectionExample(getenv('NFX_OPENJPEG'));
            paths = collection.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyNumElements(copy.blocks, 2);
            t.verifyEqual(copy.blocks(2).image.data, collection.blocks(2).image.data);
        end

        function twentyIndependentFramesKeepTimingAndLegacyComplexity(t)
            source = fixtureCompressedSequence(getenv('NFX_OPENJPEG'), [33 35], 20);
            planned = source.plan();
            t.verifyEqual(planned(2).file.header.clevel, 3);
            t.verifyNumElements(planned(2).file.images, 20);
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message); t.verifyNumElements(copy.blocks, 20);
            for k = 1:20
                t.verifyEqual(copy.blocks(k).image.data, source.blocks(k).image.data);
                t.verifyEqual(copy.blocks(k).timing.number_frames, 1);
                t.verifyEqual(copy.blocks(k).timing.nominal_frame_rate, 25);
                t.verifyEqual(copy.blocks(k).timing.base_timestamp, ...
                    source.blocks(k).timing.base_timestamp);
                t.verifyEqual(copy.blocks(k).timing.temp_block_index, k);
            end
        end

        function suppliedGeometrySectionsAndOverflowArePreserved(t)
            source = fixtureCompressedMetadata(getenv('NFX_OPENJPEG'));
            original = source.plan(); paths = source.write(t.folder);
            parsed = inspectContainer(paths{1});
            t.verifyGreaterThanOrEqual(numel(parsed.des), 2);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            replanned = copy.plan();
            for k = 1:numel(source.blocks)
                before = source.blocks(k).image;
                after = copy.blocks(k).image;
                t.verifyEqual({after.tre_records.tag}, {before.tre_records.tag});
                t.verifyEqual({after.tre_records.payload}, {before.tre_records.payload});
                t.verifyEqual(after.treCount('RSMPCA'), 6);
                t.verifyEqual(after.RSMIDA().edition, before.RSMIDA().edition);
                t.verifyEqual(after.ICHIPB().payload(), before.ICHIPB().payload());
                t.verifyEqual(replanned(2).file.images(k).header.iloc, ...
                    original(2).file.images(k).header.iloc);
            end
            output = fullfile(t.folder, 'copy'); mkdir(output); copy.write(output);
            for k = 1:numel(original)
                name = original(k).filename;
                t.verifyEqual(readBytes(fullfile(output, name)), ...
                    readBytes(fullfile(t.folder, name)));
            end
        end

        function compressionWarningIsAdvisory(t)
            [~, image] = fixtureMotion(zeros(32, 32, 'uint8'));
            image.header.nppbh = 1024; image.header.nppbv = 1024;
            t.verifyWarning(@() image.compress(getenv('NFX_OPENJPEG'), ...
                MemoryWarningBytes=0), 'nfx:MemoryUsage');
            t.verifyError(@() image.compress(getenv('NFX_OPENJPEG'), ...
                MemoryWarningBytes=-1), 'nfx:MemoryWarningBytes');
        end

        function mismatchedFileDeclarationFailsBeforePublication(t)
            source = fixtureCompressedCollection(getenv('NFX_OPENJPEG'), ...
                'NPJE', 'uint8', 'MONO');
            planned = source.plan(); file = planned(2).file;
            [layer, found] = file.MIMCSA(); t.assertTrue(found);
            layer.mi_req_decoder = 'NC'; layer.mi_req_profile = 'Not Applicable';
            layer.mi_req_level = 'N/A';
            file = nfx.File(header=file.header) + file.images(1) + layer;
            report = file.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'LayerEncoding')));
            t.verifyError(@() file.write(fullfile(t.folder, 'invalid.ntf')), 'nfx:Invalid');
            t.verifyEmpty(dir(fullfile(t.folder, '*.ntf')));
        end

        function singleFrameMotionRoundTrip(t, profile, pixelType, representation)
            source = fixtureCompressedCollection(getenv('NFX_OPENJPEG'), ...
                profile, pixelType, representation);
            planned = source.plan();
            expectedLevel = 3 + 4 * (strcmp(pixelType, 'uint16') && strcmp(representation, 'RGB'));
            t.verifyEqual(planned(2).file.header.clevel, expectedLevel);
            paths = source.write(t.folder);
            parsed = inspectContainer(paths{1});
            t.verifyNumElements(parsed.images, 2);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyTrue(copy.validate().valid);
            t.verifyEqual(copy.layers.payload(), source.layers.payload());
            for k = 1:2
                expected = source.blocks(k).image;
                actual = copy.blocks(k).image;
                t.verifyEqual(actual.data, expected.data);
                t.verifyEqual(actual.compression.codestream, expected.compression.codestream);
                t.verifyEqual(parsed.images(k).data, expected.compression.codestream);
                t.verifyEqual(nitfread(paths{1}, k), expected.data);
                t.verifyTrue(endsWith(actual.header.icat, '.M'));
                t.verifyEqual(actual.header.ic, 'C8');
                t.verifyEqual(actual.header.nbpp, 8 + 8 * strcmp(pixelType, 'uint16'));
                t.verifyEqual(copy.blocks(k).timing.nominal_frame_rate, 25);
                t.verifyEqual(copy.blocks(k).timing.base_timestamp, ...
                    source.blocks(k).timing.base_timestamp);
                t.verifyEqual(copy.blocks(k).timing.number_frames, 1);
                t.verifyEmpty(copy.blocks(k).timing.dt);
            end
            output = fullfile(t.folder, 'copy'); mkdir(output);
            copy.write(output);
            for k = 1:numel(planned)
                name = planned(k).filename;
                t.verifyEqual(readBytes(fullfile(output, name)), ...
                    readBytes(fullfile(t.folder, name)));
            end
        end

        function standaloneTimingCanPrecedeCompression(t, profile)
            [file, image] = fixtureMotion(zeros(33, 35, 'uint8'));
            image.header.nppbh = 1024; image.header.nppbv = 1024;
            image = image.compress(getenv('NFX_OPENJPEG'), Profile=profile);
            file = nfx.File(header=file.header) + image;
            filename = fullfile(t.folder, 'frame.ntf'); file.write(filename);
            [copy, ok, status] = nfx.File.read(filename, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images.MTIMSA().payload(), image.MTIMSA().payload());
            t.verifyEqual(copy.images.data, image.data);
        end

        function inconsistentLayerDecoderRejected(t)
            source = fixtureCompressedCollection(getenv('NFX_OPENJPEG'), ...
                'NPJE', 'uint16', 'MONO');
            source.blocks(2).image = source.blocks(2).image.uncompress();
            report = source.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'LayerEncoding')));
            t.verifyError(@() source.write(t.folder), 'nfx:Invalid');
            t.verifyEmpty(dir(fullfile(t.folder, '*.ntf')));
        end

        function multiFrameCompressionStillRejected(t)
            [~, image] = fixtureMotion(zeros(32, 32, 1, 2, 'uint8'));
            image.header.nppbh = 1024; image.header.nppbv = 1024;
            t.verifyError(@() image.compress(getenv('NFX_OPENJPEG')), 'nfx:JPEG2000Scope');
        end
    end
end
