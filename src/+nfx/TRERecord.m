classdef (Sealed) TRERecord
    %TRERecord - Inspect one logical serialized TRE attachment
    %   RECORD = IMAGE.tre(INDEX) returns an independent scalar snapshot
    %   view. DISP(RECORD) selects its concrete decoder for a bounded
    %   display. RECORD.RECORDS retains the complete physical snapshots.
    %   Use typed owner methods, such as IMAGE.RPC00B, to retrieve an
    %   independently editable concrete object.
    %
    %   An absent selection returns a default scalar view and OK=false
    %   from the owner's tre method. No decoded object is retained here.
    %
    %   See also ImageSegment.tre, File.tre, MetadataWrapper.tre

    properties (SetAccess = private)
        records
    end
    properties (Dependent, SetAccess = private)
        tag
        id
        physical_count
        byte_count
    end
    methods (Static, Access = ?nfx.internal.FileReader)
        function [ok, status] = checkReadGroup(records, owner) %#codegen
            %checkReadGroup - Validate supported bytes and their direct owner
            [ok, status] = validateWrappedRecords(records);
            if ~ok, return; end
            tag = records(1).tag; payload = records(1).payload;
            if strcmp(owner, 'text')
                legal = strcmp(tag, 'FREESA') || ...
                    (strcmp(tag, 'FCRNSA') && any(payload(1) == 'YN'));
            elseif any(strcmp(tag, {'J2KLRA', 'MTIMSA'}))
                legal = strcmp(owner, 'image');
            else
                legal = wrapperLegal(tag, payload, owner);
            end
            if ~legal
                ok = false;
                status = decodeStatus('InvalidPlacement', ...
                    'This TRE is not supported on its encoded owner.');
            end
        end
    end
    methods
        function obj = TRERecord(records) %#codegen
            %TRERecord - Capture a homogeneous physical-record group
            arguments
                records = nfx.internal.emptyTRERecords()
            end
            obj.records = nfx.internal.emptyTRERecords();
            if ~isstruct(records) || ~(isrow(records) || isempty(records)) || ...
                    numel(fieldnames(records)) ~= 3 || ...
                    ~all(isfield(records, {'tag', 'payload', 'id'}))
                return
            end
            for k = 1:numel(records)
                entry = records(k);
                valid = ischar(entry.tag) && isequal(size(entry.tag), [1 6]) && ...
                    all(entry.tag >= ' ' & entry.tag <= '~') && ...
                    isa(entry.payload, 'uint8') && isrow(entry.payload) && ...
                    ~isempty(entry.payload) && numel(entry.payload) <= 99985 && ...
                    isa(entry.id, 'double') && isscalar(entry.id) && ...
                    isreal(entry.id) && ~issparse(entry.id) && ...
                    isfinite(entry.id) && entry.id >= 0 && ...
                    entry.id < flintmax && fix(entry.id) == entry.id;
                if ~valid
                    return
                end
                if k > 1 && (~strcmp(entry.tag, records(1).tag) || ...
                        entry.id ~= records(1).id)
                    return
                end
            end
            obj.records = records;
        end

        function value = get.tag(obj) %#codegen
            %get.tag - Return the concrete tag or blank for an absent record
            value = '';
            if ~isempty(obj.records)
                value = obj.records(1).tag;
            end
        end

        function value = get.id(obj) %#codegen
            %get.id - Return the owner identity or NaN for an absent record
            value = NaN;
            if ~isempty(obj.records)
                value = obj.records(1).id;
            end
        end

        function value = get.physical_count(obj) %#codegen
            %get.physical_count - Count the encoded continuation instances
            value = numel(obj.records);
        end

        function value = get.byte_count(obj) %#codegen
            %get.byte_count - Count payload bytes excluding record envelopes
            value = 0;
            for k = 1:numel(obj.records)
                value = value + numel(obj.records(k).payload);
            end
        end

        function disp(obj) %#codegen
            %disp - Decode a temporary concrete value for bounded inspection
            if isempty(obj.records)
                fprintf('  nfx.TRERecord: no attachment\n');
                return
            end
            fprintf('  %s (ID %.0f, %.0f records, %.0f payload bytes)\n', ...
                strtrim(obj.tag), obj.id, obj.physical_count, obj.byte_count);
            displayTRERecords(obj.records);
        end
    end
end
