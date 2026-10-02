classdef (Sealed) SOURCB < nfx.TRE
    %SOURCB - Map source descriptions
    %   OBJ = SOURCB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   SOURCB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   SOURCB properties:
    %       cetag - Constant tag identifier
    %       is_sca - IS_SCA metadata
    %       cpatch - CPATCH metadata
    %       sources - SOURCES metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'SOURCB' % Registered tag identifier
    end
    properties
        % IS_SCA metadata
        is_sca {mustBeMetadata(is_sca, ...
            1, 999999999, 1)} = NaN
        cpatch {mustBeAscii(cpatch, 10)} = '' % CPATCH metadata
        % SOURCES repeated entries
        sources {mustBesources} = repmat(newsources(), 1, 0)
    end
    methods
        function obj = SOURCB(options) %#codegen
            arguments
                options.?nfx.SOURCB
            end
            if isfield(options, 'is_sca')
                obj.is_sca = options.is_sca;
            end
            if isfield(options, 'cpatch')
                obj.cpatch = options.cpatch;
            end
            if isfield(options, 'sources')
                obj.sources = options.sources;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-14 (2024-04)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.is_sca, 9, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'is_sca', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(obj.sources) < 1 || ...
                numel(obj.sources) > 99, ...
                'Count', 'sources', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.sources)
                report = validatesources(obj.sources(k), report, reference);
            end
            payloadLength = 9 + ...
                10 + ...
                lengthsources(obj.sources);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.is_sca, 9, 0, false, false, false)];
            data = [data textField(obj.cpatch, 10)];
            data = [data decimalField(numel(obj.sources), 2, 0, false)];
            for k = 1:numel(obj.sources)
                data = [data writesources(obj.sources(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = sourcesEntry() %#codegen
            %sourcesEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.sourcesEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newsources();
        end

        function entry = polygonsEntry() %#codegen
            %polygonsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.polygonsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newpolygons();
        end

        function entry = pointsEntry() %#codegen
            %pointsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.pointsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newpoints();
        end

        function entry = magneticEntry() %#codegen
            %magneticEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.magneticEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newmagnetic();
        end

        function entry = legendsEntry() %#codegen
            %legendsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.legendsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newlegends();
        end

        function entry = insetsEntry() %#codegen
            %insetsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SOURCB.insetsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newinsets();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.SOURCB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(9, 1, 999999999, ...
                true, false);
            if reader.ok, obj.is_sca = value; end
            [value, reader] = reader.text(10, true, false);
            if reader.ok, obj.cpatch = value; end
            [count, reader] = reader.count(2, 885, 99);
            entries = repmat(newsources(), 1, 0);
            for k = 1:count
                [entry, reader] = readsources(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.sources = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.SOURCB());
        end
    end
end

function entry = newsources() %#codegen
    entry = struct( ...
        'polygons', repmat(newpolygons(), 1, 0), ...
        'prt', '', ...
        'urf', '', ...
        'edn', '', ...
        'nam', '', ...
        'cdp', 29, ...
        'cdv', '', ...
        'cdv27', '', ...
        'srn', '', ...
        'sca', NaN, ...
        'unisqu', '', ...
        'squ', NaN, ...
        'unipci', '', ...
        'pci', NaN, ...
        'wpc', 999, ...
        'nst', 0, ...
        'unihke', '', ...
        'hke', NaN, ...
        'lonhke', NaN, ...
        'lathke', NaN, ...
        'qss', 'U', ...
        'qod', 'N', ...
        'cdv10', '', ...
        'qle', 'UNRESTRICTED', ...
        'cpy', 'UNCOPYRIGHTED', ...
        'magnetic', repmat(newmagnetic(), 1, 0), ...
        'legends', repmat(newlegends(), 1, 0), ...
        'dag', '', ...
        'dcd', '', ...
        'ell', '', ...
        'elc', '', ...
        'dvr', '', ...
        'vdcdvr', '', ...
        'sda', '', ...
        'vdcsda', '', ...
        'prn', '', ...
        'pco', '', ...
        'prj', zeros(1, 0), ...
        'xor', NaN, ...
        'yor', NaN, ...
        'grd', '', ...
        'grn', '', ...
        'zna', 0, ...
        'insets', repmat(newinsets(), 1, 0));
end

function mustBesources(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 44 || ...
            ~all(isfield(entries, { ...
                'polygons', ...
                'prt', ...
                'urf', ...
                'edn', ...
                'nam', ...
                'cdp', ...
                'cdv', ...
                'cdv27', ...
                'srn', ...
                'sca', ...
                'unisqu', ...
                'squ', ...
                'unipci', ...
                'pci', ...
                'wpc', ...
                'nst', ...
                'unihke', ...
                'hke', ...
                'lonhke', ...
                'lathke', ...
                'qss', ...
                'qod', ...
                'cdv10', ...
                'qle', ...
                'cpy', ...
                'magnetic', ...
                'legends', ...
                'dag', ...
                'dcd', ...
                'ell', ...
                'elc', ...
                'dvr', ...
                'vdcdvr', ...
                'sda', ...
                'vdcsda', ...
                'prn', ...
                'pco', ...
                'prj', ...
                'xor', ...
                'yor', ...
                'grd', ...
                'grn', ...
                'zna', ...
                'insets'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBepolygons(entry.polygons);
        mustBeAscii(entry.prt, 10);
        mustBeAscii(entry.urf, 20);
        mustBeAscii(entry.edn, 7);
        mustBeAscii(entry.nam, 20);
        mustBeMetadata(entry.cdp, 0, 999, true);
        mustBeAscii(entry.cdv, 8);
        mustBeAscii(entry.cdv27, 8);
        mustBeAscii(entry.srn, 80);
        mustBeMetadata(entry.sca, 0, 999999999, true);
        mustBeAscii(entry.unisqu, 3);
        mustBeMetadata(entry.squ, 0, 9999999999, true);
        mustBeAscii(entry.unipci, 3);
        mustBeMetadata(entry.pci, 0, 9999, true);
        mustBeMetadata(entry.wpc, 0, 999, true);
        mustBeMetadata(entry.nst, 0, 999, true);
        mustBeAscii(entry.unihke, 3);
        mustBeMetadata(entry.hke, -99999, 999999, false);
        mustBeMetadata(entry.lonhke, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.lathke, -99999999999999, 999999999999999, false);
        mustBeAscii(entry.qss, 1);
        mustBeAscii(entry.qod, 1);
        mustBeAscii(entry.cdv10, 8);
        mustBeAscii(entry.qle, 80);
        mustBeAscii(entry.cpy, 80);
        mustBemagnetic(entry.magnetic);
        mustBelegends(entry.legends);
        mustBeAscii(entry.dag, 80);
        mustBeAscii(entry.dcd, 4);
        mustBeAscii(entry.ell, 80);
        mustBeAscii(entry.elc, 3);
        mustBeAscii(entry.dvr, 80);
        mustBeAscii(entry.vdcdvr, 4);
        mustBeAscii(entry.sda, 80);
        mustBeAscii(entry.vdcsda, 4);
        mustBeAscii(entry.prn, 80);
        mustBeAscii(entry.pco, 2);
        mustBeMetadataArray(entry.prj, -Inf, Inf, false);
        mustBeMetadata(entry.xor, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.yor, -99999999999999, 999999999999999, false);
        mustBeAscii(entry.grd, 3);
        mustBeAscii(entry.grn, 80);
        mustBeMetadata(entry.zna, 0, 9999, true);
        mustBeinsets(entry.insets);
    end
end

function report = validatesources(entry, report, reference) %#codegen
    report = addIssue(report, numel(entry.polygons) < 0 || ...
        numel(entry.polygons) > 99, ...
        'Count', 'polygons', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.polygons)
        report = validatepolygons(entry.polygons(childK), report, reference);
    end
    report = addIssue(report, isempty(strtrim(char(entry.urf))), ...
        'Required', 'urf', 'Supply URF.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.edn))), ...
        'Required', 'edn', 'Supply EDN.', reference);
    [~, valid] = treNumber(entry.cdp, 3, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'cdp', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.cdv))), ...
        'Required', 'cdv', 'Supply CDV.', reference);
    [~, valid] = treNumber(entry.sca, 9, 0, false, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'sca', ...
        'Supply a value fitting the encoded precision.', reference);
    if ~isempty(strtrim(char(entry.unisqu)))
        [~, valid] = treNumber(entry.squ, 10, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'squ', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unisqu)))) && ~isnan(entry.squ), ...
        'AbsentField', 'squ', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unipci)))
        [~, valid] = treNumber(entry.pci, 4, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'pci', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unipci)))) && ~isnan(entry.pci), ...
        'AbsentField', 'pci', 'Leave the omitted field unset.', reference);
    [~, valid] = treNumber(entry.wpc, 3, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'wpc', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.nst, 3, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'nst', ...
        'Supply a value fitting the encoded precision.', reference);
    if ~isempty(strtrim(char(entry.unihke)))
        [~, valid] = variableDecimalNumber(entry.hke, 6);
        report = addIssue(report, ~valid, 'Encoding', 'hke', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unihke)))) && ~isnan(entry.hke), ...
        'AbsentField', 'hke', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unihke)))
        [~, valid] = variableDecimalNumber(entry.lonhke, 15);
        report = addIssue(report, ~valid, 'Encoding', 'lonhke', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unihke)))) && ~isnan(entry.lonhke), ...
        'AbsentField', 'lonhke', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unihke)))
        [~, valid] = variableDecimalNumber(entry.lathke, 15);
        report = addIssue(report, ~valid, 'Encoding', 'lathke', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unihke)))) && ~isnan(entry.lathke), ...
        'AbsentField', 'lathke', 'Leave the omitted field unset.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.qss, {'T', 'S', 'C', 'R', 'U'})), ...
        'Enumeration', 'qss', 'Use a defined field value.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.qod, {'Y', 'N'})), ...
        'Enumeration', 'qod', 'Use a defined field value.', reference);
    if ~strcmp(entry.qss, 'U') && strcmp(entry.qod, 'N')
        report = addIssue(report, isempty(strtrim(char(entry.cdv10))), ...
            'Required', 'cdv10', 'Supply CDV10.', reference);
    end
    report = addIssue(report, ~(~strcmp(entry.qss, 'U') && strcmp(entry.qod, 'N')) && ~isempty(entry.cdv10), ...
        'AbsentField', 'cdv10', 'Leave the omitted field unset.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.qle))), ...
        'Required', 'qle', 'Supply QLE.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.cpy))), ...
        'Required', 'cpy', 'Supply CPY.', reference);
    report = addIssue(report, numel(entry.magnetic) < 0 || ...
        numel(entry.magnetic) > 99, ...
        'Count', 'magnetic', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.magnetic)
        report = validatemagnetic(entry.magnetic(childK), report, reference);
    end
    report = addIssue(report, numel(entry.legends) < 0 || ...
        numel(entry.legends) > 99, ...
        'Count', 'legends', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.legends)
        report = validatelegends(entry.legends(childK), report, reference);
    end
    report = addIssue(report, isempty(strtrim(char(entry.dag))), ...
        'Required', 'dag', 'Supply DAG.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.dcd))), ...
        'Required', 'dcd', 'Supply DCD.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.ell))), ...
        'Required', 'ell', 'Supply ELL.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.elc))), ...
        'Required', 'elc', 'Supply ELC.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.prn))), ...
        'Required', 'prn', 'Supply PRN.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.pco))), ...
        'Required', 'pco', 'Supply PCO.', reference);
    report = addIssue(report, numel(entry.prj) < 0 || ...
        numel(entry.prj) > 9, ...
        'Count', 'prj', 'Vector count is outside the defined range.', reference);
    for j = 1:numel(entry.prj)
        [~, valid] = variableDecimalNumber(entry.prj(j), 15);
        report = addIssue(report, ~valid, 'Encoding', 'prj', ...
            'Supply values fitting the encoded precision.', reference);
    end
    [~, valid] = variableDecimalNumber(entry.xor, 15);
    report = addIssue(report, ~valid, 'Encoding', 'xor', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.yor, 15);
    report = addIssue(report, ~valid, 'Encoding', 'yor', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.zna, 4, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'zna', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, numel(entry.insets) < 0 || ...
        numel(entry.insets) > 99, ...
        'Count', 'insets', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.insets)
        report = validateinsets(entry.insets(childK), report, reference);
    end
    report = addIssue(report, ~knownDate(entry.cdv, 8), ...
        'Metadata', 'cdv', 'Supply a valid significant date.', reference);
    report = addIssue(report, ~isempty(char(entry.cdv27)) && ~knownDate(entry.cdv27, 8), ...
        'Metadata', 'cdv27', 'Supply a valid perishable date or leave it blank.', reference);
    report = addIssue(report, ~isempty(char(entry.cdv10)) && ~knownDate(entry.cdv10, 8), ...
        'Metadata', 'cdv10', 'Supply a valid downgrading date.', reference);
    report = addIssue(report, entry.wpc > 100 && entry.wpc ~= 999, ...
        'Metadata', 'wpc', 'Use a percentage or 999 for unknown.', reference);
