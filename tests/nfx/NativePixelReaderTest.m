classdef NativePixelReaderTest < NfxTest
    properties (TestParameter)
        pixelType = {'uint8', 'uint16'}
        bands = {1, 3, 10}
        frames = {1, 3}
        shape = {[1 1], [5 7], [3 4], [5 1]}
    end
    methods (Test)
        function everyNativeLayoutRecoversExactSamples(t, pixelType, bands, frames, shape)
            count = prod(shape) * bands * frames;
            scale = 1 + 256 * strcmp(pixelType, 'uint16');
            values = cast(mod(0:count - 1, 256) * scale, pixelType);
            data = reshape(values, [shape bands frames]);
            file = pixelFixture(data, bands, frames);
            filename = fullfile(t.folder, 'pixels.ntf'); file.write(filename);
            raw = readBytes(filename);
            [index, ok, status] = nfx.internal.indexNITF(raw);
            t.assertTrue(ok, status.message);
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, ...
                numel(data), zeros(0, 0, pixelType));
            t.assertTrue(ok, status.message);
            t.verifyClass(pixels, pixelType); t.verifyEqual(pixels, data);
            oracle = inspectContainer(filename);
            t.verifyEqual(pixels, decodeMotion(oracle.images, frames));
        end

        function literalSampleNeedsNoWriter(t)
            raw = literalReaderFile();
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, ...
                1, zeros(0, 0, 'uint8'));
            t.assertTrue(ok, status.message); t.verifyEqual(pixels, uint8(197));
        end

        function resourceLimitAndWrongPrototypeReturnEmptyNativeValues(t)
            raw = literalReaderFile();
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, ...
                0, zeros(0, 0, 'uint8'));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyEmpty(pixels); t.verifyClass(pixels, 'uint8');
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, ...
                1, zeros(0, 0, 'uint16'));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(pixels); t.verifyClass(pixels, 'uint16');
        end

        function incompatibleFrameLayoutFailsBeforeAllocation(t)
            raw = literalReaderFile();
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            entry = index.images; entry.layout.imode = 'F';
            [pixels, ok, status] = nfx.internal.readPixels(raw, entry, 1, uint8([]));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(pixels);
            entry = index.images; entry.layout.ic = 'C8';
            [pixels, ok, status] = nfx.internal.readPixels(raw, entry, 1, uint8([]));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedFeature');
            t.verifyEmpty(pixels);
        end

        function nonzeroPaddingIsNotDiscarded(t)
            file = fixtureFile(uint8([1 2; 3 4]));
            filename = fullfile(t.folder, 'padding.ntf'); file.write(filename);
            raw = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            raw(end) = 255;
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, 4, uint8([]));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedFeature');
            t.verifyEmpty(pixels);
        end

        function leftJustifiedBitsRemainInTheirNativePositions(t)
            [base, image] = fixtureFile(uint16([0 16 32768 65520]));
            image.header.pjust = 'L'; image.header.abpp = 12;
            file = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'left.ntf'); file.write(filename);
            raw = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            [pixels, ok, status] = nfx.internal.readPixels(raw, index.images, 4, uint16([]));
            t.assertTrue(ok, status.message);
            t.verifyEqual(pixels, uint16([0 16 32768 65520]));
            t.verifyEqual(index.images.header.abpp, 12);
            t.verifyEqual(index.images.header.pjust, 'L');
        end
    end
end

function file = pixelFixture(data, bands, frames)
    if frames > 1
        file = fixtureMotion(data);
    else
        representation = 'MULTI';
        if bands == 1, representation = 'MONO'; end
        file = fixtureFile(data, representation);
    end
end
