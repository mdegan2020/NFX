classdef (Sealed) J2KLRB < nfx.TRE
    %J2KLRB - JPEG 2000 codestream and layer metadata
    %   OBJ = J2KLRB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   J2KLRB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   J2KLRB properties:
    %       cetag - Constant tag identifier
    %       orig - ORIG metadata
    %       cstream - CSTREAM metadata
    %       nlevels_o - NLEVELS_O metadata
    %       nbands_o - NBANDS_O metadata
    %       layers - LAYERS metadata
    %       nlevels_i - NLEVELS_I metadata
    %       nbands_i - NBANDS_I metadata
    %       nlayers_i - NLAYERS_I metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'J2KLRB' % Registered tag identifier
    end
    properties
        % ORIG metadata
        orig {mustBeMetadata(orig, ...
            0, 9, 1)} = NaN
        cstream {mustBeAscii(cstream, 10)} = '' % CSTREAM metadata
        % NLEVELS_O metadata
        nlevels_o {mustBeMetadata(nlevels_o, ...
            0, 32, 1)} = NaN
        % NBANDS_O metadata
        nbands_o {mustBeMetadata(nbands_o, ...
            1, 16384, 1)} = NaN
        % LAYERS repeated entries
        layers {mustBelayers} = repmat(newlayers(), 1, 0)
        % NLEVELS_I metadata
        nlevels_i {mustBeMetadata(nlevels_i, ...
            0, 32, 1)} = NaN
        % NBANDS_I metadata
        nbands_i {mustBeMetadata(nbands_i, ...
            1, 16384, 1)} = NaN
        % NLAYERS_I metadata
        nlayers_i {mustBeMetadata(nlayers_i, ...
            1, 999, 1)} = NaN
    end
    methods
        function obj = J2KLRB(options) %#codegen
            arguments
                options.?nfx.J2KLRB
            end
            if isfield(options, 'orig')
                obj.orig = options.orig;
            end
            if isfield(options, 'cstream')
                obj.cstream = options.cstream;
            end
            if isfield(options, 'nlevels_o')
                obj.nlevels_o = options.nlevels_o;
            end
            if isfield(options, 'nbands_o')
                obj.nbands_o = options.nbands_o;
            end
            if isfield(options, 'layers')
                obj.layers = options.layers;
            end
            if isfield(options, 'nlevels_i')
                obj.nlevels_i = options.nlevels_i;
            end
            if isfield(options, 'nbands_i')
                obj.nbands_i = options.nbands_i;
            end
            if isfield(options, 'nlayers_i')
                obj.nlayers_i = options.nlayers_i;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'ISO/IEC BIIF Profile BPJ2K01.20, Table 8-4 (2023-10)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.orig, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'orig', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.cstream, {'J2K-P1', 'HTONLY', 'HTDECLARED', 'MIXED'})), ...
                'Enumeration', 'cstream', 'Use a defined CSTREAM value.', reference);
            [~, valid] = treNumber(obj.nlevels_o, 2, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'nlevels_o', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.nbands_o, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'nbands_o', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(obj.layers) < 1 || ...
                numel(obj.layers) > 999, ...
                'Count', 'layers', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.layers)
                report = validatelayers(obj.layers(k), report, reference);
            end
            if mod(obj.orig, 2) == 1
                [~, valid] = treNumber(obj.nlevels_i, 2, 0, false, false, false);
                report = addIssue(report, ~valid, 'Encoding', 'nlevels_i', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(mod(obj.orig, 2) == 1) && ~isnan(obj.nlevels_i), ...
                'AbsentField', 'nlevels_i', 'Leave the omitted field empty.', reference);
            if mod(obj.orig, 2) == 1
                [~, valid] = treNumber(obj.nbands_i, 5, 0, false, false, false);
                report = addIssue(report, ~valid, 'Encoding', 'nbands_i', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(mod(obj.orig, 2) == 1) && ~isnan(obj.nbands_i), ...
                'AbsentField', 'nbands_i', 'Leave the omitted field empty.', reference);
            if mod(obj.orig, 2) == 1
                [~, valid] = treNumber(obj.nlayers_i, 3, 0, false, false, false);
                report = addIssue(report, ~valid, 'Encoding', 'nlayers_i', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(mod(obj.orig, 2) == 1) && ~isnan(obj.nlayers_i), ...
                'AbsentField', 'nlayers_i', 'Leave the omitted field empty.', reference);
            report = addIssue(report, ~isequal([obj.layers.layer_id], 0:numel(obj.layers) - 1), ...
                'Metadata', 'layer_id', 'Supply consecutive zero-based layer identifiers.', reference);
            report = addIssue(report, mod(obj.orig, 2) == 1 && ...
                (obj.nlevels_i > obj.nlevels_o || obj.nbands_i > obj.nbands_o || ...
                 obj.nlayers_i > numel(obj.layers)), ...
                'Metadata', 'nlevels_i/nbands_i/nlayers_i', 'Parsed counts cannot exceed original counts.', reference);
            report = addIssue(report, strcmp(obj.cstream, 'J2K-P1') && any(strcmp({obj.layers.placehold}, 'Y')), ...
                'Metadata', 'placehold', 'Part-1 codestreams do not contain placeholder passes.', reference);
            payloadLength = 1 + ...
                10 + ...
                2 + ...
                5 + ...
                lengthlayers(obj.layers) + ...
                double(mod(obj.orig, 2) == 1) * (2) + ...
                double(mod(obj.orig, 2) == 1) * (5) + ...
                double(mod(obj.orig, 2) == 1) * (3);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.orig, 1, 0, false, false, false)];
            data = [data textField(obj.cstream, 10)];
            data = [data treNumber(obj.nlevels_o, 2, 0, false, false, false)];
            data = [data treNumber(obj.nbands_o, 5, 0, false, false, false)];
            data = [data decimalField(numel(obj.layers), 3, 0, false)];
            for k = 1:numel(obj.layers)
                data = [data writelayers(obj.layers(k))]; %#ok<AGROW>
            end
            if mod(obj.orig, 2) == 1
                data = [data treNumber(obj.nlevels_i, 2, 0, false, false, false)];
            end
            if mod(obj.orig, 2) == 1
                data = [data treNumber(obj.nbands_i, 5, 0, false, false, false)];
            end
            if mod(obj.orig, 2) == 1
                data = [data treNumber(obj.nlayers_i, 3, 0, false, false, false)];
            end
        end
    end
    methods (Static)
        function entry = layersEntry() %#codegen
            %layersEntry - Create one editable repeated entry
            %   ENTRY = nfx.J2KLRB.layersEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newlayers();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.J2KLRB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(1, 0, 9, ...
                true, false);
            if reader.ok, obj.orig = value; end
            [value, reader] = reader.text(10, true, false);
            if reader.ok, obj.cstream = value; end
            [value, reader] = reader.number(2, 0, 32, ...
                true, false);
            if reader.ok, obj.nlevels_o = value; end
            [value, reader] = reader.number(5, 1, 16384, ...
                true, false);
            if reader.ok, obj.nbands_o = value; end
            [count, reader] = reader.count(3, 13, 999);
            entries = repmat(newlayers(), 1, 0);
            for k = 1:count
                [entry, reader] = readlayers(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.layers = entries; end
            if mod(obj.orig, 2) == 1
                [value, reader] = reader.number(2, 0, 32, ...
                    true, false);
                if reader.ok, obj.nlevels_i = value; end
            end
            if mod(obj.orig, 2) == 1
                [value, reader] = reader.number(5, 1, 16384, ...
                    true, false);
                if reader.ok, obj.nbands_i = value; end
            end
            if mod(obj.orig, 2) == 1
                [value, reader] = reader.number(3, 1, 999, ...
                    true, false);
                if reader.ok, obj.nlayers_i = value; end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.J2KLRB());
        end
    end
