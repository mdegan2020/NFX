classdef FileReadTest < NfxTest
    properties (TestParameter)
        invalidFilename = {42, [], '', "", missing, ["a", "b"], ['a'; 'b'], char(0)}
        invalidLimit = {0, -1, 1.5, Inf, NaN, single(1), [1 2], 1i}
    end
    methods (Test)
        function mixedNativeImagesMetadataAndTextRoundTrip(t)
            [base, first] = fixtureFile(uint8([0 255; 1 2]));
            [~, second] = fixtureFile(uint16([0 256 65535]));
            first.header.icom = 'First image';
            second.header.icom = repmat('B', 9, 80);
            second.header.abpp = 16;
            first = first + nfx.FREESA(3) + nfx.FREESA(7);
            text = fixtureText(sprintf('one\ntwo'));
            source = nfx.File(header=base.header) + first + text + second;
            filename = fullfile(t.folder, 'source.ntf'); source.write(filename);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyEqual(file.images(1).data, first.data);
            t.verifyEqual(file.images(2).data, second.data);
            t.verifyEqual(file.images(1).header.icom, first.header.icom);
            t.verifyEqual(file.images(2).header.icom, second.header.icom);
            t.verifyEqual(file.texts.data, text.data);
            t.verifyEqual(file.images(2).header.abpp, 16);
            t.verifyEqual(nitfread(filename, 1), file.images(1).data);
            t.verifyEqual(nitfread(filename, 2), file.images(2).data);
            [record, found] = file.images(1).FREESA(2);
            t.verifyTrue(found); t.verifyEqual(numel(record.payload()), 7);
            output = fullfile(t.folder, 'rewritten.ntf'); file.write(output);
            t.verifyEqual(readBytes(output), readBytes(filename));
        end

        function motionAndEffectiveFrameMetadataRoundTrip(t)
            [base, image] = fixtureMotion(); rpc = fixtureRPC();
            wrapper = nfx.FSYNWA(start_frame_number=2) + rpc;
            image = image + wrapper;
            source = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'motion.ntf'); source.write(filename);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyEqual(file.images.data, image.data);
            t.verifyEqual(file.images.number_frames, image.number_frames);
            t.verifyEqual(file.effectiveTREs(1, 1), source.effectiveTREs(1, 1));
            t.verifyEqual(file.effectiveTREs(1, 2), source.effectiveTREs(1, 2));
            output = fullfile(t.folder, 'motion-copy.ntf'); file.write(output);
            t.verifyEqual(readBytes(output), readBytes(filename));
        end

        function metadataEditsRemainIndependent(t)
            source = fixtureFile(); filename = fullfile(t.folder, 'edit.ntf');
            source.write(filename);
            [file, ok, status] = nfx.File.read(filename, readAll=true); t.assertTrue(ok, status.message);
            image = file.images(1); [rpc, found] = image.RPC00B(); t.assertTrue(found);
            rpc.err_bias = 1.25;
            image = image.removeTRE(image.tre_ids(1)) + rpc;
            image.header.icom = 'Edited metadata';
            edited = nfx.File(header=file.header) + image;
            output = fullfile(t.folder, 'edited.ntf'); edited.write(output);
            [read, ok, status] = nfx.File.read(output, readAll=true); t.assertTrue(ok, status.message);
            t.verifyEqual(read.images.data, source.images.data);
            t.verifyEqual(read.images.RPC00B().err_bias, 1.25);
            t.verifyEqual(file.images.RPC00B().err_bias, 0);
            t.verifySize(file.images.header.icom, [0 80]);
        end

        function publicLimitsApplyBeforeAllocationAndAcrossImages(t)
            [base, image] = fixtureFile(ones(2, 3, 'uint8'));
            source = nfx.File(header=base.header) + image + image;
            filename = fullfile(t.folder, 'limits.ntf'); source.write(filename);
            count = numel(readBytes(filename));
            [file, ok, status] = nfx.File.read(filename, readAll=true, MaxBytes=count - 1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyEmpty(file.images);
            [file, ok, status] = nfx.File.read(filename, readAll=true, MaxPixels=11);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyEmpty(file.images);
            [file, ok, status] = nfx.File.read(filename, readAll=true, MaxBytes=count, MaxPixels=12);
            t.assertTrue(ok, status.message); t.verifyNumElements(file.images, 2);
        end

        function invalidFileNamesUseStatus(t, invalidFilename)
            [file, ok, status] = nfx.File.read(invalidFilename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(file.images);
        end

        function invalidLimitsUseStatus(t, invalidLimit)
            [~, ok, status] = nfx.File.read('unused.ntf', readAll=true, MaxBytes=invalidLimit);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.File.read('unused.ntf', readAll=true, MaxPixels=invalidLimit);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
        end

        function missingAndTruncatedFilesGiveActionableDiagnostics(t)
            filename = fullfile(t.folder, 'absent.ntf');
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'IOError');
            t.verifyEqual(status.path, filename); t.verifyEmpty(file.images);
            putBytes(filename, uint8('NITF'));
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEqual(status.offset, 0); t.verifyEqual(status.path, filename);
            t.verifyEmpty(file.images);
        end

        function contradictoryABPPAndModeAreRejected(t)
            filename = fullfile(t.folder, 'abpp.ntf'); raw = literalReaderFile();
            raw(773:774) = uint8('01'); putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
            raw = literalReaderFile(); raw(795) = uint8('F'); putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
        end

        function emptyFileIsMalformedRatherThanInvalidInput(t)
            filename = fullfile(t.folder, 'empty.ntf');
            putBytes(filename, zeros(1, 0, 'uint8'));
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEqual(status.offset, 0); t.verifyEqual(status.path, filename);
            t.verifyEmpty(file.images);
        end

        function textAttachmentCannotReferToAbsentImage(t)
            base = fixtureFile(); source = nfx.File(header=base.header) + fixtureText('text');
            filename = fullfile(t.folder, 'attachment.ntf'); source.write(filename);
            raw = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            raw(index.texts.location.headerOffset + (10:12)) = uint8('001');
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.texts);
        end

        function importedUserAreaIsPreserved(t)
            [base, image] = fixtureFile(uint8(1));
            source = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'user-area.ntf'); source.write(filename);
            raw = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            entry = index.images; first = entry.extended.offset - 7;
            finish = entry.extended.offset + entry.extended.length;
            raw(first - 5:finish) = [raw(first:finish) uint8('00000')];
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyTrue(status.metadata_complete);
            output = fullfile(t.folder, 'user-area-copy.ntf');
            file.write(output);
            t.verifyEqual(readBytes(output), raw);
        end

        function knownByteBufferCannotSmuggleJ2KLRAIntoUncompressedImage(t)
            % Only the derived compressed snapshot may own original J2KLRA.
            raw = literalReaderFile(); frame = fixtureDecodableTRE('J2KLRA').bytes();
            count = numel(frame) + 3;
            raw = [raw(1:838) uint8(sprintf('%05d000', count)) frame raw(844:end)];
            raw(343:354) = uint8(sprintf('%012d', numel(raw)));
            raw(364:369) = uint8(sprintf('%06d', 439 + count));
            filename = fullfile(t.folder, 'misplaced-j2klra.ntf'); putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifySubstring(status.message, 'J2KLRA'); t.verifyEmpty(file.images);
        end

        function rawInputLimitsAreAlsoChecked(t)
            [file, ok, status] = nfx.internal.FileReader.readBytes(literalReaderFile(), NaN);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(file.images);
        end

        function reorderedOverflowDESCannotChangeMetadataPrecedence(t)
            [base, image] = fixtureFile(uint8(1));
            generic = nfx.DESSegment(uint8(99), ...
                header=nfx.DESHeader(desid='RAW', desclas='U'));
            source = nfx.File(header=base.header) + generic + (image + nfx.FREESA(99985));
            filename = fullfile(t.folder, 'des-order.ntf'); source.write(filename);
            raw = readBytes(filename);
            [index, ok] = nfx.internal.indexNITF(raw); t.assertTrue(ok);
            first = index.des(1).location.headerOffset;
            second = index.des(2).location.headerOffset;
            raw(first + 1:end) = [raw(second + 1:end) raw(first + 1:second)];
            raw(392:417) = [raw(405:417) raw(392:404)];
            raw(index.images.extended.offset + (-2:0)) = uint8('001');
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedFeature');
            t.verifySubstring(status.message, 'DES order'); t.verifyEmpty(file.images);
        end

        function noncanonicalImageFieldIsNotRewrittenSilently(t)
            raw = literalReaderFile(); raw(783:788) = uint8(' 550.0');
            filename = fullfile(t.folder, 'spelling.ntf'); putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename, readAll=true);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifySubstring(status.message, 'Stored image fields');
            t.verifyEmpty(file.images);
        end
    end
end
