classdef CompositionTest < NfxTest
    properties (TestParameter)
        badPixels = {ones(2), single(ones(2)), int16(ones(2)), true(2), ...
            sparse(eye(2)), zeros(2,2,2,2,'uint8'), '123', ones(2)*1i}
    end
    methods (Test)
        function rejectPixelConversions(t, badPixels)
            t.verifyError(@() nfx.ImageSegment(badPixels), 'nfx:Pixels');
            t.verifyError(@() assignProperty(nfx.ImageSegment(), 'data', badPixels), 'nfx:Pixels');
        end
        function mutableBeforeAttachmentIsolatedAfter(t)
            [file, image, rpc] = fixtureFile();
            first = fullfile(t.folder, 'first.ntf');
            second = fullfile(t.folder, 'second.ntf');
            file.write(first);
            rpc.line_off = 999;
            image.header.iid2 = 'Changed after attachment';
            image.data(1,1) = uint16(60000);
            file.write(second);
            t.verifyEqual(readBytes(first), readBytes(second));
            t.verifyEqual(file.images(1).data(1,1), uint16(257));
            t.verifyEqual(rpc.line_off, 999);
        end
        function repeatedAttachmentAndRemovalOrder(t)
            [~, image, rpc] = fixtureFile();
            image = image + rpc + rpc;
            t.verifyEqual(image.tre_ids, [1 2 3]);
            t.verifyEqual(image.tre_tags, repmat('RPC00B',3,1));
            t.verifyFalse(image.validate().valid);
            image = image.removeTRE(2);
            image = image + rpc;
            t.verifyEqual(image.tre_ids, [1 3 4]);
            image = image.removeTRE(1).removeTRE(3);
            t.verifyEqual(image.tre_ids, 4);
            t.verifyTrue(image.validate().valid);
        end
        function unknownAndRemovedIDs(t)
            [~, image] = fixtureFile();
            image = image.removeTRE(1);
            t.verifyEmpty(image.tre_ids);
            t.verifyEmpty(image.tre_tags);
            t.verifyError(@() image.removeTRE(1), 'nfx:UnknownAttachment');
            t.verifyError(@() image.removeTRE('1'), 'nfx:Metadata');
        end
        function attachmentIDsDoNotAffectBytes(t)
            [file, image, rpc] = fixtureFile();
            image = image.removeTRE(1) + rpc;
            rebuilt = nfx.File(header=file.header) + image;
            first = fullfile(t.folder, 'first.ntf');
            second = fullfile(t.folder, 'second.ntf');
            file.write(first);
            rebuilt.write(second);
            t.verifyEqual(readBytes(first), readBytes(second));
            t.verifyEqual(image.tre_ids, 2);
        end
        function invalidTREIsNotAttached(t)
            image = nfx.ImageSegment();
            t.verifyError(@() plus(image,nfx.RPC00B()), 'nfx:Invalid');
            t.verifyEmpty(image.tre_ids);
        end
        function multipleImagesHaveIndependentDisplayLevels(t)
            [file, image] = fixtureFile();
            file = file + image;
            report = file.validate();
            t.verifyTrue(report.valid);
            t.verifyEqual(file.header.numi, 2);
            t.verifyEqual(file.header.hl, 420);
            t.verifyEqual([file.images(1).header.idlvl file.images(2).header.idlvl], [1 2]);
        end
        function emptyPixelsCannotWrite(t)
            [file, image] = fixtureFile();
            image.data = zeros(0,3,'uint16');
            file = nfx.File(header=file.header) + image;
            t.verifyFalse(file.validate().valid);
            t.verifyError(@() file.write(fullfile(t.folder,'empty.ntf')), 'nfx:Invalid');
        end
        function builtInTREsOnly(t)
            image = nfx.ImageSegment();
            tre = SyntheticTRE(uint8([0 255]));
            t.verifyError(@() plus(image,tre),'nfx:UnsupportedTRE');
        end
        function baseEnvelopeAllowsBinaryPayloads(t)
            tre = SyntheticTRE(uint8([0 128 255]));
            t.verifyEqual(tre.bytes(),[uint8('BINARY00003') uint8([0 128 255])]);
            t.verifyEqual(tre.cel,3);
        end
        function baseEnvelopeRejectsOversizedPayload(t)
            tre = SyntheticTRE(zeros(1,99986,'uint8'));
            t.verifyError(@() tre.bytes(),'nfx:TRELength');
        end
        function imageCountLimit(t)
            file = repeatImage(nfx.ImageSegment(),999);
            t.verifyError(@() plus(file,nfx.ImageSegment()),'nfx:ImageCount');
        end
        function sourceArrayRemainsIndependent(t)
            pixels = uint16([60000 1; 2 3]);
            image = nfx.ImageSegment(pixels);
            pixels(1,1) = 0;
            t.verifyEqual(image.data(1,1),uint16(60000));
            t.verifyEqual(pixels(1,1),uint16(0));
        end
    end
end
