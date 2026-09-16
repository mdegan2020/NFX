classdef File
    %FILE - A NITF file assembled from segment and metadata snapshots
    %   OBJ = FILE(header=HEADER) creates an empty file. Append ImageSegment,
    %   TextSegment, DESSegment, and permitted TRE values with the + operator.
    %   Supply required metadata, validate, and write to a filesystem path.
    %
    %   OBJ.header derives lengths, counts, and complexity from all segments.
    %   Images, texts, and DESs serialize in that order. OBJ.des also includes
    %   any derived TRE_OVERFLOW segments. OBJ.images resolves automatic
    %   display levels while preserving explicit caller choices.
    %
    %   FILE functions:
    %       plus      - Append a segment or TRE value snapshot
    %       removeTRE - Remove a file-level logical TRE attachment
    %       validate  - Check generic NITF rules and requested profiles
    %       write     - Write validated content with destination protection
    %
    %   See also FileHeader, ImageSegment, TextSegment, DESSegment

    properties (Dependent)
        header % Editable metadata with current structural fields
    end
    properties (Dependent, SetAccess = private)
        images % Image snapshots with resolved display levels
        des % Explicit DES snapshots followed by derived TRE_OVERFLOW segments
        tre_ids % File-level logical attachment IDs
        tre_tags % File-level logical attachment tags
        tre_records % File-level physical record snapshots
    end
    properties (SetAccess = private)
        texts % Text snapshots in insertion order
    end
    properties (Access = private)
        headerValue
        imageValues
        desValues
        store = nfx.internal.TREStore()
        contextIsBound = false
        contextDirty = false
        contextInheritance
        contextDefinitions
    end
    methods
        function obj = File(options) %#codegen
            %FILE - Construct an empty file
            arguments
                options.header (1,1) nfx.FileHeader = nfx.FileHeader()
            end
            obj.headerValue = options.header;
            obj.imageValues = nfx.ImageSegment.empty(1, 0);
            obj.texts = nfx.TextSegment.empty(1, 0);
            obj.desValues = nfx.DESSegment.empty(1, 0);
        end
        function value = get.header(obj) %#codegen
            %get.header - Derive structural metadata for the complete file
            [value, ~] = layout(obj);
        end
        function obj = set.header(obj, value) %#codegen
            %set.header - Replace editable file metadata
            arguments
                obj (1,1) nfx.File
                value (1,1) nfx.FileHeader
            end
            obj.headerValue = value;
            obj.contextDirty = obj.contextIsBound;
        end
        function value = get.images(obj) %#codegen
            %get.images - Assign unused levels to images with automatic IDs
            value = obj.imageValues;
            used = zeros(1, numel(value));
            for k = 1:numel(value), used(k) = explicitLevel(value(k)); end
            next = 1;
            for k = 1:numel(value)
                if isnan(used(k))
                    while any(used == next), next = next+1; end
                    value(k) = resolveLevel(value(k), next);
                    used(k) = next;
                    next = next+1;
                end
            end
        end
        function value = get.des(obj) %#codegen
            %get.des - Return the DESs in their final file order
            [~, plan] = layout(obj);
            value = plan.des;
        end
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return logical file-header attachment IDs
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return logical file-header attachment tags
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Return physical file-header snapshots
            value = obj.store.records;
        end
        function obj = plus(obj, item) %#codegen
            %PLUS - Append a segment or permitted file-header TRE snapshot
            %   OBJ = OBJ + ITEM captures ITEM by value. Later edits to ITEM
            %   leave OBJ unchanged. Each segment type retains insertion order.
            arguments
                obj (1,1) nfx.File
                item (1,1)
            end
            obj.contextDirty = obj.contextIsBound;
            if isa(item, 'nfx.ImageSegment')
                if numel(obj.imageValues) >= 999
                    error('nfx:ImageCount', 'NITF permits at most 999 image segments.');
                end
                obj.imageValues(end+1) = item;
            elseif isa(item, 'nfx.TextSegment')
                if numel(obj.texts) >= 999
                    error('nfx:TextCount', 'NITF permits at most 999 text segments.');
                end
                obj.texts(end+1) = item;
            elseif isa(item, 'nfx.SensorDES') || isa(item, 'nfx.DESSegment')
                if isa(item, 'nfx.SensorDES'), item = segment(item); end
                if strcmp(item.header.desid, 'TRE_OVERFLOW')
                    error('nfx:DerivedOverflow', 'Attach TREs to their owner; File derives overflow DESs.');
                end
                if numel(obj.desValues) >= 999
                    error('nfx:DESCount', 'NITF permits at most 999 DES segments.');
                end
                obj.desValues(end+1) = item;
            elseif isa(item, 'nfx.TRE')
                obj.store = obj.store.attach(item, 'file');
            else
                error('nfx:SegmentType', 'Append an NFX image, text, DES, or supported TRE.');
            end
        end
        function obj = removeTRE(obj, id) %#codegen
            %removeTRE - Remove a file-header logical attachment by ID
            arguments
                obj (1,1) nfx.File
                id {mustBeMetadata(id, 1, 9007199254740991, 1), mustBeFinite}
            end
            obj.store = obj.store.remove(id);
            obj.contextDirty = obj.contextIsBound;
        end
        function report = validate(obj, options) %#codegen
            %VALIDATE - Check all segments and their file-level relationships
            %   REPORT = VALIDATE(OBJ) checks the generic NITF container.
            %   SNIP_COMPLIANT=true also requests SNIP enforcement; unsupported
            %   profile rules are errors, so conformance cannot pass silently.
            arguments
                obj (1,1) nfx.File
                options.SNIP_COMPLIANT (1,1) {mustBeA(options.SNIP_COMPLIANT, 'logical')} = false
            end
            [h, plan] = layout(obj);
            report = newReport('NITF 2.1');
            report = mergeReport(report, validate(h), 'header.');
            report = addIssue(report,obj.contextDirty,'CollectionContextChanged','collection', ...
                'Edit the source collection and replan after changing a file with inherited collection metadata.', ...
                'NFX-MIE-NC1 collection snapshot integrity');
            reference = 'JBP 2025.1, 5.11 and 5.14';
            report = addIssue(report, h.numi+h.numt+h.numdes == 0, 'SegmentCount', ...
                'images/texts/des', 'Attach at least one data segment.', reference);
            levels = zeros(1, h.numi);
            for k = 1:h.numi
                levels(k) = plan.images(k).header.idlvl;
                report = mergeReport(report, validateStructure(plan.images(k)), sprintf('images(%d).', k));
            end
            [contexts,child] = resolveContexts(obj,h,plan);
            report = mergeReport(report,child,'');
            if child.valid
                report = mergeReport(report,contextImageReport(contexts,plan.images),'');
                for c = 1:numel(contexts)
                    report = mergeReport(report,glasHeaderContextReport(contexts(c).file_records,plan.des), ...
                        sprintf('contexts(%.0f).file.',c));
                end
                views = contextViews(contexts,plan.images);
                positions = plan.positions([contexts.image],:);
                report = mergeReport(report,rsmFileReport(views,positions),'rsm.');
                report = mergeReport(report,glasFileReport(obj.store.records,views,plan.des,positions),'glas.');
            end
            report = addIssue(report, numel(unique(levels)) ~= numel(levels), 'DisplayLevel', ...
                'images.header.idlvl', 'Display levels must be unique across all images.', reference);
            for k = 1:h.numi
                parent = plan.images(k).header.ialvl;
                timing = plan.images(k).tre_records;
                for j = find(strcmp({timing.tag},'MTIMSA'))
                    report = addIssue(report,str2double(char(timing(j).payload(1:3))) ~= k, ...
                        'MotionSegmentIndex',sprintf('images(%d).MTIMSA',k), ...
                        'MTIMSA image index must identify its owning segment.', ...
                        'NGA.STND.0044 1.3.3, 6.9.2.3');
                end
                report = addIssue(report, parent ~= 0 && ~any(levels == parent), ...
                    'DisplayAttachment', sprintf('images(%d).header.ialvl', k), ...
                    'Attachment level must identify an image in this file.', reference);
                report = addIssue(report, any(plan.positions(k,:) < 0), 'DisplayLocation', ...
                    sprintf('images(%d).header.iloc', k), ...
                    'The absolute image position must remain in the nonnegative CCS quadrant.', ...
                    'JBP 2025.1, 4.5.2 requirements 008 and 009');
                im = plan.images(k).header;
                report = addIssue(report,h.clevel >= 51 && ...
                    (max(plan.positions(k,:)+[im.nrows im.ncols]) > 99999999 || ...
                    min(im.nrows,im.ncols) > 65536 || size(plan.images(k).data,3) > 999), ...
                    'MotionComplexity',sprintf('images(%d)',k), ...
                    'The image exceeds the supported MIE complexity-level limits.', ...
                    'NGA.STND.0044 1.3.3, Table 15');
            end
            for k = 1:h.numt
                report = mergeReport(report, validate(obj.texts(k)), sprintf('texts(%d).', k));
                parent = obj.texts(k).header.txtalvl;
                report = addIssue(report, parent ~= 0 && ~any(levels == parent), ...
                    'TextAttachment', sprintf('texts(%d).header.txtalvl', k), ...
                    'Text attachment must identify an image in this file or be zero.', reference);
            end
            for k = 1:h.numdes
                report = mergeReport(report, validate(plan.des(k)), sprintf('des(%d).', k));
            end
            if options.SNIP_COMPLIANT
                report.scope = 'NITF 2.1 + SNIP';
                report = addIssue(report, true, 'SNIPNotSupported', 'SNIP_COMPLIANT', ...
                    'SNIP validation and writing are not implemented.', 'NGA.STND.0072 SNIP');
            end
        end
        function [records,fileRecords] = effectiveTREs(obj,imageIndex,frameIndex) %#codegen
            %effectiveTREs - Inspect effective image metadata in physical order
            %   RECORDS = effectiveTREs(OBJ,IMAGEINDEX,FRAMEINDEX) returns
            %   snapshots selected by wrappers and scalar override precedence.
            %   Augment and partial-override records retain their wire order.
            %   BYTE_OFFSET is zero based. FILE_INDEX is zero for this file,
            %   or the source index in a captured MIECollection plan.
            %   [RECORDS,FILERECORDS] also returns effective file-header TREs.
            arguments
                obj (1,1) nfx.File
                imageIndex {mustBeMetadata(imageIndex,1,999,1),mustBeFinite}
                frameIndex {mustBeMetadata(frameIndex,1,4294967295,1),mustBeFinite} = 1
            end
            if obj.contextDirty, error('nfx:CollectionContextChanged','Replan inherited metadata from the source collection.'); end
            [h,plan] = layout(obj);
            if imageIndex > numel(plan.images) || frameIndex > plan.images(imageIndex).number_frames
                error('nfx:ContextBounds','Select an existing image and frame.');
            end
            [contexts,report] = resolveContexts(obj,h,plan);
            requireValid(report);
            selected = find([contexts.image] == imageIndex & [contexts.first] <= frameIndex & [contexts.last] >= frameIndex,1);
            records = contexts(selected).records; fileRecords = contexts(selected).file_records;
        end
        function write(obj, filename, options) %#codegen
            %WRITE - Write a validated file with destination protection
            %   WRITE(OBJ,FILENAME) writes to a new filesystem path. Metadata
            %   validation finishes before any output file is created.
            %
            %   WRITE(...,Overwrite=true) permits replacing an existing file
            %   after complete output has been prepared in the same folder.
            %
            %   WRITE(...,SNIP_COMPLIANT=true) fails because SNIP enforcement
            %   is not implemented. Ordinary generic output remains supported.
            arguments
                obj (1,1) nfx.File
                filename {mustBeTextScalar, mustBeNonempty}
                options.Overwrite (1,1) {mustBeA(options.Overwrite, 'logical')} = false
                options.SNIP_COMPLIANT (1,1) {mustBeA(options.SNIP_COMPLIANT, 'logical')} = false
            end
            requireValid(validate(obj, SNIP_COMPLIANT=options.SNIP_COMPLIANT));
            destination = char(filename);
            if isempty(destination) || any(destination == '*') || ...
                    any(destination == '?') || any(destination == char(0)) || ...
                    contains(destination, '://') || isfolder(destination)
                error('nfx:Destination', 'Supply a local filename, without wildcards or a directory target.');
            end
            if isfile(destination) && ~options.Overwrite
                error('nfx:Exists', 'Destination exists; use Overwrite=true to replace it.');
            end
            folder = fileparts(destination);
            if isempty(folder), folder = pwd; end
            if ~isfolder(folder)
                error('nfx:Destination', 'The destination folder does not exist.');
            end
            [layoutHeader, plan] = layout(obj);
            fileHeader = bytes(layoutHeader);
            imageHeaders = repmat(struct('data', zeros(1,0,'uint8')), 1, numel(plan.images));
            for k = 1:numel(plan.images)
                imageHeaders(k).data = subheader(plan.images(k), plan.imageAreas(k).data, plan.imageOverflow(k), ...
                    plan.imageUserAreas(k).data, plan.imageUserOverflow(k));
            end
            textHeaders = repmat(struct('data', zeros(1,0,'uint8')), 1, numel(obj.texts));
            for k = 1:numel(obj.texts)
                textHeaders(k).data = subheader(obj.texts(k), plan.textAreas(k).data, plan.textOverflow(k));
            end
            desHeaders = repmat(struct('data', zeros(1,0,'uint8')), 1, numel(plan.des));
            for k = 1:numel(plan.des), desHeaders(k).data = bytes(plan.des(k).header); end
            temporary = [tempname(folder) '.nfx-part'];
            cleanup = onCleanup(@() discardTemporary(temporary));
            writeTemporary(obj, temporary, layoutHeader.fl, fileHeader, plan, imageHeaders, textHeaders, desHeaders);
            % Recheck immediately before publishing the completed output.
            if isfolder(destination)
                error('nfx:Destination', 'The destination became a directory.');
            end
            if isfile(destination) && ~options.Overwrite
                error('nfx:Exists', 'The destination appeared while writing.');
            end
            [ok, message] = movefile(temporary, destination);
            if ~ok
                error('nfx:PublishFailed', 'Could not replace the destination: %s', message);
            end
            clear cleanup
        end
    end
    methods (Hidden)
        function [nodes,catalog] = contextState(obj) %#codegen
            %contextState - Expose immutable metadata for collection preflight
            [h,plan] = layout(obj); nodes = contextNodes(contextAreas(h,plan));
            catalog = contextCatalog(nodes,plan.images);
        end
    end
    methods (Access = ?nfx.MIECollection)
        function obj = bindContext(obj,input) %#codegen
            %bindContext - Capture validated collection catalogs by value
            obj.contextInheritance = input.nodes; obj.contextDefinitions = input.catalog;
            obj.contextIsBound = true; obj.contextDirty = false;
        end
    end
    methods (Access = private)
        function [contexts,report] = resolveContexts(obj,header,plan) %#codegen
            %resolveContexts - Combine local bytes with captured foreign scopes
            nodes = contextNodes(contextAreas(header,plan));
            if obj.contextIsBound
                inherited = obj.contextInheritance; count = numel(nodes);
                for k = 1:numel(inherited)
                    if inherited(k).parent > 0, inherited(k).parent = inherited(k).parent+count; end
                end
                [contexts,report] = frameContexts([nodes inherited],plan.images,obj.contextDefinitions);
            else
                [contexts,report] = frameContexts(nodes,plan.images);
            end
        end
        function [h, plan] = layout(obj) %#codegen
            %LAYOUT - Derive area placement and lengths without serializing pixels
            h = obj.headerValue;
            plan.images = obj.images;
            plan.positions = displayPositions(plan.images);
            plan.des = obj.desValues;
            h.numi = numel(plan.images);
            h.numt = numel(obj.texts);
            plan.imageAreas = repmat(struct('data', zeros(1,0,'uint8')), 1, h.numi);
            plan.imageUserAreas = repmat(struct('data', zeros(1,0,'uint8')), 1, h.numi);
            plan.textAreas = repmat(struct('data', zeros(1,0,'uint8')), 1, h.numt);
            plan.imageOverflow = zeros(1, h.numi);
            plan.imageUserOverflow = zeros(1, h.numi);
            plan.textOverflow = zeros(1, h.numt);
            [h.xhd, h.udhd, excess, overflowUser] = obj.store.modelAreas(99985);
            h.xhdlofl = 0; h.udhofl = 0;
            if ~isempty(excess)
                if overflowUser
                    plan.des(end+1) = nfx.DESSegment.overflow(excess, 'UDHD', 0);
                    h.udhofl = numel(plan.des);
                else
                    plan.des(end+1) = nfx.DESSegment.overflow(excess, 'XHD', 0);
                    h.xhdlofl = numel(plan.des);
                end
            end
            plan.fileExtended = h.xhd; plan.fileUser = h.udhd;
            plan.fileExtendedPresent = ~isempty(h.xhd) || h.xhdlofl ~= 0;
            h.lish = zeros(1, h.numi);
            h.li = zeros(1, h.numi);
            for k = 1:h.numi
                [plan.imageAreas(k).data, plan.imageUserAreas(k).data, excess, overflowUser] = areas(plan.images(k));
                if ~isempty(excess)
                    if overflowUser
                        plan.des(end+1) = nfx.DESSegment.overflow(excess, 'UDID', k);
                        plan.imageUserOverflow(k) = numel(plan.des);
                    else
                        plan.des(end+1) = nfx.DESSegment.overflow(excess, 'IXSHD', k);
                        plan.imageOverflow(k) = numel(plan.des);
                    end
                end
                h.lish(k) = plan.images(k).lish;
                h.li(k) = plan.images(k).li;
            end
            h.ltsh = zeros(1, h.numt);
            h.lt = zeros(1, h.numt);
            for k = 1:h.numt
                [plan.textAreas(k).data, excess] = areas(obj.texts(k));
                if ~isempty(excess)
                    plan.des(end+1) = nfx.DESSegment.overflow(excess, 'TXSHD', k);
                    plan.textOverflow(k) = numel(plan.des);
                end
                h.ltsh(k) = obj.texts(k).ltsh;
                h.lt(k) = obj.texts(k).lt;
            end
            h.numdes = numel(plan.des);
            h.ldsh = zeros(1, h.numdes);
            h.ld = zeros(1, h.numdes);
            for k = 1:h.numdes
                h.ldsh(k) = plan.des(k).ldsh;
                h.ld(k) = plan.des(k).ld;
            end
            h.hl = 388+16*h.numi+9*h.numt+13*h.numdes+numel(h.xhd)+numel(h.udhd)+ ...
                3*(~isempty(h.xhd) || h.xhdlofl ~= 0)+3*(~isempty(h.udhd) || h.udhofl ~= 0);
            h.fl = h.hl+sum(h.lish)+sum(h.li)+sum(h.ltsh)+sum(h.lt)+sum(h.ldsh)+sum(h.ld);
            h.clevel = complexity(h, plan.images, plan.positions);
        end
        function writeTemporary(obj, filename, length, fileHeader, plan, imageHeaders, textHeaders, desHeaders) %#codegen
            %writeTemporary - Close output before publication, including on errors
            output = nfx.internal.OutputFile(filename);
            cleanup = onCleanup(@() delete(output));
            fid = output.id;
            count = writeBytes(fid, fileHeader);
            for k = 1:numel(plan.images)
                count = count + writeBytes(fid, imageHeaders(k).data);
                count = count + writePixels(plan.images(k), fid);
            end
            for k = 1:numel(obj.texts)
                count = count + writeBytes(fid, textHeaders(k).data);
                count = count + writeBytes(fid, uint8(obj.texts(k).data));
            end
            for k = 1:numel(plan.des)
                count = count + writeBytes(fid, desHeaders(k).data);
                count = count + writeBytes(fid, plan.des(k).data);
            end
            if count ~= length || ftell(fid) ~= length
                error('nfx:WriteFailed', 'Output length does not match the calculated file length.');
            end
            closeStatus = close(output);
            if closeStatus ~= 0
                error('nfx:WriteFailed', 'The filesystem could not close the completed output.');
            end
            clear cleanup
        end
    end
