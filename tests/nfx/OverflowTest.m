classdef OverflowTest < NfxTest
    methods (Test)
        function fullIndividualRecordMovesIntactToDES(t)
            [file,image] = fixtureFile(uint8(1));
            image = image.removeTRE(1)+nfx.FREESA(99985);
            file = nfx.File(header=file.header)+image;
            name = fullfile(t.folder,'whole-record.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEmpty(parsed.images(1).tres);
            t.verifyEqual(parsed.images(1).overflow, 1);
            t.verifyEqual(numel(parsed.des(1).data), 99996);
            t.verifyEqual(char(parsed.des(1).data(1:11)), 'FREESA99985');
            t.verifyEqual(parsed.des(1).data(12:end), repmat(uint8(255),1,99985));
            t.verifyEqual(parsed.des(1).fields.desoflw, 'IXSHD');
            t.verifyEqual(parsed.des(1).fields.desitem, 1);
            t.verifyEqual(file.header.lish, 442);
            t.verifyEqual(file.header.ldsh, 209);
            t.verifyEqual(nitfread(name), image.data);
        end
        function inlineImageAndFileBoundary(t)
            [file,image] = fixtureFile(uint8(1));
            image = image.removeTRE(1)+nfx.FREESA(99974);
            file = nfx.File(header=file.header)+image+nfx.FREESA(99974);
            name = fullfile(t.folder,'inline.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(file.header.numdes, 0);
            t.verifyEqual(file.header.hl, 100392);
            t.verifyEqual(file.header.lish, 100427);
            t.verifyEqual(numel(parsed.tres(1).payload), 99974);
            t.verifyEqual(numel(parsed.images(1).tres(1).payload), 99974);
            t.verifyEmpty(parsed.des);
        end
        function textHeaderAtAndBeyondMaximum(t)
            base = fixtureFile();
            first = fixtureText()+nfx.FREESA(9702);
            second = fixtureText()+nfx.FREESA(9703);
            file = nfx.File(header=base.header)+first+second;
            name = fullfile(t.folder,'text-boundary.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(file.header.ltsh, [9998 285]);
            t.verifyEqual(parsed.texts(1).overflow, 0);
            t.verifyEqual(parsed.texts(2).overflow, 1);
            t.verifyEqual(parsed.des(1).fields.desoflw, 'TXSHD');
            t.verifyEqual(parsed.des(1).fields.desitem, 2);
            t.verifyEqual(numel(parsed.texts(2).allTRE(1).payload), 9703);
        end
        function allOwnersAndExplicitDESMaintainIndices(t)
            [base,image] = fixtureFile(uint8(1));
            image = image+nfx.FREESA(99985)+nfx.FREESA(2);
            text = fixtureText()+nfx.FREESA(9702)+nfx.FREESA(1);
            explicit = nfx.DESSegment(uint8(7),header=nfx.DESHeader(desid='SYNTHETIC_TEST',desclas='U'));
            file = nfx.File(header=base.header)+image+text+explicit+nfx.FREESA(90000)+nfx.FREESA(10000);
            name = fullfile(t.folder,'owners.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual([parsed.overflow parsed.images(1).overflow parsed.texts(1).overflow], [2 3 4]);
            t.verifyEqual({parsed.images(1).allTRE.tag}, {'RPC00B','FREESA','FREESA'});
            t.verifyEqual(numel(parsed.images(1).tres), 1);
            t.verifyEqual(numel(parsed.des(3).tres), 2);
            t.verifyEqual(parsed.des(2).fields.desitem, 0);
            t.verifyEqual(parsed.des(2).fields.desoflw, 'XHD');
            t.verifyEqual(numel(file.des), 4);
            file = file.removeTRE(2);
            t.verifyEqual(numel(file.des), 3);
            t.verifyEqual(file.des(2).header.desoflw, 'IXSHD');
        end
        function overflowKeepsPrefixAndSuffixOrder(t)
            [base,image] = fixtureFile(uint8(1));
            image = image.removeTRE(1)+nfx.FREESA(99974)+nfx.FREESA(1)+nfx.FREESA(2);
            file = nfx.File(header=base.header)+image;
            first = fullfile(t.folder,'first.ntf');
            second = fullfile(t.folder,'second.ntf');
            file.write(first);
            file.write(second);
            parsed = inspectContainer(first);
            t.verifyEqual(cellfun(@numel,{parsed.images(1).allTRE.payload}), [99974 1 2]);
            t.verifyEqual(readBytes(first), readBytes(second));
        end
        function corruptOverflowReferenceIsDetected(t)
            file = fixtureFile()+nfx.FREESA(99985);
            name = fullfile(t.folder,'corrupt.ntf');
            file.write(name);
            data = readBytes(name);
            data(file.header.hl-2:file.header.hl) = uint8('002');
            putBytes(name,data);
            t.verifyError(@() inspectContainer(name), 'oracle:OverflowOwner');
        end
        function emptyTREPayloadIsRejected(t)
            t.verifyError(@() bytes(SyntheticTRE(zeros(1,0,'uint8'))), 'nfx:TRELength');
            t.verifyError(@() nfx.FREESA(99986), 'nfx:Metadata');
        end
    end
end
