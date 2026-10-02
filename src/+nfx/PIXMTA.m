classdef (Sealed) PIXMTA < nfx.TRE
    %PIXMTA - Pixel metric descriptions and image associations
    %   OBJ = PIXMTA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIXMTA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIXMTA properties:
    %       cetag - Constant tag identifier
    %       aisdlvl - AISDLVL metadata
    %       origin_x - ORIGIN_X metadata
    %       origin_y - ORIGIN_Y metadata
    %       scale_x - SCALE_X metadata
    %       scale_y - SCALE_Y metadata
    %       sample_mode - SAMPLE_MODE metadata
    %       perband - PERBAND metadata
    %       metrics - METRICS metadata
    %       reserved - RESERVED metadata
    %       all_images - Associate all applicable images
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIXMTA' % Registered tag identifier
    end
    properties
        aisdlvl {mustBeAssociatedLevels} = zeros(1, 0)
        all_images {mustBeLogicalScalar} = false
        % ORIGIN_X metadata
        origin_x {mustBeMetadata(origin_x, ...
            -1.7976931348623157e308, 1.7976931348623157e308, 0)} = NaN
        % ORIGIN_Y metadata
        origin_y {mustBeMetadata(origin_y, ...
            -1.7976931348623157e308, 1.7976931348623157e308, 0)} = NaN
        % SCALE_X metadata
        scale_x {mustBeMetadata(scale_x, ...
            0, 1.7976931348623157e308, 0)} = NaN
        % SCALE_Y metadata
        scale_y {mustBeMetadata(scale_y, ...
            0, 1.7976931348623157e308, 0)} = NaN
        sample_mode {mustBeAscii(sample_mode, 1)} = '' % SAMPLE_MODE metadata
        perband {mustBeAscii(perband, 1)} = '' % PERBAND metadata
        % METRICS repeated entries
        metrics {mustBemetrics} = repmat(newmetrics(), 1, 0)
        reserved {mustBeByteRow} = zeros(1, 0, 'uint8')
    end
    methods
        function obj = PIXMTA(options) %#codegen
            arguments
                options.?nfx.PIXMTA
            end
            if isfield(options, 'aisdlvl')
                obj.aisdlvl = options.aisdlvl;
            end
            if isfield(options, 'origin_x')
                obj.origin_x = options.origin_x;
            end
            if isfield(options, 'origin_y')
                obj.origin_y = options.origin_y;
            end
            if isfield(options, 'scale_x')
                obj.scale_x = options.scale_x;
            end
            if isfield(options, 'scale_y')
                obj.scale_y = options.scale_y;
            end
            if isfield(options, 'sample_mode')
                obj.sample_mode = options.sample_mode;
            end
            if isfield(options, 'perband')
                obj.perband = options.perband;
            end
            if isfield(options, 'metrics')
                obj.metrics = options.metrics;
            end
            if isfield(options, 'reserved')
                obj.reserved = options.reserved;
            end
            if isfield(options, 'all_images')
                obj.all_images = options.all_images;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AJ, Table AJ.6-8 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, (obj.all_images && ~isempty(obj.aisdlvl)) || ...
                numel(unique(obj.aisdlvl)) ~= numel(obj.aisdlvl), ...
                'AssociatedImages', 'aisdlvl', 'Supply distinct display levels or ALL_IMAGES.', reference);
            [~, valid] = treNumber(obj.origin_x, 14, 7, true, false, true);
            report = addIssue(report, ~valid, 'Encoding', 'origin_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.origin_y, 14, 7, true, false, true);
            report = addIssue(report, ~valid, 'Encoding', 'origin_y', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.scale_x, 14, 7, true, false, true);
            report = addIssue(report, ~valid, 'Encoding', 'scale_x', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.scale_y, 14, 7, true, false, true);
            report = addIssue(report, ~valid, 'Encoding', 'scale_y', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.sample_mode, {'F', 'I'})), ...
                'Enumeration', 'sample_mode', 'Use a defined SAMPLE_MODE value.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.perband, {'A', 'P'})), ...
                'Enumeration', 'perband', 'Use a defined PERBAND value.', reference);
            report = addIssue(report, numel(obj.metrics) < 1 || ...
                numel(obj.metrics) > 1233, ...
                'Count', 'metrics', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.metrics)
                report = validatemetrics(obj.metrics(k), report, reference);
            end
            report = addIssue(report, obj.scale_x <= 0 || obj.scale_y <= 0, ...
                'Metadata', 'scale_x/scale_y', 'Pixel metric grid scales must be positive.', reference);
            payloadLength = 3 + 3 * numel(obj.aisdlvl) + ...
                14 + ...
                14 + ...
                14 + ...
                14 + ...
                1 + ...
                5 + ...
                1 + ...
                lengthmetrics(obj.metrics) + ...
                5 + numel(obj.reserved);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data associatedLevels(obj.aisdlvl, obj.all_images)];
            data = [data treNumber(obj.origin_x, 14, 7, true, false, true)];
            data = [data treNumber(obj.origin_y, 14, 7, true, false, true)];
            data = [data treNumber(obj.scale_x, 14, 7, true, false, true)];
            data = [data treNumber(obj.scale_y, 14, 7, true, false, true)];
            data = [data textField(obj.sample_mode, 1)];
            data = [data decimalField(numel(obj.metrics), 5, 0, false)];
            data = [data textField(obj.perband, 1)];
            for k = 1:numel(obj.metrics)
                data = [data writemetrics(obj.metrics(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.reserved), 5, 0, false) obj.reserved];
        end
    end
    methods (Static)
        function entry = metricsEntry() %#codegen
            %metricsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIXMTA.metricsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newmetrics();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.PIXMTA();
            reader = nfx.internal.TREReader(data);
            [levels, allImages, reader] = readAssociatedLevels(reader);
            if reader.ok, obj.aisdlvl = levels; obj.all_images = allImages; end
            [value, reader] = reader.number(14, -Inf, Inf, ...
                false, false);
            if reader.ok, obj.origin_x = value; end
            [value, reader] = reader.number(14, -Inf, Inf, ...
                false, false);
            if reader.ok, obj.origin_y = value; end
            [value, reader] = reader.number(14, 0, Inf, ...
                false, false);
            if reader.ok, obj.scale_x = value; end
            [value, reader] = reader.number(14, 0, Inf, ...
                false, false);
            if reader.ok, obj.scale_y = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.sample_mode = value; end
            [metricsCount, reader] = reader.count(5, 81, 1233);
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.perband = value; end
            count = metricsCount;
            entries = repmat(newmetrics(), 1, 0);
            for k = 1:count
                [entry, reader] = readmetrics(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.metrics = entries; end
            [count, reader] = reader.count(5, 1, 99985);
            [value, reader] = reader.take(count);
            if reader.ok, obj.reserved = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIXMTA());
        end
    end