end

function data = writesources(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(entry.polygons), 2, 0, false)];
    for childK = 1:numel(entry.polygons)
        data = [data writepolygons(entry.polygons(childK))]; %#ok<AGROW>
    end
    data = [data textField(entry.prt, 10)];
    data = [data textField(entry.urf, 20)];
    data = [data textField(entry.edn, 7)];
    data = [data textField(entry.nam, 20)];
    data = [data treNumber(entry.cdp, 3, 0, false, false, false)];
    data = [data textField(entry.cdv, 8)];
    data = [data textField(entry.cdv27, 8)];
    data = [data textField(entry.srn, 80)];
    data = [data treNumber(entry.sca, 9, 0, false, true, false)];
    data = [data textField(entry.unisqu, 3)];
    if ~isempty(strtrim(char(entry.unisqu)))
        data = [data treNumber(entry.squ, 10, 0, false, false, false)];
    end
    data = [data textField(entry.unipci, 3)];
    if ~isempty(strtrim(char(entry.unipci)))
        data = [data treNumber(entry.pci, 4, 0, false, false, false)];
    end
    data = [data treNumber(entry.wpc, 3, 0, false, false, false)];
    data = [data treNumber(entry.nst, 3, 0, false, false, false)];
    data = [data textField(entry.unihke, 3)];
    if ~isempty(strtrim(char(entry.unihke)))
        data = [data variableDecimalNumber(entry.hke, 6)];
    end
    if ~isempty(strtrim(char(entry.unihke)))
        data = [data variableDecimalNumber(entry.lonhke, 15)];
    end
    if ~isempty(strtrim(char(entry.unihke)))
        data = [data variableDecimalNumber(entry.lathke, 15)];
    end
    data = [data textField(entry.qss, 1)];
    data = [data textField(entry.qod, 1)];
    if ~strcmp(entry.qss, 'U') && strcmp(entry.qod, 'N')
        data = [data textField(entry.cdv10, 8)];
    end
    data = [data textField(entry.qle, 80)];
    data = [data textField(entry.cpy, 80)];
    data = [data decimalField(numel(entry.magnetic), 2, 0, false)];
    for childK = 1:numel(entry.magnetic)
        data = [data writemagnetic(entry.magnetic(childK))]; %#ok<AGROW>
    end
    data = [data decimalField(numel(entry.legends), 2, 0, false)];
    for childK = 1:numel(entry.legends)
        data = [data writelegends(entry.legends(childK))]; %#ok<AGROW>
    end
    data = [data textField(entry.dag, 80)];
    data = [data textField(entry.dcd, 4)];
    data = [data textField(entry.ell, 80)];
    data = [data textField(entry.elc, 3)];
    data = [data textField(entry.dvr, 80)];
    data = [data textField(entry.vdcdvr, 4)];
    data = [data textField(entry.sda, 80)];
    data = [data textField(entry.vdcsda, 4)];
    data = [data textField(entry.prn, 80)];
    data = [data textField(entry.pco, 2)];
    data = [data decimalField(numel(entry.prj), 1, 0, false)];
    for j = 1:numel(entry.prj)
        data = [data variableDecimalNumber(entry.prj(j), 15)]; %#ok<AGROW>
    end
    data = [data variableDecimalNumber(entry.xor, 15)];
    data = [data variableDecimalNumber(entry.yor, 15)];
    data = [data textField(entry.grd, 3)];
    data = [data textField(entry.grn, 80)];
    data = [data treNumber(entry.zna, 4, 0, false, false, false)];
    data = [data decimalField(numel(entry.insets), 2, 0, false)];
    for childK = 1:numel(entry.insets)
        data = [data writeinsets(entry.insets(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readsources(reader) %#codegen
    entry = newsources();
    [childCount, reader] = reader.count(2, 3, 99);
    childEntries = repmat(newpolygons(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readpolygons(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.polygons = childEntries; end
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.prt = value; end
    [value, reader] = reader.text(20, true, false);
    if reader.ok, entry.urf = value; end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.edn = value; end
    [value, reader] = reader.text(20, true, false);
    if reader.ok, entry.nam = value; end
    [value, reader] = reader.number(3, 0, 999, ...
        true, false);
    if reader.ok, entry.cdp = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.cdv = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.cdv27 = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.srn = value; end
    [value, reader] = reader.number(9, 0, 999999999, ...
        true, true);
    if reader.ok, entry.sca = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unisqu = value; end
    if ~isempty(strtrim(char(entry.unisqu)))
        [value, reader] = reader.number(10, 0, 9999999999, ...
            true, false);
        if reader.ok, entry.squ = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unipci = value; end
    if ~isempty(strtrim(char(entry.unipci)))
        [value, reader] = reader.number(4, 0, 9999, ...
            true, false);
        if reader.ok, entry.pci = value; end
    end
    [value, reader] = reader.number(3, 0, 999, ...
        true, false);
    if reader.ok, entry.wpc = value; end
    [value, reader] = reader.number(3, 0, 999, ...
        true, false);
    if reader.ok, entry.nst = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unihke = value; end
    if ~isempty(strtrim(char(entry.unihke)))
        [value, reader] = reader.number(6, -99999, 999999, ...
            false, false);
        if reader.ok, entry.hke = value; end
    end
    if ~isempty(strtrim(char(entry.unihke)))
        [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
            false, false);
        if reader.ok, entry.lonhke = value; end
    end
    if ~isempty(strtrim(char(entry.unihke)))
        [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
            false, false);
        if reader.ok, entry.lathke = value; end
    end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.qss = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.qod = value; end
    if ~strcmp(entry.qss, 'U') && strcmp(entry.qod, 'N')
        [value, reader] = reader.text(8, true, false);
        if reader.ok, entry.cdv10 = value; end
    end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.qle = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.cpy = value; end
    [childCount, reader] = reader.count(2, 63, 99);
    childEntries = repmat(newmagnetic(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readmagnetic(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.magnetic = childEntries; end
    [childCount, reader] = reader.count(2, 10, 99);
    childEntries = repmat(newlegends(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readlegends(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.legends = childEntries; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.dag = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.dcd = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.ell = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.elc = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.dvr = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.vdcdvr = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.sda = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.vdcsda = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.prn = value; end
    [value, reader] = reader.text(2, true, false);
    if reader.ok, entry.pco = value; end
    [valueCount, reader] = reader.count(1, 15, 9);
    [value, reader] = reader.numbers(valueCount, 15, -Inf, Inf, false);
    if reader.ok, entry.prj = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.xor = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.yor = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.grd = value; end
    [value, reader] = reader.text(80, true, false);
    if reader.ok, entry.grn = value; end
    [value, reader] = reader.number(4, 0, 9999, ...
        true, false);
    if reader.ok, entry.zna = value; end
    [childCount, reader] = reader.count(2, 259, 99);
    childEntries = repmat(newinsets(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readinsets(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.insets = childEntries; end
end

function count = lengthsources(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + lengthpolygons(entry.polygons) + ...
            10 + ...
            20 + ...
            7 + ...
            20 + ...
            3 + ...
            8 + ...
            8 + ...
            80 + ...
            9 + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unisqu)))) * (10) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unipci)))) * (4) + ...
            3 + ...
            3 + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unihke)))) * (6) + ...
            double(~isempty(strtrim(char(entry.unihke)))) * (15) + ...
            double(~isempty(strtrim(char(entry.unihke)))) * (15) + ...
            1 + ...
            1 + ...
            double(~strcmp(entry.qss, 'U') && strcmp(entry.qod, 'N')) * (8) + ...
            80 + ...
            80 + ...
            lengthmagnetic(entry.magnetic) + ...
            lengthlegends(entry.legends) + ...
            80 + ...
            4 + ...
            80 + ...
            3 + ...
            80 + ...
            4 + ...
            80 + ...
            4 + ...
            80 + ...
            2 + ...
            1 + 15 * numel(entry.prj) + ...
            15 + ...
            15 + ...
            3 + ...
            80 + ...
            4 + ...
            lengthinsets(entry.insets);
    end
end

function entry = newpolygons() %#codegen
    entry = struct( ...
        'points', repmat(newpoints(), 1, 0));
end

function mustBepolygons(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'points'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBepoints(entry.points);
    end
end

function report = validatepolygons(entry, report, reference) %#codegen
    report = addIssue(report, numel(entry.points) < 0 || ...
        numel(entry.points) > 999, ...
        'Count', 'points', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.points)
        report = validatepoints(entry.points(childK), report, reference);
    end
    report = addIssue(report, ~isempty(entry.points) && numel(entry.points) < 4, ...
        'Metadata', 'points', 'Use zero points or a polygon with at least four points.', reference);
end

function data = writepolygons(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(entry.points), 3, 0, false)];
    for childK = 1:numel(entry.points)
        data = [data writepoints(entry.points(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readpolygons(reader) %#codegen
    entry = newpolygons();
    [childCount, reader] = reader.count(3, 30, 999);
    childEntries = repmat(newpoints(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readpoints(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.points = childEntries; end
end

function count = lengthpolygons(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + lengthpoints(entry.points);
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

function entry = newmagnetic() %#codegen
    entry = struct( ...
        'cdv30', '', ...
        'unirat', 'DEG', ...
        'rat', NaN, ...
        'unigma', 'DEG', ...
        'gma', NaN, ...
        'longma', NaN, ...
        'latgma', NaN, ...
        'unigca', '', ...
        'gca', NaN);
end

function mustBemagnetic(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 9 || ...
            ~all(isfield(entries, { ...
                'cdv30', ...
                'unirat', ...
                'rat', ...
                'unigma', ...
                'gma', ...
                'longma', ...
                'latgma', ...
                'unigca', ...
                'gca'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.cdv30, 8);
        mustBeAscii(entry.unirat, 3);
        mustBeMetadata(entry.rat, -9999999, 99999999, false);
        mustBeAscii(entry.unigma, 3);
        mustBeMetadata(entry.gma, -9999999, 99999999, false);
        mustBeMetadata(entry.longma, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.latgma, -99999999999999, 999999999999999, false);
        mustBeAscii(entry.unigca, 3);
        mustBeMetadata(entry.gca, -9999999, 99999999, false);
    end
end

function report = validatemagnetic(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.cdv30))), ...
        'Required', 'cdv30', 'Supply CDV30.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.unirat))), ...
        'Required', 'unirat', 'Supply UNIRAT.', reference);
    [~, valid] = variableDecimalNumber(entry.rat, 8);
    report = addIssue(report, ~valid, 'Encoding', 'rat', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.unigma))), ...
        'Required', 'unigma', 'Supply UNIGMA.', reference);
    [~, valid] = variableDecimalNumber(entry.gma, 8);
    report = addIssue(report, ~valid, 'Encoding', 'gma', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.longma, 15, true);
    report = addIssue(report, ~valid, 'Encoding', 'longma', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.latgma, 15, true);
    report = addIssue(report, ~valid, 'Encoding', 'latgma', ...
        'Supply a value fitting the encoded precision.', reference);
    if ~isempty(strtrim(char(entry.unigca)))
        [~, valid] = variableDecimalNumber(entry.gca, 8);
        report = addIssue(report, ~valid, 'Encoding', 'gca', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unigca)))) && ~isnan(entry.gca), ...
        'AbsentField', 'gca', 'Leave the omitted field unset.', reference);
    report = addIssue(report, ~knownDate(entry.cdv30, 8), ...
        'Metadata', 'cdv30', 'Supply a valid date.', reference);
end

function data = writemagnetic(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.cdv30, 8)];
    data = [data textField(entry.unirat, 3)];
    data = [data variableDecimalNumber(entry.rat, 8)];
    data = [data textField(entry.unigma, 3)];
    data = [data variableDecimalNumber(entry.gma, 8)];
    data = [data variableDecimalNumber(entry.longma, 15, true)];
    data = [data variableDecimalNumber(entry.latgma, 15, true)];
    data = [data textField(entry.unigca, 3)];
    if ~isempty(strtrim(char(entry.unigca)))
        data = [data variableDecimalNumber(entry.gca, 8)];
    end
end

function [entry, reader] = readmagnetic(reader) %#codegen
    entry = newmagnetic();
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.cdv30 = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unirat = value; end
    [value, reader] = reader.number(8, -9999999, 99999999, ...
        false, false);
    if reader.ok, entry.rat = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unigma = value; end
    [value, reader] = reader.number(8, -9999999, 99999999, ...
        false, false);
    if reader.ok, entry.gma = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, true);
    if reader.ok, entry.longma = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, true);
    if reader.ok, entry.latgma = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unigca = value; end
    if ~isempty(strtrim(char(entry.unigca)))
        [value, reader] = reader.number(8, -9999999, 99999999, ...
            false, false);
        if reader.ok, entry.gca = value; end
    end
end

function count = lengthmagnetic(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 8 + ...
            3 + ...
            8 + ...
            3 + ...
            8 + ...
            15 + ...
            15 + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unigca)))) * (8);
    end
