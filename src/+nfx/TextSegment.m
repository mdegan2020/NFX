classdef TextSegment
    %TextSegment - Standard text with ordered TRE snapshots
    %   OBJ = TextSegment(TEXT,header=HEADER) stores BCS text. TEXT must be a
    %   character row or string scalar. Line endings are normalized to CR/LF;
    %   printable ASCII and form-feed characters are preserved.
    %
    %   OBJ = OBJ + TRE attaches a validated metadata snapshot. Remove a
    %   logical attachment with removeTRE(OBJ,ID), using OBJ.tre_ids.
    %
    %   See also TextHeader, File, FREESA

    properties
        header (1,1) nfx.TextHeader = nfx.TextHeader()
    end
    properties (Dependent)
        data % Normalized standard text
    end
    properties (Dependent, SetAccess = private)
        lt % Text data length in bytes
        ltsh % Text subheader length in bytes
        tre_ids % Logical attachment IDs
        tre_tags % Logical attachment tags
        tre_records % Physical record snapshots
    end
    properties (Access = private)
        textValue = ''
        store = nfx.internal.TREStore()
    end
    methods
        function [tre, ok, status] = FCRNSA(obj, index, options) %#codegen
            %FCRNSA - Retrieve an editable copy of a direct FCRNSA attachment
            %   [TRE, OK, STATUS] = OBJ.FCRNSA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FCRNSA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FCRNSA and OK=false.
            %
            %   See also tre, treCount, nfx.FCRNSA.deserialize
            arguments
                obj (1,1) nfx.TextSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FCRNSA(), index, options.ID);
        end

        function [tre, ok, status] = FREESA(obj, index, options) %#codegen
            %FREESA - Retrieve an editable copy of a direct FREESA attachment
            %   [TRE, OK, STATUS] = OBJ.FREESA(INDEX) selects the INDEXth
            %   logical occurrence in insertion order; INDEX defaults to 1.
            %   OBJ.FREESA(ID=ID) selects its stable attachment identity.
            %   Failure returns a default scalar FREESA and OK=false.
            %
            %   See also tre, treCount, nfx.FREESA.deserialize
            arguments
                obj (1,1) nfx.TextSegment
                index = 1
                options.ID = []
            end
            [tre, ok, status] = readTRE( ...
                obj.tre_records, nfx.FREESA(), index, options.ID);
        end

        function [count, ok, status] = treCount(obj, tag) %#codegen
            %treCount - Count direct logical TRE attachments
            %   N = OBJ.treCount(TAG) counts matching logical attachments.
            %   N = OBJ.treCount() counts all types, including continuations
            %   as one attachment. Wrapper children are inspected separately.
            %
            %   See also tre, tre_ids, tre_records
            arguments
                obj (1,1) nfx.TextSegment
                tag = ''
            end
            [count, ok, status] = countTRE(obj.tre_records, tag);
        end

        function [record, ok, status] = tre(obj, index, options) %#codegen
            %tre - Inspect one logical attachment through a scalar view
            %   [RECORD, OK, STATUS] = OBJ.tre(INDEX) selects all TRE types
            %   in insertion order. INDEX defaults to 1. OBJ.tre(ID=ID)
            %   selects a stable attachment identity. Failure returns a
            %   default scalar nfx.TRERecord and OK=false.
            %
            %   See also nfx.TRERecord, treCount
            arguments
                obj (1,1) nfx.TextSegment
                index = 1
                options.ID = []
            end
            [record, ok, status] = viewTRE( ...
                obj.tre_records, index, options.ID);
        end
    end
    methods
        function obj = TextSegment(data, options) %#codegen
            %TextSegment - Construct normalized text and its metadata
            arguments
                data = ''
                options.header (1,1) nfx.TextHeader = nfx.TextHeader()
            end
            obj.data = data;
            obj.header = options.header;
        end
        function value = get.data(obj) %#codegen
            %get.data - Return normalized standard text
            value = obj.textValue;
        end
        function obj = set.data(obj, value) %#codegen
            %set.data - Validate BCS text and normalize line endings
            if ~(ischar(value) && (isrow(value) || isempty(value))) && ...
                    ~(isstring(value) && isscalar(value) && ~ismissing(value))
                error('nfx:TextData', 'Supply a character row or a nonmissing string scalar.');
            end
            value = char(value);
            if any((value < ' ' | value > '~') & value ~= 10 & value ~= 12 & value ~= 13)
                error('nfx:TextData', 'STA permits printable ASCII, line breaks, and form feed.');
            end
            value = strrep(value, char([13 10]), newline);
            value = strrep(value, char(13), newline);
            obj.textValue = strrep(value, newline, char([13 10]));
        end
        function value = get.lt(obj) %#codegen
            %get.lt - Derive text payload length
            value = numel(obj.textValue);
        end
        function value = get.ltsh(obj) %#codegen
            %get.ltsh - Derive the header length after overflow selection
            [inline, overflow] = obj.store.areas(9713);
            value = 282+numel(inline)+3*(~isempty(inline) || ~isempty(overflow));
        end
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return logical IDs in insertion order
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return logical tags in insertion order
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Return the physical snapshots
            value = obj.store.records;
        end
        function obj = plus(obj, tre) %#codegen
            %PLUS - Attach a validated value snapshot
            arguments
                obj (1,1) nfx.TextSegment
                tre (1,1) nfx.TRE
            end
            obj.store = obj.store.attach(tre, 'text');
        end
        function obj = removeTRE(obj, id) %#codegen
            %removeTRE - Remove a logical attachment without reordering others
            arguments
                obj (1,1) nfx.TextSegment
                id {mustBeMetadata(id, 1, 9007199254740991, 1), mustBeFinite}
            end
            obj.store = obj.store.remove(id);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check metadata and byte-length limits
            report = newReport('NITF 2.1 text segment');
            report = mergeReport(report, validate(obj.header), 'header.');
            report = addIssue(report, obj.lt < 1 || obj.lt > 99998, 'TextLength', ...
                'data', 'Text payload must contain 1 to 99998 bytes.', 'JBP 2025.1, Table 5.11-1');
        end
    end
    methods (Access = ?nfx.File)
        function [inline, overflow] = areas(obj) %#codegen
            %AREAS - Select complete inline records within the text header
            [inline, overflow] = obj.store.areas(9713);
        end
        function value = subheader(obj, inline, overflow) %#codegen
            %SUBHEADER - Encode the preflight-selected metadata area
            value = bytes(obj.header, inline, overflow);
        end
    end
end
