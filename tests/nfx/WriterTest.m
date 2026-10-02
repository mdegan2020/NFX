classdef WriterTest < NfxTest
    properties (TestParameter)
        pixelCase = struct( ...
            'u8Mono', struct('data',reshape(uint8(1:35),5,7),'rep','MONO'), ...
            'u16Mono', struct('data',reshape(uint16(1001:1035),5,7),'rep','MONO'), ...
            'u8RGB', struct('data',reshape(uint8(1:105),5,7,3),'rep','RGB'), ...
            'u16RGB', struct('data',reshape(uint16(50001:50105),5,7,3),'rep','RGB'), ...
            'multi', struct('data',reshape(uint16(3001:3140),5,7,4),'rep','MULTI'), ...
            'xbands', struct('data',reshape(uint8(mod(1:350,256)),5,7,10),'rep','MULTI'), ...
            'onePixel', struct('data',uint16(65535),'rep','MONO'), ...
            'oneRow', struct('data',uint8(1:7),'rep','MONO'), ...
            'oneColumn', struct('data',uint16((601:605).'),'rep','MONO'))
    end
    methods (Test)
        function independentBytesAndReaderRoundTrip(t, pixelCase)
            file = fixtureFile(pixelCase.data,pixelCase.rep);
            filename = fullfile(t.folder, 'roundtrip.ntf');
            file.write(filename);
            parsed = inspectNITF(filename);
            t.verifyEqual(parsed.pixels, pixelCase.data);
            t.verifyEqual(parsed.fl, file.header.fl);
            t.verifyEqual(parsed.lish, file.images(1).lish);
            t.verifyEqual(parsed.li, file.images(1).li);
            t.verifyEqual(parsed.irep, pixelCase.rep);
            t.verifyTrue(isnitf(filename));
            recovered = nitfread(filename);
            t.verifyEqual(recovered, pixelCase.data);
            info = nitfinfo(filename);
            t.verifyEqual(double(info.FileLength), parsed.fl);
            t.verifyEqual(double(info.NITFFileHeaderLength), parsed.hl);
        end
        function exactFileAndImageBytes(t)
            file = fixtureFile();
            filename = fullfile(t.folder, 'fields.ntf');
            file.write(filename);
            parsed = inspectNITF(filename);
            h = parsed.fileHeader;
            t.verifyEqual(char(h(1:15)), 'NITF02.1003BF01');
            t.verifyEqual(h(298:300), uint8([1 128 255]));
            t.verifyEqual(char(h(343:379)), '0000000019940004040010014940000000096');
            t.verifyEqual(char(parsed.imageHeader(334:375)), ...
                '0000000500000007INTMONO    VIS     09R 0NC');
            t.verifyEqual(char(parsed.rpc(1:15)), '10000.000000.00');
            t.verifyEqual(numel(parsed.rpc), 1041);
        end
        function exactBigEndianBlockOrder(t)
            file = fixtureFile(uint16([1 256; 513 65535]));
            image = file.images(1);
            image.header.nppbh = 2;
            image.header.nppbv = 2;
            file = nfx.File(header=file.header)+image;
            filename = fullfile(t.folder,'endian.ntf');
            file.write(filename);
            bytes = readBytes(filename);
            t.verifyEqual(bytes(end-7:end), uint8([0 1 1 0 2 1 255 255]));
        end
        function determinismAndPreservation(t)
            file = fixtureFile();
            before = file;
            first = fullfile(t.folder,'first.ntf');
            second = fullfile(t.folder,'second.ntf');
            report = file.validate();
            file.write(first);
            file.write(second);
            t.verifyTrue(report.valid);
            t.verifyEqual(file, before);
            t.verifyEqual(readBytes(first), readBytes(second));
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function noTREIsValidGenericNITF(t)
            [file, image] = fixtureFile();
            image = image.removeTRE(1);
            file = nfx.File(header=file.header)+image;
            filename = fullfile(t.folder,'without-tre.ntf');
            file.write(filename);
            parsed = inspectNITF(filename);
            t.verifyEmpty(parsed.rpc);
            t.verifyEqual(parsed.lish,439);
            t.verifyEqual(nitfread(filename),image.data);
        end
        function defaultBlocks(t)
            [file, image] = fixtureFile(uint8([1 2; 3 4]));
            image.header.nppbh = 1024;
            image.header.nppbv = 1024;
            file = nfx.File(header=file.header)+image;
            filename = fullfile(t.folder,'default.ntf');
            file.write(filename);
            t.verifyEqual(file.images(1).li,1024^2);
            t.verifyEqual(nitfread(filename),uint8([1 2; 3 4]));
            bytes = readBytes(filename);
            offset = file.header.hl+file.header.lish;
            t.verifyEqual(bytes(offset+[1 2 1025 1026]),uint8([1 2 3 4]));
        end
        function oracleDetectsLengthCorruption(t)
            file = fixtureFile();
            filename = fullfile(t.folder,'malformed.ntf');
            file.write(filename);
            bytes = readBytes(filename);
            bytes(354) = uint8('0');
            putBytes(filename,bytes);
            t.verifyError(@() inspectNITF(filename),'oracle:Length');
        end
        function defaultMultipleBlocksAndPartialEdges(t)
            pixels = reshape(uint16(mod((1:1025*1027)*31,65536)),1025,1027);
            [file,image] = fixtureFile(pixels);
            image.header.nppbh = 1024;
            image.header.nppbv = 1024;
            file = nfx.File(header=file.header)+image;
            filename = fullfile(t.folder,'four-default-blocks.ntf');
            file.write(filename);
            t.verifyEqual([image.header.nbpr image.header.nbpc],[2 2]);
            t.verifyEqual(nitfread(filename),pixels);
        end
    end
end
