classdef (TestTags = {'OpenJPEG'}) JPEG2000ReadTest < NfxTest
    properties
        encoder
        sampleFile
    end
    properties (TestParameter)
        profile = {'NPJE', 'EPJE'}
        pixelClass = {'uint8', 'uint16'}
        bands = {1, 3, 5, 10}
        corruption = {'soc', 'geometry', 'precision', 'comrat', 'layers', ...
                      'missingLayers', 'abpp', 'pjust', 'mode'}
        decoderFault = {'missing', 'wrongType', 'wrongShape'}
        warningState = {'on', 'off'}
    end
    methods (TestClassSetup)
        function createOriginalEncoding(t)
            t.encoder = getenv('NFX_OPENJPEG');
            t.assertTrue(isfile(t.encoder));
            data = reshape(uint16(mod(0:32 * 33 - 1, 4096)), 32, 33);
            t.sampleFile = compressedFile(data, t.encoder, 'EPJE');
        end
    end
    methods (Test)
        function profilesPreserveNativeSamplesAndStoredBytes(t, profile, pixelClass, bands)
            data = reshape(cast(mod(0:32 * 35 * bands - 1, 251), pixelClass), ...
                32, 35, bands);
            source = compressedFile(data, t.encoder, profile);
            first = fullfile(t.folder, 'source.ntf'); source.write(first);
            [copy, ok, status] = nfx.File.read(first);
            t.assertTrue(ok, status.message); t.verifyEqual(copy.images.data, data);
            t.verifyClass(copy.images.data, pixelClass);
            t.verifyEqual(copy.images.compression.profile, profile);
            t.verifyEqual(copy.images.compression.codestream, source.images.compression.codestream);
            t.verifyEmpty(fieldnames(copy.images.compression.metrics));
            t.verifyEqual(copy.images.tre_records, source.images.tre_records);
            second = fullfile(t.folder, 'copy.ntf'); copy.write(second);
            t.verifyEqual(readBytes(second), readBytes(first));
        end

        function partialTilesAndMixedSegmentsReadExactly(t, profile)
            data = reshape(uint16(mod(0:1025 * 1030 - 1, 65536)), 1025, 1030);
            source = compressedFile(data, t.encoder, profile);
            [~, plain] = fixtureFile();
            source = source + plain + fixtureText();
            path = fullfile(t.folder, 'tiles.ntf'); source.write(path);
            [copy, ok, status] = nfx.File.read(path);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images(1).data, data);
            t.verifyEqual(copy.images(2).data, plain.data);
            t.verifyEqual(copy.texts.data, source.texts.data);
            t.verifyEqual(copy.images(1).compression.codestream, ...
                source.images(1).compression.codestream);
        end

        function readingAndMetadataEditsNeedNoEncoder(t)
            first = fullfile(t.folder, 'source.ntf'); t.sampleFile.write(first);
            previous = getenv('NFX_OPENJPEG');
            cleanup = onCleanup(@() setenv('NFX_OPENJPEG', previous));
            setenv('NFX_OPENJPEG', fullfile(t.folder, 'absent.exe'));
            [copy, ok, status] = nfx.File.read(first);
            t.assertTrue(ok, status.message);
            image = copy.images; image.header.iid1 = 'EDITED';
            image = image + fixtureRPC();
            edited = nfx.File(header=copy.header) + image;
            second = fullfile(t.folder, 'edited.ntf'); edited.write(second);
            parsed = inspectContainer(second);
            t.verifyEqual(parsed.images.data, t.sampleFile.images.compression.codestream);
            t.verifyEqual(image.RPC00B().payload(), fixtureRPC().payload());
            image.data(1) = uint16(999);
            t.verifyEmpty(image.compression); t.verifyEqual(image.header.ic, 'NC');
            t.verifyEqual(image.treCount('J2KLRA'), 0);
            t.verifyEqual(copy.images.data(1), uint16(0));
            t.verifyEqual(image.treCount('RPC00B'), 1);
        end

        function resourceBudgetPrecedesEntropyDecoding(t)
            path = fullfile(t.folder, 'limited.ntf'); t.sampleFile.write(path);
            [copy, ok, status] = nfx.File.read(path, MaxPixels=32 * 33 - 1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyEmpty(copy.images);
        end

        function replacingImportedImagePreservesItsCompressedSnapshot(t)
            path = fullfile(t.folder, 'original.ntf'); t.sampleFile.write(path);
            [copy, ok, status] = nfx.File.read(path); t.assertTrue(ok, status.message);
            image = copy.images; image.header.icom = 'Updated compressed metadata';
            edited = copy.replaceImage(1, image);
            destination = fullfile(t.folder, 'copy.ntf'); edited.write(destination);
            parsed = inspectContainer(destination);
            t.verifyEqual(parsed.images.data, t.sampleFile.images.compression.codestream);
            t.verifyEqual(edited.images.J2KLRA().payload(), copy.images.J2KLRA().payload());
            t.verifyEqual(edited.images.data, copy.images.data);
        end

        function headerAndCodestreamContradictionsFail(t, corruption)
            path = fullfile(t.folder, 'bad.ntf'); t.sampleFile.write(path);
            raw = readBytes(path); [index, ok] = nfx.internal.indexNITF(raw);
            t.assertTrue(ok); entry = index.images;
            header = entry.location.headerOffset;
            stream = entry.location.dataOffset;
            layers = entry.extended.offset;
            switch corruption
                case 'soc', raw(stream + 1) = 0;
                case 'geometry', raw(stream + 12) = 34;
                case 'precision', raw(stream + 43) = 7;
                case 'comrat', raw(header + (436:439)) = uint8('N001');
                case 'layers', raw(layers + 11 + (4:8)) = uint8('00002');
                case 'missingLayers'
                    count = entry.extended.length;
                    raw = [raw(1:layers - 8) uint8('00000') ...
                           raw(layers + count + 1:end)];
                    raw(343:354) = uint8(sprintf('%012d', numel(raw)));
                    raw(364:369) = uint8(sprintf('%06d', ...
                        entry.location.headerLength - count - 3));
                case 'abpp', raw(header + (369:370)) = uint8('12');
                case 'pjust', raw(header + 371) = uint8('L');
                case 'mode', raw(header + 455) = uint8('F');
            end
            putBytes(path, raw); [copy, ok, status] = nfx.File.read(path);
            t.verifyFalse(ok, corruption);
            t.verifyNotEqual(status.code, 'OK'); t.verifyEmpty(copy.images);
        end

        function codecFailureReturnsADiagnostic(t)
            [pixels, ok, status] = nfx.internal.decodeJPEG2000(uint8('invalid'));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(pixels);
        end

        function recoveredDamagedPixelsAreRejected(t, warningState)
            previousRng = rng; restoreRng = onCleanup(@() rng(previousRng));
            rng(6042);
            data = randi([0 65535], 32, 33, 'uint16');
            source = compressedFile(data, t.encoder, 'NPJE');
            path = fullfile(t.folder, 'damaged.ntf'); source.write(path);
            raw = readBytes(path); [index, indexed] = nfx.internal.indexNITF(raw);
            t.assertTrue(indexed);
            raw(index.images.location.dataOffset + (256:257)) = uint8([255 255]);
            putBytes(path, raw);
            id = 'MATLAB:imagesci:jp2adapter:libraryWarning';
            previous = warning('query', id);
            restoreWarning = onCleanup(@() warning(previous));
            warning(warningState, id);
            handles = fileHandles(); temporary = dir(fullfile(tempdir, '*.j2c'));
            [copy, ok, status] = nfx.File.read(path);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(copy.images);
            t.verifyEqual(warning('query', id).state, warningState);
            t.verifyEqual(fileHandles(), handles);
            remaining = dir(fullfile(tempdir, '*.j2c'));
            t.verifyEqual({remaining.name}, {temporary.name});
        end

        function codecBoundaryRejectsUnavailableOrContradictoryOutput(t, decoderFault)
            path = fullfile(t.folder, 'backend.ntf'); t.sampleFile.write(path);
            switch decoderFault
                case 'missing'
                    body = sprintf(['function pixels=imread(varargin)\n' ...
                        'error(''MATLAB:UndefinedFunction'',''Injected unavailable codec.'');\nend\n']);
                    expected = 'MissingDependency';
                case 'wrongType'
                    body = sprintf('function pixels=imread(varargin)\npixels=ones(32,33,''single'');\nend\n');
                    expected = 'MalformedFile';
                otherwise
                    body = sprintf('function pixels=imread(varargin)\npixels=zeros(32,32,''uint16'');\nend\n');
                    expected = 'MalformedFile';
            end
            handles = fileHandles(); injectIOFailure(t, 'imread', body);
            [copy, ok, status] = nfx.File.read(path);
            t.verifyFalse(ok); t.verifyEqual(status.code, expected);
            t.verifyEmpty(copy.images); t.verifyEqual(fileHandles(), handles);
        end

        function temporaryCodecWriteFailureClosesItsFile(t)
            path = fullfile(t.folder, 'backend.ntf'); t.sampleFile.write(path);
            handles = fileHandles();
            temporary = dir(fullfile(tempdir, '*.j2c'));
            injectIOFailure(t, 'fwrite', sprintf('function count=fwrite(varargin)\ncount=0;\nend\n'));
            [copy, ok, status] = nfx.File.read(path);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'IOError');
            t.verifyEmpty(copy.images); t.verifyEqual(fileHandles(), handles);
            remaining = dir(fullfile(tempdir, '*.j2c'));
            t.verifyEqual({remaining.name}, {temporary.name});
        end
    end
end

function file = compressedFile(data, encoder, profile)
    base = fixtureFile();
    representation = 'MONO'; category = 'VIS';
    if size(data, 3) == 3, representation = 'RGB';
    elseif size(data, 3) > 1, representation = 'MULTI'; category = 'MS';
    end
    header = nfx.ImageHeader(iid1='J2KREAD', idatim='20260915120000', ...
        isclas='U', irep=representation, icat=category, icords='D', ...
        igeolo=['+11.000+022.000+11.000+023.000' ...
                '+10.000+023.000+10.000+022.000']);
    image = nfx.ImageSegment(data, header=header).compress(encoder, Profile=profile);
    file = nfx.File(header=base.header) + image;
end
