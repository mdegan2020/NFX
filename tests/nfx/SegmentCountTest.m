classdef SegmentCountTest < NfxTest
    properties (TestParameter)
        imageCase = {struct('count',20,'level',3),struct('count',21,'level',5), ...
            struct('count',100,'level',5),struct('count',101,'level',9)}
        desCase = {struct('count',10,'level',3),struct('count',11,'level',6), ...
            struct('count',50,'level',6),struct('count',51,'level',7), ...
            struct('count',100,'level',7),struct('count',101,'level',9)}
        textCase = {struct('count',32,'level',3),struct('count',33,'level',9)}
    end
    methods (Test)
        function imageCountComplexity(t, imageCase)
            [~,image] = fixtureFile(uint8(1));
            file = repeatSegment(image,imageCase.count);
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.header.clevel,imageCase.level);
        end
        function desCountComplexity(t, desCase)
            des = nfx.DESSegment(uint8(0),header=nfx.DESHeader(desid='SYNTHETIC_TEST',desclas='U'));
            file = repeatSegment(des,desCase.count);
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.header.clevel,desCase.level);
        end
        function textCountComplexity(t, textCase)
            file = repeatSegment(fixtureText(),textCase.count);
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.header.clevel,textCase.level);
        end
        function explicitAndDerivedDESCountsRespectTheSameLimit(t)
            des = nfx.DESSegment(uint8(0),header=nfx.DESHeader(desid='SYNTHETIC_TEST',desclas='U'));
            file = repeatSegment(des,999);
            t.verifyError(@() plus(file,des), 'nfx:DESCount');
            file = file+nfx.FREESA(99985);
            t.verifyEqual(file.header.numdes,1000);
            t.verifyFalse(file.validate().valid);
            t.verifyError(@() file.write(fullfile(t.folder,'too-many.ntf')), 'nfx:Invalid');
        end
        function textCountLimit(t)
            text = fixtureText();
            file = repeatSegment(text,999);
            t.verifyError(@() plus(file,text), 'nfx:TextCount');
        end
    end
end
