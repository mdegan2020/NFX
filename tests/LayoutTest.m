classdef LayoutTest < NfxTest
    properties (TestParameter)
        dimensionCase = struct('at03',struct('columns',2048,'level',3), ...
            'enter05',struct('columns',2049,'level',5), ...
            'at05',struct('columns',8192,'level',5), ...
            'enter06',struct('columns',8193,'level',6), ...
            'at06',struct('columns',65536,'level',6), ...
            'enter07',struct('columns',65537,'level',7))
        bandCase = struct('at03',struct('bands',9,'level',3), ...
            'enter05',struct('bands',10,'level',5), ...
            'at05',struct('bands',255,'level',5), ...
            'enter07',struct('bands',256,'level',7), ...
            'at07',struct('bands',999,'level',7), ...
            'enter09',struct('bands',1000,'level',9))
    end
    methods (Test)
        function dimensionComplexity(t, dimensionCase)
            [file,image] = fixtureFile(zeros(1,dimensionCase.columns,'uint8'));
            image.header.nppbh = 1024;
            file = nfx.File(header=file.header)+image;
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.header.clevel,dimensionCase.level);
        end
        function bandComplexity(t, bandCase)
            file = fixtureFile(zeros(1,1,bandCase.bands,'uint8'),'MULTI');
            filename = fullfile(t.folder,'bands.ntf');
            file.write(filename);
            t.verifyEqual(file.header.clevel,bandCase.level);
            t.verifyEqual(size(nitfread(filename),3),bandCase.bands);
        end
        function RGB16RequiresLevel07(t)
            file = fixtureFile(zeros(1,1,3,'uint16'),'RGB');
            t.verifyEqual(file.header.clevel,7);
        end
        function blockDimensionsInfluenceComplexity(t)
            [file,image] = fixtureFile(uint8(1));
            image.header.nppbh = 2049;
            file = nfx.File(header=file.header)+image;
            t.verifyEqual(file.header.clevel,5);
        end
        function paddedSizeInfluencesComplexity(t)
            [file,image] = fixtureFile(zeros(1,1,4,'uint8'),'MULTI');
            image.header.nppbh = 8192;
            image.header.nppbv = 8192;
            file = nfx.File(header=file.header)+image;
            t.verifyEqual(file.header.clevel,5);
            t.verifyEqual(file.images(1).li,4*8192^2);
        end
        function paddedSizeCrossesTwoGiB(t)
            [file,image] = fixtureFile(zeros(1,1,32,'uint8'),'MULTI');
            image.header.nppbh = 8192;
            image.header.nppbv = 8192;
            file = nfx.File(header=file.header)+image;
            t.verifyEqual(file.header.clevel,7);
        end
        function paddedSizeCrossesOneGiB(t)
            [file,image] = fixtureFile(zeros(1,1,16,'uint8'),'MULTI');
            image.header.nppbh = 8192;
            image.header.nppbv = 8192;
            file = nfx.File(header=file.header)+image;
            t.verifyEqual(file.header.clevel,6);
        end
        function oversizedImageFailsWithoutAllocation(t)
            [file,image] = fixtureFile(zeros(1,1,200,'uint8'),'MULTI');
            image.header.nppbh = 8192;
            image.header.nppbv = 8192;
            file = nfx.File(header=file.header)+image;
            report = file.validate();
            t.verifyFalse(report.valid);
            t.verifyEqual(file.header.clevel,9);
            t.verifyTrue(any(strcmp({report.issues.id},'Length')));
            t.verifyError(@() file.write(fullfile(t.folder,'oversized.ntf')),'nfx:Invalid');
            t.verifyFalse(isfile(fullfile(t.folder,'oversized.ntf')));
        end
        function bandCountLimit(t)
            file = fixtureFile(zeros(1,1,100000,'uint8'),'MULTI');
            report = file.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'Bands')));
        end
    end
end
