classdef (Hidden) CollectionReader
    %CollectionReader - Import explicitly named MIE files without directory scans
    % Collections grow after source-size/count checks; no maximum buffer is
    % allocated for every possible file or temporal block.
    methods (Static)
        function [collection, ok, status] = read(source, maxBytes, maxPixels, maxFiles)
            collection = nfx.MIECollection(); ok = false;
            status = nfx.internal.readStatus(); status.scope = 'collection';
            if ~validLimit(maxBytes) || ~validLimit(maxPixels) || ~validLimit(maxFiles)
                status.code = 'InvalidInput';
                status.message = 'Collection limits must be positive finite double integers.';
                return
            end
            manifestInput = isText(source);
            if manifestInput
                paths = {char(source)};
            elseif isstring(source) && isvector(source) && ~any(ismissing(source))
                paths = cellstr(reshape(source, 1, []));
            elseif iscell(source) && isvector(source)
                paths = reshape(source, 1, []);
                for k = 1:numel(paths)
                    if ~isText(paths{k})
                        status.code = 'InvalidInput'; status.message = 'Supply filename text values.';
                        return
                    end
                    paths{k} = char(paths{k});
                end
            else
                status.code = 'InvalidInput';
                status.message = 'Supply a manifest filename or an explicit filename list.';
                return
            end
            if isempty(paths) || any(cellfun(@isempty, paths)) || ...
                    any(cellfun(@(p) any(p == 0), paths))
                status.code = 'InvalidInput'; status.message = 'Filenames cannot be empty or contain NUL.';
                return
            end
            if numel(paths) > maxFiles
                status.code = 'ResourceLimit'; status.message = 'File count exceeds MaxFiles.'; return
            end
            item = struct('filename', '', 'file', nfx.File(), ...
                'camera_set_index', 0, 'time_interval_index', 0, 'manifest', false);
            files = repmat(item, 1, 0); names = cell(1, 0);
            bytes = 0; samples = 0; first = 1;
            while first <= numel(paths)
                filename = paths{first};
                [~, stem, extension] = fileparts(filename); name = [stem extension];
                if any(strcmpi(name, names))
                    status = problem('MalformedFile', 'Duplicate collection filename.', filename); return
                end
                if ~isfile(filename)
                    status = problem('MissingFile', 'A required collection file is absent.', filename); return
                end
                [raw, loaded, child] = nfx.internal.loadReadFile(filename, maxBytes - bytes);
                if ~loaded, status = child; return, end
                [file, loaded, child] = nfx.internal.FileReader.readBytes(raw, maxPixels - samples, false);
                if ~loaded, status = child; status.path = filename; return, end
                bytes = bytes + numel(raw);
                for k = 1:numel(file.images), samples = samples + numel(file.images(k).data); end
                current = item; current.filename = name; current.file = file;
                files(end + 1) = current; names{end + 1} = name; %#ok<AGROW>
                if first == 1 && manifestInput
                    [manifestNames, loaded, child] = fileList(file, maxFiles);
                    if ~loaded, status = child; status.path = filename; return, end
                    if ~strcmpi(manifestNames{1}, name)
                        status = problem('MalformedFile', 'The manifest must be the first listed file.', filename);
                        return
                    end
                    folder = fileparts(filename);
                    for k = 2:numel(manifestNames)
                        paths{end + 1} = fullfile(folder, manifestNames{k}); %#ok<AGROW>
                    end
                end
                first = first + 1;
            end
            [~, sets, intervals, named] = collectionNames(names);
            if named
                [~, order] = sortrows([intervals' sets']);
                files = files(order); paths = paths(order);
            end
            [collection, ok, status] = nfx.internal.CollectionReader.reconstruct(files);
            if ~ok && isempty(status.path) && status.index >= 1 && status.index <= numel(paths)
                status.path = paths{status.index};
            end
            if ~ok, collection = nfx.MIECollection(); end
        end

        function [collection, ok, status] = reconstruct(files)
            collection = nfx.MIECollection(); ok = false;
            status = nfx.internal.readStatus(); status.scope = 'collection';
            [base, sets, intervals, parsed] = collectionNames({files.filename});
            if ~parsed
                status.code = 'UnsupportedFeature';
                status.message = 'Filenames are outside the original-resolution NFX MIE naming scheme.';
                return
            end
            collection.base_name = base; collection.header = files(1).file.header;
            baseline = definitionRecords(files(1).file);
            for k = 1:numel(files)
                files(k).camera_set_index = sets(k);
                files(k).time_interval_index = intervals(k);
                files(k).manifest = sets(k) == 0 && intervals(k) == 0;
                if ~sameRecords(baseline, definitionRecords(files(k).file))
                    status.code = 'MalformedFile'; status.index = k;
                    status.message = 'Collection files contain conflicting common definitions.'; return
                end
            end
            for k = 1:files(1).file.treCount('MIMCSA')
                collection.layers(end + 1) = files(1).file.MIMCSA(k);
            end
            for k = 1:files(1).file.treCount('CAMSDA')
                collection.camera_sets(end + 1) = files(1).file.CAMSDA(k);
            end
            for k = 1:files(1).file.treCount('MICIDA')
                collection.camera_ids(end + 1) = files(1).file.MICIDA(k);
            end
            for k = 1:files(1).file.treCount('TMINTA')
                collection.intervals(end + 1) = files(1).file.TMINTA(k);
            end
            manifest = find([files.manifest]); collection.manifest = ~isempty(manifest);
            if numel(manifest) > 1
                status.code = 'MalformedFile'; status.message = 'A collection has at most one manifest.';
                collection = nfx.MIECollection(); return
            end
            [definitions, report] = nfx.MIECollection.readDefinitions(collection);
            if ~report.valid
                status.code = 'MalformedFile'; status.message = report.issues(1).message;
                collection = nfx.MIECollection(); return
            end
            expected = expectedNames(base, sets, intervals, definitions.sets);
            if ~isequal(expected, {files.filename})
                status.code = 'MalformedFile'; status.message = 'Filenames disagree with the camera-set catalog.';
                collection = nfx.MIECollection(); return
            end
            if ~isempty(manifest)
                [listed, valid, child] = fileList(files(manifest).file, flintmax);
                if ~valid
                    status = child; collection = nfx.MIECollection(); return
                end
                if ~isequal(listed, {files.filename})
                    status.code = 'MalformedFile'; status.message = 'The supplied files do not match the manifest list order.';
                    collection = nfx.MIECollection(); return
                end
                collection.manifest_mtimfa = files(manifest).file.treCount('MTIMFA') > 0;
                collection.quicklooks = files(manifest).file.images;
                collection.manifest_template = nfx.internal.CollectionReader.template(files(manifest).file);
            end
            [mappings, valid, child] = collectMappings(files);
            if ~valid, status = child; collection = nfx.MIECollection(); return, end
            [blocks, valid, child] = restoreBlocks(files, mappings);
            if ~valid, status = child; collection = nfx.MIECollection(); return, end
            collection.blocks = blocks;
            for k = 1:numel(files)
                if files(k).manifest, continue, end
                collection.file_templates(end + 1) = struct( ...
                    'camera_set_index', sets(k), 'time_interval_index', intervals(k), ...
                    'file', nfx.internal.CollectionReader.template(files(k).file));
            end
            collection = nfx.MIECollection.captureReadLayouts(collection, files);
            [bound, report] = nfx.MIECollection.bindReadFiles(files);
            if report.valid, report = collection.validate(); end
            if ~report.valid
                status.code = 'MalformedFile'; status.message = report.issues(1).message;
                collection = nfx.MIECollection(); return
            end
            planned = collection.plan();
            [same, detail] = sameFiles(bound, planned);
            if ~same
                status.code = 'UnsupportedFeature';
                status.message = ['Imported organization changes stored ' detail '.'];
                collection = nfx.MIECollection(); return
            end
            ok = true; status = nfx.internal.readStatus(); status.scope = 'collection';
            status.metadata_complete = report.complete;
        end

        function template = template(file)
            records = file.tre_records;
            records(ismember({records.tag}, {'MIMCSA','CAMSDA','MICIDA','TMINTA','MTIMFA'})) = [];
            texts = file.texts; keep = true(1, numel(texts));
            for k = 1:numel(texts), keep(k) = ~startsWith(texts(k).header.textid, 'FILE'); end
            des = file.des; keepDES = true(1, numel(des));
            for k = 1:numel(des), keepDES(k) = ~strcmp(des(k).header.desid, 'TRE_OVERFLOW'); end
            template = nfx.File.restoreRead(file.header, nfx.ImageSegment.empty(1, 0), ...
                texts(keep), des(keepDES), records);
        end
    end
