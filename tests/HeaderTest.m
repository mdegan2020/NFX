classdef HeaderTest < NfxTest
    properties (TestParameter)
        badText = {42, NaN, missing, ["a" "b"], ['a'; 'b'], sprintf('a\nb'), char(233)}
        badDate = {'', '20260229120000', '20260931120000', '20260001120000', ...
            '20260101240000', '20260101126000', '20260101120060', '2026-101120000', ...
            '20261301120000', 'abcdefghijklmN', '19000229120000'}
        goodDate = {'20260915120000','20000229120000','2024----------','--------------','--470214------'}
        badBlock = {0, -1, 8193, 1.5, Inf, single(4), '4', [4 4], 2+1i}
        color = {[1 2], [1 2 256], [1 -1 2], [1 1.5 2], [1 NaN 2], uint8([1 2 3]), 1i*[1 2 3]}
    end
    methods (Test)
        function strictASCII(t, badText)
            t.verifyError(@() nfx.FileHeader(ostaid=badText), 'nfx:Text');
            t.verifyError(@() nfx.ImageHeader(iid1=badText), 'nfx:Text');
        end
        function textWidthAndTypes(t)
            header = nfx.FileHeader(ostaid="NFX", fdt='20260915120000', fsclas='U');
            encoded = header.bytes();
            t.verifyEqual(char(encoded(16:25)), 'NFX       ');
            t.verifyError(@() nfx.FileHeader(ostaid='TOO-LONG-ID'), 'nfx:Text');
            t.verifyError(@() nfx.ImageHeader(iid2=repmat('x',1,81)), 'nfx:Text');
        end
        function invalidTimestamp(t, badDate)
            [file, segment] = fixtureFile();
            file.header.fdt = badDate;
            segment.header.idatim = badDate;
            t.verifyFalse(file.validate().valid);
            t.verifyFalse(segment.validate().valid);
        end
        function validUnknownAndLeapDate(t, goodDate)
            [file, segment] = fixtureFile();
            file.header.fdt = goodDate;
            segment.header.idatim = goodDate;
            t.verifyTrue(file.validate().valid);
            t.verifyTrue(segment.validate().valid);
        end
        function invalidBlock(t, badBlock)
            t.verifyError(@() nfx.ImageHeader(nppbh=badBlock), 'nfx:Metadata');
        end
        function blockSizeCannotBeUnset(t)
            t.verifyError(@() nfx.ImageHeader(nppbh=NaN), 'MATLAB:validators:mustBeFinite');
        end
        function backgroundIsDoubleMetadata(t, color)
            t.verifyError(@() nfx.FileHeader(fbkgc=color), 'nfx:Color');
        end
        function missingFieldsAndUnsupportedClassification(t)
            file = nfx.File();
            report = file.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.field}, 'header.ostaid')));
            t.verifyTrue(any(strcmp({report.issues.field}, 'header.fsclas')));
            t.verifyTrue(any(strcmp({report.issues.id}, 'SegmentCount')));
            t.verifyError(@() file.header.bytes(), 'nfx:Invalid');
        end
        function copyTracking(t)
            file = fixtureFile();
            file.header.fscop = 10;
            file.header.fscpys = 9;
            t.verifyFalse(file.validate().valid);
            file.header.fscpys = 10;
            t.verifyTrue(file.validate().valid);
        end
        function derivedDimensionsAndReplacement(t)
            segment = nfx.ImageSegment(zeros(1025, 1027, 2, 'uint16'));
            t.verifyEqual([segment.header.nrows segment.header.ncols], [1025 1027]);
            t.verifyEqual([segment.header.nbands segment.header.nbpp segment.header.abpp], [2 16 1]);
            t.verifyEqual([segment.header.nbpr segment.header.nbpc], [2 2]);
            segment.header.nppbh = 500;
            segment.header.nppbv = 400;
            t.verifyEqual([segment.header.nbpr segment.header.nbpc], [3 3]);
            segment.data = zeros(4, 7, 12, 'uint8');
            t.verifyEqual([segment.header.nrows segment.header.ncols segment.header.nbpp], [4 7 8]);
            t.verifyEqual(segment.header.nbands, 0);
            t.verifyEqual(segment.header.xbands, 12);
            t.verifyEqual(segment.header.abpp, 1);
        end
        function replacingHeaderCannotLeaveStaleShape(t)
            segment = nfx.ImageSegment(zeros(2, 3, 'uint8'));
            segment.header = nfx.ImageHeader(nppbh=1,nppbv=1);
            t.verifyEqual([segment.header.nrows segment.header.ncols segment.header.nbpr], [2 3 3]);
            t.verifyError(@() assignProperty(segment.header, 'nrows', 99), 'MATLAB:class:SetProhibited');
        end
        function bitWidthsAndJustification(t)
            [~, segment] = fixtureFile();
            segment.header.abpp = 8;
            t.verifyFalse(segment.validate().valid);
            segment.header.abpp = NaN;
            segment.header.pjust = 'X';
            t.verifyFalse(segment.validate().valid);
            segment.header.pjust = 'L';
            t.verifyTrue(segment.validate().valid);
            t.verifyEqual(segment.header.abpp, 16);
        end
        function oversizedRawExtensionIsRejected(t)
            [~, segment] = fixtureFile();
            t.verifyError(@() segment.header.bytes(zeros(1,99986,'uint8')), 'nfx:TREOverflow');
        end
        function representationsAndCategories(t)
            [~, segment] = fixtureFile();
            segment.header.irep = 'RGB';
            t.verifyFalse(segment.validate().valid);
            segment.header.irep = 'MONO';
            segment.header.icat = 'BOGUS';
            t.verifyFalse(segment.validate().valid);
            segment.header.icat = 'VIS';
            segment.header.isclas = 'S';
            t.verifyFalse(segment.validate().valid);
        end
        function headerLengthWithoutTRE(t)
            [~, image] = fixtureFile();
            image = image.removeTRE(image.tre_ids(1));
            encoded = image.header.bytes();
            t.verifyEqual(numel(encoded), 439);
            t.verifyEqual(image.lish, 439);
            t.verifyEqual(char(encoded(end-9:end)), '0000000000');
        end
        function oversizedBlockCount(t)
            [~, image] = fixtureFile(zeros(1, 10000, 'uint8'));
            image.header.nppbh = 1;
            t.verifyFalse(image.validate().valid);
        end
    end
end
