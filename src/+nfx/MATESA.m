classdef (Sealed) MATESA < nfx.TRE
    %MATESA - Identifiers for related files and image segments
    %   OBJ = MATESA(Name=VALUE) supplies CUR_SOURCE, CUR_MATE_TYPE,
    %   CUR_FILE_ID, and GROUPS. GROUPS is a row struct array with fields
    %   relationship and mates. Each mates row struct array contains source,
    %   mate_type, and mate_id. Counts and identifier lengths are derived.
    %
    %   The caller supplies mates in the required chronological order. A
    %   record that exceeds the TRE length limit must be divided into further
    %   MATESA instances, retaining that order and current-file identification.
    %   Text fields support the complete one-byte ECS-A character set.
    %
    %   See also TRE, File, ImageSegment

    properties (Constant)
        cetag = 'MATESA'
    end
    properties
        cur_source {mustBeECS(cur_source, 42)} = ''
        cur_mate_type {mustBeECS(cur_mate_type, 16)} = ''
        cur_file_id {mustBeECS(cur_file_id, 9999)} = ''
        groups {mustBeMateGroups} = struct('relationship', {}, 'mates', {})
    end
    properties (Dependent, SetAccess = private)
        cur_file_id_len
        num_groups
        num_mates
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable MATESA value
            %   [OBJ, OK, STATUS] = nfx.MATESA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also MATESA, MATESA.payload
            arguments
                data
            end
            obj = nfx.MATESA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(42, true, true);
            if reader.ok
                obj.cur_source = value;
            end
            [value, reader] = reader.text(16, true, true);
            if reader.ok
                obj.cur_mate_type = value;
            end
            [width, reader] = reader.count(4, 1, 9999);
            [identifier, reader] = reader.text(width, false, true);
            [count, reader] = reader.count(4, 28, 9999);
            mate = struct('source', '', 'mate_type', '', 'mate_id', '');
            group = struct('relationship', '', 'mates', repmat(mate, 1, 0));
            groups = repmat(group, 1, count);
            for k = 1:count
                [groups(k).relationship, reader] = reader.text(24, true, true);
                [number, reader] = reader.count(4, 62, 9999);
                mates = repmat(mate, 1, number);
                for j = 1:number
                    [mates(j).source, reader] = reader.text(42, true, true);
                    [mates(j).mate_type, reader] = reader.text(16, true, true);
                    [width, reader] = reader.count(4, 1, 9999);
                    [mates(j).mate_id, reader] = reader.text(width, false, true);
                end
                groups(k).mates = mates;
            end
            if reader.ok
                obj.cur_file_id = identifier;
                obj.groups = groups;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MATESA());
        end
    end
    methods
        function obj = MATESA(options) %#codegen
            %MATESA - Construct editable grouped relationship metadata
            arguments
                options.?nfx.MATESA
            end
            if isfield(options, 'cur_source'), obj.cur_source = options.cur_source; end
            if isfield(options, 'cur_mate_type'), obj.cur_mate_type = options.cur_mate_type; end
            if isfield(options, 'cur_file_id'), obj.cur_file_id = options.cur_file_id; end
            if isfield(options, 'groups'), obj.groups = options.groups; end
        end
        function value = get.cur_file_id_len(obj) %#codegen
            %get.cur_file_id_len - Derive the current identifier's byte length
            value = numel(char(obj.cur_file_id));
        end
        function value = get.num_groups(obj) %#codegen
            %get.num_groups - Derive the number of relationship groups
            value = numel(obj.groups);
        end
        function value = get.num_mates(obj) %#codegen
            %get.num_mates - Derive mate counts in relationship order
            value = zeros(1, obj.num_groups);
            for k = 1:obj.num_groups, value(k) = numel(obj.groups(k).mates); end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check relationship codes, identifiers, and record limits
            report = newReport('STDI-0002 Appendix AK MATESA');
            reference = 'STDI-0002-1 Appendix AK, AK6 and AK7';
            report = addIssue(report, ~validMateID(obj.cur_mate_type, obj.cur_file_id), ...
                'MateIdentifier', 'cur_mate_type/cur_file_id', 'Supply a supported identifier type and a nonblank matching ID.', reference);
            report = addIssue(report, obj.num_groups < 1 || obj.num_groups > 9999, ...
                'MateGroups', 'groups', 'Each instance requires 1 to 9999 relationship groups.', reference);
            count = 66+obj.cur_file_id_len;
            for k = 1:obj.num_groups
                group = obj.groups(k);
                report = addIssue(report, ~validRelationship(group.relationship), 'MateRelationship', ...
                    sprintf('groups(%d).relationship', k), 'Use a published relationship and permitted PRE_/POST_ modifier.', reference);
                report = addIssue(report, isempty(group.mates) || numel(group.mates) > 9999, ...
                    'MateCount', sprintf('groups(%d).mates', k), 'Each group requires 1 to 9999 mates.', reference);
                count = count+28;
                for m = 1:numel(group.mates)
                    mate = group.mates(m);
                    report = addIssue(report, ~validMateID(mate.mate_type, mate.mate_id), ...
                        'MateIdentifier', sprintf('groups(%d).mates(%d)', k, m), ...
                        'Supply a supported identifier type and a nonblank matching ID.', reference);
                    count = count+62+numel(char(mate.mate_id));
                end
            end
            report = addIssue(report, count > 99985, 'TRELength', 'groups', ...
                'Divide mates into further MATESA instances while preserving chronological order.', reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode groups and mates in their supplied order
            requireValid(validate(obj));
            count = 66+obj.cur_file_id_len;
            for k = 1:obj.num_groups
                count = count+28;
                for m = 1:numel(obj.groups(k).mates)
                    count = count+62+numel(char(obj.groups(k).mates(m).mate_id));
                end
            end
            value = zeros(1, count, 'uint8');
            initial = [textField(obj.cur_source, 42) textField(obj.cur_mate_type, 16) ...
                decimalField(obj.cur_file_id_len, 4, 0, false) uint8(char(obj.cur_file_id)) ...
                decimalField(obj.num_groups, 4, 0, false)];
            offset = numel(initial);
            value(1:offset) = initial;
            for k = 1:obj.num_groups
                group = obj.groups(k);
                value(offset+1:offset+28) = [textField(group.relationship, 24) ...
                    decimalField(numel(group.mates), 4, 0, false)];
                offset = offset+28;
                for m = 1:numel(group.mates)
                    mate = group.mates(m);
                    item = [textField(mate.source, 42) textField(mate.mate_type, 16) ...
                        decimalField(numel(char(mate.mate_id)), 4, 0, false) uint8(char(mate.mate_id))];
                    value(offset+1:offset+numel(item)) = item;
                    offset = offset+numel(item);
                end
            end
        end
    end
end

function mustBeMateGroups(value) %#codegen
    %mustBeMateGroups - Require the concrete nested relationship structure
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~all(isfield(value, {'relationship','mates'})) || numel(fieldnames(value)) ~= 2
        error('nfx:MateGroups', 'Supply relationship/mates row structs.');
    end
    for k = 1:numel(value)
        mustBeECS(value(k).relationship, 24);
        mates = value(k).mates;
        if ~isstruct(mates) || ~(isrow(mates) || isempty(mates)) || ...
                ~all(isfield(mates, {'source','mate_type','mate_id'})) || numel(fieldnames(mates)) ~= 3
            error('nfx:MateGroups', 'Each mates value must be a source/mate_type/mate_id row struct array.');
        end
        for m = 1:numel(mates)
            mustBeECS(mates(m).source, 42);
            mustBeECS(mates(m).mate_type, 16);
            mustBeECS(mates(m).mate_id, 9999);
        end
    end
end

function valid = validMateID(kind, id) %#codegen
    %validMateID - Check the identifier's type and directly inferable syntax
    kind = strtrim(char(kind));
    id = char(id);
    valid = ~isempty(strtrim(id));
    switch kind
        case {'FTITLE','IID2'}
            valid = valid && numel(id) <= 80;
        case {'FILENAME','DOCID'}
            % Meaning and long-term stability are supplied by the producer.
        case 'UUID'
            valid = valid && validUUID(id);
        case 'URN'
            valid = valid && startsWith(id, 'urn:') && numel(id) > 4 && ~any(id == ' ');
        case 'URL'
            valid = valid && contains(id, ':') && ~any(id == ' ');
        case 'IC-ID'
            valid = valid && startsWith(id, 'guide://') && numel(id) > 8 && ~any(id == ' ');
        otherwise
            valid = false;
    end
end

function valid = validRelationship(value) %#codegen
    %validRelationship - Check published relationships and permitted modifiers
    value = strtrim(char(value));
    modified = false;
    if startsWith(value, 'PRE_')
        value = value(5:end); modified = true;
    elseif startsWith(value, 'POST_')
        value = value(6:end); modified = true;
    end
    if modified
        valid = any(strcmp(value, {'DARKCOLLECT','GEOPOSITION_CALIB','RADIOMTRC_CALIB', ...
            'EVENTEXERCISE','MISSIONSORTIE','SPECIALTASK'}));
    else
        valid = any(strcmp(value, {'CHANGEDETECTION','INCOHERENT_CD','COHERENT_CD', ...
            'BAS','COLLECTION_SET','CONCURRENT','CONTEXT','COUPLED_SET','DSA','LOC', ...
            'MULTILOOK','MULTIMATE','MULTIPHENOM','MULTIVIEW','STEREO','TRIANGULATION', ...
            'DARKCOLLECT','GEOPOSITION_CALIB','RADIOMTRC_CALIB','EVENTEXERCISE', ...
            'MISSIONSORTIE','PATTERNOFLIFE','SPECIALTASK','CHILD','IDP','PARENT','SIBLING', ...
            'DEM','EXPLOITPROD','FUSION','MOSAIC','PIXEL_METRIC','POINTCLOUD', ...
            'RECTIFICATION','REFERENCE','SHARPEN','SPECIFICATION'}));
    end
end