end

function [mappings, ok, status] = collectMappings(files)
    mappings = nfx.MTIMFA.empty(1, 0); sources = zeros(1, 0); ok = false;
    status = problem('MalformedFile', 'Conflicting or misplaced temporal block mappings.', '');
    for f = 1:numel(files)
        file = files(f).file; status.index = f;
        for k = 1:file.treCount('MTIMFA')
            value = file.MTIMFA(k);
            if ~files(f).manifest && (value.camera_set_index ~= files(f).camera_set_index || ...
                    value.time_interval_index ~= files(f).time_interval_index)
                return
            end
            duplicate = 0;
            for j = 1:numel(mappings)
                if strcmp(mappings(j).layer_id, value.layer_id) && ...
                        mappings(j).camera_set_index == value.camera_set_index && ...
                        mappings(j).time_interval_index == value.time_interval_index
                    duplicate = j; break
                end
            end
            if duplicate > 0
                if sources(duplicate) == f || ...
                        ~isequal(mappings(duplicate).payload(), value.payload())
                    return
                end
            else
                mappings(end + 1) = value; sources(end + 1) = f; %#ok<AGROW>
            end
        end
    end
    ok = true; status = nfx.internal.readStatus();
end

function [blocks, ok, status] = restoreBlocks(files, mappings)
    blocks = nfx.MotionBlock.empty(1, 0); ok = false;
    status = problem('MalformedFile', 'Temporal block mappings disagree with stored imagery.', '');
    item = struct('set', 0, 'interval', 0, 'layer', '', 'camera', '', ...
        'ordinal', 0, 'segment', NaN, 'first', '', 'last', '');
    entries = repmat(item, 1, 0);
    for k = 1:numel(mappings)
        mapping = mappings(k);
        for c = 1:numel(mapping.cameras)
            camera = mapping.cameras(c);
            for b = 1:numel(camera.temporal_blocks)
                block = camera.temporal_blocks(b); entry = item;
                entry.set = mapping.camera_set_index; entry.interval = mapping.time_interval_index;
                entry.layer = mapping.layer_id; entry.camera = camera.camera_id;
                entry.ordinal = b; entry.segment = block.image_seg_index;
                entry.first = block.start_timestamp; entry.last = block.end_timestamp;
                if isempty(strtrim(entry.first)) || isempty(strtrim(entry.last)), return, end
                entries(end + 1) = entry; %#ok<AGROW>
            end
        end
    end
    used = false(1, numel(entries));
    for f = 1:numel(files)
        if files(f).manifest, continue, end
        status.index = f;
        images = files(f).file.images;
        if isempty(images), return, end
        for j = 1:numel(images)
            image = images(j);
            if image.treCount('MTIMSA') ~= 1, return, end
            timing = image.MTIMSA();
            selected = find([entries.set] == files(f).camera_set_index & ...
                [entries.interval] == files(f).time_interval_index & [entries.segment] == j);
            if ~isscalar(selected) || used(selected), return, end
            entry = entries(selected);
            if ~strcmpi(timing.camera_id, entry.camera) || ~strcmp(timing.layer_id, entry.layer) || ...
                    timing.camera_set_index ~= entry.set || timing.time_interval_index ~= entry.interval || ...
                    timing.temp_block_index ~= entry.ordinal || timing.image_seg_index ~= j
                return
            end
            prior = find([entries.set] == entry.set & [entries.interval] == entry.interval & ...
                strcmpi({entries.camera}, entry.camera) & [entries.ordinal] < entry.ordinal & ~used);
            [~, order] = sort([entries(prior).ordinal]); prior = prior(order);
            for p = prior
                if ~isnan(entries(p).segment), return, end
                blocks(end + 1) = missingBlock(entries(p)); used(p) = true; %#ok<AGROW>
            end
            records = image.tre_records; record = records(strcmp({records.tag}, 'MTIMSA'));
            image = image.removeTRE(record.id);
            blocks(end + 1) = nfx.MotionBlock(image, timing=timing, ...
                start_timestamp=entry.first, end_timestamp=entry.last); %#ok<AGROW>
            used(selected) = true;
        end
    end
    for p = find(~used)
        if ~isnan(entries(p).segment)
            status.message = 'A mapped image segment is absent from the supplied collection.'; return
        end
        blocks(end + 1) = missingBlock(entries(p)); %#ok<AGROW>
    end
    ok = true; status = nfx.internal.readStatus();