end

function entry = newlegends() %#codegen
    entry = struct( ...
        'bad', '');
end

function mustBelegends(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 1 || ...
            ~all(isfield(entries, { ...
                'bad'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.bad, 10);
    end
end

function report = validatelegends(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.bad))), ...
        'Required', 'bad', 'Supply BAD.', reference);
end

function data = writelegends(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.bad, 10)];
end

function [entry, reader] = readlegends(reader) %#codegen
    entry = newlegends();
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.bad = value; end
end

function count = lengthlegends(entries) %#codegen
    count = 2 + 10 * numel(entries);
end

function entry = newinsets() %#codegen
    entry = struct( ...
        'int', '', ...
        'ins_sca', NaN, ...
        'ntl', NaN, ...
        'ttl', NaN, ...
        'nvl', NaN, ...
        'tvl', NaN, ...
        'ntr', NaN, ...
        'ttr', NaN, ...
        'nvr', NaN, ...
        'tvr', NaN, ...
        'nrl', NaN, ...
        'trl', NaN, ...
        'nsl', NaN, ...
        'tsl', NaN, ...
        'nrr', NaN, ...
        'trr', NaN, ...
        'nsr', NaN, ...
        'tsr', NaN);
end

function mustBeinsets(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 18 || ...
            ~all(isfield(entries, { ...
                'int', ...
                'ins_sca', ...
                'ntl', ...
                'ttl', ...
                'nvl', ...
                'tvl', ...
                'ntr', ...
                'ttr', ...
                'nvr', ...
                'tvr', ...
                'nrl', ...
                'trl', ...
                'nsl', ...
                'tsl', ...
                'nrr', ...
                'trr', ...
                'nsr', ...
                'tsr'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.int, 10);
        mustBeMetadata(entry.ins_sca, 0, 999999999, true);
        mustBeMetadata(entry.ntl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.ttl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nvl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.tvl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.ntr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.ttr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nvr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.tvr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nrl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.trl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nsl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.tsl, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nrr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.trr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.nsr, -99999999999999, 999999999999999, false);
        mustBeMetadata(entry.tsr, -99999999999999, 999999999999999, false);
    end
end

function report = validateinsets(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.int))), ...
        'Required', 'int', 'Supply INT.', reference);
    [~, valid] = treNumber(entry.ins_sca, 9, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ins_sca', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.ntl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'ntl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.ttl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'ttl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nvl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nvl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.tvl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'tvl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.ntr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'ntr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.ttr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'ttr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nvr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nvr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.tvr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'tvr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nrl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nrl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.trl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'trl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nsl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nsl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.tsl, 15);
    report = addIssue(report, ~valid, 'Encoding', 'tsl', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nrr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nrr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.trr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'trr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.nsr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'nsr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.tsr, 15);
    report = addIssue(report, ~valid, 'Encoding', 'tsr', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writeinsets(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.int, 10)];
    data = [data treNumber(entry.ins_sca, 9, 0, false, false, false)];
    data = [data variableDecimalNumber(entry.ntl, 15)];
    data = [data variableDecimalNumber(entry.ttl, 15)];
    data = [data variableDecimalNumber(entry.nvl, 15)];
    data = [data variableDecimalNumber(entry.tvl, 15)];
    data = [data variableDecimalNumber(entry.ntr, 15)];
    data = [data variableDecimalNumber(entry.ttr, 15)];
    data = [data variableDecimalNumber(entry.nvr, 15)];
    data = [data variableDecimalNumber(entry.tvr, 15)];
    data = [data variableDecimalNumber(entry.nrl, 15)];
    data = [data variableDecimalNumber(entry.trl, 15)];
    data = [data variableDecimalNumber(entry.nsl, 15)];
    data = [data variableDecimalNumber(entry.tsl, 15)];
    data = [data variableDecimalNumber(entry.nrr, 15)];
    data = [data variableDecimalNumber(entry.trr, 15)];
    data = [data variableDecimalNumber(entry.nsr, 15)];
    data = [data variableDecimalNumber(entry.tsr, 15)];
end

function [entry, reader] = readinsets(reader) %#codegen
    entry = newinsets();
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.int = value; end
    [value, reader] = reader.number(9, 0, 999999999, ...
        true, false);
    if reader.ok, entry.ins_sca = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.ntl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.ttl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nvl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.tvl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.ntr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.ttr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nvr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.tvr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nrl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.trl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nsl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.tsl = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nrr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.trr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.nsr = value; end
    [value, reader] = reader.number(15, -99999999999999, 999999999999999, ...
        false, false);
    if reader.ok, entry.tsr = value; end
end

function count = lengthinsets(entries) %#codegen
    count = 2 + 259 * numel(entries);
end
