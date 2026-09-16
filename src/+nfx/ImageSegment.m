classdef ImageSegment
    %ImageSegment - Image pixels, header, and ordered TRE snapshots
    %   OBJ = ImageSegment creates an empty segment for incremental editing.
    %
    %   OBJ = ImageSegment(DATA) attaches dense real uint8 or uint16 pixels
    %   in rows-by-columns-by-bands-by-frames order without converting class.
    %   Multiple frames require matching MTIMSA timing and a motion ICAT.
    %
    %   OBJ = ImageSegment(DATA,header=HEADER) also supplies image metadata.
    %   Derived fields always reflect DATA and current block dimensions.
    %
    %   ImageSegment functions:
    %       plus      - Append a validated TRE snapshot
    %       removeTRE - Remove one attachment by its ID
    %       validate  - Check header, data, and attached TREs
    %
    %   ImageSegment properties:
    %       data     - Native pixel array
    %       header   - Editable image header with derived dimensions
    %       tre_ids  - Attachment IDs in insertion order
    %       tre_tags - Six-character tags in insertion order
    %       lish     - Derived subheader byte length
    %       li       - Derived padded image byte length
    %
    %   See also ImageHeader, RPC00B, File

    properties (Dependent)
        data % Native rows-by-columns-by-bands-by-frames pixels
        header % Metadata with fresh derived fields
    end
    properties (Dependent, SetAccess = private)
        tre_ids % Ordered private-collection identities, exposed for removal
        tre_tags % Ordered tags, one row per attachment
        tre_records % Physical record snapshots, including logical attachment IDs
        lish % Serialized image header length
        li % Serialized padded pixel length
        number_frames % Frame count derived from the fourth pixel dimension
    end
    properties (Access = private)
        pixels = zeros(0, 0, 'uint8')
        headerValue
        store = nfx.internal.TREStore()
        stats = struct('bits', 1, 'trailing', 8)
    end
    methods
        function obj = ImageSegment(data, options) %#codegen
            %ImageSegment - Construct a segment without pixel conversion
            arguments
                data {mustBePixels} = zeros(0, 0, 'uint8')
                options.header (1,1) nfx.ImageHeader = nfx.ImageHeader()
            end
            obj.pixels = data;
            obj.stats = pixelStatistics(data);
            obj.headerValue = options.header;
        end
        function value = get.data(obj) %#codegen
            %get.data - Return the native pixel array
            value = obj.pixels;
        end
        function obj = set.data(obj, value) %#codegen
            %set.data - Replace pixels without an implicit type conversion
            mustBePixels(value);
            obj.pixels = value;
            obj.stats = pixelStatistics(value);
        end
        function value = get.header(obj) %#codegen
            %get.header - Derive structural fields on access
            value = derive(obj.headerValue, obj.pixels, obj.stats);
        end
        function obj = set.header(obj, value) %#codegen
            %set.header - Replace editable image metadata
            arguments
                obj (1,1) nfx.ImageSegment
                value (1,1) nfx.ImageHeader
            end
            obj.headerValue = value;
        end
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return attachment identifiers in insertion order
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return attachment tags in insertion order
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Return physical snapshots for inspection
            value = obj.store.records;
        end
        function value = get.lish(obj) %#codegen
            %get.lish - Derive the subheader length with whole-record overflow
            [inline, user, overflow, overflowUser] = obj.store.modelAreas(99985);
            h = obj.header;
            bands = size(obj.pixels, 3);
            value = 426 + 13*bands + 5*(bands > 9) + ...
                60*~strcmp(h.icords, ' ') + 80*h.nicom + numel(inline) + numel(user) + ...
                3*(~isempty(inline) || (~isempty(overflow) && ~overflowUser)) + ...
                3*(~isempty(user) || (~isempty(overflow) && overflowUser));
        end
        function value = get.li(obj) %#codegen
            %get.li - Derive padded image byte length
            h = obj.header;
            value = h.nbpr * h.nbpc * h.nppbh * h.nppbv * ...
                size(obj.pixels, 3) * obj.number_frames * (h.nbpp / 8);
        end
        function value = get.number_frames(obj) %#codegen
            %get.number_frames - Derive the stored frame count
            value = size(obj.pixels,4);
        end
        function obj = plus(obj, tre) %#codegen
            %PLUS - Append a serialized TRE snapshot
            %   OBJ = OBJ + TRE validates TRE and appends its current state.
            %   Later edits to TRE leave OBJ unchanged. Use TRE_IDS to select
            %   an attachment for removal. Placement is checked on attachment.
            arguments
                obj (1,1) nfx.ImageSegment
                tre (1,1) nfx.TRE
            end
            obj.store = obj.store.attach(tre, 'image');
        end
        function obj = removeTRE(obj, id) %#codegen
            %removeTRE - Remove one attachment without reordering others
            %   OBJ = removeTRE(OBJ,ID) removes the attachment identified in
            %   OBJ.tre_ids. Removed IDs are not reused within this collection.
            arguments
                obj (1,1) nfx.ImageSegment
                id {mustBeMetadata(id, 1, 9007199254740991, 1), mustBeFinite}
            end
            obj.store = obj.store.remove(id);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the supported image and attached metadata
            %   REPORT = VALIDATE(OBJ) aggregates header and segment issues.
            %   Repeated RPC00B attachments can be edited and removed, but a
            %   writable image may contain at most one RPC00B model.
            arguments
                obj (1,1) nfx.ImageSegment
            end
            report = validateStructure(obj);
            [extended,user,overflow,~] = obj.store.modelAreas(99985);
            item = struct('owner',1,'offset',0,'data',zeros(1,0,'uint8'));
            areas = repmat(item,1,3);
            areas(1).data = user; areas(2).data = extended; areas(2).offset = numel(user);
            areas(3).data = overflow; areas(3).offset = numel(user)+numel(extended);
            [contexts,child] = frameContexts(contextNodes(areas),obj);
            report = mergeReport(report,child,'');
            if child.valid, report = mergeReport(report,contextImageReport(contexts,obj),''); end
        end
    end

    methods (Access = ?nfx.File)
        function report = validateStructure(obj) %#codegen
            %validateStructure - Check storage before resolving metadata contexts
            report = newReport('NITF 2.1 image segment');
            report = mergeReport(report, validate(obj.header), 'header.');
            reference = 'JBP 2025.1, 5.9 and 5.13; STDI-0002-1 App E, E.3.12';
            report = addIssue(report, isempty(obj.pixels), 'PixelsRequired', ...
                'data', 'Attach a nonempty pixel array.', reference);
            report = addIssue(report, sum(strcmp({obj.store.records.tag}, 'RPC00B')) > 1, ...
                'DuplicateRPC', 'tre_ids', 'Remove duplicate RPC00B attachments before writing.', reference);
            report = mergeReport(report,motionImageReport(obj.store.records,obj.header,obj.number_frames),'motion.');
            report = addIssue(report, obj.li > 9999999998 || obj.lish > 999998, ...
                'Length', 'li/lish', 'Image data or subheader exceeds its NITF length field.', reference);
        end
        function value = subheader(obj, inline, overflow, user, userOverflow) %#codegen
            %SUBHEADER - Serialize the preflight-selected metadata areas
            value = bytes(obj.header, inline, overflow, user, userOverflow);
        end
        function [inline, user, overflow, overflowUser] = areas(obj) %#codegen
            %AREAS - Partition whole records for the owning file
            [inline, user, overflow, overflowUser] = obj.store.modelAreas(99985);
        end
        function value = explicitLevel(obj) %#codegen
            %explicitLevel - Return the caller's level or an automatic marker
            value = explicitLevel(obj.headerValue);
        end
        function obj = resolveLevel(obj, value) %#codegen
            %resolveLevel - Refresh the containing file's display default
            obj.headerValue = resolveLevel(obj.headerValue, value);
        end
        function count = writePixels(obj, fid) %#codegen
            %writePixels - Stream band-interleaved blocks in big-endian order
            h = obj.header;
            count = 0;
            for blockRow = 1:h.nbpc
                rows = (blockRow-1)*h.nppbv+1:min(blockRow*h.nppbv, h.nrows);
                for blockCol = 1:h.nbpr
                    cols = (blockCol-1)*h.nppbh+1:min(blockCol*h.nppbh, h.ncols);
                    for frame = 1:obj.number_frames
                        for band = 1:size(obj.pixels, 3)
                            % Transpose just this block for row-major storage.
                            block = zeros(h.nppbh, h.nppbv, 'like', obj.pixels);
                            block(1:numel(cols), 1:numel(rows)) = obj.pixels(rows, cols, band, frame).';
                            if isa(block, 'uint16')
                                buffer = zeros(2, numel(block), 'uint8');
                                buffer(1,:) = uint8(bitshift(block(:), -8));
                                buffer(2,:) = uint8(bitand(block(:), uint16(255)));
                                count = count + writeBytes(fid, buffer);
                            else
                                count = count + writeBytes(fid, block);
                            end
                        end
                    end
                end
            end
        end
    end
end
