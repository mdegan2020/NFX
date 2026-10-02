classdef MIEManifestTest < NfxTest
    methods (Test)
        function fileListSplitsAtWholeEntriesUsingNormativeIDs(t)
            c = longCollection(); files = c.plan(); manifest = files(1).file;
            t.verifyEqual(numel(manifest.texts),2);
            t.verifyEqual(manifest.texts(1).header.textid,'FILE001');
            t.verifyEqual(manifest.texts(2).header.textid,'FILE002');
            actual = ''; names = {files.filename};
            for k = 1:numel(manifest.texts)
                text = manifest.texts(k); t.verifyLessThanOrEqual(text.lt,99998);
                t.verifyTrue(endsWith(text.data,char([13 10]))); actual = [actual text.data]; %#ok<AGROW>
            end
            t.verifyEqual(actual,strjoin([names {''}],char([13 10])));
            path = fullfile(t.folder,'split-manifest.ntf'); manifest.write(path); parsed = inspectContainer(path);
            t.verifyEqual([parsed.texts.data],uint8(actual)); t.verifyEqual(numel(parsed.texts),2);
        end
        function laterPublicationFailureReportsCompletedFiles(t)
            c = fixtureMIECollection(); files = c.plan();
            first = fullfile(t.folder,files(2).filename); second = fullfile(t.folder,files(3).filename);
            manifest = fullfile(t.folder,files(1).filename);
            putBytes(second,uint8('protected later file')); putBytes(manifest,uint8('existing manifest'));
            fileattrib(second,'-w'); t.addTeardown(@() fileattrib(second,'+w'));
            try
                c.write(t.folder,Overwrite=true); t.assertFail('Expected a later publication failure.');
            catch exception
                t.verifyEqual(exception.identifier,'nfx:CollectionWrite');
                t.verifyTrue(contains(exception.message,'Already published (1)'));
                t.verifyTrue(contains(exception.message,first)); t.verifyTrue(contains(exception.message,second));
            end
            t.verifyTrue(isfile(first)); parsed = inspectContainer(first); t.verifyEqual(numel(parsed.images),3);
            t.verifyEqual(readBytes(second),uint8('protected later file'));
            t.verifyEqual(readBytes(manifest),uint8('existing manifest'));
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function destinationPreflightRunsForEveryPlannedFile(t)
            c = fixtureMIECollection(); files = c.plan();
            mkdir(fullfile(t.folder,files(end).filename));
            t.verifyError(@() c.write(t.folder),'nfx:Destination');
            t.verifyFalse(isfile(fullfile(t.folder,files(2).filename)));
            t.verifyError(@() c.write(fullfile(t.folder,'missing')),'nfx:Destination');
        end
        function metadataOnlyManifestRepresentsEmptyScheduledIntervals(t)
            c = fixtureMIECollection(); c.blocks = nfx.MotionBlock.empty(1,0);
            c.intervals.intervals(1).start_timestamp = ''; c.intervals.intervals(1).end_timestamp = '';
            files = c.plan(); t.verifyEqual(numel(files),1); t.verifyEmpty(files.file.images);
            paths = c.write(t.folder); t.verifyEqual(numel(paths),1);
            c.manifest = false; report = c.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'EmptyCollection')));
        end
        function unavailableOnlyGroupsAreRetainedInTheManifest(t)
            c = fixtureMIECollection(); c.manifest_mtimfa = true;
            for k = 1:numel(c.blocks), c.blocks(k).available = false; c.blocks(k).image = nfx.ImageSegment(); end
            files = c.plan(); t.verifyEqual(numel(files),1); records = files.file.tre_records;
            mappings = records(strcmp({records.tag},'MTIMFA')); t.verifyEqual(numel(mappings),6);
            path = fullfile(t.folder,'missing-manifest.ntf'); files.file.write(path);
            parsed = inspectContainer(path); t.verifyEmpty(parsed.images);
        end
    end
end

function c = longCollection()
    c = fixtureMIECollection(); c.base_name = repmat('b',1,240);
    c.layers = c.layers(1); c.camera_sets.camera_sets = struct('cameras',c.camera_sets.camera_sets(1).cameras(1));
    c.camera_ids.cameras = c.camera_ids.cameras(1); block = c.blocks(1);
    count = 420; c.blocks = repmat(block,1,count);
    windows = repmat(c.intervals.intervals(1),1,count);
    base = datetime(2026,9,15,12,0,0,'Format','yyyyMMddHHmmss');
    for k = 1:count
        prefix = char(base+seconds(k-1)); finish = char(base+seconds(k));
        windows(k) = struct('time_interval_index',k,'start_timestamp',[prefix '.000000000'], ...
            'end_timestamp',[finish '.000000000']);
        c.blocks(k).timing.time_interval_index = k; c.blocks(k).timing.base_timestamp = windows(k).start_timestamp;
        c.blocks(k).start_timestamp = windows(k).start_timestamp; c.blocks(k).end_timestamp = [prefix '.250000000'];
    end
    c.intervals = nfx.TMINTA(windows);
end
