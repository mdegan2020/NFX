classdef ContainerTest < NfxTest
    properties (TestParameter)
        invalidText = {42, uint8('text'), ["a" "b"], missing, ['a';'b'], char(233), char(9), char(0)}
        badLocation = {[0 0 0], single([0 0]), [-10000 0], [0 100000], [NaN 0], [0 0.5]}
        badComments = {42, repmat('x',10,1), repmat('x',1,81), missing, sprintf('line\nbreak')}
    end
    methods (Test)
        function mixedImagesTextAndDESHaveExactOrdering(t)
            [file, first] = fixtureFile(uint8([1 2;3 4]));
            [~, second] = fixtureFile(uint16([256 513 65535]));
            first.header.nppbh = 2; first.header.nppbv = 2;
            second.header.nppbh = 3; second.header.nppbv = 1;
            text = fixtureText(sprintf('one\ntwo\rthree\r\nfour'));
            des = nfx.DESSegment(uint8([0 128 255]), ...
                header=nfx.DESHeader(desid='SYNTHETIC_TEST', desclas='U', desshf=uint8([1 0])));
            file = nfx.File(header=file.header)+text+first+des+second;
            name = fullfile(t.folder,'mixed.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.hl, 442);
            t.verifyEqual(file.header.numi, 2);
            t.verifyEqual(file.header.numt, 1);
            t.verifyEqual(file.header.numdes, 1);
            t.verifyEqual(parsed.images(1).data, uint8([1 2 3 4]));
            t.verifyEqual(parsed.images(2).data, uint8([1 0 2 1 255 255]));
            t.verifyEqual(parsed.images(2).fields.idlvl, 2);
            t.verifyEqual(parsed.texts(1).data, uint8(sprintf('one\r\ntwo\r\nthree\r\nfour')));
            t.verifyEqual(parsed.des(1).data, uint8([0 128 255]));
            t.verifyEqual(parsed.des(1).fields.desshf, uint8([1 0]));
            t.verifyEqual(nitfread(name,1), first.data);
            t.verifyEqual(nitfread(name,2), second.data);
        end
        function textOnlyNeedsNoDummyImage(t)
            base = fixtureFile();
            text = fixtureText('manifest.ntf');
            file = nfx.File(header=base.header)+text+text;
            name = fullfile(t.folder,'text-only.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEmpty(parsed.images);
            t.verifyEqual(parsed.hl, 406);
            t.verifyEqual(numel(parsed.texts), 2);
            t.verifyEqual(parsed.texts(1).fields.textid, 'TEXT001');
            t.verifyEqual(parsed.texts(1).fields.txtdt, '20260915120000');
            t.verifyEqual(file.header.ltsh, [282 282]);
            t.verifyEqual(file.header.lt, [12 12]);
        end
        function textPayloadAndHeaderValidation(t)
            t.verifyFalse(fixtureText('').validate().valid);
            t.verifyTrue(fixtureText(repmat('a',1,99998)).validate().valid);
            t.verifyFalse(fixtureText(repmat('a',1,99999)).validate().valid);
            text = fixtureText();
            text.header.txtdt = '20260230120000';
            t.verifyFalse(text.validate().valid);
            text.header.txtdt = '--------------';
            text.header.tsclas = 'S';
            t.verifyFalse(text.validate().valid);
            text.header.tsclas = 'U';
            t.verifyTrue(text.validate().valid);
            t.verifyEqual(fixtureText(char(12)).lt, 1);
        end
        function textRejectsUnsupportedInput(t, invalidText)
            t.verifyError(@() nfx.TextSegment(invalidText), 'nfx:TextData');
        end
        function explicitAndAutomaticDisplayLevels(t)
            [base,image] = fixtureFile(uint8(1));
            explicit = image;
            explicit.header.idlvl = 1;
            file = nfx.File(header=base.header)+image+explicit+image;
            t.verifyEqual(file.images(1).header.idlvl, 2);
            t.verifyEqual(file.images(2).header.idlvl, 1);
            t.verifyEqual(file.images(3).header.idlvl, 3);
            t.verifyTrue(file.validate().valid);
            duplicated = file+explicit;
            t.verifyFalse(duplicated.validate().valid);
            explicit.header.idlvl = NaN;
            restored = file+explicit;
            t.verifyTrue(restored.validate().valid);
        end
        function imageAndTextAttachmentReferences(t)
            [base,image] = fixtureFile(uint8(1));
            image.header.iloc = [1 0];
            child = image;
            child.header.idlvl = 2;
            child.header.ialvl = 1;
            child.header.iloc = [-1 8193];
            text = fixtureText();
            text.header.txtalvl = 2;
            file = nfx.File(header=base.header)+child+image+text;
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.header.clevel, 6);
            name = fullfile(t.folder,'attached.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.images(1).fields.iloc, [-1 8193]);
            t.verifyEqual(parsed.images(1).fields.ialvl, 1);
            t.verifyEqual(parsed.texts(1).fields.txtalvl, 2);
            danglingImage = nfx.File(header=base.header)+child;
            danglingText = nfx.File(header=base.header)+image+text;
            t.verifyFalse(danglingImage.validate().valid);
            t.verifyFalse(danglingText.validate().valid);
            child.header.ialvl = 2;
            t.verifyFalse(child.validate().valid);
        end
        function absoluteDisplayPositionsCannotBeNegative(t)
            [base,image] = fixtureFile(uint8(1));
            image.header.iloc = [-1 0];
            outside = nfx.File(header=base.header)+image;
            report = outside.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'DisplayLocation')));
            t.verifyError(@() outside.write(fullfile(t.folder,'outside.ntf')), 'nfx:Invalid');
            image.header.iloc = [1 0];
            child = image;
            child.header.ialvl = 1;
            child.header.iloc = [-2 0];
            outside = nfx.File(header=base.header)+image+child;
            t.verifyFalse(outside.validate().valid);
            child.header.iloc = [-1 0];
            inside = nfx.File(header=base.header)+image+child;
            t.verifyTrue(inside.validate().valid);
        end
        function invalidDisplayLocation(t, badLocation)
            t.verifyError(@() nfx.ImageHeader(iloc=badLocation), 'nfx:Location');
        end
        function suppliedDecimalCornersAndComments(t)
            [base,image] = fixtureFile(uint8(1));
            image.header.iid1 = 'QUICK_LOOK';
            image.header.icords = 'D';
            image.header.igeolo = '+40.000-075.000+40.000-074.000+39.000-074.000+39.000-075.000';
            image.header.icom = ["Band 1: 0.650 micrometres"; "Red source band 1"];
            file = nfx.File(header=base.header)+image;
            name = fullfile(t.folder,'comments.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.images(1).fields.igeolo, image.header.igeolo);
            t.verifyEqual(parsed.images(1).fields.icom, image.header.icom);
            t.verifyEqual(file.header.lish, 1714);
            t.verifyEqual(nitfread(name), image.data);
            image.header.icom = '';
            t.verifyEqual(image.header.nicom, 0);
        end
        function cornerPrecisionAndInvalidRanges(t)
            [~,image] = fixtureFile(uint8(1));
            image.header.icords = 'G';
            image.header.igeolo = repmat('400000N0750000W',1,4);
            t.verifyTrue(image.validate().valid);
            image.header.igeolo = repmat('406000N0750000W',1,4);
            t.verifyFalse(image.validate().valid);
            image.header.igeolo = repmat('4000  N07500  W',1,4);
            t.verifyTrue(image.validate().valid);
            image.header.icords = 'D';
            image.header.igeolo = repmat('+90.001+180.000',1,4);
            t.verifyFalse(image.validate().valid);
            image.header.igeolo = repmat('+40.0  -075.   ',1,4);
            t.verifyTrue(image.validate().valid);
            image.header.icords = ' ';
            t.verifyFalse(image.validate().valid);
        end
        function commentsRejectBadShapesAndCharacters(t, badComments)
            t.verifyError(@() nfx.ImageHeader(icom=badComments), 'nfx:Comments');
        end
        function fileAndTextSnapshotRemovalAndPlacement(t)
            base = fixtureFile();
            tre = nfx.FREESA(5);
            text = fixtureText()+tre+tre;
            file = nfx.File(header=base.header)+text+tre+tre;
            tre.count = 9;
            text = text.removeTRE(1)+tre;
            file = file.removeTRE(1)+tre;
            t.verifyEqual(text.tre_ids, [2 3]);
            t.verifyEqual(file.tre_ids, [2 3]);
            t.verifyEqual(file.tre_tags, repmat('FREESA',2,1));
            t.verifyEqual(numel(file.texts(1).tre_records(1).payload), 5);
            t.verifyEqual(numel(file.tre_records(2).payload), 9);
            t.verifyError(@() text.removeTRE(1), 'nfx:UnknownAttachment');
            t.verifyError(@() file.removeTRE(1), 'nfx:UnknownAttachment');
            t.verifyError(@() plus(file,fixtureRPC()), 'nfx:TREPlacement');
            t.verifyError(@() plus(text,fixtureRPC()), 'nfx:TREPlacement');
            t.verifyError(@() plus(file,42), 'nfx:SegmentType');
        end
        function DESContainerDoesNotAcceptNumericConversion(t)
            t.verifyError(@() nfx.DESSegment([0 255]), 'nfx:Bytes');
            t.verifyError(@() nfx.DESHeader(desshf=[0 255]), 'nfx:Bytes');
            t.verifyFalse(nfx.DESSegment().validate().valid);
            header = nfx.DESHeader(desid='SYNTHETIC_TEST',desclas='U',desshf=zeros(1,9799,'uint8'));
            t.verifyFalse(nfx.DESSegment(uint8(0),header=header).validate().valid);
            header.desid = 'TRE_OVERFLOW';
            t.verifyFalse(header.validate().valid);
            t.verifyError(@() plus(nfx.File(),nfx.DESSegment(uint8(1),header=header)), 'nfx:DerivedOverflow');
        end
        function laterImageFailurePreservesExistingDestination(t)
            [file,image] = fixtureFile(uint8(1));
            secondStart = file.header.fl+16;
            file = file+image;
            name = fullfile(t.folder,'existing.ntf');
            putBytes(name,uint8('preserve'));
            handles = fileHandles();
            injectIOFailure(t,'fwrite',sprintf(['function count=fwrite(fid,data,varargin)\n' ...
                'if builtin(''ftell'',fid)>=%d, count=0;\n' ...
                'else, count=builtin(''fwrite'',fid,data,varargin{:}); end\nend\n'],secondStart));
            t.verifyError(@() file.write(name,Overwrite=true), 'nfx:WriteFailed');
            t.verifyEqual(readBytes(name),uint8('preserve'));
            t.verifyEqual(fileHandles(),handles);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function invalidLaterTextFailsBeforeOutput(t)
            file = fixtureFile()+fixtureText('');
            name = fullfile(t.folder,'new.ntf');
            t.verifyError(@() file.write(name), 'nfx:Invalid');
            t.verifyFalse(isfile(name));
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
    end
end
