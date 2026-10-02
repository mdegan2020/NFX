classdef (Sealed) CSEPHA < nfx.TRE
    %CSEPHA - Commercial sensor ephemeris samples
    %   OBJ = CSEPHA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   CSEPHA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   CSEPHA properties:
    %       cetag - Constant tag identifier
    %       ephem_flag - EPHEM_FLAG metadata
    %       dt_ephem - DT_EPHEM metadata
    %       date_ephem - DATE_EPHEM metadata
    %       t0_ephem - T0_EPHEM metadata
    %       ephemeris - EPHEMERIS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'CSEPHA' % Registered tag identifier
    end
    properties
        ephem_flag {mustBeAscii(ephem_flag, 12)} = '' % EPHEM_FLAG metadata
        % DT_EPHEM metadata
        dt_ephem {mustBeMetadata(dt_ephem, ...
            0.1, 999.9, 0)} = NaN
        date_ephem {mustBeAscii(date_ephem, 8)} = '' % DATE_EPHEM metadata
        t0_ephem {mustBeAscii(t0_ephem, 13)} = '' % T0_EPHEM metadata
        % EPHEMERIS repeated entries
        ephemeris {mustBeephemeris} = repmat(newephemeris(), 1, 0)
    end
    methods
        function obj = CSEPHA(options) %#codegen
            arguments
                options.?nfx.CSEPHA
            end
            if isfield(options, 'ephem_flag')
                obj.ephem_flag = options.ephem_flag;
            end
            if isfield(options, 'dt_ephem')
                obj.dt_ephem = options.dt_ephem;
            end
            if isfield(options, 'date_ephem')
                obj.date_ephem = options.date_ephem;
            end
            if isfield(options, 't0_ephem')
                obj.t0_ephem = options.t0_ephem;
            end
            if isfield(options, 'ephemeris')
                obj.ephemeris = options.ephemeris;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix D, Table D-3 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.ephem_flag, {'COLLECT-TIME', 'PREDICTED', 'REFINED'})), ...
                'Enumeration', 'ephem_flag', 'Use a defined EPHEM_FLAG value.', reference);
            [~, valid] = treNumber(obj.dt_ephem, 5, 1, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'dt_ephem', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.date_ephem))), ...
                'Required', 'date_ephem', 'Supply DATE_EPHEM.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.t0_ephem))), ...
                'Required', 't0_ephem', 'Supply T0_EPHEM.', reference);
            report = addIssue(report, numel(obj.ephemeris) < 1 || ...
                numel(obj.ephemeris) > 999, ...
                'Count', 'ephemeris', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.ephemeris)
                report = validateephemeris(obj.ephemeris(k), report, reference);
            end
            report = addIssue(report, ~knownDate(obj.date_ephem, 8) || ...
                str2double(char(obj.date_ephem)) < 20000101, ...
                'Metadata', 'date_ephem', 'Supply a valid date from year 2000 onward.', reference);
            report = addIssue(report, ~knownClockTime(obj.t0_ephem, 6), ...
                'Metadata', 't0_ephem', 'Supply HHMMSS.mmmmmm UTC time.', reference);
            payloadLength = 12 + ...
                5 + ...
                8 + ...
                13 + ...
                lengthephemeris(obj.ephemeris);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.ephem_flag, 12)];
            data = [data treNumber(obj.dt_ephem, 5, 1, false, false, false)];
            data = [data textField(obj.date_ephem, 8)];
            data = [data textField(obj.t0_ephem, 13)];
            data = [data decimalField(numel(obj.ephemeris), 3, 0, false)];
            for k = 1:numel(obj.ephemeris)
                data = [data writeephemeris(obj.ephemeris(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = ephemerisEntry() %#codegen
            %ephemerisEntry - Create one editable repeated entry
            %   ENTRY = nfx.CSEPHA.ephemerisEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newephemeris();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.CSEPHA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.ephem_flag = value; end
            [value, reader] = reader.number(5, 0.1, 999.9, ...
                false, false);
            if reader.ok, obj.dt_ephem = value; end
            [value, reader] = reader.text(8, true, false);
            if reader.ok, obj.date_ephem = value; end
            [value, reader] = reader.text(13, true, false);
            if reader.ok, obj.t0_ephem = value; end
            [count, reader] = reader.count(3, 36, 999);
            entries = repmat(newephemeris(), 1, 0);
            for k = 1:count
                [entry, reader] = readephemeris(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.ephemeris = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSEPHA());
        end
    end
end

function entry = newephemeris() %#codegen
    entry = struct( ...
        'ephem_x', NaN, ...
        'ephem_y', NaN, ...
        'ephem_z', NaN);
end

function mustBeephemeris(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'ephem_x', ...
                'ephem_y', ...
                'ephem_z'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.ephem_x, -99999999.99, 99999999.99, false);
        mustBeMetadata(entry.ephem_y, -99999999.99, 99999999.99, false);
        mustBeMetadata(entry.ephem_z, -99999999.99, 99999999.99, false);
    end
end

function report = validateephemeris(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.ephem_x, 12, 2, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ephem_x', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.ephem_y, 12, 2, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ephem_y', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.ephem_z, 12, 2, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ephem_z', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writeephemeris(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.ephem_x, 12, 2, true, false, false)];
    data = [data treNumber(entry.ephem_y, 12, 2, true, false, false)];
    data = [data treNumber(entry.ephem_z, 12, 2, true, false, false)];
end

function [entry, reader] = readephemeris(reader) %#codegen
    entry = newephemeris();
    [value, reader] = reader.number(12, -99999999.99, 99999999.99, ...
        false, false);
    if reader.ok, entry.ephem_x = value; end
    [value, reader] = reader.number(12, -99999999.99, 99999999.99, ...
        false, false);
    if reader.ok, entry.ephem_y = value; end
    [value, reader] = reader.number(12, -99999999.99, 99999999.99, ...
        false, false);
    if reader.ok, entry.ephem_z = value; end
end

function count = lengthephemeris(entries) %#codegen
    count = 3 + 36 * numel(entries);
end
