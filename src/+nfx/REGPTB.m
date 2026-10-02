classdef (Sealed) REGPTB < nfx.TRE
    %REGPTB - Geographic registration points
    %   OBJ = REGPTB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   REGPTB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   REGPTB properties:
    %       cetag - Constant tag identifier
    %       points - POINTS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'REGPTB' % Registered tag identifier
    end
    properties
        % POINTS repeated entries
        points {mustBepoints} = repmat(newpoints(), 1, 0)
    end
    methods
        function obj = REGPTB(options) %#codegen
            arguments
                options.?nfx.REGPTB
            end
            if isfield(options, 'points')
                obj.points = options.points;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-7 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.points) < 1 || ...
                numel(obj.points) > 1298, ...
                'Count', 'points', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.points)
                report = validatepoints(obj.points(k), report, reference);
            end
            payloadLength = lengthpoints(obj.points);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.points), 4, 0, false)];
            for k = 1:numel(obj.points)
                data = [data writepoints(obj.points(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = pointsEntry() %#codegen
            %pointsEntry - Create one editable repeated entry
            %   ENTRY = nfx.REGPTB.pointsEntry() supplies the field
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
            obj = nfx.REGPTB();
            reader = nfx.internal.TREReader(data, 99985);
            [count, reader] = reader.count(4, 77, 1298);
            entries = repmat(newpoints(), 1, 0);
            for k = 1:count
                [entry, reader] = readpoints(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.points = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.REGPTB());
        end
    end
end

function entry = newpoints() %#codegen
    entry = struct( ...
        'pid', '', ...
        'lon', NaN, ...
        'lat', NaN, ...
        'zvl', NaN, ...
        'dix', NaN, ...
        'diy', NaN);
end

function mustBepoints(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 6 || ...
            ~all(isfield(entries, { ...
                'pid', ...
                'lon', ...
                'lat', ...
                'zvl', ...
                'dix', ...
                'diy'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.pid, 10);
        mustBeMetadata(entry.lon, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.lat, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.zvl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.dix, -9999999999, 99999999999, false);
        mustBeMetadata(entry.diy, -9999999999, 99999999999, false);
    end
end

function report = validatepoints(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.pid))), ...
        'Required', 'pid', 'Supply PID.', reference);
    [~, valid] = variableDecimalNumber(entry.lon, 15);
    report = addIssue(report, ~valid, 'Encoding', 'lon', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.lat, 15);
    report = addIssue(report, ~valid, 'Encoding', 'lat', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.zvl, 15, true);
    report = addIssue(report, ~valid, 'Encoding', 'zvl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.dix, 11);
    report = addIssue(report, ~valid, 'Encoding', 'dix', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.diy, 11);
    report = addIssue(report, ~valid, 'Encoding', 'diy', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writepoints(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.pid, 10)];
    data = [data variableDecimalNumber(entry.lon, 15)];
    data = [data variableDecimalNumber(entry.lat, 15)];
    data = [data variableDecimalNumber(entry.zvl, 15, true)];
    data = [data variableDecimalNumber(entry.dix, 11)];
    data = [data variableDecimalNumber(entry.diy, 11)];
end

function [entry, reader] = readpoints(reader) %#codegen
    entry = newpoints();
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.pid = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.lon = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.lat = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, true);
    if reader.ok, entry.zvl = value; end
    [value, reader] = reader.number(11, -9999999999, 99999999999, ...
        false, false);
    if reader.ok, entry.dix = value; end
    [value, reader] = reader.number(11, -9999999999, 99999999999, ...
        false, false);
    if reader.ok, entry.diy = value; end
end

function count = lengthpoints(entries) %#codegen
    count = 4 + 77 * numel(entries);
end
