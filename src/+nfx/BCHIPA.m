classdef (Sealed) BCHIPA < nfx.TRE
    %BCHIPA - Band processing provenance and correspondence
    %   OBJ = BCHIPA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   BCHIPA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   BCHIPA properties:
    %       cetag - Constant tag identifier
    %       sde_uuid - SDE_UUID metadata
    %       num_insts - NUM_INSTS metadata
    %       instance - INSTANCE metadata
    %       include_a - INCLUDE_A metadata
    %       tot_orig_bands - TOT_ORIG_BANDS metadata
    %       tot_curr_bands - TOT_CURR_BANDS metadata
    %       bwp_is - BWP_IS metadata
    %       sdes - SDES metadata
    %       include_b - INCLUDE_B metadata
    %       original_bands - ORIGINAL_BANDS metadata
    %       include_c - INCLUDE_C metadata
    %       current_bands - CURRENT_BANDS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'BCHIPA' % Registered tag identifier
    end
    properties
        sde_uuid {mustBeAscii(sde_uuid, 36)} = '' % SDE_UUID metadata
        % NUM_INSTS metadata
        num_insts {mustBeMetadata(num_insts, ...
            1, 99999, 1)} = 1
        % INSTANCE metadata
        instance {mustBeMetadata(instance, ...
            1, 99999, 1)} = 1
        include_a {mustBeAscii(include_a, 1)} = 'Y' % INCLUDE_A metadata
        % TOT_ORIG_BANDS metadata
        tot_orig_bands {mustBeMetadata(tot_orig_bands, ...
            1, 99999, 1)} = NaN
        % TOT_CURR_BANDS metadata
        tot_curr_bands {mustBeMetadata(tot_curr_bands, ...
            1, 99999, 1)} = NaN
        % BWP_IS metadata
        bwp_is {mustBeMetadataArray(bwp_is, ...
            1, 999, 1)} = zeros(1, 0)
        % SDES repeated entries
        sdes {mustBesdes} = repmat(newsdes(), 1, 0)
        include_b {mustBeAscii(include_b, 1)} = 'N' % INCLUDE_B metadata
        % ORIGINAL_BANDS repeated entries
        original_bands {mustBeoriginal_bands} = repmat(neworiginal_bands(), 1, 0)
        include_c {mustBeAscii(include_c, 1)} = 'N' % INCLUDE_C metadata
        % CURRENT_BANDS repeated entries
        current_bands {mustBecurrent_bands} = repmat(newcurrent_bands(), 1, 0)
    end
    methods
        function obj = BCHIPA(options) %#codegen
            arguments
                options.?nfx.BCHIPA
            end
            if isfield(options, 'sde_uuid')
                obj.sde_uuid = options.sde_uuid;
            end
            if isfield(options, 'num_insts')
                obj.num_insts = options.num_insts;
            end
            if isfield(options, 'instance')
                obj.instance = options.instance;
            end
            if isfield(options, 'include_a')
                obj.include_a = options.include_a;
            end
            if isfield(options, 'tot_orig_bands')
                obj.tot_orig_bands = options.tot_orig_bands;
            end
            if isfield(options, 'tot_curr_bands')
                obj.tot_curr_bands = options.tot_curr_bands;
            end
            if isfield(options, 'bwp_is')
                obj.bwp_is = options.bwp_is;
            end
            if isfield(options, 'sdes')
                obj.sdes = options.sdes;
            end
            if isfield(options, 'include_b')
                obj.include_b = options.include_b;
            end
            if isfield(options, 'original_bands')
                obj.original_bands = options.original_bands;
            end
            if isfield(options, 'include_c')
                obj.include_c = options.include_c;
            end
            if isfield(options, 'current_bands')
                obj.current_bands = options.current_bands;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AR, Table AR.5-3 (2024-04)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.num_insts, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'num_insts', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.instance, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'instance', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.include_a, {'Y', 'N'})), ...
                'Enumeration', 'include_a', 'Use a defined INCLUDE_A value.', reference);
            if strcmp(obj.include_a, 'Y')
                [~, valid] = treNumber(obj.tot_orig_bands, 5, 0, false, false, false);
                report = addIssue(report, ~valid, 'Encoding', 'tot_orig_bands', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.include_a, 'Y')) && ~isnan(obj.tot_orig_bands), ...
                'AbsentField', 'tot_orig_bands', 'Leave the omitted field empty.', reference);
            if strcmp(obj.include_a, 'Y')
                [~, valid] = treNumber(obj.tot_curr_bands, 5, 0, false, false, false);
                report = addIssue(report, ~valid, 'Encoding', 'tot_curr_bands', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.include_a, 'Y')) && ~isnan(obj.tot_curr_bands), ...
                'AbsentField', 'tot_curr_bands', 'Leave the omitted field empty.', reference);
            if strcmp(obj.include_a, 'Y')
                report = addIssue(report, ...
                    ~(isrow(obj.bwp_is) || isempty(obj.bwp_is)) || ...
                    numel(obj.bwp_is) < 1 || numel(obj.bwp_is) > 999, ...
                    'Count', 'bwp_is', 'Supply a row within the defined count limits.', reference);
                for k = 1:numel(obj.bwp_is)
                    [~, valid] = treNumber(obj.bwp_is(k), 3, 0, false, false, false);
                    report = addIssue(report, ~valid, 'Encoding', 'bwp_is', ...
                        'Supply finite values fitting the encoded precision.', reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.include_a, 'Y')) && ~isempty(obj.bwp_is), ...
                'AbsentField', 'bwp_is', 'Leave the omitted field empty.', reference);
            if strcmp(obj.include_a, 'Y')
                report = addIssue(report, numel(obj.sdes) < 0 || ...
                    numel(obj.sdes) > 999, ...
                    'Count', 'sdes', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.sdes)
                    report = validatesdes(obj.sdes(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.include_a, 'Y')) && ~isempty(obj.sdes), ...
                'AbsentField', 'sdes', 'Leave the omitted group empty.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.include_b, {'Y', 'N'})), ...
                'Enumeration', 'include_b', 'Use a defined INCLUDE_B value.', reference);
            if strcmp(obj.include_b, 'Y')
                report = addIssue(report, numel(obj.original_bands) < 1 || ...
                    numel(obj.original_bands) > 99999, ...
                    'Count', 'original_bands', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.original_bands)
                    report = validateoriginal_bands(obj.original_bands(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.include_b, 'Y')) && ~isempty(obj.original_bands), ...
                'AbsentField', 'original_bands', 'Leave the omitted group empty.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.include_c, {'Y', 'N'})), ...
                'Enumeration', 'include_c', 'Use a defined INCLUDE_C value.', reference);
            if strcmp(obj.include_c, 'Y')
                report = addIssue(report, numel(obj.current_bands) < 1 || ...
                    numel(obj.current_bands) > 99999, ...
                    'Count', 'current_bands', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.current_bands)
                    report = validatecurrent_bands(obj.current_bands(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.include_c, 'Y')) && ~isempty(obj.current_bands), ...
                'AbsentField', 'current_bands', 'Leave the omitted group empty.', reference);
            report = addIssue(report, obj.instance > obj.num_insts, ...
                'Metadata', 'instance', 'INSTANCE cannot exceed NUM_INSTS.', reference);
            report = addIssue(report, obj.instance == 1 && ~strcmp(obj.include_a, 'Y'), ...
                'Metadata', 'include_a', 'The first instance must include the image identification group.', reference);
            report = addIssue(report, strcmp(obj.include_a, 'N') && strcmp(obj.include_b, 'N') && strcmp(obj.include_c, 'N'), ...
                'Metadata', 'include_a/include_b/include_c', 'Include at least one metadata group.', reference);
            report = addIssue(report, ~isempty(char(obj.sde_uuid)) && ...
                (~validUUID(obj.sde_uuid) || ~strcmp(char(obj.sde_uuid), lower(char(obj.sde_uuid)))), ...
                'Metadata', 'sde_uuid', 'Supply a lowercase canonical UUID or leave it blank.', reference);
            payloadLength = 36 + ...
                5 + ...
                5 + ...
                1 + ...
                double(strcmp(obj.include_a, 'Y')) * (5) + ...
                double(strcmp(obj.include_a, 'Y')) * (5) + ...
                double(strcmp(obj.include_a, 'Y')) * (3 + 3 * numel(obj.bwp_is)) + ...
                double(strcmp(obj.include_a, 'Y')) * (lengthsdes(obj.sdes)) + ...
                1 + ...
                double(strcmp(obj.include_b, 'Y')) * (lengthoriginal_bands(obj.original_bands)) + ...
                1 + ...
                double(strcmp(obj.include_c, 'Y')) * (lengthcurrent_bands(obj.current_bands));
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.sde_uuid, 36)];
            data = [data treNumber(obj.num_insts, 5, 0, false, false, false)];
            data = [data treNumber(obj.instance, 5, 0, false, false, false)];
            data = [data textField(obj.include_a, 1)];
            if strcmp(obj.include_a, 'Y')
                data = [data treNumber(obj.tot_orig_bands, 5, 0, false, false, false)];
            end
            if strcmp(obj.include_a, 'Y')
                data = [data treNumber(obj.tot_curr_bands, 5, 0, false, false, false)];
            end
            if strcmp(obj.include_a, 'Y')
                data = [data decimalField(numel(obj.bwp_is), 3, 0, false)];
                for k = 1:numel(obj.bwp_is)
                    data = [data treNumber(obj.bwp_is(k), 3, 0, false, false, false)]; %#ok<AGROW>
                end
            end
            if strcmp(obj.include_a, 'Y')
                data = [data decimalField(numel(obj.sdes), 3, 0, false)];
                for k = 1:numel(obj.sdes)
                    data = [data writesdes(obj.sdes(k))]; %#ok<AGROW>
                end
            end
            data = [data textField(obj.include_b, 1)];
            if strcmp(obj.include_b, 'Y')
                data = [data decimalField(numel(obj.original_bands), 5, 0, false)];
                for k = 1:numel(obj.original_bands)
                    data = [data writeoriginal_bands(obj.original_bands(k))]; %#ok<AGROW>
                end
            end
            data = [data textField(obj.include_c, 1)];
            if strcmp(obj.include_c, 'Y')
                data = [data decimalField(numel(obj.current_bands), 5, 0, false)];
                for k = 1:numel(obj.current_bands)
                    data = [data writecurrent_bands(obj.current_bands(k))]; %#ok<AGROW>
                end
            end
        end
    end
    methods (Static)
        function entry = sdesEntry() %#codegen
            %sdesEntry - Create one editable repeated entry
            %   ENTRY = nfx.BCHIPA.sdesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newsdes();
        end

        function entry = original_bandsEntry() %#codegen
            %original_bandsEntry - Create one editable repeated entry
            %   ENTRY = nfx.BCHIPA.original_bandsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = neworiginal_bands();
        end

        function entry = current_bandsEntry() %#codegen
            %current_bandsEntry - Create one editable repeated entry
            %   ENTRY = nfx.BCHIPA.current_bandsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newcurrent_bands();
        end

        function entry = originalEntry() %#codegen
            %originalEntry - Create one editable repeated entry
            %   ENTRY = nfx.BCHIPA.originalEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = neworiginal();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.BCHIPA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(36, true, false);
            if reader.ok, obj.sde_uuid = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.num_insts = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.instance = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.include_a = value; end
            if strcmp(obj.include_a, 'Y')
                [value, reader] = reader.number(5, 1, 99999, ...
                    true, false);
                if reader.ok, obj.tot_orig_bands = value; end
            end
            if strcmp(obj.include_a, 'Y')
                [value, reader] = reader.number(5, 1, 99999, ...
                    true, false);
                if reader.ok, obj.tot_curr_bands = value; end
            end
            if strcmp(obj.include_a, 'Y')
                [count, reader] = reader.count(3, 3, 999);
                [value, reader] = reader.numbers(count, 3, 1, 999, ...
                    true, false);
                if reader.ok, obj.bwp_is = value; end
            end
            if strcmp(obj.include_a, 'Y')
                [count, reader] = reader.count(3, 33, 999);
                entries = repmat(newsdes(), 1, 0);
                for k = 1:count
                    [entry, reader] = readsdes(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.sdes = entries; end
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.include_b = value; end
            if strcmp(obj.include_b, 'Y')
                [count, reader] = reader.count(5, 20, 99999);
                entries = repmat(neworiginal_bands(), 1, 0);
                for k = 1:count
                    [entry, reader] = readoriginal_bands(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.original_bands = entries; end
            end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.include_c = value; end
            if strcmp(obj.include_c, 'Y')
                [count, reader] = reader.count(5, 29, 99999);
                entries = repmat(newcurrent_bands(), 1, 0);
                for k = 1:count
                    [entry, reader] = readcurrent_bands(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.current_bands = entries; end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.BCHIPA());
        end
    end
end

function entry = newsdes() %#codegen
    entry = struct( ...
        'sde_name', '', ...
        'sde_status', '');
end

function mustBesdes(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'sde_name', ...
                'sde_status'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.sde_name, 32);
        mustBeAscii(entry.sde_status, 1);
    end
end

function report = validatesdes(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.sde_name))), ...
        'Required', 'sde_name', 'Supply SDE_NAME.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.sde_status, {'O', 'W', 'C', 'D', 'U', 'N'})), ...
        'Enumeration', 'sde_status', 'Use a defined field value.', reference);
