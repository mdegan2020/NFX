classdef MIECollectionTest < NfxTest
    methods (Test)
        function largeCCSPositionsUseAnEarlierImageAnchor(t)
            collection = fixtureMIECollection();
            sets = collection.camera_sets.camera_sets;
            sets(1).cameras(1).iloc = [99999 0]; sets(1).cameras(2).iloc = [99999 0];
            collection.camera_sets.camera_sets = sets;
            report = collection.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'CameraPlacement')));
            collection.camera_sets.camera_sets = sets(1);
            collection.camera_ids.cameras = collection.camera_ids.cameras(1:2);
            collection.blocks = collection.blocks([1 2 3 5 6]);
            files = collection.plan(); image = files(2).file.images(3);
            t.verifyEqual(image.header.ialvl,1); t.verifyEqual(image.header.iloc,[99999 0]);
        end
        function excessivePerFileImageCountIsAStructuredFailure(t)
            collection = fixtureMIECollection(); templates = collection.blocks([1 3]);
            collection.intervals = nfx.TMINTA(struct('time_interval_index',1, ...
                'start_timestamp','20260915120000.000000000','end_timestamp','20260915130000.000000000'));
            blocks = repmat(templates(1),1,1000);
            for camera = 1:2
                for k = 1:500
                    block = templates(camera);
                    prefix = sprintf('2026091512%02.0f%02.0f',floor((k-1)/60),mod(k-1,60));
                    block.start_timestamp = [prefix '.000000000']; block.end_timestamp = [prefix '.250000000'];
                    block.timing.base_timestamp = block.start_timestamp;
                    blocks((camera-1)*500+k) = block;
                end
            end
            collection.blocks = blocks; report = collection.validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'CollectionImageCount')));
            t.verifyError(@() collection.write(t.folder),'nfx:Invalid'); t.verifyEmpty(dir(fullfile(t.folder,'*.ntf')));
        end
        function documentedCollectionExampleIsSelfContained(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'examples')));
            collection = mieExample(); files = collection.plan();
            t.verifyEqual(numel(files),5); t.verifyEqual(numel(files(1).file.images),1);
            paths = collection.write(t.folder); t.verifyEqual(numel(paths),5);
            manifest = inspectContainer(paths{end}); t.verifyEqual(numel(manifest.images),1);
            t.verifyEqual(nitfread(paths{end}),uint8([0 64;128 255]));
        end
        function plansCanonicalFileGroupsAndDerivedReferences(t)
            collection = fixtureMIECollection(); files = collection.plan();
            expected = {'synthetic.c0i0.ntf','synthetic.c1i1.ntf','synthetic.c2i1.ntf','synthetic.c1i2.ntf','synthetic.c2i2.ntf'};
            t.verifyEqual({files.filename},expected); t.verifyEqual([files.manifest],[true false false false false]);
            t.verifyEqual(arrayfun(@(f)numel(f.file.images),files),[0 3 1 2 1]);
            image = files(2).file.images(2); payload = image.tre_records(end).payload;
            t.verifyEqual(char(payload(1:3)),'002'); t.verifyEqual(char(payload(42:44)),'001');
            t.verifyEqual(char(payload(81:89)),'000001002');
            t.verifyEqual(image.header.idlvl,2); t.verifyEqual(image.header.iloc,[0 0]);
            t.verifyEqual(files(3).file.images.header.iloc,[5 0]);
            t.verifyEqual(collection.blocks(2).timing.image_seg_index,1);
            t.verifyEqual(collection.blocks(2).timing.temp_block_index,1);
            t.verifyFalse(any(strcmp(collection.blocks(2).image.tre_tags,'MTIMSA')));
        end
        function writtenFilesRecoverFramesAndTheExactManifest(t)
            collection = fixtureMIECollection(); files = collection.plan(); paths = collection.write(t.folder);
            t.verifyEqual(paths{end},fullfile(t.folder,files(1).filename));
            manifest = inspectContainer(paths{end});
            t.verifyEqual(manifest.clevel,3); t.verifyEmpty(manifest.images);
            t.verifyEqual(manifest.texts.fields.textid,'FILE001');
            t.verifyEqual(manifest.texts.fields.txtitl,['MIE4NITF Manifest File List' repmat(' ',1,53)]);
            expected = uint8(strjoin([{files.filename} {''}],char([13 10])));
            t.verifyEqual(manifest.texts.data,expected);
            blocks = {[1 2 3],4,[5 6],7};
            for k = 2:numel(files)
                parsed = inspectContainer(fullfile(t.folder,files(k).filename));
                t.verifyEqual(parsed.clevel,51);
                for j = 1:numel(parsed.images)
                    t.verifyEqual(decodeMotion(parsed.images(j),3),collection.blocks(blocks{k-1}(j)).image.data);
                end
                common = parsed.allTRE(~strcmp({parsed.allTRE.tag},'MTIMFA'));
                t.verifyEqual({common.tag},{manifest.allTRE.tag});
                t.verifyEqual({common.payload},{manifest.allTRE.payload});
            end
        end
        function manifestCanIncludeEveryMappingAndConsolidatesIntervals(t)
            collection = fixtureMIECollection(); collection.manifest_mtimfa = true;
            duplicate = collection.intervals; duplicate.intervals(1).start_timestamp = string(duplicate.intervals(1).start_timestamp);
            collection.intervals = [collection.intervals duplicate]; files = collection.plan();
            records = files(1).file.tre_records; interval = records(strcmp({records.tag},'TMINTA'));
            t.verifyEqual(numel(interval),1); t.verifyEqual(char(interval.payload(1:4)),'0002');
            actual = records(strcmp({records.tag},'MTIMFA')); expected = actual([]);
            for k = 2:numel(files)
                records = files(k).file.tre_records; expected = [expected records(strcmp({records.tag},'MTIMFA'))]; %#ok<AGROW>
            end
            t.verifyEqual({actual.payload},{expected.payload});
            collection.intervals(2).intervals(1).end_timestamp = '20260915120000.900000000';
            issue(t,collection,'ConflictingInterval');
        end
        function aSingleCameraSetOmitsTheCameraFilenameIndex(t)
            collection = fixtureMIECollection(); collection.camera_sets.camera_sets = collection.camera_sets.camera_sets(1);
            collection.camera_ids.cameras = collection.camera_ids.cameras(1:2);
            collection.blocks = collection.blocks([1 2 3 5 6]); files = collection.plan();
            t.verifyEqual({files.filename},{'synthetic.i0.ntf','synthetic.i1.ntf','synthetic.i2.ntf'});
            collection.manifest = false; files = collection.plan(); t.verifyEqual({files.filename},{'synthetic.i1.ntf','synthetic.i2.ntf'});
        end
        function unavailableBlocksKeepBlankImageReferences(t)
            collection = fixtureMIECollection(); collection.blocks(2).available = false; collection.blocks(2).image = nfx.ImageSegment();
            files = collection.plan(); t.verifyEqual(numel(files(2).file.images),2);
            records = files(2).file.tre_records; mapping = records(strcmp({records.tag},'MTIMFA')); data = mapping(1).payload;
            t.verifyEqual(char(data(136:138)),'001'); t.verifyEqual(char(data(187:189)),'   ');
            collection.blocks(4).available = false; collection.blocks(4).image = nfx.ImageSegment();
            issue(t,collection,'MissingBlockManifest'); collection.manifest_mtimfa = true;
            files = collection.plan(); t.verifyFalse(any(strcmp({files.filename},'synthetic.c2i1.ntf')));
        end
        function suppliedQuicklookIsCopiedWithItsAssociations(t)
            collection = fixtureMIECollection(); image = quicklook(collection); collection.quicklooks = image;
            files = collection.plan(); t.verifyEqual(numel(files(1).file.images),1);
            path = fullfile(t.folder,'manifest.ntf'); files(1).file.write(path); parsed = inspectContainer(path);
            t.verifyEqual(nitfread(path),image.data); t.verifyEqual(parsed.images.fields.imode,'B');
            t.verifyEqual(parsed.images.allTRE.payload(1:3),uint8('001'));
            collection.quicklooks = [image image]; issue(t,collection,'DuplicateQuicklook');
            collection.quicklooks = image; collection.quicklooks.header.icom = ''; issue(t,collection,'QuicklookComments');
        end
        function completePreflightProtectsAllDestinations(t)
            collection = fixtureMIECollection(); paths = collection.write(t.folder); original = readBytes(paths{1});
            collection.blocks(end).image.data = zeros(1,1,2,3,'uint16'); issue(t,collection,'CameraDimensions');
            t.verifyError(@() collection.write(t.folder,Overwrite=true),'nfx:Invalid');
            t.verifyEqual(readBytes(paths{1}),original);
            valid = fixtureMIECollection(); t.verifyError(@() valid.write(t.folder),'nfx:Exists');
            names = {dir(fullfile(t.folder,'*.ntf')).name}; t.verifyEqual(numel(names),5);
        end
        function definitionAndRelationshipFailuresAreExplicit(t)
            issue(t,nfx.MIECollection(),'CollectionDefinitions');
            c = fixtureMIECollection(); c.layers = [c.layers c.layers(1)]; issue(t,c,'DuplicateLayer');
            c = fixtureMIECollection(); c.camera_ids.cameras = c.camera_ids.cameras(1:2); issue(t,c,'CoreCameraCoverage');
            c = fixtureMIECollection(); c.blocks(1).timing.camera_id = 'FFFFFFFF-0000-4000-8000-000000000001'; issue(t,c,'BlockReference');
            c = fixtureMIECollection(); c.blocks(1).end_timestamp = '20260915120002.000000000'; issue(t,c,'BlockIntervalBounds');
            c = fixtureMIECollection(); c.blocks(2) = c.blocks(1); issue(t,c,'BlockOrder');
            c = fixtureMIECollection(); c.layers(1).min_frame_rate = NaN; issue(t,c,'CollectionRates');
        end
        function templatesKeepIndependentHeadersAndMetadata(t)
            c = fixtureMIECollection(); template = nfx.File(header=c.header)+nfx.FREESA(3);
            template.header.ftitle = 'Specific file';
            c.file_templates = struct('camera_set_index',1,'time_interval_index',2,'file',template);
            files = c.plan(); t.verifyEqual(files(4).file.header.ftitle,'Specific file');
            t.verifyEqual(files(4).file.tre_tags(1,:),'FREESA');
            c.file_templates = [c.file_templates c.file_templates]; issue(t,c,'DuplicateFileTemplate');
            c.file_templates = c.file_templates(1); c.file_templates.file = template+c.blocks(1).image;
            issue(t,c,'TemplateImages');
        end
        function inputTypesAndPortableNamesAreChecked(t)
            c = fixtureMIECollection(); c.base_name = '../escape'; issue(t,c,'CollectionName');
            c.base_name = 'CON'; issue(t,c,'CollectionName');
            t.verifyError(@() nfx.MIECollection(layers=42),'nfx:MIEObjects');
            t.verifyError(@() nfx.MIECollection(manifest=1),'nfx:LogicalScalar');
            t.verifyError(@() nfx.MIECollection(file_templates=struct('file',nfx.File())),'nfx:MIETemplates');
        end
    end
end

function image = quicklook(collection)
    image = collection.blocks(1).image; image.data = image.data(:,:,:,1);
    image.header.icom = 'First frame selected for collection overview.';
    timing = nfx.MTIMSA(image_seg_index=99,camera_set_index=0,time_interval_index=0,temp_block_index=0, ...
        nominal_frame_rate=0,base_timestamp='20260915120000.040000000',number_frames=1);
    image = image+timing;
end

function issue(t,collection,id)
    report = collection.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end