end

function block = missingBlock(entry)
    timing = nfx.MTIMSA(camera_id=entry.camera, time_interval_index=entry.interval);
    block = nfx.MotionBlock(available=false, timing=timing, ...
        start_timestamp=entry.first, end_timestamp=entry.last);
end

function [valid, detail] = sameFiles(first, second)
    detail = 'file count';
    valid = numel(first) == numel(second);
    if ~valid, return, end
    for k = 1:numel(first)
        a = first(k).file; b = second(k).file;
        detail = sprintf('file %d header or records', k);
        if ~strcmp(first(k).filename, second(k).filename) || ...
                ~isequal(a.header.bytes(), b.header.bytes()) || ...
                ~sameRecords(a.tre_records, b.tre_records) || ...
                ~isequal(a.storedSubheaders(), b.storedSubheaders()) || ...
                numel(a.images) ~= numel(b.images) || ...
                numel(a.texts) ~= numel(b.texts) || numel(a.des) ~= numel(b.des)
            valid = false; return
        end
        for j = 1:numel(a.images)
            x = a.images(j); y = b.images(j);
            detail = sprintf('file %d image %d data/header/records', k, j);
            if ~isequal(x.data, y.data) || ~isequal(x.header.bytes(), y.header.bytes()) || ...
                    ~sameRecords(x.tre_records, y.tre_records)
                valid = false; return
            end
        end
        for j = 1:numel(a.texts)
            x = a.texts(j); y = b.texts(j);
            detail = sprintf('file %d text %d data/header/records', k, j);
            if ~isequal(x.data, y.data) || ~isequal(x.header.bytes(), y.header.bytes()) || ...
                    ~sameRecords(x.tre_records, y.tre_records)
                valid = false; return
            end
        end
        for j = 1:numel(a.des)
            detail = sprintf('file %d DES %d data/header', k, j);
            if ~isequal(a.des(j).data, b.des(j).data) || ~isequal(a.des(j).header, b.des(j).header)
                valid = false; return
            end
        end
    end
