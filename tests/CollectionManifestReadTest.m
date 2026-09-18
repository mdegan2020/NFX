classdef CollectionManifestReadTest < NfxTest
    methods (Test)
        function splitFilenameListsReadEveryNamedMember(t)
            collection = longCollection();
            folder = t.folder;
            paths = collection.write(folder);
            [manifest, ok, status] = nfx.File.read(paths{end});
            t.assertTrue(ok, status.message); t.assertNumElements(manifest.texts, 2);
            t.verifyEqual(manifest.texts(2).header.textid, 'FILE002');
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message); t.verifyNumElements(copy.blocks, 650);
            planned = copy.plan();
            t.verifyEqual(planned(end).filename, [collection.base_name '.i650.ntf']);
            t.verifyEqual(planned(end).file.images.data, uint8(197));
            delete(paths{end - 1});
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MissingFile');
            t.verifyEqual(status.path, paths{end - 1}); t.verifyEmpty(copy.blocks);
        end
    end
end

function collection = longCollection()
    collection = fixtureMIECollection(); collection.base_name = repmat('b', 1, 150);
    collection.layers = collection.layers(1);
    camera = collection.camera_sets.camera_sets(1).cameras(1);
    camera.nrows = 1; camera.ncols = 1;
    collection.camera_sets.camera_sets = struct('cameras', camera);
    collection.camera_ids.cameras = collection.camera_ids.cameras(1);
    block = collection.blocks(1); block.image.data = uint8(197);
    block.image.header.irep = 'MONO';
    block.image.header.nppbh = 1; block.image.header.nppbv = 1;
    block.timing.dt = zeros(1, 0, 'uint64');
    count = 650; collection.blocks = repmat(block, 1, count);
    windows = repmat(collection.intervals.intervals(1), 1, count);
    base = datetime(2026, 9, 15, 12, 0, 0, 'Format', 'yyyyMMddHHmmss');
    for k = 1:count
        prefix = char(base + seconds(k - 1)); finish = char(base + seconds(k));
        windows(k) = struct('time_interval_index', k, ...
            'start_timestamp', [prefix '.000000000'], ...
            'end_timestamp', [finish '.000000000']);
        collection.blocks(k).timing.time_interval_index = k;
        collection.blocks(k).timing.base_timestamp = windows(k).start_timestamp;
        collection.blocks(k).start_timestamp = windows(k).start_timestamp;
        collection.blocks(k).end_timestamp = [prefix '.250000000'];
    end
    collection.intervals = nfx.TMINTA(windows);
end
