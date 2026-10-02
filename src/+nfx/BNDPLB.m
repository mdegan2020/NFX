classdef (Sealed) BNDPLB < nfx.TRE
    %BNDPLB - Bounding polygon coordinates
    %   OBJ = BNDPLB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   BNDPLB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   BNDPLB properties:
    %       cetag - Constant tag identifier
    %       points - POINTS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'BNDPLB' % Registered tag identifier
    end
    properties
        % POINTS repeated entries
        points {mustBepoints} = repmat(newpoints(), 1, 0)
    end
    methods
        function obj = BNDPLB(options) %#codegen
            arguments
                options.?nfx.BNDPLB
            end
            if isfield(options, 'points')
                obj.points = options.points;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-9 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.points) < 4 || ...
                numel(obj.points) > 3332, ...
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
            %   ENTRY = nfx.BNDPLB.pointsEntry() supplies the field
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
            obj = nfx.BNDPLB();
            reader = nfx.internal.TREReader(data, 99985);
            [count, reader] = reader.count(4, 30, 3332);
            entries = repmat(newpoints(), 1, 0);
            for k = 1:count
                [entry, reader] = readpoints(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.points = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.BNDPLB());
        end
    end
end

function entry = newpoints() %#codegen
    entry = struct( ...
        'lon', NaN, ...
        'lat', NaN);
end

function mustBepoints(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'lon', ...
                'lat'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.lon, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.lat, -99999999999999, 999999999999999, false);
    end
end

function report = validatepoints(entry, report, reference) %#codegen
    [~, valid] = variableDecimalNumber(entry.lon, 15);
    report = addIssue(report, ~valid, 'Encoding', 'lon', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.lat, 15);
    report = addIssue(report, ~valid, 'Encoding', 'lat', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writepoints(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data variableDecimalNumber(entry.lon, 15)];
    data = [data variableDecimalNumber(entry.lat, 15)];
end

function [entry, reader] = readpoints(reader) %#codegen
    entry = newpoints();
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.lon = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.lat = value; end
end

function count = lengthpoints(entries) %#codegen
    count = 4 + 30 * numel(entries);
end
