classdef (Sealed) ATTPTA < nfx.TRE
    %ATTPTA - Attributed image points
    %   OBJ = ATTPTA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ATTPTA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ATTPTA properties:
    %       cetag - Constant tag identifier
    %       att_cs - ATT_CS metadata
    %       id_type - ID_TYPE metadata
    %       images - IMAGES metadata
    %       global_constants - GLOBAL_CONSTANTS metadata
    %       global_variables - GLOBAL_VARIABLES metadata
    %       groups - GROUPS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ATTPTA' % Registered tag identifier
    end
    properties
        att_cs {mustBeAscii(att_cs, 40)} = '' % ATT_CS metadata
        % ID_TYPE metadata
        id_type {mustBeMetadata(id_type, ...
            1, 2, 1)} = NaN
        % IMAGES repeated entries
        images {mustBeimages} = repmat(newimages(), 1, 0)
        % GLOBAL_CONSTANTS repeated entries
        global_constants {mustBeglobal_constants} = repmat(newglobal_constants(), 1, 0)
        % GLOBAL_VARIABLES repeated entries
        global_variables {mustBeglobal_variables} = repmat(newglobal_variables(), 1, 0)
        % GROUPS repeated entries
        groups {mustBegroups} = repmat(newgroups(), 1, 0)
    end
    methods
        function obj = ATTPTA(options) %#codegen
            arguments
                options.?nfx.ATTPTA
            end
            if isfield(options, 'att_cs')
                obj.att_cs = options.att_cs;
            end
            if isfield(options, 'id_type')
                obj.id_type = options.id_type;
            end
            if isfield(options, 'images')
                obj.images = options.images;
            end
            if isfield(options, 'global_constants')
                obj.global_constants = options.global_constants;
            end
            if isfield(options, 'global_variables')
                obj.global_variables = options.global_variables;
            end
            if isfield(options, 'groups')
                obj.groups = options.groups;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix W, Table 1 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.att_cs))), ...
                'Required', 'att_cs', 'Supply ATT_CS.', reference);
            [~, valid] = treNumber(obj.id_type, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'id_type', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(obj.images) < 1 || ...
                numel(obj.images) > 999, ...
                'Count', 'images', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.images)
                report = validateimages(obj.images(k), report, reference);
            end
            report = addIssue(report, numel(obj.global_constants) < 0 || ...
                numel(obj.global_constants) > 999, ...
                'Count', 'global_constants', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.global_constants)
                report = validateglobal_constants(obj.global_constants(k), report, reference);
            end
            report = addIssue(report, numel(obj.global_variables) < 0 || ...
                numel(obj.global_variables) > 999, ...
                'Count', 'global_variables', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.global_variables)
                report = validateglobal_variables(obj.global_variables(k), report, reference);
            end
            report = addIssue(report, numel(obj.groups) < 1 || ...
                numel(obj.groups) > 999, ...
                'Count', 'groups', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.groups)
                report = validategroups(obj.groups(k), report, reference, obj.global_variables, obj.global_constants);
            end
            if obj.id_type == 2
                for k = 1:numel(obj.images)
                    word = char(obj.images(k).imid);
            report = addIssue(report, numel(word) ~= 5 || ~startsWith(word, 'DL') || ...
                any(word(3:end) < '0' | word(3:end) > '9') || ...
                str2double(word(3:end)) < 1, ...
                'Metadata', 'imid', 'Use DL followed by a three-digit display level.', reference);
                end
            end
            payloadLength = 3 + ...
                40 + ...
                1 + ...
                lengthimages(obj.images) + ...
                lengthglobal_constants(obj.global_constants) + ...
                lengthglobal_variables(obj.global_variables) + ...
                lengthgroups(obj.groups, obj.global_variables, obj.global_constants);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99988, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.images), 3, 0, false)];
            data = [data textField(obj.att_cs, 40)];
            data = [data treNumber(obj.id_type, 1, 0, false, false, false)];
            for k = 1:numel(obj.images)
                data = [data writeimages(obj.images(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.global_constants), 3, 0, false)];
            for k = 1:numel(obj.global_constants)
                data = [data writeglobal_constants(obj.global_constants(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.global_variables), 3, 0, false)];
            for k = 1:numel(obj.global_variables)
                data = [data writeglobal_variables(obj.global_variables(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.groups), 3, 0, false)];
            for k = 1:numel(obj.groups)
                data = [data writegroups(obj.groups(k), obj.global_variables, obj.global_constants)]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = imagesEntry() %#codegen
            %imagesEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.imagesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newimages();
        end

        function entry = global_constantsEntry() %#codegen
            %global_constantsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.global_constantsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newglobal_constants();
        end

        function entry = global_variablesEntry() %#codegen
            %global_variablesEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.global_variablesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newglobal_variables();
        end

        function entry = groupsEntry() %#codegen
            %groupsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.groupsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newgroups();
        end

        function entry = local_constantsEntry() %#codegen
            %local_constantsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.local_constantsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newlocal_constants();
        end

        function entry = local_variablesEntry() %#codegen
            %local_variablesEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.local_variablesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newlocal_variables();
        end

        function entry = pointsEntry() %#codegen
            %pointsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ATTPTA.pointsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newpoints();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.ATTPTA();
            reader = nfx.internal.TREReader(data, 99988);
            [imagesCount, reader] = reader.count(3, 80, 999);
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.att_cs = value; end
            [value, reader] = reader.number(1, 1, 2, ...
                true, false);
            if reader.ok, obj.id_type = value; end
            count = imagesCount;
            entries = repmat(newimages(), 1, 0);
            for k = 1:count
                [entry, reader] = readimages(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.images = entries; end
            [count, reader] = reader.count(3, 54, 999);
            entries = repmat(newglobal_constants(), 1, 0);
            for k = 1:count
                [entry, reader] = readglobal_constants(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.global_constants = entries; end
            [count, reader] = reader.count(3, 54, 999);
            entries = repmat(newglobal_variables(), 1, 0);
            for k = 1:count
                [entry, reader] = readglobal_variables(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.global_variables = entries; end
            [count, reader] = reader.count(3, 10, 999);
            entries = repmat(newgroups(), 1, 0);
            for k = 1:count
                [entry, reader] = readgroups(reader, obj.global_variables, obj.global_constants);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.groups = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ATTPTA());
        end
    end
end

function entry = newimages() %#codegen
    entry = struct( ...
        'imid', '');
end

function mustBeimages(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'imid'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.imid, 80);
    end
end

function report = validateimages(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.imid))), ...
        'Required', 'imid', 'Supply IMID.', reference);
