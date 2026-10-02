classdef (Sealed) ACCVTB < nfx.TRE
    %ACCVTB - Regional positional accuracy
    %   OBJ = ACCVTB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   ACCVTB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   ACCVTB properties:
    %       cetag - Constant tag identifier
    %       regions - REGIONS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'ACCVTB' % Registered tag identifier
    end
    properties
        % REGIONS repeated entries
        regions {mustBeregions} = repmat(newregions(), 1, 0)
    end
    methods
        function obj = ACCVTB(options) %#codegen
            arguments
                options.?nfx.ACCVTB
            end
            if isfield(options, 'regions')
                obj.regions = options.regions;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-12 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.regions) < 1 || ...
                numel(obj.regions) > 99, ...
                'Count', 'regions', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.regions)
                report = validateregions(obj.regions(k), report, reference);
            end
            payloadLength = lengthregions(obj.regions);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.regions), 2, 0, false)];
            for k = 1:numel(obj.regions)
                data = [data writeregions(obj.regions(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = regionsEntry() %#codegen
            %regionsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ACCVTB.regionsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newregions();
        end

        function entry = pointsEntry() %#codegen
            %pointsEntry - Create one editable repeated entry
            %   ENTRY = nfx.ACCVTB.pointsEntry() supplies the field
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
            obj = nfx.ACCVTB();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(2, 9, 99);
            entries = repmat(newregions(), 1, 0);
            for k = 1:count
                [entry, reader] = readregions(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.regions = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ACCVTB());
        end
    end
end

function entry = newregions() %#codegen
    entry = struct( ...
        'uniaav', '', ...
        'aav', NaN, ...
        'uniapv', '', ...
        'apv', NaN, ...
        'points', repmat(newpoints(), 1, 0));
end

function mustBeregions(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 5 || ...
            ~all(isfield(entries, { ...
                'uniaav', ...
                'aav', ...
                'uniapv', ...
                'apv', ...
                'points'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.uniaav, 3);
        mustBeMetadata(entry.aav, 0, 99999, true);
        mustBeAscii(entry.uniapv, 3);
        mustBeMetadata(entry.apv, 0, 99999, true);
        mustBepoints(entry.points);
    end
end

function report = validateregions(entry, report, reference) %#codegen
    if ~isempty(strtrim(char(entry.uniaav)))
        [~, valid] = treNumber(entry.aav, 5, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'aav', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.uniaav)))) && ~isnan(entry.aav), ...
        'AbsentField', 'aav', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.uniapv)))
        [~, valid] = treNumber(entry.apv, 5, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'apv', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.uniapv)))) && ~isnan(entry.apv), ...
        'AbsentField', 'apv', 'Leave the omitted field unset.', reference);
    report = addIssue(report, numel(entry.points) < 0 || ...
        numel(entry.points) > 999, ...
        'Count', 'points', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.points)
        report = validatepoints(entry.points(childK), report, reference);
    end
    report = addIssue(report, ~isempty(entry.points) && numel(entry.points) < 4, ...
        'Metadata', 'points', 'Use zero points for the whole image or at least four.', reference);
end

function data = writeregions(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.uniaav, 3)];
    if ~isempty(strtrim(char(entry.uniaav)))
        data = [data treNumber(entry.aav, 5, 0, false, false, false)];
    end
    data = [data textField(entry.uniapv, 3)];
    if ~isempty(strtrim(char(entry.uniapv)))
        data = [data treNumber(entry.apv, 5, 0, false, false, false)];
    end
    data = [data decimalField(numel(entry.points), 3, 0, false)];
    for childK = 1:numel(entry.points)
        data = [data writepoints(entry.points(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readregions(reader) %#codegen
    entry = newregions();
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.uniaav = value; end
    if ~isempty(strtrim(char(entry.uniaav)))
        [value, reader] = reader.number(5, 0, 99999, ...
            true, false);
        if reader.ok, entry.aav = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.uniapv = value; end
    if ~isempty(strtrim(char(entry.uniapv)))
        [value, reader] = reader.number(5, 0, 99999, ...
            true, false);
        if reader.ok, entry.apv = value; end
    end
    [childCount, reader] = reader.count(3, 30, 999);
    childEntries = repmat(newpoints(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readpoints(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.points = childEntries; end
end

function count = lengthregions(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 3 + ...
            double(~isempty(strtrim(char(entry.uniaav)))) * (5) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.uniapv)))) * (5) + ...
            lengthpoints(entry.points);
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
    count = 3 + 30 * numel(entries);
end
