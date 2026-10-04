classdef (TestTags = {'OpenJPEGMex'}) OpenJPEGMexTest < NfxTest
    properties (TestParameter)
        profile = {'NPJE', 'EPJE'}
        threads = {1, 2}
        pixelCase = struct( ...
            'mono8', struct('shape', [32 35 1], 'type', 'uint8'), ...
            'mono16', struct('shape', [33 35 1], 'type', 'uint16'), ...
            'rgb8', struct('shape', [33 35 3], 'type', 'uint8'), ...
            'rgb16', struct('shape', [33 35 3], 'type', 'uint16'), ...
            'msi16', struct('shape', [32 35 5], 'type', 'uint16'), ...
            'xbands', struct('shape', [32 35 10], 'type', 'uint8'), ...
            'edges', struct('shape', [1025 1027 1], 'type', 'uint16'))
        backend = {'auto', 'mex', 'matlab'}
        badThreads = {0, -1, 1.5, Inf, NaN, true, uint32(2), [1 2], 2^31}
        badBackend = {'other', '', ["mex" "auto"], missing, 1}
    end
    methods (TestClassSetup)
        function requireBinary(t)
            t.assertTrue(nfx.internal.hasOpenJPEGMex(), ...
                'Build with buildOpenJPEGMex before selecting these tests.');
            t.assertEqual(nfx.internal.openjpegMex('info'), '2.5.4');
        end
    end
    methods (Test)
        function exactPixelsAndIndependentMarkers(t, profile, pixelCase, threads)
            pixels = makePixels(pixelCase);
            image = makeImage(pixels).compress( ...
                Backend='mex', Profile=profile, Threads=threads);
            bytes = image.compression.codestream;
            path = fullfile(t.folder, 'stream.j2c'); putBytes(path, bytes);
            oracle = inspectCodestream(path);
            t.verifyEqual(oracle.rsiz, 2);
            t.verifyEqual(oracle.cod, ...
                [0 double(strcmp(profile, 'EPJE')) 0 20 0 5 4 4 0 1]);
            t.verifyEqual(oracle.grid, ...
                [size(pixels, 2) size(pixels, 1) 0 0 1024 1024 0 0]);
            t.verifyEqual(imread(path), pixels);
            t.verifyEqual(nfx.JPEG2000.decode(bytes, Backend='mex', ...
                Threads=threads), pixels);
            t.verifyEqual(image.compression.metrics.temporary_bytes, 0);
            t.verifyEqual(image.compression.metrics.threads, threads);
            t.verifyEqual(image.compression.metrics.backend, 'mex');
            t.verifyEqual(image.J2KLRA().payload(), image.compression.j2klra);
            base = fixtureFile(); file = nfx.File(header=base.header) + image;
            nitf = fullfile(t.folder, 'image.ntf'); file.write(nitf);
            t.verifyEqual(nitfread(nitf), pixels);
        end

        function fileDeferredAndTemporaryReads(t, backend, profile)
            pixels = makePixels(t.pixelCase.rgb16);
            image = makeImage(pixels).compress(Profile=profile);
            base = fixtureFile(); file = nfx.File(header=base.header) + image;
            path = fullfile(t.folder, 'source.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, ...
                JPEG2000Backend=backend, JPEG2000Threads=2);
            t.assertTrue(ok, status.message);
            t.verifyFalse(copy.images.pixelsLoaded);
            t.verifyEqual(copy.images.data, pixels);
            t.verifyFalse(copy.images.pixelsLoaded);
            [segment, ok, status] = copy.images.read();
            t.assertTrue(ok, status.message); t.verifyEqual(segment.data, pixels);
            [loaded, ok, status] = copy.readAll();
            t.assertTrue(ok, status.message);
            t.verifyEqual(loaded.images.data, pixels);
            t.verifyEqual(loaded.images.compression.codestream, image.compression.codestream);
            destination = fullfile(t.folder, 'copy.ntf'); loaded.write(destination);
            t.verifyEqual(readBytes(destination), readBytes(path));
        end

        function readSelectionAndOverride(t)
            pixels = makePixels(t.pixelCase.mono16);
            image = makeImage(pixels).compress();
            base = fixtureFile(); file = nfx.File(header=base.header) + image + image;
            path = fullfile(t.folder, 'source.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, readSegment=2, ...
                JPEG2000Backend='mex', JPEG2000Threads=2);
            t.assertTrue(ok, status.message);
            t.verifyEqual([copy.images.pixelsLoaded], [false true]);
            [copy, ok, status] = copy.readSegment(1, JPEG2000Backend='matlab');
            t.assertTrue(ok, status.message); t.verifyEqual(copy.images(1).data, pixels);
        end

        function limitsPrecedeNativeAllocation(t)
            pixels = makePixels(t.pixelCase.mono16);
            packed = nfx.JPEG2000(pixels);
            t.verifyError(@() nfx.JPEG2000.decode(packed.codestream, ...
                MaxPixels=numel(pixels)-1), 'nfx:OpenJPEGResourceLimit');
            t.verifyError(@() nfx.internal.openjpegMex('decode', ...
                packed.codestream, numel(pixels)-1, 1), 'nfx:OpenJPEGResourceLimit');
            t.verifyEqual(nfx.JPEG2000.decode(packed.codestream, ...
                MaxPixels=numel(pixels)), pixels);
        end

        function invalidThreadsFailWithoutCoercion(t, badThreads)
            t.verifyError(@() nfx.JPEG2000(ones(32, 'uint8'), ...
                Threads=badThreads), 'nfx:OpenJPEGThreads');
            [~, ok, status] = nfx.File.read('unused.ntf', JPEG2000Threads=badThreads);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.ImageSegment().read(JPEG2000Threads=badThreads);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
        end

        function invalidReaderBackendFailsWithoutIO(t, badBackend)
            [~, ok, status] = nfx.File.read('unused.ntf', JPEG2000Backend=badBackend);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.File().readAll(JPEG2000Backend=badBackend);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.MIECollection.read('unused.ntf', JPEG2000Backend=badBackend);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
        end

        function nativeBoundaryRejectsInvalidInputs(t)
            t.verifyError(@() nfx.internal.openjpegMex('encode', ...
                ones(32), 'NPJE', 1), 'nfx:OpenJPEGMexInput');
            t.verifyError(@() nfx.internal.openjpegMex('encode', ...
                zeros(31, 32, 'uint8'), 'NPJE', 1), 'nfx:OpenJPEGMexInput');
            t.verifyError(@() nfx.internal.openjpegMex('decode', ...
                uint8([255; 79; 255; 217]), flintmax, 1), 'nfx:OpenJPEGMexInput');
            t.verifyError(@() nfx.internal.openjpegMex('decode', ...
                uint8([255 79 255 217]), flintmax, 1), 'nfx:OpenJPEGCodec');
            t.verifyError(@() nfx.internal.openjpegMex('unknown', ...
                zeros(32, 'uint8'), 'NPJE', 1), 'nfx:OpenJPEGMexInput');
            t.verifyError(@() nfx.JPEG2000(zeros(32, 'uint8'), ...
                'unused.exe', Backend='mex'), 'nfx:OpenJPEGBackend');
        end

        function damagedEntropyDoesNotFallBack(t)
            stream = RandStream('mt19937ar', Seed=6042);
            pixels = randi(stream, [0 65535], 32, 33, 'uint16');
            packed = nfx.JPEG2000(pixels);
            bytes = packed.codestream; bytes(256:257) = uint8([255 255]);
            [result, ok, status] = nfx.internal.decodeJPEG2000(bytes, 'mex');
            t.verifyFalse(ok); t.verifyEmpty(result);
            t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEqual(nfx.JPEG2000.decode(packed.codestream), pixels);
        end

        function mexDoesNotCallImreadOrStageFiles(t)
            pixels = makePixels(t.pixelCase.mono16);
            injectIOFailure(t, 'imread', sprintf(['function x=imread(varargin)\n' ...
                'error(''test:UnexpectedIO'',''Unexpected imread.'');\nend\n']));
            injectIOFailure(t, 'tempname', sprintf(['function x=tempname(varargin)\n' ...
                'error(''test:UnexpectedIO'',''Unexpected staging.'');\nend\n']));
            packed = nfx.JPEG2000(pixels, Backend='mex');
            t.verifyEqual(nfx.JPEG2000.decode(packed.codestream), pixels);
        end

        function collectionHonorsExplicitDecoder(t)
            source = fixtureCompressedCollection('', 'NPJE', 'uint16', 'MONO');
            paths = source.write(t.folder);
            injectIOFailure(t, 'imread', sprintf(['function x=imread(varargin)\n' ...
                'error(''MATLAB:UndefinedFunction'',''Injected unavailable decoder.'');\nend\n']));
            [~, ok, status] = nfx.MIECollection.read(paths{end}, ...
                JPEG2000Backend='matlab');
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MissingDependency');
            [copy, ok, status] = nfx.MIECollection.read(paths{end}, ...
                JPEG2000Backend='mex');
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.blocks(1).image.data, source.blocks(1).image.data);
        end
    end
    methods (Test, TestTags = {'LargeData'})
        function fullResolutionNativeRoundTrip(t, profile)
            pixels = repmat(uint16(0:14999), 5000, 1);
            packed = nfx.JPEG2000(pixels, Profile=profile, ...
                Backend='mex', Threads=4);
            restored = nfx.JPEG2000.decode(packed.codestream, ...
                Backend='mex', Threads=4);
            t.verifyEqual(restored, pixels);
            t.verifyEqual(packed.info.dimensions, [5000 15000 1]);
        end
    end
    methods (Test, TestTags = {'OpenJPEG'})
        function executableAndMexInteroperate(t, profile)
            pixels = makePixels(t.pixelCase.rgb16);
            legacy = nfx.JPEG2000(pixels, getenv('NFX_OPENJPEG'), Profile=profile);
            native = nfx.JPEG2000(pixels, Backend='mex', Profile=profile);
            t.verifyEqual(legacy.metrics.backend, 'cli');
            t.verifyEqual(native.codestream, legacy.codestream);
            t.verifyEqual(nfx.JPEG2000.decode(legacy.codestream, Backend='mex'), pixels);
            t.verifyEqual(nfx.JPEG2000.decode(native.codestream, Backend='matlab'), pixels);
        end

        function collectionForwardsDecoderOptions(t, profile, backend)
            source = fixtureCompressedCollection( ...
                getenv('NFX_OPENJPEG'), profile, 'uint16', 'MULTI');
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read( ...
                paths{end}, ...
                JPEG2000Backend=backend, JPEG2000Threads=2);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.blocks(1).image.data, source.blocks(1).image.data);
            t.verifyEqual(copy.blocks(2).image.data, source.blocks(2).image.data);
        end
    end
end

function pixels = makePixels(spec)
    stream = RandStream('mt19937ar', Seed=1573);
    pixels = randi(stream, [0 double(intmax(spec.type))], spec.shape, spec.type);
end

function image = makeImage(pixels)
    representation = 'MONO'; category = 'VIS';
    if size(pixels, 3) == 3, representation = 'RGB'; end
    if size(pixels, 3) > 3, representation = 'MULTI'; category = 'MS'; end
    header = nfx.ImageHeader(iid1='MEX', idatim='20261004120000', ...
        isclas='U', irep=representation, icat=category);
    image = nfx.ImageSegment(pixels, header=header);
end