end

function valid = isText(value)
    valid = (ischar(value) && isrow(value)) || ...
        (isstring(value) && isscalar(value) && ~ismissing(value));
end

function valid = validLimit(value)
    valid = isa(value, 'double') && isscalar(value) && isreal(value) && ...
        ~issparse(value) && isfinite(value) && value >= 1 && ...
        value <= flintmax && fix(value) == value;
end

function status = problem(code, message, path)
    status = nfx.internal.readStatus(); status.scope = 'collection';
    status.code = code; status.message = message; status.path = path;
end

function records = definitionRecords(file)
    records = file.tre_records;
    records = records(ismember({records.tag}, {'MIMCSA','CAMSDA','MICIDA','TMINTA'}));
end

function valid = sameRecords(first, second)
    valid = numel(first) == numel(second);
    if ~valid, return, end
    for k = 1:numel(first)
        if ~strcmp(first(k).tag, second(k).tag) || ~isequal(first(k).payload, second(k).payload)
            valid = false; return
        end
    end
end

function [names, ok, status] = fileList(file, maxFiles)
    names = cell(1, 0); ok = false;
    status = problem('MalformedFile', 'Missing or malformed FILEnnn manifest text.', '');
    count = 0;
    for k = 1:numel(file.texts)
        segment = file.texts(k); id = char(segment.header.textid);
        if ~startsWith(id, 'FILE'), continue, end
        count = count + 1;
        if ~strcmp(id, sprintf('FILE%03d', count)) || ...
                ~strcmp(segment.header.txtitl, 'MIE4NITF Manifest File List') || ...
                ~endsWith(segment.data, char([13 10]))
            return
        end
        entries = strsplit(segment.data, char([13 10]), 'CollapseDelimiters', false);
        entries(end) = [];
        if numel(names) + numel(entries) > maxFiles
            status.code = 'ResourceLimit'; status.message = 'File count exceeds MaxFiles.'; return
        end
        for j = 1:numel(entries)
            name = entries{j};
            if isempty(name) || numel(name) > 255 || any(ismember(name, '\/:*?"<>|')) || ...
                    any(double(name) < 32) || ~strcmp(name, strtrim(name)) || ...
                    any(strcmpi(name, names))
                return
            end
            names{end + 1} = name; %#ok<AGROW>
        end
    end
    ok = count > 0 && ~isempty(names);
    if ok, status = nfx.internal.readStatus(); end
end

function [base, sets, intervals, ok] = collectionNames(names)
    base = ''; sets = zeros(1, numel(names)); intervals = sets; ok = false;
    for k = 1:numel(names)
        tokens = regexp(names{k}, '^(.*)\.c([0-9]+)i([0-9]+)\.ntf$', 'tokens', 'once');
        if isempty(tokens)
            tokens = regexp(names{k}, '^(.*)\.i([0-9]+)\.ntf$', 'tokens', 'once');
            if isempty(tokens), return, end
            tokens = {tokens{1}, '1', tokens{2}};
            if strcmp(tokens{3}, '0'), tokens{2} = '0'; end
        end
        if isempty(tokens{1}) || numel(tokens{1}) > 240 || ...
                any(double(tokens{1}) < 32 | double(tokens{1}) > 126)
            return
        end
        if k == 1, base = tokens{1}; elseif ~strcmp(base, tokens{1}), return, end
        sets(k) = str2double(tokens{2}); intervals(k) = str2double(tokens{3});
        if sets(k) > 999 || intervals(k) > 999999 || ...
                (sets(k) == 0) ~= (intervals(k) == 0)
            return
        end
    end
    ok = true;
end

function names = expectedNames(base, sets, intervals, totalSets)
    names = cell(1, numel(sets));
    for k = 1:numel(sets)
        if totalSets > 1
            names{k} = sprintf('%s.c%di%d.ntf', base, sets(k), intervals(k));
        else
            names{k} = sprintf('%s.i%d.ntf', base, intervals(k));
        end
    end
end
