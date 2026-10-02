classdef CollectionContextTest < NfxTest
    methods (Test)
        function temporalBlocksMaySelectEveryCameraWithoutAnExplicitCM(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = hierarchy('CS','1','TI','1',nfx.CONTXA(context_type='TB',index_list='1')+rpc);
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            files = collection.plan(); t.verifyEqual(model(files(2).file,1),rpc.payload());
            t.verifyEmpty(model(files(2).file,2)); t.verifyEqual(model(files(2).file,3),rpc.payload());
        end
        function manifestMetadataResolvesThroughCompleteHierarchy(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = hierarchy('CS','1','TI','1', ...
                hierarchy('CM','1','TB','1',rpc));
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            files = collection.plan();
            t.verifyEmpty(model(files(2).file,2)); t.verifyEmpty(model(files(2).file,3));
            t.verifyEqual(model(files(2).file,1),rpc.payload());
            records = files(2).file.effectiveTREs(1);
            t.verifyEqual(records(strcmp({records.tag},'RPC00B')).file_index,1);
            for k = 3:numel(files), t.verifyEmpty(model(files(k).file,1)); end
            t.verifyTrue(files(2).file.validate().valid);
            collection.manifest_template = nfx.File(header=collection.header);
            t.verifyEqual(model(files(2).file,1),rpc.payload());
            file = files(2).file+nfx.FREESA(1);
            report = file.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'CollectionContextChanged')));
        end
        function orthogonalHierarchyAndOpenRangesSelectRuntimeCameras(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = hierarchy('TI','1-','CS','1',hierarchy('CM','1-','TB','1',rpc));
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            files = collection.plan();
            t.verifyEqual(model(files(2).file,1),rpc.payload());
            t.verifyEmpty(model(files(2).file,2));
            t.verifyEqual(model(files(2).file,3),rpc.payload());
            t.verifyEqual(model(files(4).file,1),rpc.payload());
            t.verifyEqual(model(files(4).file,2),rpc.payload());
        end
        function standaloneImageryUsesLocalBlockMappings(t)
            collection = fixtureMIECollection(); files = collection.plan();
            rpc = fixtureRPC(); file = files(2).file+hierarchy('CM','2','TB','1',rpc);
            t.verifyTrue(file.validate().valid);
            t.verifyEmpty(model(file,1)); t.verifyEmpty(model(file,2)); t.verifyEqual(model(file,3),rpc.payload());
        end
        function collectionContextBoundsAndManifestCameraZeroFail(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrappers = {hierarchy('CS','3','TI','1',nfx.FREESA(1)), ...
                hierarchy('CS','1','TI','3',nfx.FREESA(1)), ...
                hierarchy('CS','2','CM','2',nfx.FREESA(1)), ...
                hierarchy('CS','1','TI','1',hierarchy('CM','2','TB','2',rpc)), ...
                nfx.CONTXA(context_type='CM',index_list='1')+nfx.FREESA(1)};
            for k = 1:numel(wrappers)
                collection.manifest_template = nfx.File(header=collection.header)+wrappers{k};
                report = collection.validate(); t.verifyFalse(report.valid);
                t.verifyTrue(any(strcmp({report.issues.id},'CollectionContextBounds')));
            end
        end
        function foreignImageryFileCanSupplyAReferencedBlockModel(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = hierarchy('CS','2','TI','2',hierarchy('CM','1','TB','1',rpc));
            collection.file_templates = struct('camera_set_index',1,'time_interval_index',1, ...
                'file',nfx.File(header=collection.header)+wrapper);
            files = collection.plan();
            t.verifyEqual(model(files(5).file,1),rpc.payload());
            t.verifyEmpty(model(files(2).file,1));
            collection.write(t.folder);
            parsed = inspectContainer(fullfile(t.folder,files(2).filename));
            t.verifyTrue(any(strcmp({parsed.allTRE.tag},'CONTXA')));
        end
        function conflictingFilesDoNotInventAnOverrideOrder(t)
            collection = fixtureMIECollection(); first = fixtureRPC(); second = first; second.line_off = 7;
            collection.blocks(1).image = collection.blocks(1).image+first;
            wrapper = hierarchy('CS','1','TI','1',hierarchy('CM','1','TB','1',second));
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            report = collection.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'CrossFilePrecedence')));
            t.verifyError(@() collection.write(t.folder),'nfx:Invalid'); t.verifyEmpty(dir(fullfile(t.folder,'*.ntf')));
            wrapper = hierarchy('CS','1','TI','1',hierarchy('CM','1','TB','1',first));
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            files = collection.plan(); t.verifyEqual(model(files(2).file,1),first.payload());
        end
        function cameraRootCanSelectAnotherIntervalAndBlock(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = hierarchy('CM','1','TI','2', ...
                nfx.CONTXA(context_type='TB',index_list='1')+rpc);
            collection.file_templates = struct('camera_set_index',1,'time_interval_index',1, ...
                'file',nfx.File(header=collection.header)+wrapper);
            files = collection.plan();
            t.verifyEqual(model(files(4).file,1),rpc.payload());
            t.verifyEmpty(model(files(4).file,2));
            for k = [2 3 5]
                for j = 1:numel(files(k).file.images), t.verifyEmpty(model(files(k).file,j)); end
            end
            wrapper = hierarchy('CM','1','TI','2', ...
                nfx.CONTXA(context_type='TB',index_list='2')+rpc);
            collection.file_templates.file = nfx.File(header=collection.header)+wrapper;
            report = collection.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'CollectionContextBounds')));
        end
        function cameraRootInheritsHeaderMetadataOnlyWithinItsSourceSet(t)
            collection = fixtureMIECollection(); leaf = nfx.FREESA(17);
            wrapper = hierarchy('CM','1','TI','2',leaf);
            collection.file_templates = struct('camera_set_index',1,'time_interval_index',1, ...
                'file',nfx.File(header=collection.header)+wrapper);
            files = collection.plan();
            for k = 2:numel(files)
                for j = 1:numel(files(k).file.images)
                    [records,header] = files(k).file.effectiveTREs(j);
                    t.verifyEmpty(records(strcmp({records.tag},'FREESA')));
                    found = header(strcmp({header.tag},'FREESA'));
                    if k == 4 && j == 1
                        t.verifyEqual(found.payload,leaf.payload()); t.verifyEqual(found.file_index,2);
                    else
                        t.verifyEmpty(found);
                    end
                end
            end
        end
        function foreignFrameBoundsAreCheckedAtTheTarget(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            frames = nfx.CONTXA(context_type='FR',index_list='4')+rpc;
            wrapper = hierarchy('CS','1','TI','1',hierarchy('CM','1','TB','1',frames));
            collection.manifest_template = nfx.File(header=collection.header)+wrapper;
            report = collection.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'ContextBounds')));
        end
    end
end

function value = hierarchy(first,firstIndices,second,secondIndices,leaf)
    %hierarchy - Build an explicit two-level association for synthetic tests
    value = nfx.CONTXA(context_type=first,index_list=firstIndices)+ ...
        (nfx.CONTXA(context_type=second,index_list=secondIndices)+leaf);
end

function value = model(file,image)
    %model - Select effective RPC bytes from a collection image
    records = file.effectiveTREs(image); value = [records(strcmp({records.tag},'RPC00B')).payload];
end
