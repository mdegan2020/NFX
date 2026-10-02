classdef (Sealed) FACCBB < nfx.TRE
    %FACCBB - Feature attribute and value codes
    %   OBJ = FACCBB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   FACCBB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   FACCBB properties:
    %       cetag - Constant tag identifier
    %       attributes - ATTRIBUTES metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'FACCBB' % Registered tag identifier
    end
    properties
        % ATTRIBUTES repeated entries
        attributes {mustBeattributes} = repmat(newattributes(), 1, 0)
    end
    methods
        function obj = FACCBB(options) %#codegen
            arguments
                options.?nfx.FACCBB
            end
            if isfield(options, 'attributes')
                obj.attributes = options.attributes;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-15 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.attributes) < 1 || ...
                numel(obj.attributes) > 99, ...
                'Count', 'attributes', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.attributes)
                report = validateattributes(obj.attributes(k), report, reference);
            end
            payloadLength = lengthattributes(obj.attributes);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.attributes), 2, 0, false)];
            for k = 1:numel(obj.attributes)
                data = [data writeattributes(obj.attributes(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = attributesEntry() %#codegen
            %attributesEntry - Create one editable repeated entry
            %   ENTRY = nfx.FACCBB.attributesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newattributes();
        end

        function entry = valuesEntry() %#codegen
            %valuesEntry - Create one editable repeated entry
            %   ENTRY = nfx.FACCBB.valuesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newvalues();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.FACCBB();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(2, 94, 99);
            entries = repmat(newattributes(), 1, 0);
            for k = 1:count
                [entry, reader] = readattributes(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.attributes = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.FACCBB());
        end
    end
end

function entry = newattributes() %#codegen
    entry = struct( ...
        'code', '', ...
        'name', '', ...
        'status', 'FACC', ...
        'units', '', ...
        'values', repmat(newvalues(), 1, 0));
end

function mustBeattributes(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 5 || ...
            ~all(isfield(entries, { ...
                'code', ...
                'name', ...
                'status', ...
                'units', ...
                'values'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.code, 3);
        mustBeAscii(entry.name, 80);
        mustBeAscii(entry.status, 4);
        mustBeAscii(entry.units, 4);
        mustBevalues(entry.values);
    end
end

function report = validateattributes(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.code))), ...
        'Required', 'code', 'Supply CODE.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.name))), ...
        'Required', 'name', 'Supply NAME.', reference);
    report = addIssue(report, numel(entry.values) < 1 || ...
        numel(entry.values) > 999, ...
        'Count', 'values', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.values)
        report = validatevalues(entry.values(childK), report, reference);
    end
end

function data = writeattributes(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.code, 3)];
    data = [data textField(entry.name, 80)];
    data = [data textField(entry.status, 4)];
    data = [data textField(entry.units, 4)];
    data = [data decimalField(numel(entry.values), 3, 0, false)];
    for childK = 1:numel(entry.values)
        data = [data writevalues(entry.values(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readattributes(reader) %#codegen
    entry = newattributes();
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.code = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.name = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.status = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.units = value; end
    [childCount, reader] = reader.count(3, 83, 999);
    childEntries = repmat(newvalues(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readvalues(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.values = childEntries; end
end

function count = lengthattributes(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 3 + ...
            80 + ...
            4 + ...
            4 + ...
            lengthvalues(entry.values);
    end
end

function entry = newvalues() %#codegen
    entry = struct( ...
        'val', zeros(1, 0, 'uint8'), ...
        'desc', '');
end

function mustBevalues(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'val', ...
                'desc'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeByteRow(entry.val);
        mustBeAscii(entry.desc, 80);
    end
end

function report = validatevalues(entry, report, reference) %#codegen
    report = addIssue(report, numel(entry.val) < 1 || ...
        numel(entry.val) > 999, ...
        'Length', 'val', 'Byte count is outside the defined range.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.desc))), ...
        'Required', 'desc', 'Supply DESC.', reference);
end

function data = writevalues(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(entry.val), 3, 0, false) entry.val];
    data = [data textField(entry.desc, 80)];
end

function [entry, reader] = readvalues(reader) %#codegen
    entry = newvalues();
    [byteCount, reader] = reader.count(3, 1, 999);
    [value, reader] = reader.take(byteCount);
    if reader.ok, entry.val = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.desc = value; end
end

function count = lengthvalues(entries) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 3 + numel(entry.val) + ...
            80;
    end
end