end

function data = writeimages(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.imid, 80)];
end

function [entry, reader] = readimages(reader) %#codegen
    entry = newimages();
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.imid = value; end
end

function count = lengthimages(entries) %#codegen
    count = 0 + 80 * numel(entries);
end

function entry = newglobal_constants() %#codegen
    entry = struct( ...
        'att_id', '', ...
        'att_value', '', ...
        'att_units', '----', ...
        'as', '');
end

function mustBeglobal_constants(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'att_id', ...
                'att_value', ...
                'att_units', ...
                'as'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.att_id, 6);
        mustBeAscii(entry.att_value, 9999);
        mustBeAscii(entry.att_units, 4);
        mustBeAscii(entry.as, 40);
    end
end

function report = validateglobal_constants(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.att_id))), ...
        'Required', 'att_id', 'Supply ATT_ID.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_value))), ...
        'Required', 'att_value', 'Supply ATT_VALUE.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_units))), ...
        'Required', 'att_units', 'Supply ATT_UNITS.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.as))), ...
        'Required', 'as', 'Supply AS.', reference);
end

function data = writeglobal_constants(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.att_id, 6)];
    data = [data decimalField(numel(char(entry.att_value)), 4, 0, false) ...
        uint8(char(entry.att_value))];
    data = [data textField(entry.att_units, 4)];
    data = [data textField(entry.as, 40)];
end

function [entry, reader] = readglobal_constants(reader) %#codegen
    entry = newglobal_constants();
    [value, reader] = reader.text(6, true, false);
    if reader.ok, entry.att_id = value; end
    [count, reader] = reader.count(4, 1, 9999);
    [value, reader] = reader.text(count, false, false);
    if reader.ok, entry.att_value = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.att_units = value; end
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.as = value; end
end

function count = lengthglobal_constants(entries) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 6 + ...
            4 + numel(char(entry.att_value)) + ...
            4 + ...
            40;
    end
end

function entry = newglobal_variables() %#codegen
    entry = struct( ...
        'att_id', '', ...
        'att_len', NaN, ...
        'att_units', '----', ...
        'as', '');
end

function mustBeglobal_variables(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'att_id', ...
                'att_len', ...
                'att_units', ...
                'as'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.att_id, 6);
        mustBeMetadata(entry.att_len, 1, 9999, true);
        mustBeAscii(entry.att_units, 4);
        mustBeAscii(entry.as, 40);
    end
end

function report = validateglobal_variables(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.att_id))), ...
        'Required', 'att_id', 'Supply ATT_ID.', reference);
    [~, valid] = treNumber(entry.att_len, 4, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'att_len', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_units))), ...
        'Required', 'att_units', 'Supply ATT_UNITS.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.as))), ...
        'Required', 'as', 'Supply AS.', reference);
