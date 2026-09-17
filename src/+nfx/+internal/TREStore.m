classdef (Hidden) TREStore
    %TREStore - Ordered value snapshots shared by NITF metadata owners
    properties (SetAccess = private)
        records
    end
    properties (Access = private)
        nextId = 1
    end
    properties (Dependent, SetAccess = private)
        ids
        tags
    end
    methods (Static)
        function obj = fromSnapshots(records) %#codegen
            %fromSnapshots - Restore already checked homogeneous snapshots
            %   Internal deserialization supplies contiguous local IDs.
            obj = nfx.internal.TREStore();
            obj.records = records;
            if ~isempty(records)
                obj.nextId = max([records.id]) + 1;
            end
        end
    end
    methods
        function obj = TREStore() %#codegen
            %TREStore - Initialize variable-length homogeneous snapshots
            obj.records = nfx.internal.emptyTRERecords();
        end
        function obj = withJPEG2000(obj,payload)
            %withJPEG2000 - Append a derived record with reserved identity zero
            obj.records(end+1) = struct('tag','J2KLRA','payload',payload,'id',0);
        end
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
                case {'nfx.RPC00B','nfx.CSCRNA','nfx.ICHIPB','nfx.MTIMSA','nfx.AIMIDB','nfx.ACFTB','nfx.HISTOA','nfx.BANDSB','nfx.SENSRB', ...
                        'nfx.RSMIDA','nfx.RSMPCA','nfx.RSMPIA','nfx.RSMGGA','nfx.RSMGIA','nfx.RSMAPB','nfx.RSMECB','nfx.RSMDCB', ...
                        'nfx.CSRLSB','nfx.CSWRPB'}
                    legal = strcmp(owner, 'image');
                case 'nfx.FCRNSA'
                    legal = strcmp(owner, 'image') || ...
                        (any(strcmp(owner, {'file','text'})) && any(strcmp(tre.predict_corners, {'Y','N'})));
                case {'nfx.MIMCSA','nfx.CSDIDA','nfx.TMINTA','nfx.CAMSDA','nfx.MTIMFA','nfx.MICIDA'}
                    legal = strcmp(owner, 'file');
                case {'nfx.MATESA','nfx.ILLUMB','nfx.CSEXRB'}
                    legal = any(strcmp(owner, {'file','image'}));
                case 'nfx.FREESA'
                    legal = any(strcmp(owner, {'file','image','text'}));
                case {'nfx.FSYNWA','nfx.FASYWA','nfx.CONTXA'}
                    % Validate fields before inspecting the serialized context.
                    bytes(tre);
                    legal = any(strcmp(owner,{'file','image'})) && tre.allowsPlacement(owner);
                otherwise
                    error('nfx:UnsupportedTRE', 'This concrete TRE is not supported.');
            end
            if ~legal && ~strcmp(owner,'wrapped')
                error('nfx:TREPlacement', '%s cannot attach to %s.', tre.cetag, owner);
            end
            snapshots = physicalRecords(tre);
            if obj.nextId >= flintmax
                error('nfx:AttachmentId', 'Attachment identity space is exhausted.');
            end
            for k = 1:numel(snapshots)
                obj.records(end+1) = struct('tag', snapshots(k).tag, 'payload', snapshots(k).payload, 'id', obj.nextId);
            end
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
        function [extended, user, overflow, overflowUser] = modelAreas(obj, capacity) %#codegen
            %modelAreas - Fill extended then user areas for GLAS/GFM metadata
            %   Each area retains a whole-record prefix. An indivisible record
            %   that exceeds the area capacity remains in the overflow suffix.
            overflowUser = containsGLAS(obj.records);
            user = zeros(1,0,'uint8');
            if ~overflowUser
                [extended,overflow] = areas(obj,capacity); return
            end
            lengths = zeros(1,numel(obj.records));
            for k = 1:numel(lengths), lengths(k) = 11+numel(obj.records(k).payload); end
            first = find(cumsum(lengths) > capacity,1)-1;
            if isempty(first), first = numel(lengths); end
            second = find(cumsum(lengths(first+1:end)) > capacity,1)-1;
            if isempty(second), second = numel(lengths)-first; end
            last = first+second;
            extended = encode(obj.records(1:first),sum(lengths(1:first)));
            user = encode(obj.records(first+1:last),sum(lengths(first+1:last)));
            overflow = encode(obj.records(last+1:end),sum(lengths(last+1:end)));
        end
    end
end

function value = containsGLAS(records) %#codegen
    %containsGLAS - Recognize model leaves inside validated metadata wrappers
    value = false;
    for k = 1:numel(records)
        data = records(k).payload; tag = records(k).tag; first = 1; last = numel(data);
        while true
            if any(strcmp(tag,{'CSEXRB','CSRLSB','CSWRPB'})), value = true; return; end
            if strcmp(tag,'FSYNWA'), at = first+18;
            elseif strcmp(tag,'FASYWA'), at = first+48;
            elseif strcmp(tag,'CONTXA'), at = first+7+str2double(char(data(first+3:first+6)));
            else, at = last+1;
            end
            if at > numel(data), break; end
            tag = char(data(at:at+5)); length = str2double(char(data(at+6:at+10)));
            first = at+11; last = first+length-1;
        end
    end
end

function value = encode(records, count) %#codegen
    %encode - Serialize validated snapshots without changing their order
    value = zeros(1, count, 'uint8');
    offset = 0;
    for k = 1:numel(records)
        record = records(k);
        framed = [uint8(record.tag) uint8(sprintf('%05.0f', numel(record.payload))) record.payload];
        value(offset+1:offset+numel(framed)) = framed;
        offset = offset+numel(framed);
    end
end
