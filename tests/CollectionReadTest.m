classdef CollectionReadTest < NfxTest
    properties (TestParameter)
        variation = {'ordinary', 'manifestMappings', 'unavailable', ...
            'allUnavailable', 'metadataOnly', 'quicklook', 'interleaved', 'templates'}
        contextSource = {'manifest', 'imagery'}
        largeField = {'delta', 'multiplier'}
        invalidSource = {42, [], '', "", missing, {42}, {''}, ['a'; 'b'], char(0)}
        invalidLimit = {0, -1, 1.5, Inf, NaN, single(1), [1 2], 1i}
        damage = {'definitions', 'mapping', 'timing', 'listID', 'listPath', ...
            'listDuplicate', 'listMissing', 'layer', 'filename'}
    end
    methods (Test)
        function timingAboveFlintmaxRemainsExact(t, largeField)
            source = fixtureMIECollection(); source.blocks = source.blocks(1);
            first = '20260101000000.000000001'; last = '20270101000000.000000001';
            source.intervals = nfx.TMINTA(struct('time_interval_index', 1, ...
                'start_timestamp', first, 'end_timestamp', last));
            source.blocks.image.data = source.blocks.image.data(:,:,:,1);
            source.blocks.start_timestamp = first; source.blocks.end_timestamp = last;
            source.blocks.timing.base_timestamp = first;
            exact = bitshift(uint64(1), 53) + uint64(7);
            source.blocks.timing.dt = exact; source.blocks.timing.dt_multiplier = uint64(1);
            if strcmp(largeField, 'multiplier')
                source.blocks.timing.dt = uint64(1); source.blocks.timing.dt_multiplier = exact;
            end
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.blocks.timing.dt, source.blocks.timing.dt);
            t.verifyEqual(copy.blocks.timing.dt_multiplier, source.blocks.timing.dt_multiplier);
            t.verifyEqual(copy.blocks.timing.base_timestamp, first);
        end

        function writerVariantsRoundTrip(t, variation)
            source = readerCollection(variation);
            original = source.plan(); paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message); t.verifyTrue(copy.validate().valid);
            actual = copy.plan(); verifyPlans(t, original, actual);
            output = fullfile(t.folder, 'copy'); mkdir(output); copy.write(output);
            for k = 1:numel(original)
                name = original(k).filename;
                t.verifyEqual(readBytes(fullfile(output, name)), readBytes(fullfile(t.folder, name)));
            end
            t.verifyEqual(nnz(~[copy.blocks.available]), nnz(~[source.blocks.available]));
            if ~isempty(copy.blocks)
                available = find([copy.blocks.available], 1);
                if ~isempty(available)
                    t.verifyClass(copy.blocks(available).timing.dt, 'uint64');
                    copy.blocks(available).image.header.icom = 'Independent edit';
                    t.verifyNotEqual(copy.blocks(available).image.header.icom, ...
                        source.blocks(available).image.header.icom);
                end
            end
        end

        function explicitListsAllowAnyOrderAndNoManifest(t)
            source = fixtureMIECollection(); source.manifest = false;
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(string(paths(end:-1:1)));
            t.assertTrue(ok, status.message); t.verifyFalse(copy.manifest);
            verifyPlans(t, source.plan(), copy.plan());
            [copy, ok, status] = nfx.MIECollection.read(paths(end:-1:1));
            t.assertTrue(ok, status.message); verifyPlans(t, source.plan(), copy.plan());
        end

        function completeContextsRestoreForeignFrameMetadata(t, contextSource)
            source = fixtureMIECollection(); rpc = fixtureRPC();
            leaf = nfx.CONTXA(context_type='FR', index_list='2-3') + rpc;
            wrapper = hierarchy('CS', '2', 'TI', '2', ...
                hierarchy('CM', '1', 'TB', '1', leaf));
            template = nfx.File(header=source.header) + wrapper;
            if strcmp(contextSource, 'manifest'), source.manifest_template = template;
            else
                source.file_templates = struct('camera_set_index', 1, ...
                    'time_interval_index', 1, 'file', template);
            end
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message); verifyPlans(t, source.plan(), copy.plan());
            planned = copy.plan(); file = planned(end).file;
            records = file.effectiveTREs(1, 1);
            t.verifyEmpty(records(strcmp({records.tag}, 'RPC00B')));
            values = file.effectiveTREs(1, 2); selected = values(strcmp({values.tag}, 'RPC00B'));
            t.verifyEqual(selected.payload, rpc.payload());
            for k = 1:numel(paths)
                [single, ok, status] = nfx.File.read(paths{k});
                t.assertTrue(ok, status.message);
                t.verifyFalse(single.context_complete); t.verifyFalse(status.context_complete);
                report = single.validate(); t.verifyFalse(report.valid);
                t.verifyTrue(any(strcmp({report.issues.id}, 'CollectionContextRequired')));
                if ~isempty(single.images)
                    t.verifyError(@() single.effectiveTREs(1), 'nfx:CollectionContextRequired');
                end
            end
        end

        function missingRequiredFileIsNotAnUnavailableBlock(t)
            source = readerCollection('unavailable'); paths = source.write(t.folder);
            delete(paths{1});
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MissingFile');
            t.verifyEqual(status.path, paths{1}); t.verifyEmpty(copy.blocks);
        end

        function aggregateLimitsAreExact(t)
            source = fixtureMIECollection(); paths = source.write(t.folder);
            bytes = 0; pixels = 0; planned = source.plan();
            for k = 1:numel(paths), info = dir(paths{k}); bytes = bytes + info.bytes; end
            for k = 1:numel(planned)
                for image = planned(k).file.images, pixels = pixels + numel(image.data); end
            end
            [copy, ok, status] = nfx.MIECollection.read(paths{end}, ...
                MaxBytes=bytes, MaxPixels=pixels, MaxFiles=numel(paths));
            t.assertTrue(ok, status.message); t.verifyNumElements(copy.blocks, 7);
            [~, ok, status] = nfx.MIECollection.read(paths{end}, MaxBytes=bytes - 1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            [~, ok, status] = nfx.MIECollection.read(paths{end}, MaxPixels=pixels - 1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
            [~, ok, status] = nfx.MIECollection.read(paths{end}, MaxFiles=numel(paths) - 1);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'ResourceLimit');
        end

        function invalidSourcesUseDiagnostics(t, invalidSource)
            [copy, ok, status] = nfx.MIECollection.read(invalidSource);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput'); t.verifyEmpty(copy.blocks);
        end

        function invalidLimitsUseDiagnostics(t, invalidLimit)
            [~, ok, status] = nfx.MIECollection.read('unused', MaxBytes=invalidLimit);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.MIECollection.read('unused', MaxPixels=invalidLimit);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
            [~, ok, status] = nfx.MIECollection.read('unused', MaxFiles=invalidLimit);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidInput');
        end

        function conflictingFilesAndBrokenIndicesFail(t, damage)
            source = fixtureMIECollection(); paths = source.write(t.folder);
            target = paths{1}; raw = readBytes(target); input = paths{end};
            switch damage
                case 'definitions'
                    at = strfind(char(raw), 'MIMCSA'); raw(at(1) + 11) = uint8('X');
                case 'mapping'
                    at = strfind(char(raw), 'MTIMFA'); raw(at(1) + 11 + 36 + 2) = uint8('2');
                case 'timing'
                    at = strfind(char(raw), 'MTIMSA'); raw(at(1) + 11 + 2) = uint8('2');
                case 'layer'
                    at = strfind(char(raw), 'MTIMSA'); raw(at(1) + 11 + 3) = uint8('X');
                case 'filename'
                    target = fullfile(t.folder, 'foreign.ntf'); input = [paths(2:end) {target}];
                otherwise
                    target = paths{end}; raw = readBytes(target);
                    [index, indexed] = nfx.internal.indexNITF(raw); t.assertTrue(indexed);
                    first = index.texts(1).location.dataOffset + 1;
                    if strcmp(damage, 'listID')
                        raw(index.texts(1).location.headerOffset + 9) = uint8('2');
                    elseif strcmp(damage, 'listPath')
                        raw(first:first + 2) = uint8('../');
                    elseif strcmp(damage, 'listDuplicate')
                        names = {source.plan().filename};
                        raw(first + numel(names{1}) + 2 + (0:numel(names{1}) - 1)) = uint8(names{1});
                    else
                        raw(first + numel('synthetic.c0i0.ntf') + 2) = uint8('z');
                    end
            end
            putBytes(target, raw);
            [copy, ok, status] = nfx.MIECollection.read(input);
            t.verifyFalse(ok, damage); t.verifyNotEqual(status.code, 'OK');
            t.verifyEmpty(copy.blocks); t.verifyEmpty(copy.base_name);
        end

        function duplicateAndIncompleteExplicitListsFail(t)
            source = fixtureMIECollection(); paths = source.write(t.folder);
            [~, ok, status] = nfx.MIECollection.read([paths paths(1)]);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            [~, ok, status] = nfx.MIECollection.read(paths(2:end));
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
        end

        function nonAsciiFilenameUsesAnUnsupportedDiagnostic(t)
            source = fixtureFile(); path = fullfile(t.folder, [char(9731) '.i1.ntf']);
            source.write(path);
            [copy, ok, status] = nfx.MIECollection.read({path});
            t.verifyFalse(ok); t.verifyEqual(status.code, 'UnsupportedFeature');
            t.verifyEmpty(copy.base_name);
        end
    end
end

function collection = readerCollection(variation)
    collection = fixtureMIECollection();
    switch variation
        case 'manifestMappings', collection.manifest_mtimfa = true;
        case {'unavailable', 'allUnavailable'}
            collection.manifest_mtimfa = true;
            indices = [1 4];
            if strcmp(variation, 'allUnavailable'), indices = 1:numel(collection.blocks); end
            for k = indices
                collection.blocks(k).available = false;
                collection.blocks(k).image = nfx.ImageSegment();
            end
        case 'metadataOnly', collection.blocks = nfx.MotionBlock.empty(1, 0);
        case 'interleaved', collection.blocks = collection.blocks([1 3 2 4:7]);
        case 'quicklook'
            image = collection.blocks(1).image; image.data = image.data(:,:,:,1);
            image.header.icom = 'First visible frame selected for overview.';
            timing = collection.blocks(1).timing; timing.layer_id = 'VIS';
            timing.number_frames = 1; timing.nominal_frame_rate = 0;
            timing.dt = zeros(1, 0, 'uint64'); timing.base_timestamp = '20260915120000.040000000';
            collection.quicklooks = image + timing;
        case 'templates'
            header = collection.header; header.ftitle = 'Local template metadata';
            template = nfx.File(header=header) + fixtureText('Preserved note') + ...
                nfx.FREESA(9);
            collection.manifest_template = template;
            collection.file_templates = struct('camera_set_index', 1, ...
                'time_interval_index', 1, 'file', template + fixtureCSATTB());
    end
end

function verifyPlans(t, first, second)
    t.assertEqual({second.filename}, {first.filename});
    for k = 1:numel(first)
        a = first(k).file; b = second(k).file;
        t.verifyTrue(b.context_complete);
        t.verifyEqual(b.header.bytes(), a.header.bytes());
        t.verifyEqual({b.tre_records.payload}, {a.tre_records.payload});
        t.verifyEqual({b.des.data}, {a.des.data});
        for j = 1:numel(a.images)
            t.verifyEqual(b.images(j).data, a.images(j).data);
            t.verifyEqual(b.images(j).MTIMSA().payload(), a.images(j).MTIMSA().payload());
            for frame = 1:a.images(j).number_frames
                t.verifyEqual(b.effectiveTREs(j, frame), a.effectiveTREs(j, frame));
            end
        end
    end
end

function value = hierarchy(first, indices, second, other, leaf)
    value = nfx.CONTXA(context_type=first, index_list=indices) + ...
        (nfx.CONTXA(context_type=second, index_list=other) + leaf);
end