end

function data = writeglobal_variables(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.att_id, 6)];
    data = [data treNumber(entry.att_len, 4, 0, false, false, false)];
    data = [data textField(entry.att_units, 4)];
    data = [data textField(entry.as, 40)];
end

function [entry, reader] = readglobal_variables(reader) %#codegen
    entry = newglobal_variables();
    [value, reader] = reader.text(6, true, false);
    if reader.ok, entry.att_id = value; end
    [value, reader] = reader.number(4, 1, 9999, ...
        true, false);
    if reader.ok, entry.att_len = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.att_units = value; end
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.as = value; end
end

function count = lengthglobal_variables(entries) %#codegen
    count = 3 + 54 * numel(entries);
end

function entry = newgroups() %#codegen
    entry = struct( ...
        'local_constants', repmat(newlocal_constants(), 1, 0), ...
        'local_variables', repmat(newlocal_variables(), 1, 0), ...
        'points', repmat(newpoints(), 1, 0));
end

function mustBegroups(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'local_constants', ...
                'local_variables', ...
                'points'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBelocal_constants(entry.local_constants);
        mustBelocal_variables(entry.local_variables);
        mustBepoints(entry.points);
    end
end

function report = validategroups(entry, report, reference, context_global_variables, context_global_constants) %#codegen
    report = addIssue(report, numel(entry.local_constants) < 0 || ...
        numel(entry.local_constants) > 999, ...
        'Count', 'local_constants', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.local_constants)
        report = validatelocal_constants(entry.local_constants(childK), report, reference);
    end
    report = addIssue(report, numel(entry.local_variables) < 0 || ...
        numel(entry.local_variables) > 999, ...
        'Count', 'local_variables', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.local_variables)
        report = validatelocal_variables(entry.local_variables(childK), report, reference);
    end
    report = addIssue(report, numel(entry.points) < 1 || ...
        numel(entry.points) > 9999, ...
        'Count', 'points', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.points)
        report = validatepoints(entry.points(childK), report, reference, context_global_variables, entry.local_variables);
    end
    report = addIssue(report, isempty(context_global_constants) && isempty(context_global_variables) && ...
        isempty(entry.local_constants) && isempty(entry.local_variables), ...
        'Metadata', 'attributes', 'Every point must have at least one attribute.', reference);
end

function data = writegroups(entry, context_global_variables, ~) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(entry.local_constants), 3, 0, false)];
    for childK = 1:numel(entry.local_constants)
        data = [data writelocal_constants(entry.local_constants(childK))]; %#ok<AGROW>
    end
    data = [data decimalField(numel(entry.local_variables), 3, 0, false)];
    for childK = 1:numel(entry.local_variables)
        data = [data writelocal_variables(entry.local_variables(childK))]; %#ok<AGROW>
    end
    data = [data decimalField(numel(entry.points), 4, 0, false)];
    for childK = 1:numel(entry.points)
        data = [data writepoints(entry.points(childK), context_global_variables, entry.local_variables)]; %#ok<AGROW>
    end
end

