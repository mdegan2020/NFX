classdef (Sealed) CSSFAA < nfx.TRE
    %CSSFAA - Sensor field alignment metadata
    %   OBJ = CSSFAA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   CSSFAA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   CSSFAA properties:
    %       cetag - Constant tag identifier
    %       bands - BANDS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'CSSFAA' % Registered tag identifier
    end
    properties
        % BANDS repeated entries
        bands {mustBebands} = repmat(newbands(), 1, 0)
    end
    methods
        function obj = CSSFAA(options) %#codegen
            arguments
                options.?nfx.CSSFAA
            end
            if isfield(options, 'bands')
                obj.bands = options.bands;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix D, Table D-6 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.bands) < 1 || ...
                numel(obj.bands) > 9, ...
                'Count', 'bands', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.bands)
                report = validatebands(obj.bands(k), report, reference);
            end
            payloadLength = lengthbands(obj.bands);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.bands), 1, 0, false)];
            for k = 1:numel(obj.bands)
                data = [data writebands(obj.bands(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = bandsEntry() %#codegen
            %bandsEntry - Create one editable repeated entry
            %   ENTRY = nfx.CSSFAA.bandsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newbands();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.CSSFAA();
            reader = nfx.internal.TREReader(data, 99985);
            [count, reader] = reader.count(1, 106, 9);
            entries = repmat(newbands(), 1, 0);
            for k = 1:count
                [entry, reader] = readbands(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.bands = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CSSFAA());
        end
    end
end

function entry = newbands() %#codegen
    entry = struct( ...
        'band_type', '', ...
        'band_id', '', ...
        'foc_length', NaN, ...
        'delta', NaN, ...
        'oppoff_x', '', ...
        'oppoff_y', '', ...
        'oppoff_z', '', ...
        'start_x', NaN, ...
        'start_y', NaN, ...
        'finish_x', NaN, ...
        'finish_y', NaN);
end

function mustBebands(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 11 || ...
            ~all(isfield(entries, { ...
                'band_type', ...
                'band_id', ...
                'foc_length', ...
                'delta', ...
                'oppoff_x', ...
                'oppoff_y', ...
                'oppoff_z', ...
                'start_x', ...
                'start_y', ...
                'finish_x', ...
                'finish_y'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.band_type, 1);
        mustBeAscii(entry.band_id, 6);
        mustBeMetadata(entry.foc_length, 1e-05, 99999.99999, false);
        mustBeMetadata(entry.delta, 1, 9999999, true);
        mustBeAscii(entry.oppoff_x, 7);
        mustBeAscii(entry.oppoff_y, 7);
        mustBeAscii(entry.oppoff_z, 7);
        mustBeMetadata(entry.start_x, -99999.9999, 99999.9999, false);
        mustBeMetadata(entry.start_y, -99999.9999, 99999.9999, false);
        mustBeMetadata(entry.finish_x, -99999.9999, 99999.9999, false);
        mustBeMetadata(entry.finish_y, -99999.9999, 99999.9999, false);
    end
end

function report = validatebands(entry, report, reference) %#codegen
    report = addIssue(report, ...
        ~any(strcmp(entry.band_type, {'', 'M', 'R', 'G', 'B', 'N'})), ...
        'Enumeration', 'band_type', 'Use a defined field value.', reference);
    [~, valid] = treNumber(entry.foc_length, 11, 5, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'foc_length', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.delta, 7, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'delta', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.oppoff_x))), ...
        'Required', 'oppoff_x', 'Supply OPPOFF_X.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.oppoff_y))), ...
        'Required', 'oppoff_y', 'Supply OPPOFF_Y.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.oppoff_z))), ...
        'Required', 'oppoff_z', 'Supply OPPOFF_Z.', reference);
    [~, valid] = treNumber(entry.start_x, 11, 4, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'start_x', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.start_y, 11, 4, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'start_y', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.finish_x, 11, 4, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'finish_x', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.finish_y, 11, 4, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'finish_y', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, ~validPrincipalOffset(entry.oppoff_x), ...
        'Metadata', 'oppoff_x', 'Supply a signed decimal in the seven-byte offset field.', reference);
    report = addIssue(report, ~validPrincipalOffset(entry.oppoff_y), ...
        'Metadata', 'oppoff_y', 'Supply a signed decimal in the seven-byte offset field.', reference);
    report = addIssue(report, ~validPrincipalOffset(entry.oppoff_z), ...
        'Metadata', 'oppoff_z', 'Supply a signed decimal in the seven-byte offset field.', reference);
end

function data = writebands(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.band_type, 1)];
    data = [data textField(entry.band_id, 6)];
    data = [data treNumber(entry.foc_length, 11, 5, false, false, false)];
    data = [data uint8('00000001')];
    data = [data uint8('00000001')];
    data = [data treNumber(entry.delta, 7, 0, false, false, false)];
    data = [data textField(entry.oppoff_x, 7)];
    data = [data textField(entry.oppoff_y, 7)];
    data = [data textField(entry.oppoff_z, 7)];
    data = [data treNumber(entry.start_x, 11, 4, true, false, false)];
    data = [data treNumber(entry.start_y, 11, 4, true, false, false)];
    data = [data treNumber(entry.finish_x, 11, 4, true, false, false)];
    data = [data treNumber(entry.finish_y, 11, 4, true, false, false)];
end

function [entry, reader] = readbands(reader) %#codegen
    entry = newbands();
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.band_type = value; end
    [value, reader] = reader.text(6, true, false);
    if reader.ok, entry.band_id = value; end
    [value, reader] = reader.number(11, 1e-05, 99999.99999, ...
        false, false);
    if reader.ok, entry.foc_length = value; end
    reader = reader.literal('00000001');
    reader = reader.literal('00000001');
    [value, reader] = reader.number(7, 1, 9999999, ...
        true, false);
    if reader.ok, entry.delta = value; end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.oppoff_x = value; end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.oppoff_y = value; end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.oppoff_z = value; end
    [value, reader] = reader.number(11, -99999.9999, 99999.9999, ...
        false, false);
    if reader.ok, entry.start_x = value; end
    [value, reader] = reader.number(11, -99999.9999, 99999.9999, ...
        false, false);
    if reader.ok, entry.start_y = value; end
    [value, reader] = reader.number(11, -99999.9999, 99999.9999, ...
        false, false);
    if reader.ok, entry.finish_x = value; end
    [value, reader] = reader.number(11, -99999.9999, 99999.9999, ...
        false, false);
    if reader.ok, entry.finish_y = value; end
end

function count = lengthbands(entries) %#codegen
    count = 1 + 106 * numel(entries);
end
