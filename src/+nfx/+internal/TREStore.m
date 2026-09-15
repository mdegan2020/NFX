classdef (Hidden) TREStore
    %TREStore - Ordered value snapshots shared by NITF metadata owners
    properties (SetAccess = private)
        records = repmat(struct('tag', '      ', 'payload', zeros(1,0,'uint8'), 'id', 0), 1, 0)
    end
    properties (Access = private)
        nextId = 1
    end
    properties (Dependent, SetAccess = private)
        ids
        tags
    end
    methods
        function value = get.ids(obj) %#codegen
            %get.ids - Return logical identities in insertion order
            value = unique([obj.records.id], 'stable');
        end
        function value = get.tags(obj) %#codegen
            %get.tags - Return one tag per logical attachment
            ids = obj.ids;
            value = repmat(' ', numel(ids), 6);
            for k = 1:numel(ids)
                value(k,:) = obj.records(find([obj.records.id] == ids(k), 1)).tag;
            end
        end
        function obj = attach(obj, tre, owner) %#codegen
            %ATTACH - Validate placement and capture the supplied record
            switch class(tre)
                case 'nfx.RPC00B'
                    legal = strcmp(owner, 'image');
                case 'nfx.FREESA'
                    legal = any(strcmp(owner, {'file','image','text'}));
                otherwise
                    error('nfx:UnsupportedTRE', 'This concrete TRE is not supported.');
            end
            if ~legal, error('nfx:TREPlacement', '%s cannot attach to %s.', tre.cetag, owner); end
            framed = bytes(tre);
            if obj.nextId >= flintmax
                error('nfx:AttachmentId', 'Attachment identity space is exhausted.');
            end
            obj.records(end+1) = struct('tag', tre.cetag, 'payload', framed(12:end), 'id', obj.nextId);
            obj.nextId = obj.nextId+1;
        end
        function obj = remove(obj, id) %#codegen
            %REMOVE - Remove every physical record in a logical attachment
            selected = [obj.records.id] == id;
            if ~any(selected), error('nfx:UnknownAttachment', 'No TRE attachment has ID %g.', id); end
            obj.records(selected) = [];
        end
        function [inline, overflow] = areas(obj, capacity) %#codegen
            %AREAS - Keep a whole-record prefix inline and move its suffix
            lengths = zeros(1, numel(obj.records));
            for k = 1:numel(lengths), lengths(k) = 11+numel(obj.records(k).payload); end
            count = find(cumsum(lengths) > capacity, 1)-1;
            if isempty(count), count = numel(lengths); end
            inline = encode(obj.records(1:count), sum(lengths(1:count)));
            overflow = encode(obj.records(count+1:end), sum(lengths(count+1:end)));
        end
    end
end

function value = encode(records, count) %#codegen
    %encode - Serialize validated snapshots without changing their order
    value = zeros(1, count, 'uint8');
    offset = 0;
    for k = 1:numel(records)
        record = records(k);
        framed = [uint8(record.tag) uint8(sprintf('%05d', numel(record.payload))) record.payload];
        value(offset+1:offset+numel(framed)) = framed;
        offset = offset+numel(framed);
    end
end
