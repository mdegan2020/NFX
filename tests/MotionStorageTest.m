classdef MotionStorageTest < NfxTest
    methods (Test)
        function nativeFramesPreserveBandsBlocksAndPadding(t)
            for type = {'uint8','uint16'}
                for bands = [1 2 3 10]
                    data = reshape(cast(mod(1:5*7*bands*3,251),type{1}),5,7,bands,3);
                    [file,image] = fixtureMotion(data); t.verifyTrue(file.validate().valid);
                    name = fullfile(t.folder,'frames.ntf'); file.write(name,Overwrite=true); parsed = inspectContainer(name);
                    t.verifyEqual(decodeMotion(parsed.images,3),data);
                    t.verifyEqual(numel(parsed.images.data),2*2*4*3*bands*3*(image.header.nbpp/8));
                    t.verifyEqual(parsed.images.fields.imode,image.header.imode);
                    t.verifyEqual(image.number_frames,3);
                    if bands == 1, t.verifyEqual(image.header.imode,'F'); else, t.verifyEqual(image.header.imode,'T'); end
                    t.verifyEqual(parsed.clevel,51+3*(bands > 9));
                end
            end
        end
        function exactTinyBlockByteSequence(t)
            data = zeros(1,3,2,2,'uint16');
            data(1,:,1,1) = [1 2 3]; data(1,:,2,1) = [11 12 13];
            data(1,:,1,2) = [21 22 23]; data(1,:,2,2) = [31 32 33];
            [base,image] = fixtureMotion(data); image.header.nppbh = 2; image.header.nppbv = 1;
            file = nfx.File(header=base.header)+image; name = fullfile(t.folder,'tiny.ntf'); file.write(name);
            parsed = inspectContainer(name);
            expected = [1 2 11 12 21 22 31 32 3 0 13 0 23 0 33 0];
            t.verifyEqual(parsed.images.data,reshape([zeros(size(expected));uint8(expected)],1,[]));
        end
        function stillImageModeAndLegacyReaderRemainAvailable(t)
            data = reshape(uint16(1:35),5,7); [file,image] = fixtureMotion(data);
            t.verifyEqual(image.header.imode,'B'); t.verifyEqual(file.header.clevel,3);
            name = fullfile(t.folder,'still.ntf'); file.write(name); t.verifyEqual(nitfread(name),data);
        end
        function laterFramesRefreshSignificantBitsAndMode(t)
            [~,image] = fixtureMotion(zeros(1,1,1,3,'uint16')); t.verifyEqual(image.header.abpp,1);
            image.data(1,1,1,3) = 32768; t.verifyEqual(image.header.abpp,16);
            image.data = uint8(3); t.verifyEqual(image.header.abpp,2); t.verifyEqual(image.header.imode,'B');
            t.verifyEqual(image.number_frames,1); t.verifyEqual(image.header.nbpp,8);
        end
        function timingCountsCategoryAndOwnerAreChecked(t)
            [base,image,timing] = fixtureMotion(); image = image.removeTRE(image.tre_ids(1));
            issue(t,image,'MotionTiming'); image.header.icat = 'MS'; image = image+timing; issue(t,image,'MotionCategory');
            image.header.icat = 'MS.M'; image = image.removeTRE(image.tre_ids(1)); timing.number_frames = 2;
            image = image+timing; issue(t,image,'MotionFrameCount');
            timing.number_frames = 3; timing.image_seg_index = 2; image = image.removeTRE(image.tre_ids(1))+timing;
            issue(t,nfx.File(header=base.header)+image,'MotionSegmentIndex');
            image = image+timing; issue(t,image,'MotionTiming');
        end
        function motionComplexityAccountsForEverySegment(t)
            [base,image] = fixtureMotion(zeros(8193,1,1,2,'uint8')); image.header.nppbv = 8;
            file = nfx.File(header=base.header)+image; t.verifyEqual(file.header.clevel,54); t.verifyTrue(file.validate().valid);
            image.data = zeros(65537,1,1,2,'uint8');
            file = nfx.File(header=base.header)+image; t.verifyEqual(file.header.clevel,57); t.verifyTrue(file.validate().valid);
            [~,image] = fixtureMotion(zeros(1,1,256,2,'uint8'));
            file = nfx.File(header=base.header)+image; t.verifyEqual(file.header.clevel,57);
            image.data = zeros(1,1,1000,2,'uint8'); file = nfx.File(header=base.header)+image; issue(t,file,'MotionComplexity');
            [~,image] = fixtureMotion(); [~,still] = fixtureFile(uint8(1)); still.header.iloc = [0 9000];
            file = nfx.File(header=base.header)+image+still; t.verifyEqual(file.header.clevel,54); t.verifyTrue(file.validate().valid);
        end
        function invalidMotionPreservesExistingDestination(t)
            [file,image] = fixtureMotion(); name = fullfile(t.folder,'existing.ntf'); file.write(name); before = readBytes(name);
            image.data = image.data(:,:,:,1:2); invalid = nfx.File(header=file.header)+image;
            t.verifyError(@() invalid.write(name,Overwrite=true),'nfx:Invalid'); t.verifyEqual(readBytes(name),before);
        end
    end
end

function issue(t,item,id)
    report = item.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end