end

function entry = newlayers() %#codegen
    entry = struct( ...
        'layer_id', NaN, ...
        'bitrate', NaN, ...
        'placehold', '');
end

function mustBelayers(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'layer_id', ...
                'bitrate', ...
                'placehold'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.layer_id, 0, 998, true);
        mustBeMetadata(entry.bitrate, 0, 37, false);
        mustBeAscii(entry.placehold, 1);
    end
end

function report = validatelayers(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.layer_id, 3, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'layer_id', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.bitrate, 9, 6, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'bitrate', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.placehold, {'Y', 'N'})), ...
        'Enumeration', 'placehold', 'Use a defined field value.', reference);
end

function data = writelayers(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.layer_id, 3, 0, false, false, false)];
    data = [data treNumber(entry.bitrate, 9, 6, false, false, false)];
    data = [data textField(entry.placehold, 1)];
end

function [entry, reader] = readlayers(reader) %#codegen
    entry = newlayers();
    [value, reader] = reader.number(3, 0, 998, ...
        true, false);
    if reader.ok, entry.layer_id = value; end
    [value, reader] = reader.number(9, 0, 37, ...
        false, false);
    if reader.ok, entry.bitrate = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.placehold = value; end
end

function count = lengthlayers(entries) %#codegen
    count = 3 + 13 * numel(entries);
end