function [entry, reader] = readgroups(reader, context_global_variables, ~) %#codegen
    entry = newgroups();
    [childCount, reader] = reader.count(3, 54, 999);
    childEntries = repmat(newlocal_constants(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readlocal_constants(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.local_constants = childEntries; end
    [childCount, reader] = reader.count(3, 54, 999);
    childEntries = repmat(newlocal_variables(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readlocal_variables(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.local_variables = childEntries; end
    [childCount, reader] = reader.count(4, 16, 9999);
    childEntries = repmat(newpoints(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readpoints(reader, context_global_variables, entry.local_variables);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.points = childEntries; end
end

function count = lengthgroups(entries, context_global_variables, ~) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + lengthlocal_constants(entry.local_constants) + ...
            lengthlocal_variables(entry.local_variables) + ...
            lengthpoints(entry.points, context_global_variables, entry.local_variables);
    end
end

function entry = newlocal_constants() %#codegen
    entry = struct( ...
        'att_id', '', ...
        'att_value', '', ...
        'att_units', '----', ...
        'as', '');
end

function mustBelocal_constants(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'att_id', ...
                'att_value', ...
                'att_units', ...
                'as'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.att_id, 6);
        mustBeAscii(entry.att_value, 9999);
        mustBeAscii(entry.att_units, 4);
        mustBeAscii(entry.as, 40);
    end
end

function report = validatelocal_constants(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.att_id))), ...
        'Required', 'att_id', 'Supply ATT_ID.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_value))), ...
        'Required', 'att_value', 'Supply ATT_VALUE.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_units))), ...
        'Required', 'att_units', 'Supply ATT_UNITS.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.as))), ...
        'Required', 'as', 'Supply AS.', reference);
end

function data = writelocal_constants(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.att_id, 6)];
    data = [data decimalField(numel(char(entry.att_value)), 4, 0, false) ...
        uint8(char(entry.att_value))];
    data = [data textField(entry.att_units, 4)];
    data = [data textField(entry.as, 40)];
end

function [entry, reader] = readlocal_constants(reader) %#codegen
    entry = newlocal_constants();
    [value, reader] = reader.text(6, true, false);
    if reader.ok, entry.att_id = value; end
    [count, reader] = reader.count(4, 1, 9999);
    [value, reader] = reader.text(count, false, false);
    if reader.ok, entry.att_value = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.att_units = value; end
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.as = value; end
end

function count = lengthlocal_constants(entries) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 6 + ...
            4 + numel(char(entry.att_value)) + ...
            4 + ...
            40;
    end
end

function entry = newlocal_variables() %#codegen
    entry = struct( ...
        'att_id', '', ...
        'att_len', NaN, ...
        'att_units', '----', ...
        'as', '');
end

function mustBelocal_variables(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'att_id', ...
                'att_len', ...
                'att_units', ...
                'as'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.att_id, 6);
        mustBeMetadata(entry.att_len, 1, 9999, true);
        mustBeAscii(entry.att_units, 4);
        mustBeAscii(entry.as, 40);
    end
end

function report = validatelocal_variables(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.att_id))), ...
        'Required', 'att_id', 'Supply ATT_ID.', reference);
    [~, valid] = treNumber(entry.att_len, 4, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'att_len', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.att_units))), ...
        'Required', 'att_units', 'Supply ATT_UNITS.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.as))), ...
        'Required', 'as', 'Supply AS.', reference);
end

function data = writelocal_variables(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.att_id, 6)];
    data = [data treNumber(entry.att_len, 4, 0, false, false, false)];
    data = [data textField(entry.att_units, 4)];
    data = [data textField(entry.as, 40)];
end

function [entry, reader] = readlocal_variables(reader) %#codegen
    entry = newlocal_variables();
    [value, reader] = reader.text(6, true, false);
    if reader.ok, entry.att_id = value; end
    [value, reader] = reader.number(4, 1, 9999, ...
        true, false);
    if reader.ok, entry.att_len = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.att_units = value; end
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.as = value; end
end

function count = lengthlocal_variables(entries) %#codegen
    count = 3 + 54 * numel(entries);
end

function entry = newpoints() %#codegen
    entry = struct( ...
        'diy', '--------', ...
        'dix', '--------', ...
        'gva', struct('value', {}), ...
        'lva', struct('value', {}));
end

function mustBepoints(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'diy', ...
                'dix', ...
                'gva', ...
                'lva'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.diy, 8);
        mustBeAscii(entry.dix, 8);
        mustBePointValues(entry.gva);
        mustBePointValues(entry.lva);
    end
end

function report = validatepoints(entry, report, reference, context_global_variables, context_local_variables) %#codegen
    [~, valid] = pointValues(entry.gva, context_global_variables);
    report = addIssue(report, ~valid, 'Attributes', 'gva', ...
        'Supply one fitting value per variable attribute definition.', reference);
    [~, valid] = pointValues(entry.lva, context_local_variables);
    report = addIssue(report, ~valid, 'Attributes', 'lva', ...
        'Supply one fitting value per variable attribute definition.', reference);
    report = addIssue(report, ~validAttributeCoordinate(entry.diy) || ~validAttributeCoordinate(entry.dix), ...
        'Metadata', 'diy/dix', 'Supply eight digits or unknown-coordinate hyphens.', reference);
end

function data = writepoints(entry, context_global_variables, context_local_variables) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.diy, 8)];
    data = [data textField(entry.dix, 8)];
    data = [data pointValues(entry.gva, context_global_variables)];
    data = [data pointValues(entry.lva, context_local_variables)];
end

function [entry, reader] = readpoints(reader, context_global_variables, context_local_variables) %#codegen
    entry = newpoints();
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.diy = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.dix = value; end
    [value, reader] = readPointValues(reader, context_global_variables);
    if reader.ok, entry.gva = value; end
    [value, reader] = readPointValues(reader, context_local_variables);
    if reader.ok, entry.lva = value; end
end

function count = lengthpoints(entries, context_global_variables, context_local_variables) %#codegen
    count = 4;
    for k = 1:numel(entries)
        count = count + 8 + ...
            8 + ...
            sum([context_global_variables.att_len]) + ...
            sum([context_local_variables.att_len]);
    end
end
