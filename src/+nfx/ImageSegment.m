classdef ImageSegment
    %ImageSegment - Image pixels, header, and ordered TRE snapshots
    %   OBJ = ImageSegment creates an empty segment for incremental editing.
    %
    %   OBJ = ImageSegment(DATA) attaches dense real uint8 or uint16 pixels
    %   in rows-by-columns-by-bands order without converting their class.
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
        data % Native rows-by-columns-by-bands pixels
        header % Metadata with fresh derived fields
    end
    properties (Dependent, SetAccess = private)
        tre_ids % Ordered private-collection identities, exposed for removal
        tre_tags % Ordered tags, one row per attachment
        lish % Serialized image header length
        li % Serialized padded pixel length
    end
    properties (Access = private)
        pixels = zeros(0, 0, 'uint8')
        headerValue
        records = repmat(struct('tag', '      ', ...
            'payload', zeros(1, 0, 'uint8'), 'id', 0), 1, 0)
        nextId = 1
    end
    methods
        function obj = ImageSegment(data, options) %#codegen
            %ImageSegment - Construct a segment without pixel conversion
            arguments
                data {mustBePixels} = zeros(0, 0, 'uint8')
                options.header (1,1) nfx.ImageHeader = nfx.ImageHeader()
            end
            obj.pixels = data;
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
        end
        function value = get.header(obj) %#codegen
            %get.header - Derive structural fields on access
            value = derive(obj.headerValue, obj.pixels);
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
            value = zeros(1, numel(obj.records));
            for k = 1:numel(value), value(k) = obj.records(k).id; end
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return attachment tags in insertion order
            value = repmat(' ', numel(obj.records), 6);
            for k = 1:numel(obj.records), value(k,:) = obj.records(k).tag; end
        end
        function value = get.lish(obj) %#codegen
            %get.lish - Derive header length without serializing pixels
            bands = size(obj.pixels, 3);
            value = 426 + 13*bands + 5*(bands > 9);
            if ~isempty(obj.records)
                value = value + 3;
                for k = 1:numel(obj.records)
                    value = value + 11 + numel(obj.records(k).payload);
                end
            end
        end
        function value = get.li(obj) %#codegen
            %get.li - Derive padded image byte length
            h = obj.header;
            value = h.nbpr * h.nbpc * h.nppbh * h.nppbv * ...
                size(obj.pixels, 3) * (h.nbpp / 8);
        end
        function obj = plus(obj, tre) %#codegen
            %PLUS - Append a serialized TRE snapshot
            %   OBJ = OBJ + TRE validates TRE and appends its current state.
            %   Later edits to TRE leave OBJ unchanged. Use TRE_IDS to select
            %   an attachment for removal. This candidate accepts RPC00B.
            arguments
                obj (1,1) nfx.ImageSegment
                tre (1,1) nfx.TRE
            end
            if ~isa(tre, 'nfx.RPC00B')
                error('nfx:UnsupportedTRE', 'Only the built-in RPC00B TRE is supported.');
            end
            encoded = payload(tre);
            if obj.nextId >= flintmax
                error('nfx:AttachmentId', 'Attachment identity space is exhausted.');
            end
            obj.records(end + 1) = struct('tag', tre.cetag, ...
                'payload', encoded, 'id', obj.nextId);
            obj.nextId = obj.nextId + 1;
        end
        function obj = removeTRE(obj, id) %#codegen
            %removeTRE - Remove one attachment without reordering others
            %   OBJ = removeTRE(OBJ,ID) removes the attachment identified in
            %   OBJ.tre_ids. Removed IDs are not reused within this collection.
            arguments
                obj (1,1) nfx.ImageSegment
                id {mustBeMetadata(id, 1, 9007199254740991, 1), mustBeFinite}
            end
            index = find(obj.tre_ids == id, 1);
            if isempty(index)
                error('nfx:UnknownAttachment', 'No TRE attachment has ID %g.', id);
            end
            obj.records(index) = [];
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the supported image and attached metadata
            %   REPORT = VALIDATE(OBJ) aggregates header and segment issues.
            %   Repeated RPC00B attachments can be edited and removed, but a
            %   writable image may contain at most one RPC00B model.
            arguments
                obj (1,1) nfx.ImageSegment
            end
            report = newReport('NITF 2.1 image segment');
            report = mergeReport(report, validate(obj.header), 'header.');
            reference = 'JBP 2025.1, 5.9 and 5.13; STDI-0002-1 App E, E.3.12';
            report = addIssue(report, isempty(obj.pixels), 'PixelsRequired', ...
                'data', 'Attach a nonempty pixel array.', reference);
            report = addIssue(report, numel(obj.records) > 1, 'DuplicateRPC', ...
                'tre_ids', 'Remove duplicate RPC00B attachments before writing.', reference);
            extensionLength = 0;
            for k = 1:numel(obj.records)
                extensionLength = extensionLength + 11 + numel(obj.records(k).payload);
            end
            report = addIssue(report, extensionLength > 99985, 'TREOverflow', ...
                'tre_ids', 'Inline TRE area exceeds 99985 bytes; overflow is not supported.', reference);
            report = addIssue(report, obj.li > 9999999998 || obj.lish > 999998, ...
                'Length', 'li/lish', 'Image data or subheader exceeds its NITF length field.', reference);
        end
    end
    methods (Access = ?nfx.File)
        function value = subheader(obj) %#codegen
            %SUBHEADER - Serialize the attached snapshots into the header
            count = 0;
            for k = 1:numel(obj.records)
                count = count + 11 + numel(obj.records(k).payload);
            end
            extensions = zeros(1, count, 'uint8');
            offset = 0;
            for k = 1:numel(obj.records)
                record = obj.records(k);
                count = 11 + numel(record.payload);
                extensions(offset+1:offset+count) = [uint8(record.tag) ...
                    decimalField(numel(record.payload), 5, 0, false) record.payload];
                offset = offset + count;
            end
            value = bytes(obj.header, extensions);
        end
        function count = writePixels(obj, fid) %#codegen
            %writePixels - Stream band-interleaved blocks in big-endian order
            h = obj.header;
            count = 0;
            for blockRow = 1:h.nbpc
                rows = (blockRow-1)*h.nppbv+1:min(blockRow*h.nppbv, h.nrows);
                for blockCol = 1:h.nbpr
                    cols = (blockCol-1)*h.nppbh+1:min(blockCol*h.nppbh, h.ncols);
                    for band = 1:size(obj.pixels, 3)
                        % Transpose only this block, so linear storage is row-major.
                        block = zeros(h.nppbh, h.nppbv, 'like', obj.pixels);
                        block(1:numel(cols), 1:numel(rows)) = obj.pixels(rows, cols, band).';
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