end

function positions = displayPositions(images) %#codegen
    %displayPositions - Resolve cumulative offsets with bounded parent traversal
    positions = zeros(numel(images), 2);
    levels = zeros(1, numel(images));
    for k = 1:numel(images), levels(k) = images(k).header.idlvl; end
    for k = 1:numel(images)
        positions(k,:) = images(k).header.iloc(:).';
        parent = images(k).header.ialvl;
        for depth = 1:numel(images)
            index = find(levels == parent, 1);
            if parent == 0 || isempty(index), break; end
            positions(k,:) = positions(k,:)+images(index).header.iloc(:).';
            parent = images(index).header.ialvl;
        end
    end
end

function value = complexity(h, images, positions) %#codegen
    %complexity - Account for all imagery, composite placement and segment counts
    value = 3;
    upper = [0 0];
    for k = 1:numel(images)
        im = images(k).header;
        upper = max(upper, positions(k,:)+[im.nrows im.ncols]);
        bands = size(images(k).data, 3);
        if max(im.nppbh, im.nppbv) > 2048 || bands > 9, value = max(value, 5); end
        if bands > 255 || (strcmp(im.irep, 'RGB') && im.nbpp > 8), value = max(value, 7); end
        if bands > 999, value = 9; end
    end
    extent = max(upper);
    if extent > 2048 || h.numi > 20 || h.fl >= 52428800, value = max(value, 5); end
    if extent > 8192 || h.numdes > 10 || h.fl >= 1073741824, value = max(value, 6); end
    if extent > 65536 || h.numdes > 50 || h.fl >= 2147483648, value = max(value, 7); end
    if h.numi > 100 || h.numt > 32 || h.numdes > 100 || h.fl >= 10737418240, value = 9; end
    frames = zeros(1,numel(images));
    for k = 1:numel(images), frames(k) = images(k).number_frames; end
    if any(frames > 1), value = motionComplexity(h,images,positions); end
end

function value = motionComplexity(header,images,positions) %#codegen
    %motionComplexity - Apply current MIE Table 15 to the complete file
    value = 51;
    if header.fl > 214748364800, value = 54; end
    if header.fl > 429496729600, value = 57; end
    for k = 1:numel(images)
        h = images(k).header; extent = max(positions(k,:)+[h.nrows h.ncols]);
        dimensions = [h.nrows h.ncols]; bands = size(images(k).data,3);
        if extent > 8192 || max(dimensions) > 8192 || bands > 9, value = max(value,54); end
        if extent > 65536 || max(dimensions) > 65536 || min(dimensions) > 32768 || bands > 255
            value = 57;
        end
    end
end

function discardTemporary(filename) %#codegen
    %discardTemporary - Remove only an unfinished temporary output
    if isfile(filename), delete(filename); end
end
