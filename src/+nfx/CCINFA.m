classdef (Sealed) CCINFA < nfx.TRE
    %CCINFA - Country-code equivalences and optional encoded detail
    %   OBJ = CCINFA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   CCINFA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   CCINFA properties:
    %       cetag - Constant tag identifier
    %       codes - CODES metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'CCINFA' % Registered tag identifier
    end
    properties
        % CODES repeated entries
        codes {mustBecodes} = repmat(newcodes(), 1, 0)
    end
    methods
        function obj = CCINFA(options) %#codegen
            arguments
                options.?nfx.CCINFA
            end
            if isfield(options, 'codes')
                obj.codes = options.codes;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AG, Table AG.1 (2025-06)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.codes) < 1 || ...
                numel(obj.codes) > 999, ...
                'Count', 'codes', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.codes)
                report = validatecodes(obj.codes(k), report, reference);
            end
            payloadLength = lengthcodes(obj.codes);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.codes), 3, 0, false)];
            for k = 1:numel(obj.codes)
                data = [data writecodes(obj.codes(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = codesEntry() %#codegen
            %codesEntry - Create one editable repeated entry
            %   ENTRY = nfx.CCINFA.codesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newcodes();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.CCINFA();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(3, 9, 999);
            entries = repmat(newcodes(), 1, 0);
            for k = 1:count
                [entry, reader] = readcodes(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.codes = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CCINFA());
        end
    end
end

function entry = newcodes() %#codegen
    entry = struct( ...
        'code', '', ...
        'eqtype', '', ...
        'esurn', '', ...
        'detail_cmpr', '', ...
        'detail', zeros(1, 0, 'uint8'));
end

function mustBecodes(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 5 || ...
            ~all(isfield(entries, { ...
                'code', ...
                'eqtype', ...
                'esurn', ...
                'detail_cmpr', ...
                'detail'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.code, 9);
        mustBeAscii(entry.eqtype, 1);
        mustBeAscii(entry.esurn, 99);
        mustBeAscii(entry.detail_cmpr, 1);
        mustBeByteRow(entry.detail);
    end
end

function report = validatecodes(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.code))), ...
        'Required', 'code', 'Supply CODE.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.eqtype, {'', 'C'})), ...
        'Enumeration', 'eqtype', 'Use a defined field value.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.esurn))), ...
        'Required', 'esurn', 'Supply ESURN.', reference);
    report = addIssue(report, ~any(strcmp(entry.detail_cmpr, {'', 'G'})) || ...
        (isempty(entry.detail) && ~isempty(char(entry.detail_cmpr))), ...
        'Encoding', 'detail_cmpr', 'Use blank for XML or G for gzip; omit for empty detail.', reference);
    report = addIssue(report, numel(char(entry.esurn)) < 9, ...
        'Metadata', 'esurn', 'Supply a short URN of 9 to 99 characters.', reference);
    report = addIssue(report, ~strcmp(char(entry.code), strtrim(char(entry.code))) || ...
        ~strcmp(char(entry.esurn), strtrim(char(entry.esurn))), ...
        'Metadata', 'code/esurn', 'Do not pad variable-length code identifiers.', reference);
end

function data = writecodes(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(char(entry.code)), 1, 0, false) ...
        uint8(char(entry.code))];
    data = [data textField(entry.eqtype, 1)];
    data = [data decimalField(numel(char(entry.esurn)), 2, 0, false) ...
        uint8(char(entry.esurn))];
    data = [data decimalField(numel(entry.detail), 5, 0, false)];
    if ~isempty(entry.detail)
        data = [data textField(entry.detail_cmpr, 1) entry.detail];
    end
end

function [entry, reader] = readcodes(reader) %#codegen
    entry = newcodes();
    [count, reader] = reader.count(1, 1, 9);
    [value, reader] = reader.text(count, false, false);
    if reader.ok, entry.code = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.eqtype = value; end
    [count, reader] = reader.count(2, 1, 99);
    [value, reader] = reader.text(count, false, false);
    if reader.ok, entry.esurn = value; end
    [byteCount, reader] = reader.count(5, 1, 99985);
    if byteCount > 0
        [value, reader] = reader.text(1);
        if reader.ok, entry.detail_cmpr = value; end
        [value, reader] = reader.take(byteCount);
        if reader.ok, entry.detail = value; end
    end
end

function count = lengthcodes(entries) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 1 + numel(char(entry.code)) + ...
            1 + ...
            2 + numel(char(entry.esurn)) + ...
            5 + double(~isempty(entry.detail)) + numel(entry.detail);
    end
end
