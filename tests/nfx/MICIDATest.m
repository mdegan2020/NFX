classdef MICIDATest < NfxTest
    properties (TestParameter)
        example = num2cell(1:10)
    end
    methods (Test)
        function publishedExamplesHaveExactPayloads(t,example)
            examples = fixtureMIISExamples(); core = examples{example}; camera = syntheticUUID(1);
            value = nfx.MICIDA(cameras=nfx.MICIDA.camera(camera,core));
            expected = uint8(['01001' camera sprintf('%03.0f',numel(core)) core]);
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.payload(),expected);
            t.verifyEqual(value.bytes(),[uint8(sprintf('MICIDA%05.0f',numel(expected))) expected]);
            t.verifyEqual(value.miis_core_id_version,1); t.verifyEqual(value.num_camera_ids_in_tre,1);
            t.verifyEqual(value.core_id_length,numel(core));
            t.verifyEqual(nfx.MICIDA.coreIdentifier(hex2dec(core(3:4)),canonicalComponents(core)),core);
            t.verifyEqual(referenceMIISCheck(core(1:end-3)),core(end-1:end));
        end
        function publishedCheckAndWorkedExampleAreIndependentFixtures(t)
            t.verifyEqual(referenceMIISCheck('031FA3'),'79');
            core = '0170:F592-F023-7336-4AF8-AA91-62C0-0F2E-B2DA/16B7-4341-0008-41A0-BE36-5B5A-B96A-3645:D3';
            t.verifyEqual(nfx.MICIDA.coreIdentifier(112,canonicalComponents(core)),core);
            t.verifyTrue(nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(1),core)).validate().valid);
        end
        function mixedLengthsAndLetterCaseArePreserved(t)
            examples = fixtureMIISExamples(); selected = {lower(examples{6}),examples{2},examples{1}};
            cameras = repmat(nfx.MICIDA.camera('',''),1,3);
            expected = uint8('01003');
            for k = 1:3
                camera = lower(syntheticUUID(k)); cameras(k) = nfx.MICIDA.camera(string(camera),string(selected{k}));
                expected = [expected uint8([camera sprintf('%03.0f',numel(selected{k})) selected{k}])]; %#ok<AGROW>
            end
            value = nfx.MICIDA(cameras=cameras); t.verifyEqual(value.payload(),expected);
            t.verifyEqual(value.core_id_length,[47 87 127]); t.verifyEqual(value.cel,383);
            value.cameras(2).camera_core_id = string(examples{10}); t.verifyEqual(value.core_id_length,[47 47 127]);
        end
        function everyUsageByteIsCheckedAgainstComponentPresence(t)
            ids = {syntheticUUID(1),syntheticUUID(2),syntheticUUID(3)};
            for usage = 0:255
                count = (bitand(usage,96) ~= 0)+(bitand(usage,24) ~= 0)+(bitand(usage,4) ~= 0);
                allowed = usage == 2 || (usage > 0 && bitand(usage,131) == 0);
                if usage == 2, count = 1; end
                supplied = ids(1:max(count,1));
                if allowed
                    core = nfx.MICIDA.coreIdentifier(usage,supplied);
                    value = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(1),core));
                    t.verifyTrue(value.validate().valid); t.verifyEqual(numel(core),7+40*count);
                    t.verifyEqual(core(end-1:end),referenceMIISCheck(core(1:end-3)));
                else
                    t.verifyError(@() nfx.MICIDA.coreIdentifier(usage,supplied),'nfx:MIISCoreIdentifier');
                end
            end
            t.verifyError(@() nfx.MICIDA.coreIdentifier(2,ids(1:2)),'nfx:MIISCoreIdentifier');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(84,ids(1)),'nfx:MIISCoreIdentifier');
        end
        function punctuationVersionUsageAndChecksumErrorsFail(t)
            examples = fixtureMIISExamples(); core = examples{2}; invalid = {core(1:end-1)};
            positions = [5 numel(core)-2 10 45 6 2 4]; replacements = [' ' '-' '/' ':' 'G' '2' '1'];
            for k = 1:numel(positions)
                changed = core; changed(positions(k)) = replacements(k); invalid{end+1} = changed; %#ok<AGROW>
            end
            changed = core; changed(end) = '0'; invalid{end+1} = changed;
            changed = core; changed(end-1) = 'G'; invalid{end+1} = changed;
            changed = core; changed(1) = 'G'; invalid{end+1} = changed;
            for k = 1:numel(invalid)
                value = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(1),invalid{k}));
                t.verifyFalse(value.validate().valid); t.verifyError(@() value.payload(),'nfx:Invalid');
            end
        end
        function UUIDVersionsVariantsAndNonnullVersionOneNodeAreChecked(t)
            valid = {'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',syntheticUUID(1),'cd9a0ef2-24a6-5343-aa21-3cd6be881b52'};
            for k = 1:numel(valid)
                core = singleCore(valid{k}); value = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(k),core));
                t.verifyTrue(value.validate().valid);
            end
            invalid = {'f81d4fae-7dec-11d0-a765-000000000000', ...
                '00000000-0000-2000-8000-000000000001','00000000-0000-3000-8000-000000000001', ...
                '00000000-0000-6000-8000-000000000001','00000000-0000-4000-7000-000000000001', ...
                '00000000-0000-4000-c000-000000000001','00000000-0000-0000-0000-000000000000'};
            for k = 1:numel(invalid)
                core = singleCore(invalid{k}); value = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(k),core));
                t.verifyFalse(value.validate().valid);
                t.verifyError(@() nfx.MICIDA.coreIdentifier(2,invalid(k)),'nfx:MIISCoreIdentifier');
            end
        end
        function cameraAndCoreIdentitiesAreUniqueIgnoringLetterCase(t)
            examples = fixtureMIISExamples(); first = nfx.MICIDA.camera('abcdef01-1234-4000-8000-000000000001',examples{6});
            second = nfx.MICIDA.camera(upper(first.camera_id),examples{10});
            value = nfx.MICIDA(cameras=[first second]); report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'DuplicateCamera')));
            second.camera_id = syntheticUUID(2); second.camera_core_id = lower(first.camera_core_id);
            value.cameras = [first second]; report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'DuplicateCoreIdentifier')));
            value.cameras = first; value.cameras.camera_id = 'not-a-UUID'; t.verifyFalse(value.validate().valid);
        end
        function typedConstructionAndEmptyState(t)
            t.verifyFalse(nfx.MICIDA().validate().valid);
            t.verifyError(@() nfx.MICIDA(cameras=1),'nfx:MIISCameras');
            t.verifyError(@() nfx.MICIDA(cameras=struct('camera_id','x')),'nfx:MIISCameras');
            entry = nfx.MICIDA.camera('','');
            t.verifyError(@() nfx.MICIDA(cameras=repmat(entry,2,1)),'nfx:MIISCameras');
            t.verifyError(@() nfx.MICIDA.camera(1,'x'),'nfx:Text');
            t.verifyError(@() nfx.MICIDA.camera('x',true),'nfx:Text');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(single(2),{syntheticUUID(1)}),'nfx:Metadata');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(2,{}),'nfx:MIISComponents');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(2,repmat({syntheticUUID(1)},2,1)),'nfx:MIISComponents');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(2,{'x'}),'nfx:MIISCoreIdentifier');
            t.verifyError(@() nfx.MICIDA.coreIdentifier(2,{42}),'nfx:Text');
        end
        function cameraCountAndExactPayloadBoundary(t)
            cameras = cameraEntries(1000,0); value = nfx.MICIDA(cameras=cameras(1:999));
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.cel,85919);
            value.cameras = cameras; t.verifyFalse(value.validate().valid);
            value.cameras = cameraEntries(610,594); t.verifyEqual(value.cel,99985);
            t.verifyEqual(numel(value.bytes()),99996);
            value.cameras = cameraEntries(610,595); t.verifyFalse(value.validate().valid);
        end
        function attachmentSnapshotsRemovalAndFileOnlyPlacement(t)
            examples = fixtureMIISExamples(); value = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(1),examples{6}));
            original = value.payload(); file = fixtureFile()+value;
            value.cameras.camera_core_id = examples{10}; t.verifyEqual(file.tre_records.payload,original);
            file = file+value; t.verifyEqual(file.tre_ids,[1 2]);
            file = file.removeTRE(1); t.verifyEqual(file.tre_ids,2); t.verifyEqual(file.tre_records.payload,value.payload());
            t.verifyError(@() nfx.ImageSegment(zeros(2,2,'uint8'))+value,'nfx:TREPlacement');
            t.verifyError(@() fixtureText()+value,'nfx:TREPlacement');
            wrapper = nfx.FSYNWA()+value; t.verifyFalse(wrapper.validate().valid);
            t.verifyError(@() nfx.File()+wrapper,'nfx:Invalid');
        end
        function repeatedInstancesOverflowWholeAndWriteTextOnlyFiles(t)
            large = nfx.MICIDA(cameras=cameraEntries(610,594));
            examples = fixtureMIISExamples(); small = nfx.MICIDA(cameras=nfx.MICIDA.camera(syntheticUUID(1001),examples{10}));
            base = fixtureFile(); file = nfx.File(header=base.header)+fixtureText('image-i1.ntf')+small+large;
            name = fullfile(t.folder,'micida-manifest-container.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEmpty(parsed.images); t.verifyEqual(numel(parsed.texts),1); t.verifyEqual(numel(parsed.des),1);
            t.verifyEqual({parsed.allTRE.tag},{'MICIDA','MICIDA'}); t.verifyEqual(parsed.allTRE(2).payload,large.payload());
            t.verifyEqual(numel(parsed.tres),1); t.verifyEqual(parsed.des(1).fields.desoflw,'XHD');
            t.verifyEqual(parsed.des(1).fields.desitem,0);
            file = base+small; name = fullfile(t.folder,'micida-image.ntf'); file.write(name);
            t.verifyEqual(nitfread(name),base.images(1).data);
        end
    end
end

function value = syntheticUUID(index)
    %syntheticUUID - Supply deterministic version-4-shaped test identifiers
    value = sprintf('00000000-0000-4000-8000-%012.0f',index);
end

function values = canonicalComponents(core)
    %canonicalComponents - Read only known literal Appendix E fixture UUIDs
    values = strsplit(core(6:end-3),'/');
    for k = 1:numel(values)
        digits = strrep(values{k},'-','');
        values{k} = [digits(1:8) '-' digits(9:12) '-' digits(13:16) '-' digits(17:20) '-' digits(21:32)];
    end
end

function value = singleCore(uuid)
    %singleCore - Build a minor-ID fixture with an independent table check
    digits = upper(strrep(uuid,'-','')); groups = cellstr(reshape(digits,4,8).');
    prefix = ['0102:' strjoin(groups.','-')]; value = [prefix ':' referenceMIISCheck(prefix)];
end

function values = cameraEntries(count,longCount)
    %cameraEntries - Supply unique short/long core IDs for boundary tests
    values = repmat(nfx.MICIDA.camera('',''),1,count);
    for k = 1:count
        identifier = syntheticUUID(k);
        if k <= longCount
            core = nfx.MICIDA.coreIdentifier(124,{identifier,syntheticUUID(999998),syntheticUUID(999999)});
        else
            core = nfx.MICIDA.coreIdentifier(2,{identifier});
        end
        values(k) = nfx.MICIDA.camera(identifier,core);
    end
end
