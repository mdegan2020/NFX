classdef ABPPTest < NfxTest
    properties (TestParameter)
        bits = num2cell(1:16)
        badPrecision = {0, 65, 1.5, Inf, uint8(8), [8 8], '8'}
    end
    methods (Test)
        function unsignedBitBoundaries(t, bits)
            [~, image] = fixtureFile(uint16([0 2^bits-1]));
            t.verifyEqual(image.header.abpp, bits);
            t.verifyEqual(image.header.nbpp, 16);
            t.verifyTrue(image.validate().valid);
        end
        function powerOfTwoRequiresAnotherBit(t)
            [~, image] = fixtureFile(uint16([0 255]));
            t.verifyEqual(image.header.abpp, 8);
            image.data(1,2) = 256;
            t.verifyEqual(image.header.abpp, 9);
            image.data(1,2) = 0;
            t.verifyEqual(image.header.abpp, 1);
        end
        function laterBandAndReductionBlockContribute(t)
            pixels = zeros(257,257,2,'uint16');
            pixels(end,end,end) = 32768;
            [~, image] = fixtureFile(pixels,'MULTI');
            t.verifyEqual(image.header.abpp, 16);
            image.data(end,end,end) = 1023;
            t.verifyEqual(image.header.abpp, 10);
        end
        function typeReplacementAndHeaderReplacement(t)
            [~, image] = fixtureFile(uint16(65535));
            header = image.header;
            image.data = uint8([0 7]);
            image.header = header;
            t.verifyEqual([image.header.abpp image.header.nbpp], [3 8]);
            t.verifyClass(image.data, 'uint8');
            t.verifyTrue(image.validate().valid);
        end
        function declaredAcquisitionPrecisionAndAutomaticReset(t)
            [~, image] = fixtureFile(uint16([0 15]));
            image.header.abpp = 12;
            t.verifyTrue(image.validate().valid);
            t.verifyEqual(image.header.abpp, 12);
            image.header.abpp = 3;
            t.verifyFalse(image.validate().valid);
            image.header.abpp = 17;
            t.verifyFalse(image.validate().valid);
            image.header.abpp = NaN;
            t.verifyEqual(image.header.abpp, 4);
            t.verifyTrue(image.validate().valid);
        end
        function invalidPrecisionTypeOrRange(t, badPrecision)
            t.verifyError(@() nfx.ImageHeader(abpp=badPrecision), 'nfx:Metadata');
        end
        function leftJustifiedPaddingAndExactBytes(t)
            pixels = uint16([0 4096 61440]);
            [file, image] = fixtureFile(pixels);
            image.header.pjust = 'L';
            t.verifyEqual(image.header.abpp, 16);
            image.header.abpp = 4;
            image.header.nppbh = 3;
            image.header.nppbv = 1;
            file = nfx.File(header=file.header)+image;
            name = fullfile(t.folder,'left.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.images(1).fields.abpp, 4);
            t.verifyEqual(parsed.images(1).data, uint8([0 0 16 0 240 0]));
            t.verifyEqual(file.images(1).data, pixels);
            image.data(1,1) = 1;
            t.verifyFalse(image.validate().valid);
            image.header.abpp = 16;
            t.verifyTrue(image.validate().valid);
        end
        function allZeroLeftJustifiedCanDeclareOneBit(t)
            [~, image] = fixtureFile(zeros(2,'uint16'));
            image.header.pjust = 'L';
            image.header.abpp = 1;
            t.verifyTrue(image.validate().valid);
        end
        function attachedPixelsKeepTheirPrecisionSnapshot(t)
            [file,image] = fixtureFile(uint16([0 15]));
            image.data(1,2) = 65535;
            t.verifyEqual(file.images(1).header.abpp, 4);
            t.verifyEqual(image.header.abpp, 16);
        end
    end
end
