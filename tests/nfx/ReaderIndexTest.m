classdef ReaderIndexTest < NfxTest
    properties (TestParameter)
        comments = {0, 1, 9}
        bandCount = {1, 3, 10}
        truncateAt = {0, 8, 342, 359, 363, 403, 843}
        coordinates = struct('decimal', struct('code', 'D', ...
            'text', repmat('+00.000+000.000', 1, 4)), ...
            'dms', struct('code', 'G', ...
            'text', repmat('000000N0000000E', 1, 4)))
        motionBands = {1, 2}
        badInput = {[], uint16(1:400), 'NITF', zeros(400, 1, 'uint8')}
        badFile = { ...
            struct('at', 343, 'text', '000000000845', 'code', 'MalformedFile'), ...
            struct('at', 355, 'text', '000403', 'code', 'MalformedFile'), ...
            struct('at', 361, 'text', '999', 'code', 'MalformedFile'), ...
            struct('at', 364, 'text', '000440', 'code', 'MalformedFile'), ...
            struct('at', 380, 'text', '001', 'code', 'UnsupportedFeature'), ...
            struct('at', 383, 'text', '001', 'code', 'UnsupportedFeature'), ...
            struct('at', 392, 'text', '001', 'code', 'UnsupportedFeature'), ...
            struct('at', 396, 'text', '00001', 'code', 'MalformedFile'), ...
            struct('at', 6, 'text', '02.00', 'code', 'UnsupportedFeature'), ...
            struct('at', 16, 'text', repmat(' ', 1, 10), 'code', 'MalformedFile'), ...
            struct('at', 120, 'text', 'S', 'code', 'UnsupportedFeature')}
        badImage = { ...
            struct('at', 350, 'text', 'SI ', 'code', 'UnsupportedFeature'), ...
            struct('at', 334, 'text', '00000000', 'code', 'MalformedFile'), ...
            struct('at', 372, 'text', 'N', 'code', 'UnsupportedFeature'), ...
            struct('at', 373, 'text', '9', 'code', 'MalformedFile'), ...
            struct('at', 374, 'text', 'C3', 'code', 'UnsupportedFeature'), ...
            struct('at', 376, 'text', '9', 'code', 'MalformedFile'), ...
            struct('at', 379, 'text', 'nope!!', 'code', 'MalformedFile'), ...
            struct('at', 389, 'text', '1', 'code', 'UnsupportedFeature'), ...
            struct('at', 391, 'text', 'S', 'code', 'UnsupportedFeature'), ...
            struct('at', 392, 'text', '0002', 'code', 'MalformedFile'), ...
            struct('at', 400, 'text', '0000', 'code', 'MalformedFile'), ...
            struct('at', 408, 'text', '32', 'code', 'UnsupportedFeature'), ...
            struct('at', 430, 'text', '00001', 'code', 'MalformedFile')}
    end
    methods (Test)
        function literalHeaderHasExactOffsetsAndValues(t)
            [index, ok, status] = nfx.internal.indexNITF(literalReaderFile());
            t.assertTrue(ok, status.message);
            t.verifyEqual([index.fl index.hl index.clevel], [844 404 3]);
            t.verifyEqual(index.header.ostaid, 'ORIGIN');
            t.verifyEqual(index.header.fbkgc, [1 2 3]);
            t.verifyEqual(index.images.location, struct('headerOffset', 404, ...
                'headerLength', 439, 'dataOffset', 843, 'dataLength', 1));
            t.verifyEqual(index.images.header.abpp, 8);
            t.verifyEqual(index.images.layout, struct('nrows', 1, ...
                'ncols', 1, 'bands', 1, 'nbpp', 8, 'nbpr', 1, ...
                'nbpc', 1, 'imode', 'B', 'ic', 'NC', 'comrat', ''));
        end

        function optionalCommentsAndBandsMatchIndependentOracle(t, comments, bandCount, coordinates)
            representations = {'MONO', 'MULTI', 'RGB'};
            representation = representations{min(bandCount, 2 + (bandCount == 3))};
            [base, image] = fixtureFile(ones(2, 3, bandCount, 'uint16'), representation);
            image.header.icom = repmat('C', comments, 80);
            image.header.icords = coordinates.code;
            image.header.igeolo = coordinates.text;
            image.header.isubcat = repmat(550, 1, bandCount);
            image.header.abpp = 12;
            file = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'optional.ntf');
            file.write(filename);
            [index, ok, status] = nfx.internal.indexNITF(readBytes(filename));
            t.assertTrue(ok, status.message);
            oracle = inspectContainer(filename);
            t.verifyEqual(index.images.header.icom, oracle.images.fields.icom);
            t.verifyEqual(index.images.header.igeolo, oracle.images.fields.igeolo);
            t.verifyEqual(index.images.layout.bands, bandCount);
            t.verifyEqual(index.images.header.isubcat, repmat(550, 1, bandCount));
            t.verifyEqual(index.images.header.abpp, 12);
            t.verifyEqual(index.images.location.dataOffset, index.hl + file.header.lish);
        end

        function textAndDESMetadataRemainIndependent(t)
            base = fixtureFile(); text = fixtureText('manifest.ntf');
            text.header.txtitl = 'Manifest';
            support = nfx.DESSegment(uint8([0 128 255]), header= ...
                nfx.DESHeader(desid='RAW', desclas='U', desver=3, ...
                desshf=uint8([0 13 255])));
            file = nfx.File(header=base.header) + text + support;
            filename = fullfile(t.folder, 'text-des.ntf');
            file.write(filename);
            [index, ok, status] = nfx.internal.indexNITF(readBytes(filename));
            t.assertTrue(ok, status.message);
            t.verifyEmpty(index.images);
            t.verifyEqual(index.texts.header, text.header);
            t.verifyEqual(index.des.header, support.header);
            t.verifyEqual(index.des.location.dataOffset + ...
                index.des.location.dataLength, index.fl);
        end

        function fileFieldFailuresHaveNoPartialIndex(t, badFile)
            bytes = literalReaderFile();
            bytes(badFile.at:badFile.at + numel(badFile.text) - 1) = uint8(badFile.text);
            [index, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, badFile.code);
            t.verifyEqual(status.scope, 'file');
            t.verifyGreaterThanOrEqual(status.offset, 0);
            t.verifyEmpty(index.images);
            t.verifyEqual(index.fl, 0);
        end

        function imageFieldFailuresIdentifySegment(t, badImage)
            bytes = literalReaderFile(); at = 404 + badImage.at;
            bytes(at:at + numel(badImage.text) - 1) = uint8(badImage.text);
            [index, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, badImage.code);
            t.verifyEqual(status.scope, 'image');
            t.verifyEqual(status.index, 1);
            t.verifyGreaterThanOrEqual(status.offset, 404);
            t.verifyEmpty(index.images);
        end

        function truncatedInputFailsWithoutIndexingPastBuffer(t, truncateAt)
            bytes = literalReaderFile();
            [index, ok, status] = nfx.internal.indexNITF(bytes(1:truncateAt));
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(index.images);
        end

        function cursorPreservesFirstFailureAndSourceOffset(t)
            reader = nfx.internal.NITFReader(uint8('ABCDE'), 3, 4, 'text', 2);
            [bytes, reader] = reader.take(3);
            t.verifyEmpty(bytes);
            t.verifyFalse(reader.ok);
            t.verifyEqual(reader.status.offset, 2);
            t.verifyEqual(reader.status.index, 2);
            original = reader.status;
            reader = reader.expect('X', 'later field');
            t.verifyEqual(reader.status, original);
        end

        function wrongInputClassAndShapeReturnStatus(t, badInput)
            [index, ok, status] = nfx.internal.indexNITF(badInput);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(index.images);
        end

        function cursorChecksTextSignedIntegersAndCompleteConsumption(t)
            reader = nfx.internal.NITFReader(uint8([65 255]));
            [~, reader] = reader.text(2);
            t.verifyFalse(reader.ok);
            t.verifyEqual(reader.status.offset, 0);
            reader = nfx.internal.NITFReader(uint8('-0012'));
            [value, reader] = reader.integer(5, -9999, 99999);
            t.verifyTrue(reader.ok); t.verifyEqual(value, -12);
            reader = nfx.internal.NITFReader(uint8('AB'));
            [~, reader] = reader.take(1); reader = reader.finish();
            t.verifyFalse(reader.ok); t.verifyEqual(reader.status.offset, 1);
        end

        function trailingBytesMustBelongToTheSegmentTables(t)
            bytes = [literalReaderFile() uint8(0)];
            bytes(343:354) = uint8('000000000845');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEqual(status.offset, 342);
        end

        function overflowPointersKeepPhysicalOwnership(t)
            [base, image] = fixtureFile(uint8(1));
            image = image + nfx.FREESA(99985);
            text = fixtureText('text') + nfx.FREESA(9800);
            file = nfx.File(header=base.header) + nfx.FREESA(99985) + image + text;
            filename = fullfile(t.folder, 'overflow.ntf'); file.write(filename);
            [index, ok, status] = nfx.internal.indexNITF(readBytes(filename));
            t.assertTrue(ok, status.message);
            oracle = inspectContainer(filename);
            t.verifyEqual(index.extended.overflow, oracle.overflow);
            t.verifyEqual(index.images.extended.overflow, oracle.images.overflow);
            t.verifyEqual(index.texts.extended.overflow, oracle.texts.overflow);
            t.verifyEqual({index.des.owner}, {'XHD', 'IXSHD', 'TXSHD'});
            t.verifyEqual([index.des.item], [0 1 1]);
            bytes = readBytes(filename);
            bytes(index.des(1).location.headerOffset + (28:29)) = uint8('02');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.scope, 'des');
            t.verifyEqual(status.code, 'MalformedFile');
        end

        function motionLayoutRemainsExplicit(t, motionBands)
            data = zeros(3, 5, motionBands, 4, 'uint16');
            [file, image] = fixtureMotion(data);
            filename = fullfile(t.folder, 'motion.ntf'); file.write(filename);
            [index, ok, status] = nfx.internal.indexNITF(readBytes(filename));
            t.assertTrue(ok, status.message);
            t.verifyEqual(index.images.layout.imode, image.header.imode);
            t.verifyEqual(index.images.layout.bands, motionBands);
            t.verifyEqual(index.images.location.dataLength, image.li);
        end

        function shortSubheaderCannotConsumeFollowingImageData(t)
            bytes = literalReaderFile();
            bytes(777) = uint8('1'); % NICOM claims 80 more header bytes.
            bytes(343:354) = uint8('000000000924');
            bytes(370:379) = uint8('0000000081');
            bytes = [bytes zeros(1, 80, 'uint8')];
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEqual(status.scope, 'image');
        end

        function invalidTextAndDESFieldsReturnSourceDiagnostics(t)
            base = fixtureFile();
            file = nfx.File(header=base.header) + fixtureText('test') + ...
                nfx.DESSegment(uint8(1), ...
                header=nfx.DESHeader(desid='RAW', desclas='U'));
            filename = fullfile(t.folder, 'headers.ntf'); file.write(filename);
            original = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(original); t.assertTrue(ok);
            bytes = original;
            bytes(index.texts.location.headerOffset + 275) = uint8('X');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.scope, 'text');
            t.verifyEqual(status.code, 'UnsupportedFeature');
            bytes = original;
            bytes(index.des.location.headerOffset + (197:200)) = uint8('0001');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.scope, 'des');
            t.verifyEqual(status.code, 'MalformedFile');
            bytes = original;
            bytes(index.texts.location.headerOffset + (13:26)) = uint8('20260230000000');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.scope, 'text');
            t.verifyEqual(status.code, 'MalformedFile');
            bytes = original;
            bytes(index.des.location.headerOffset + (3:27)) = uint8(' ');
            [~, ok, status] = nfx.internal.indexNITF(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.scope, 'des');
            t.verifyEqual(status.code, 'MalformedFile');
        end
    end
    methods (Test, TestTags = {'OpenJPEG'})
        function compressedMetadataUsesTheSameNativeIndex(t)
            encoder = getenv('NFX_OPENJPEG');
            t.assertTrue(isfile(encoder));
            [base, image] = fixtureFile(ones(32, 32, 'uint8'));
            image.header.nppbh = 1024; image.header.nppbv = 1024;
            image = image.compress(encoder, Profile='EPJE');
            file = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'compressed.ntf'); file.write(filename);
            [index, ok, status] = nfx.internal.indexNITF(readBytes(filename));
            t.assertTrue(ok, status.message);
            t.verifyEqual(index.images.layout.ic, 'C8');
            t.verifyEqual(index.images.layout.comrat, image.compression.comrat);
            t.verifyEqual(index.images.location.dataLength, image.li);
        end
    end
end
