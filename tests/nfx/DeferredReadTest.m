classdef DeferredReadTest < NfxTest
    properties (TestParameter)
        selection = {[1 2], [2 1], 2}
        invalidSelection = {0, -1, 1.5, [1 1], [1; 2], true, single(1), 4, NaN}
        pixelType = {'uint8', 'uint16'}
        incompleteTag = {'UNKNWN', 'SECURA'}
    end
    methods (Test)
        function defaultRetainsMetadataWithoutPixels(t, pixelType)
            [source, filename] = makeFile(t.folder, pixelType);
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message);
            t.verifyFalse(any([file.images.pixelsLoaded]));
            t.verifyFalse(status.pixels_complete);
            t.verifyTrue(status.metadata_complete);
            t.verifyEqual(file.header.bytes(), source.header.bytes());
            t.verifyEqual(file.images(1).header.bytes(), source.images(1).header.bytes());
            t.verifyEqual(file.images(1).tre_records, source.images(1).tre_records);
            t.verifyEqual(file.texts.data, source.texts.data);
            t.verifyEqual(file.des.data, source.des.data);
            t.verifyEqual(file.images(1).RPC00B().payload(), ...
                source.images(1).RPC00B().payload());
            t.verifyTrue(file.validate().valid);
            t.verifyFalse(file.validate().complete);
            t.verifyFalse(any([file.images.pixelsLoaded]));
        end
        function selectedReadRetainsOnlySelectedImages(t, selection)
            [source, filename] = makeFile(t.folder, 'uint16');
            [file, ok, status] = nfx.File.read(filename, readSegment=selection);
            t.assertTrue(ok, status.message);
            t.verifyEqual([file.images.pixelsLoaded], ismember(1:3, selection));
            t.verifyEqual(file.images(selection(1)).data, source.images(selection(1)).data);
            t.verifyFalse(status.pixels_complete);
        end
        function eagerReadAndSubsequentMethodsAgree(t)
            [source, filename] = makeFile(t.folder, 'uint16');
            [eager, ok, status] = nfx.File.read(filename, readAll=true);
            t.assertTrue(ok, status.message); t.verifyTrue(status.pixels_complete);
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message);
            [partial, ok, status] = file.readSegment([1 2]);
            t.assertTrue(ok, status.message);
            t.verifyEqual([partial.images.pixelsLoaded], [true true false]);
            t.verifyFalse(any([file.images.pixelsLoaded]));
            [loaded, ok, status] = partial.readAll();
            t.assertTrue(ok, status.message); t.verifyTrue(status.pixels_complete);
            t.verifyEqual(loaded.images(3).data, source.images(3).data);
            t.verifyEqual(loaded.images(1).data, eager.images(1).data);
        end
        function temporaryGetterDoesNotChangeSnapshots(t, pixelType)
            [source, filename] = makeFile(t.folder, pixelType);
            file = nfx.File.read(filename);
            pixels = file.images(1).data;
            t.verifyEqual(pixels, source.images(1).data);
            t.verifyClass(pixels, pixelType);
            t.verifyFalse(file.images(1).pixelsLoaded);
            [image, ok, status] = file.images(1).read();
            t.assertTrue(ok, status.message); t.verifyTrue(image.pixelsLoaded);
            t.verifyFalse(file.images(1).pixelsLoaded);
        end
        function displayDoesNotLoadDeletedSource(t)
            [~, filename] = makeFile(t.folder, 'uint8');
            file = nfx.File.read(filename); delete(filename);
            image = file.images(1); %#ok<NASGU>
            output = evalc('disp(image)');
            t.verifySubstring(output, 'pixelsLoaded=0');
            t.verifyTrue(file.validate().valid);
        end
        function missingSourceUsesDiagnostics(t)
            [~, filename] = makeFile(t.folder, 'uint8');
            file = nfx.File.read(filename); delete(filename);
            [copy, ok, status] = file.readSegment(1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'IOError');
            t.verifyFalse(any([copy.images.pixelsLoaded]));
            t.verifyError(@() readData(file.images(1)), 'nfx:ReadPixels');
        end
        function changedSourceIsRejected(t)
            [~, filename] = makeFile(t.folder, 'uint8');
            file = nfx.File.read(filename);
            fid = fopen(filename, 'ab'); fwrite(fid, uint8(0)); fclose(fid);
            [~, ok, status] = file.readSegment(1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'SourceChanged');
        end
        function loadedPixelsSurviveSourceDeletion(t)
            [source, filename] = makeFile(t.folder, 'uint8');
            file = nfx.File.read(filename, readAll=true); delete(filename);
            [copy, ok, status] = file.readAll();
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images(1).data, source.images(1).data);
        end
        function metadataEditsSurviveExplicitLoading(t)
            [source, filename] = makeFile(t.folder, 'uint16');
            file = nfx.File.read(filename);
            image = file.images(1); image.header.icom = 'Edited before reading';
            image = image + nfx.FREESA(19);
            file = file.replaceImage(1, image);
            [file, ok, status] = file.readSegment(1);
            t.assertTrue(ok, status.message);
            t.verifyEqual(strtrim(file.images(1).header.icom), 'Edited before reading');
            t.verifyEqual(file.images(1).FREESA().count, 19);
            t.verifyEqual(file.images(1).data, source.images(1).data);
        end
        function writingMaterializesTemporaryCopy(t)
            [~, filename] = makeFile(t.folder, 'uint16');
            file = nfx.File.read(filename);
            output = fullfile(t.folder, 'copy.ntf'); file.write(output);
            t.verifyEqual(readBytes(output), readBytes(filename));
            t.verifyFalse(any([file.images.pixelsLoaded]));
        end
        function overflowAndWrappedMetadataRemainAvailable(t)
            [base, image] = fixtureFile();
            image = image + nfx.FREESA(60000) + nfx.FREESA(60000);
            wrapped = nfx.FSYNWA(start_frame_number=1) + fixtureSensor();
            image = image + wrapped;
            source = nfx.File(header=base.header) + image + nfx.FREESA(11);
            filename = fullfile(t.folder, 'overflow.ntf'); source.write(filename);
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message);
            t.verifyFalse(file.images.pixelsLoaded);
            t.verifyEqual(file.images.tre_records, source.images.tre_records);
            t.verifyEqual(file.tre_records, source.tre_records);
            t.verifyEqual({file.des.header}, {source.des.header});
            t.verifyEqual(file.images.FREESA(2).count, 60000);
        end
        function motionHeadersRemainAvailableBeforePixels(t)
            [source, image] = fixtureMotion();
            filename = fullfile(t.folder, 'motion.ntf'); source.write(filename);
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message);
            t.verifyFalse(file.images.pixelsLoaded);
            t.verifyEqual(file.images.number_frames, image.number_frames);
            t.verifyEqual(file.images.header.bytes(), image.header.bytes());
            t.verifyEqual(file.images.data, image.data);
        end
        function metadataBudgetExcludesSkippedPixelPayloads(t)
            [source, filename] = makeFile(t.folder, 'uint16');
            raw = readBytes(filename);
            budget = numel(raw) - sum([source.images.li]);
            [file, ok, status] = nfx.File.read(filename, MaxBytes=budget);
            t.assertTrue(ok, status.message);
            t.verifyFalse(any([file.images.pixelsLoaded]));
            [~, ok, status] = nfx.File.read(filename, readAll=true, MaxBytes=budget);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
        end
        function sampleLimitsOnlyApplyToRequestedPixels(t)
            [~, filename] = makeFile(t.folder, 'uint16');
            [file, ok, status] = nfx.File.read(filename, MaxPixels=6);
            t.assertTrue(ok, status.message);
            [partial, ok, status] = file.readSegment(1);
            t.assertTrue(ok, status.message);
            [unchanged, ok, status] = partial.readSegment(2);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            t.verifyEqual([unchanged.images.pixelsLoaded], [true false false]);
            [loaded, ok, status] = partial.readAll(MaxPixels=18);
            t.assertTrue(ok, status.message); t.verifyTrue(all([loaded.images.pixelsLoaded]));
        end
        function invalidSelectionReturnsDefault(t, invalidSelection)
            [~, filename] = makeFile(t.folder, 'uint8');
            [file, ok, status] = nfx.File.read(filename, readSegment=invalidSelection);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(file.images);
        end
        function conflictingSelectionIsRejected(t)
            [file, ok, status] = nfx.File.read('unused', readAll=true, readSegment=1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            t.verifyEmpty(file.images);
        end
        function replacedPixelsRemoveSourceDependency(t)
            [~, filename] = makeFile(t.folder, 'uint16');
            file = nfx.File.read(filename); image = file.images(1);
            image.data = uint8([1 2]); delete(filename);
            t.verifyTrue(image.pixelsLoaded);
            t.verifyEqual(image.data, uint8([1 2]));
            t.verifyEqual(image.header.ncols, 2);
        end
        function standaloneReadRejectsInvalidCloudSamples(t)
            base = fixtureFile(uint8([0 253; 254 255]));
            h = base.images.header; h.icat = 'CLOUD'; h.iid1 = 'CLOUDCOVER';
            image = nfx.ImageSegment(uint8([0 253; 254 255]), header=h) + ...
                fixtureAdditionalTRE('CSCCGA');
            source = nfx.File(header=base.header) + image;
            filename = fullfile(t.folder, 'cloud.ntf'); source.write(filename);
            raw = readBytes(filename); index = nfx.internal.indexNITF(raw);
            raw(index.images.location.dataOffset + 1) = 1;
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message);
            [image, ok, status] = file.images.read();
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyFalse(image.pixelsLoaded);
            t.verifyError(@() readData(file.images), 'nfx:ReadPixels');
        end
        function standaloneReadRetainsMetadataCoverage(t, incompleteTag)
            [base, image] = fixtureFile();
            if strcmp(incompleteTag, 'SECURA')
                tre = fixtureAdditionalTRE('SECURA');
                tre.fdattim = base.header.fdt;
            else
                tre = nfx.FREESA(7);
            end
            source = nfx.File(header=base.header) + (image + tre);
            if strcmp(incompleteTag, 'SECURA'), source = source + tre; end
            filename = fullfile(t.folder, 'incomplete.ntf'); source.write(filename);
            if strcmp(incompleteTag, 'UNKNWN')
                raw = readBytes(filename);
                at = strfind(char(raw), 'FREESA00007');
                raw(at + (0:5)) = uint8('UNKNWN');
                putBytes(filename, raw);
            end
            [file, ok, status] = nfx.File.read(filename);
            t.assertTrue(ok, status.message); t.verifyFalse(status.metadata_complete);
            [loaded, ok, status] = file.images.read();
            t.assertTrue(ok, status.message); t.verifyFalse(status.metadata_complete);
            t.verifyTrue(loaded.pixelsLoaded);
            [~, ok, status] = loaded.read();
            t.assertTrue(ok, status.message); t.verifyFalse(status.metadata_complete);
        end
        function deferredGLASStillValidatesMetadataAssociations(t)
            source = fixtureGLASFile();
            filename = fullfile(t.folder, 'glas.ntf'); source.write(filename);
            raw = readBytes(filename); index = nfx.internal.indexNITF(raw);
            raw(index.des(1).location.dataOffset + 1) = uint8('9');
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
            [file, ok, status] = nfx.File.read(filename, readSegment=1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
        end
        function deferredRSMStillValidatesCrossImageEditions(t)
            [base, image] = fixtureFile();
            image = image.removeTRE(1) + fixtureRSMIdentification() + ...
                fixturePolynomial();
            source = nfx.File(header=base.header) + image + image;
            filename = fullfile(t.folder, 'rsm.ntf'); source.write(filename);
            raw = readBytes(filename); index = nfx.internal.indexNITF(raw);
            locations = strfind(char(raw), 'SYNTHETIC ORIGINAL');
            locations = locations(locations > index.images(2).location.headerOffset);
            t.assertNumElements(locations, 2);
            for at = locations
                raw(at + (0:79)) = uint8(sprintf('%-80s', 'DIFFERENT ORIGINAL'));
            end
            putBytes(filename, raw);
            [file, ok, status] = nfx.File.read(filename);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
            [file, ok, status] = nfx.File.read(filename, readSegment=1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(file.images);
        end
    end
end

function [source, filename] = makeFile(folder, pixelType)
    [base, image] = fixtureFile(cast(reshape(1:6, 2, 3), pixelType));
    text = fixtureText('Preserve this text');
    des = nfx.DESSegment(uint8('support bytes'), ...
        header=nfx.DESHeader(desid='TEST', desclas='U'));
    source = nfx.File(header=base.header) + image + image + image + text + des;
    filename = fullfile(folder, 'deferred.ntf'); source.write(filename);
end

function value = readData(image)
    value = image.data;
end