end

function data = writesdes(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.sde_name, 32)];
    data = [data textField(entry.sde_status, 1)];
end

function [entry, reader] = readsdes(reader) %#codegen
    entry = newsdes();
    [value, reader] = reader.text(32, true, false);
    if reader.ok, entry.sde_name = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.sde_status = value; end
end

function count = lengthsdes(entries) %#codegen
    count = 3 + 33 * numel(entries);
end

function entry = neworiginal_bands() %#codegen
    entry = struct( ...
        'orig_band_number', NaN, ...
        'irepband_orig', '', ...
        'isubcat_orig', '', ...
        'lutd_orig', zeros(0, 0, 'uint8'));
end

function mustBeoriginal_bands(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 4 || ...
            ~all(isfield(entries, { ...
                'orig_band_number', ...
                'irepband_orig', ...
                'isubcat_orig', ...
                'lutd_orig'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.orig_band_number, 1, 99999, true);
        mustBeAscii(entry.irepband_orig, 2);
        mustBeAscii(entry.isubcat_orig, 8);
        mustBeTRELookupTables(entry.lutd_orig);
    end
end

function report = validateoriginal_bands(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.orig_band_number, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'orig_band_number', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writeoriginal_bands(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.orig_band_number, 5, 0, false, false, false)];
    data = [data textField(entry.irepband_orig, 2)];
    data = [data textField(entry.isubcat_orig, 8)];
    data = [data uint8('N')];
    data = [data uint8('   ')];
    data = [data decimalField(size(entry.lutd_orig, 2), 1, 0, false)];
    if ~isempty(entry.lutd_orig)
        data = [data decimalField(size(entry.lutd_orig, 1), 5, 0, false) ...
            reshape(entry.lutd_orig, 1, [])];
    end
end

function [entry, reader] = readoriginal_bands(reader) %#codegen
    entry = neworiginal_bands();
    [value, reader] = reader.number(5, 1, 99999, ...
        true, false);
    if reader.ok, entry.orig_band_number = value; end
    [value, reader] = reader.text(2, true, false);
    if reader.ok, entry.irepband_orig = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.isubcat_orig = value; end
    reader = reader.literal('N');
    reader = reader.literal('   ');
    [lutCount, reader] = reader.number(1, 0, 3, true);
    if reader.ok && lutCount > 0
        [lutLength, reader] = reader.number(5, 1, 65536, true);
        [raw, reader] = reader.take(lutCount * lutLength);
        if reader.ok, entry.lutd_orig = reshape(raw, lutLength, lutCount); end
    end
end

function count = lengthoriginal_bands(entries) %#codegen
    count = 5;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 5 + ...
            2 + ...
            8 + ...
            1 + ...
            3 + ...
            1 + 5 * double(~isempty(entry.lutd_orig)) + numel(entry.lutd_orig);
    end
end

function entry = newcurrent_bands() %#codegen
    entry = struct( ...
        'curr_band_number', NaN, ...
        'semantic_meaning', '', ...
        'mapping_type', '', ...
        'original', repmat(neworiginal(), 1, 0), ...
        'formula', '');
end

function mustBecurrent_bands(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 5 || ...
            ~all(isfield(entries, { ...
                'curr_band_number', ...
                'semantic_meaning', ...
                'mapping_type', ...
                'original', ...
                'formula'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.curr_band_number, 1, 99999, true);
        mustBeAscii(entry.semantic_meaning, 9999);
        mustBeAscii(entry.mapping_type, 15);
        mustBeoriginal(entry.original);
        mustBeAscii(entry.formula, 999);
    end
end

function report = validatecurrent_bands(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.curr_band_number, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'curr_band_number', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.mapping_type, {'', 'IDENTICAL', 'AVERAGE', 'WEIGHTED', 'LUT_APPLIED', 'COLOR_MAP', 'INSERTION', 'MOSAIC', 'DEMOSAIC', 'FORMULAIC'})), ...
        'Enumeration', 'mapping_type', 'Use a defined field value.', reference);
    report = addIssue(report, numel(entry.original) < 0 || ...
        numel(entry.original) > 99999, ...
        'Count', 'original', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.original)
        report = validateoriginal(entry.original(childK), report, reference, entry.mapping_type);
    end
    if ~isempty(entry.original) && strcmp(entry.mapping_type, 'FORMULAIC')
        report = addIssue(report, isempty(strtrim(char(entry.formula))), ...
            'Required', 'formula', 'Supply FORMULA.', reference);
    end
    report = addIssue(report, ~(~isempty(entry.original) && strcmp(entry.mapping_type, 'FORMULAIC')) && ~isempty(entry.formula), ...
        'AbsentField', 'formula', 'Leave the omitted field unset.', reference);
    report = addIssue(report, strcmp(entry.mapping_type, 'IDENTICAL') && numel(entry.original) ~= 1, ...
        'Metadata', 'original', 'An identical mapping uses exactly one original band.', reference);
    report = addIssue(report, strcmp(entry.mapping_type, 'INSERTION') && ~isempty(entry.original), ...
        'Metadata', 'original', 'An inserted band has no original-band references.', reference);
end

function data = writecurrent_bands(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.curr_band_number, 5, 0, false, false, false)];
    data = [data decimalField(numel(char(entry.semantic_meaning)), 4, 0, false) ...
        uint8(char(entry.semantic_meaning))];
    data = [data decimalField(numel(entry.original), 5, 0, false)];
    data = [data textField(entry.mapping_type, 15)];
    for childK = 1:numel(entry.original)
        data = [data writeoriginal(entry.original(childK), entry.mapping_type)]; %#ok<AGROW>
    end
    if ~isempty(entry.original) && strcmp(entry.mapping_type, 'FORMULAIC')
        data = [data decimalField(numel(char(entry.formula)), 3, 0, false) ...
            uint8(char(entry.formula))];
    end
end

function [entry, reader] = readcurrent_bands(reader) %#codegen
    entry = newcurrent_bands();
    [value, reader] = reader.number(5, 1, 99999, ...
        true, false);
    if reader.ok, entry.curr_band_number = value; end
    [count, reader] = reader.count(4, 1, 9999);
    [value, reader] = reader.text(count, false, false);
    if reader.ok, entry.semantic_meaning = value; end
    [originalCount, reader] = reader.number(5, 0, 99999, true);
    [value, reader] = reader.text(15, true, false);
    if reader.ok, entry.mapping_type = value; end
    childCount = originalCount;
    childEntries = repmat(neworiginal(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readoriginal(reader, entry.mapping_type);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.original = childEntries; end
    if ~isempty(entry.original) && strcmp(entry.mapping_type, 'FORMULAIC')
        [count, reader] = reader.count(3, 1, 999);
        [value, reader] = reader.text(count, false, false);
        if reader.ok, entry.formula = value; end
    end
end

function count = lengthcurrent_bands(entries) %#codegen
    count = 5;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 5 + ...
            4 + numel(char(entry.semantic_meaning)) + ...
            5 + ...
            15 + ...
            lengthoriginal(entry.original, entry.mapping_type) + ...
            double(~isempty(entry.original) && strcmp(entry.mapping_type, 'FORMULAIC')) * (3 + numel(char(entry.formula)));
    end
end

function entry = neworiginal() %#codegen
    entry = struct( ...
        'orig_bnd_num', NaN, ...
        'weight', NaN);
end

function mustBeoriginal(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'orig_bnd_num', ...
                'weight'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.orig_bnd_num, 1, 99999, true);
        mustBeMetadata(entry.weight, -9.99999999999999e+99, 9.99999999999999e+99, false);
    end
end

function report = validateoriginal(entry, report, reference, context_mapping_type) %#codegen
    [~, valid] = treNumber(entry.orig_bnd_num, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'orig_bnd_num', ...
        'Supply a value fitting the encoded precision.', reference);
    if strcmp(context_mapping_type, 'WEIGHTED')
        [~, valid] = rsmNumber(entry.weight, false);
        report = addIssue(report, ~valid, 'Encoding', 'weight', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(strcmp(context_mapping_type, 'WEIGHTED')) && ~isnan(entry.weight), ...
        'AbsentField', 'weight', 'Leave the omitted field unset.', reference);
end

function data = writeoriginal(entry, context_mapping_type) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.orig_bnd_num, 5, 0, false, false, false)];
    if strcmp(context_mapping_type, 'WEIGHTED')
        data = [data rsmNumber(entry.weight, false)];
    end
end

function [entry, reader] = readoriginal(reader, context_mapping_type) %#codegen
    entry = neworiginal();
    [value, reader] = reader.number(5, 1, 99999, ...
        true, false);
    if reader.ok, entry.orig_bnd_num = value; end
    if strcmp(context_mapping_type, 'WEIGHTED')
        [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
            false, false);
        if reader.ok, entry.weight = value; end
    end
end

function count = lengthoriginal(entries, context_mapping_type) %#codegen
    count = 0;
    for k = 1:numel(entries)
        count = count + 5 + ...
            double(strcmp(context_mapping_type, 'WEIGHTED')) * (21);
    end
end
