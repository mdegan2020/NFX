classdef (Sealed) GRDPSB < nfx.TRE
    %GRDPSB - Location-grid references
    %   OBJ = GRDPSB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   GRDPSB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   GRDPSB properties:
    %       cetag - Constant tag identifier
    %       grids - GRIDS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'GRDPSB' % Registered tag identifier
    end
    properties
        % GRIDS repeated entries
        grids {mustBegrids} = repmat(newgrids(), 1, 0)
    end
    methods
        function obj = GRDPSB(options) %#codegen
            arguments
                options.?nfx.GRDPSB
            end
            if isfield(options, 'grids')
                obj.grids = options.grids;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-4 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.grids) < 1 || ...
                numel(obj.grids) > 99, ...
                'Count', 'grids', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.grids)
                report = validategrids(obj.grids(k), report, reference);
            end
            payloadLength = lengthgrids(obj.grids);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.grids), 2, 0, false)];
            for k = 1:numel(obj.grids)
                data = [data writegrids(obj.grids(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = gridsEntry() %#codegen
            %gridsEntry - Create one editable repeated entry
            %   ENTRY = nfx.GRDPSB.gridsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newgrids();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.GRDPSB();
            reader = nfx.internal.TREReader(data, 99985);
            [count, reader] = reader.count(2, 66, 99);
            entries = repmat(newgrids(), 1, 0);
            for k = 1:count
                [entry, reader] = readgrids(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.grids = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.GRDPSB());
        end
    end
end

function entry = newgrids() %#codegen
    entry = struct( ...
        'zvl', NaN, ...
        'bad', '', ...
        'lod', NaN, ...
        'lad', NaN, ...
        'lso', NaN, ...
        'pso', NaN);
end

function mustBegrids(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 6 || ...
            ~all(isfield(entries, { ...
                'zvl', ...
                'bad', ...
                'lod', ...
                'lad', ...
                'lso', ...
                'pso'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.zvl, -999999.99, 999999.99, false);
        mustBeAscii(entry.bad, 10);
        mustBeMetadata(entry.lod, 0, 999999999999, false);
        mustBeMetadata(entry.lad, 0, 999999999999, false);
        mustBeMetadata(entry.lso, -9999999999, 99999999999, false);
        mustBeMetadata(entry.pso, -9999999999, 99999999999, false);
    end
end

function report = validategrids(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.zvl, 10, 2, true, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'zvl', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.bad))), ...
        'Required', 'bad', 'Supply BAD.', reference);
    [~, valid] = variableDecimalNumber(entry.lod, 12);
    report = addIssue(report, ~valid, 'Encoding', 'lod', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.lad, 12);
    report = addIssue(report, ~valid, 'Encoding', 'lad', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.lso, 11);
    report = addIssue(report, ~valid, 'Encoding', 'lso', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.pso, 11);
    report = addIssue(report, ~valid, 'Encoding', 'pso', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, entry.lod <= 0 || entry.lad <= 0, ...
        'Metadata', 'lod/lad', 'Grid spacing must be positive.', reference);
end

function data = writegrids(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.zvl, 10, 2, true, true, false)];
    data = [data textField(entry.bad, 10)];
    data = [data variableDecimalNumber(entry.lod, 12)];
    data = [data variableDecimalNumber(entry.lad, 12)];
    data = [data variableDecimalNumber(entry.lso, 11)];
    data = [data variableDecimalNumber(entry.pso, 11)];
end

function [entry, reader] = readgrids(reader) %#codegen
    entry = newgrids();
    [value, reader] = reader.number(10, -999999.99, 999999.99, ...
        false, true);
    if reader.ok, entry.zvl = value; end
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.bad = value; end
    [value, reader] = reader.number(12, 0, 999999999999, ...
        false, false);
    if reader.ok, entry.lod = value; end
    [value, reader] = reader.number(12, 0, 999999999999, ...
        false, false);
    if reader.ok, entry.lad = value; end
    [value, reader] = reader.number(11, -9999999999, 99999999999, ...
        false, false);
    if reader.ok, entry.lso = value; end
    [value, reader] = reader.number(11, -9999999999, 99999999999, ...
        false, false);
    if reader.ok, entry.pso = value; end
end

function count = lengthgrids(entries) %#codegen
    count = 2 + 66 * numel(entries);
end
