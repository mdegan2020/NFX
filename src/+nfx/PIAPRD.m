classdef (Sealed) PIAPRD < nfx.TRE
    %PIAPRD - Imagery access product metadata
    %   OBJ = PIAPRD(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIAPRD functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIAPRD properties:
    %       cetag - Constant tag identifier
    %       accessid - ACCESSID metadata
    %       fmcontrol - FMCONTROL metadata
    %       subdet - SUBDET metadata
    %       prodcode - PRODCODE metadata
    %       producerse - PRODUCERSE metadata
    %       prodidno - PRODIDNO metadata
    %       prodsnme - PRODSNME metadata
    %       producercd - PRODUCERCD metadata
    %       prodcrtime - PRODCRTIME metadata
    %       mapid - MAPID metadata
    %       sections - SECTIONS metadata
    %       organizations - ORGANIZATIONS metadata
    %       keywords - KEYWORDS metadata
    %       reports - REPORTS metadata
    %       texts - TEXTS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIAPRD' % Registered tag identifier
    end
    properties
        accessid {mustBeAscii(accessid, 64)} = '' % ACCESSID metadata
        fmcontrol {mustBeAscii(fmcontrol, 32)} = '' % FMCONTROL metadata
        subdet {mustBeAscii(subdet, 1)} = '' % SUBDET metadata
        prodcode {mustBeAscii(prodcode, 2)} = '' % PRODCODE metadata
        producerse {mustBeAscii(producerse, 6)} = '' % PRODUCERSE metadata
        prodidno {mustBeAscii(prodidno, 20)} = '' % PRODIDNO metadata
        prodsnme {mustBeAscii(prodsnme, 10)} = '' % PRODSNME metadata
        producercd {mustBeAscii(producercd, 2)} = '' % PRODUCERCD metadata
        prodcrtime {mustBeAscii(prodcrtime, 14)} = '' % PRODCRTIME metadata
        mapid {mustBeAscii(mapid, 40)} = '' % MAPID metadata
        % SECTIONS repeated entries
        sections {mustBesections} = repmat(newsections(), 1, 0)
        % ORGANIZATIONS repeated entries
        organizations {mustBeorganizations} = repmat(neworganizations(), 1, 0)
        % KEYWORDS repeated entries
        keywords {mustBekeywords} = repmat(newkeywords(), 1, 0)
        % REPORTS repeated entries
        reports {mustBereports} = repmat(newreports(), 1, 0)
        % TEXTS repeated entries
        texts {mustBetexts} = repmat(newtexts(), 1, 0)
    end
    methods
        function obj = PIAPRD(options) %#codegen
            arguments
                options.?nfx.PIAPRD
            end
            if isfield(options, 'accessid')
                obj.accessid = options.accessid;
            end
            if isfield(options, 'fmcontrol')
                obj.fmcontrol = options.fmcontrol;
            end
            if isfield(options, 'subdet')
                obj.subdet = options.subdet;
            end
            if isfield(options, 'prodcode')
                obj.prodcode = options.prodcode;
            end
            if isfield(options, 'producerse')
                obj.producerse = options.producerse;
            end
            if isfield(options, 'prodidno')
                obj.prodidno = options.prodidno;
            end
            if isfield(options, 'prodsnme')
                obj.prodsnme = options.prodsnme;
            end
            if isfield(options, 'producercd')
                obj.producercd = options.producercd;
            end
            if isfield(options, 'prodcrtime')
                obj.prodcrtime = options.prodcrtime;
            end
            if isfield(options, 'mapid')
                obj.mapid = options.mapid;
            end
            if isfield(options, 'sections')
                obj.sections = options.sections;
            end
            if isfield(options, 'organizations')
                obj.organizations = options.organizations;
            end
            if isfield(options, 'keywords')
                obj.keywords = options.keywords;
            end
            if isfield(options, 'reports')
                obj.reports = options.reports;
            end
            if isfield(options, 'texts')
                obj.texts = options.texts;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-5 (2025-06)';
            report = newReport(reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.subdet, {'', 'P', 'F', 'G', 'E'})), ...
                'Enumeration', 'subdet', 'Use a defined SUBDET value.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.prodsnme))), ...
                'Required', 'prodsnme', 'Supply PRODSNME.', reference);
            report = addIssue(report, numel(obj.sections) < 0 || ...
                numel(obj.sections) > 99, ...
                'Count', 'sections', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.sections)
                report = validatesections(obj.sections(k), report, reference);
            end
            report = addIssue(report, numel(obj.organizations) < 0 || ...
                numel(obj.organizations) > 99, ...
                'Count', 'organizations', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.organizations)
                report = validateorganizations(obj.organizations(k), report, reference);
            end
            report = addIssue(report, numel(obj.keywords) < 0 || ...
                numel(obj.keywords) > 99, ...
                'Count', 'keywords', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.keywords)
                report = validatekeywords(obj.keywords(k), report, reference);
            end
            report = addIssue(report, numel(obj.reports) < 0 || ...
                numel(obj.reports) > 99, ...
                'Count', 'reports', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.reports)
                report = validatereports(obj.reports(k), report, reference);
            end
            report = addIssue(report, numel(obj.texts) < 0 || ...
                numel(obj.texts) > 99, ...
                'Count', 'texts', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.texts)
                report = validatetexts(obj.texts(k), report, reference);
            end
            report = addIssue(report, ~isempty(char(obj.prodcrtime)) && ...
                ~knownDate(obj.prodcrtime, 14), ...
                'Metadata', 'prodcrtime', 'Supply a UTC timestamp or blank.', reference);
            payloadLength = 64 + ...
                32 + ...
                1 + ...
                2 + ...
                6 + ...
                20 + ...
                10 + ...
                2 + ...
                14 + ...
                40 + ...
                lengthsections(obj.sections) + ...
                lengthorganizations(obj.organizations) + ...
                lengthkeywords(obj.keywords) + ...
                lengthreports(obj.reports) + ...
                lengthtexts(obj.texts);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.accessid, 64)];
            data = [data textField(obj.fmcontrol, 32)];
            data = [data textField(obj.subdet, 1)];
            data = [data textField(obj.prodcode, 2)];
            data = [data textField(obj.producerse, 6)];
            data = [data textField(obj.prodidno, 20)];
            data = [data textField(obj.prodsnme, 10)];
            data = [data textField(obj.producercd, 2)];
            data = [data textField(obj.prodcrtime, 14)];
            data = [data textField(obj.mapid, 40)];
            data = [data decimalField(numel(obj.sections), 2, 0, false)];
            for k = 1:numel(obj.sections)
                data = [data writesections(obj.sections(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.organizations), 2, 0, false)];
            for k = 1:numel(obj.organizations)
                data = [data writeorganizations(obj.organizations(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.keywords), 2, 0, false)];
            for k = 1:numel(obj.keywords)
                data = [data writekeywords(obj.keywords(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.reports), 2, 0, false)];
            for k = 1:numel(obj.reports)
                data = [data writereports(obj.reports(k))]; %#ok<AGROW>
            end
            data = [data decimalField(numel(obj.texts), 2, 0, false)];
            for k = 1:numel(obj.texts)
                data = [data writetexts(obj.texts(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = sectionsEntry() %#codegen
            %sectionsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIAPRD.sectionsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newsections();
        end

        function entry = organizationsEntry() %#codegen
            %organizationsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIAPRD.organizationsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = neworganizations();
        end

        function entry = keywordsEntry() %#codegen
            %keywordsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIAPRD.keywordsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newkeywords();
        end

        function entry = reportsEntry() %#codegen
            %reportsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIAPRD.reportsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newreports();
        end

        function entry = textsEntry() %#codegen
            %textsEntry - Create one editable repeated entry
            %   ENTRY = nfx.PIAPRD.textsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newtexts();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.PIAPRD();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(64, true, false);
            if reader.ok, obj.accessid = value; end
            [value, reader] = reader.text(32, true, false);
            if reader.ok, obj.fmcontrol = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.subdet = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.prodcode = value; end
            [value, reader] = reader.text(6, true, false);
            if reader.ok, obj.producerse = value; end
            [value, reader] = reader.text(20, true, false);
            if reader.ok, obj.prodidno = value; end
            [value, reader] = reader.text(10, true, false);
            if reader.ok, obj.prodsnme = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.producercd = value; end
            [value, reader] = reader.text(14, true, false);
            if reader.ok, obj.prodcrtime = value; end
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.mapid = value; end
            [count, reader] = reader.count(2, 48, 99);
            entries = repmat(newsections(), 1, 0);
            for k = 1:count
                [entry, reader] = readsections(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.sections = entries; end
            [count, reader] = reader.count(2, 64, 99);
            entries = repmat(neworganizations(), 1, 0);
            for k = 1:count
                [entry, reader] = readorganizations(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.organizations = entries; end
            [count, reader] = reader.count(2, 255, 99);
            entries = repmat(newkeywords(), 1, 0);
            for k = 1:count
                [entry, reader] = readkeywords(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.keywords = entries; end
            [count, reader] = reader.count(2, 20, 99);
            entries = repmat(newreports(), 1, 0);
            for k = 1:count
                [entry, reader] = readreports(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.reports = entries; end
            [count, reader] = reader.count(2, 255, 99);
            entries = repmat(newtexts(), 1, 0);
            for k = 1:count
                [entry, reader] = readtexts(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.texts = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIAPRD());
        end
    end
end

function entry = newsections() %#codegen
    entry = struct( ...
        'sectitle', '', ...
        'ppnum', '', ...
        'tpp', NaN);
end

function mustBesections(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'sectitle', ...
                'ppnum', ...
                'tpp'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.sectitle, 40);
        mustBeAscii(entry.ppnum, 5);
        mustBeMetadata(entry.tpp, 1, 999, true);
    end
end

function report = validatesections(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.tpp, 3, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'tpp', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writesections(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.sectitle, 40)];
    data = [data textField(entry.ppnum, 5)];
    data = [data treNumber(entry.tpp, 3, 0, false, false, false)];
end

function [entry, reader] = readsections(reader) %#codegen
    entry = newsections();
    [value, reader] = reader.text(40, true, false);
    if reader.ok, entry.sectitle = value; end
    [value, reader] = reader.text(5, true, false);
    if reader.ok, entry.ppnum = value; end
    [value, reader] = reader.number(3, 1, 999, ...
        true, false);
    if reader.ok, entry.tpp = value; end
end

function count = lengthsections(entries) %#codegen
    count = 2 + 48 * numel(entries);
end

function entry = neworganizations() %#codegen
    entry = struct( ...
        'reqorg', '');
end

function mustBeorganizations(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'reqorg'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.reqorg, 64);
    end
end

function report = validateorganizations(~, report, ~) %#codegen
end

function data = writeorganizations(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.reqorg, 64)];
end

function [entry, reader] = readorganizations(reader) %#codegen
    entry = neworganizations();
    [value, reader] = reader.text(64, true, false);
    if reader.ok, entry.reqorg = value; end
end

function count = lengthorganizations(entries) %#codegen
    count = 2 + 64 * numel(entries);
end

function entry = newkeywords() %#codegen
    entry = struct( ...
        'keyword', '');
end

function mustBekeywords(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'keyword'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.keyword, 255);
    end
end

function report = validatekeywords(~, report, ~) %#codegen
end

function data = writekeywords(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.keyword, 255)];
end

function [entry, reader] = readkeywords(reader) %#codegen
    entry = newkeywords();
    [value, reader] = reader.text(255, true, false);
    if reader.ok, entry.keyword = value; end
end

function count = lengthkeywords(entries) %#codegen
    count = 2 + 255 * numel(entries);
end

function entry = newreports() %#codegen
    entry = struct( ...
        'assrpt', '');
end

function mustBereports(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'assrpt'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.assrpt, 20);
    end
end

function report = validatereports(~, report, ~) %#codegen
end

function data = writereports(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.assrpt, 20)];
end

function [entry, reader] = readreports(reader) %#codegen
    entry = newreports();
    [value, reader] = reader.text(20, true, false);
    if reader.ok, entry.assrpt = value; end
end

function count = lengthreports(entries) %#codegen
    count = 2 + 20 * numel(entries);
end

function entry = newtexts() %#codegen
    entry = struct( ...
        'atext', '');
end

function mustBetexts(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'atext'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.atext, 255);
    end
end

function report = validatetexts(~, report, ~) %#codegen
end

function data = writetexts(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.atext, 255)];
end

function [entry, reader] = readtexts(reader) %#codegen
    entry = newtexts();
    [value, reader] = reader.text(255, true, false);
    if reader.ok, entry.atext = value; end
end

function count = lengthtexts(entries) %#codegen
    count = 2 + 255 * numel(entries);
end