end

function entry = newmetrics() %#codegen
    entry = struct( ...
        'description', '', ...
        'unit', '', ...
        'fittype', '', ...
        'coef', zeros(1, 0));
end

function mustBemetrics(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'description', ...
                'unit', ...
                'fittype', ...
                'coef'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.description, 40);
        mustBeECS(entry.unit, 40);
        mustBeAscii(entry.fittype, 1);
        mustBeMetadataArray(entry.coef, -Inf, Inf, false);
    end
end

function report = validatemetrics(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.description))), ...
        'Required', 'description', 'Supply DESCRIPTION.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.unit))), ...
        'Required', 'unit', 'Supply UNIT.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.fittype, {'D', 'P'})), ...
        'Enumeration', 'fittype', 'Use a defined field value.', reference);
    if strcmp(entry.fittype, 'P')
        report = addIssue(report, numel(entry.coef) < 1 || ...
            numel(entry.coef) > 9, ...
            'Count', 'coef', 'Vector count is outside the defined range.', reference);
        for j = 1:numel(entry.coef)
            [~, valid] = treNumber(entry.coef(j), 15, 8, true, false, true);
            report = addIssue(report, ~valid, 'Encoding', 'coef', ...
                'Supply values fitting the encoded precision.', reference);
        end
    end
    report = addIssue(report, ~(strcmp(entry.fittype, 'P')) && ~isempty(entry.coef), ...
        'AbsentField', 'coef', 'Leave the omitted field unset.', reference);
end

function data = writemetrics(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.description, 40)];
    data = [data textField(entry.unit, 40)];
    data = [data textField(entry.fittype, 1)];
    if strcmp(entry.fittype, 'P')
        data = [data decimalField(numel(entry.coef), 1, 0, false)];
        for j = 1:numel(entry.coef)
            data = [data treNumber(entry.coef(j), 15, 8, true, false, true)]; %#ok<AGROW>
        end
    end
end

function [entry, reader] = readmetrics(reader) %#codegen
    entry = newmetrics();
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.description = value; end
    [value, reader] = reader.text(40, true, true);
    if reader.ok, entry.unit = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.fittype = value; end
    if strcmp(entry.fittype, 'P')
        [valueCount, reader] = reader.count(1, 15, 9);
        [value, reader] = reader.numbers(valueCount, 15, -Inf, Inf, false);
        if reader.ok, entry.coef = value; end
    end
end

function count = lengthmetrics(entries) %#codegen
    count = 0;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 40 + ...
            40 + ...
            1 + ...
            double(strcmp(entry.fittype, 'P')) * (1 + 15 * numel(entry.coef));
    end
end
