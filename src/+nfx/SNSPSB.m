classdef (Sealed) SNSPSB < nfx.TRE
    %SNSPSB - Source-scene sensor parameter sets
    %   OBJ = SNSPSB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   SNSPSB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   SNSPSB properties:
    %       cetag - Constant tag identifier
    %       sensors - SENSORS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'SNSPSB' % Registered tag identifier
    end
    properties
        % SENSORS repeated entries
        sensors {mustBesensors} = repmat(newsensors(), 1, 0)
    end
    methods
        function obj = SNSPSB(options) %#codegen
            arguments
                options.?nfx.SNSPSB
            end
            if isfield(options, 'sensors')
                obj.sensors = options.sensors;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix P, Table P-13 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, numel(obj.sensors) < 1 || ...
                numel(obj.sensors) > 99, ...
                'Count', 'sensors', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.sensors)
                report = validatesensors(obj.sensors(k), report, reference);
            end
            payloadLength = lengthsensors(obj.sensors);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data decimalField(numel(obj.sensors), 2, 0, false)];
            for k = 1:numel(obj.sensors)
                data = [data writesensors(obj.sensors(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = sensorsEntry() %#codegen
            %sensorsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SNSPSB.sensorsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newsensors();
        end

        function entry = polygonsEntry() %#codegen
            %polygonsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SNSPSB.polygonsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newpolygons();
        end

        function entry = pointsEntry() %#codegen
            %pointsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SNSPSB.pointsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newpoints();
        end

        function entry = bandsEntry() %#codegen
            %bandsEntry - Create one editable repeated entry
            %   ENTRY = nfx.SNSPSB.bandsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newbands();
        end

        function entry = auxiliaryEntry() %#codegen
            %auxiliaryEntry - Create one editable repeated entry
            %   ENTRY = nfx.SNSPSB.auxiliaryEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newauxiliary();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.SNSPSB();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(2, 144, 99);
            entries = repmat(newsensors(), 1, 0);
            for k = 1:count
                [entry, reader] = readsensors(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.sensors = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.SNSPSB());
        end
    end
end

function entry = newsensors() %#codegen
    entry = struct( ...
        'polygons', repmat(newpolygons(), 1, 0), ...
        'bands', repmat(newbands(), 1, 0), ...
        'unires', '', ...
        'rex', NaN, ...
        'rey', NaN, ...
        'gsx', NaN, ...
        'gsy', NaN, ...
        'gsl', '', ...
        'pltfm', '', ...
        'ins', '', ...
        'mod', '', ...
        'prl', '', ...
        'sid', '', ...
        'act', '', ...
        'uninoa', '', ...
        'noa', NaN, ...
        'uniang', '', ...
        'ang', NaN, ...
        'unialt', '', ...
        'alt', NaN, ...
        'lonscc', NaN, ...
        'latscc', NaN, ...
        'unisae', '', ...
        'saz', NaN, ...
        'sel', NaN, ...
        'unirpy', '', ...
        'rol', NaN, ...
        'pit', NaN, ...
        'yaw', NaN, ...
        'unipxt', '', ...
        'pxt', NaN, ...
        'unispe', '', ...
        'ros', NaN, ...
        'pis', NaN, ...
        'yas', NaN, ...
        'auxiliary', repmat(newauxiliary(), 1, 0));
end

function mustBesensors(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 36 || ...
            ~all(isfield(entries, { ...
                'polygons', ...
                'bands', ...
                'unires', ...
                'rex', ...
                'rey', ...
                'gsx', ...
                'gsy', ...
                'gsl', ...
                'pltfm', ...
                'ins', ...
                'mod', ...
                'prl', ...
                'sid', ...
                'act', ...
                'uninoa', ...
                'noa', ...
                'uniang', ...
                'ang', ...
                'unialt', ...
                'alt', ...
                'lonscc', ...
                'latscc', ...
                'unisae', ...
                'saz', ...
                'sel', ...
                'unirpy', ...
                'rol', ...
                'pit', ...
                'yaw', ...
                'unipxt', ...
                'pxt', ...
                'unispe', ...
                'ros', ...
                'pis', ...
                'yas', ...
                'auxiliary'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBepolygons(entry.polygons);
        mustBebands(entry.bands);
        mustBeAscii(entry.unires, 3);
        mustBeMetadata(entry.rex, 0, 999999, false);
        mustBeMetadata(entry.rey, 0, 999999, false);
        mustBeMetadata(entry.gsx, 0, 999999, false);
        mustBeMetadata(entry.gsy, 0, 999999, false);
        mustBeAscii(entry.gsl, 12);
        mustBeAscii(entry.pltfm, 8);
        mustBeAscii(entry.ins, 8);
        mustBeAscii(entry.mod, 4);
        mustBeAscii(entry.prl, 5);
        mustBeAscii(entry.sid, 10);
        mustBeAscii(entry.act, 18);
        mustBeAscii(entry.uninoa, 3);
        mustBeMetadata(entry.noa, -999999, 9999999, false);
        mustBeAscii(entry.uniang, 3);
        mustBeMetadata(entry.ang, -999999, 9999999, false);
        mustBeAscii(entry.unialt, 3);
        mustBeMetadata(entry.alt, -99999999, 999999999, false);
        mustBeMetadata(entry.lonscc, -999999.99, 999999.99, false);
        mustBeMetadata(entry.latscc, -999999.99, 999999.99, false);
        mustBeAscii(entry.unisae, 3);
        mustBeMetadata(entry.saz, -999999, 9999999, false);
        mustBeMetadata(entry.sel, -999999, 9999999, false);
        mustBeAscii(entry.unirpy, 3);
        mustBeMetadata(entry.rol, -999999, 9999999, false);
        mustBeMetadata(entry.pit, -999999, 9999999, false);
        mustBeMetadata(entry.yaw, -999999, 9999999, false);
        mustBeAscii(entry.unipxt, 3);
        mustBeMetadata(entry.pxt, -9999999999999, 99999999999999, false);
        mustBeAscii(entry.unispe, 7);
        mustBeMetadata(entry.ros, -1e+21, 1e+22, false);
        mustBeMetadata(entry.pis, -1e+21, 1e+22, false);
        mustBeMetadata(entry.yas, -1e+21, 1e+22, false);
        mustBeauxiliary(entry.auxiliary);
    end
end

function report = validatesensors(entry, report, reference) %#codegen
    report = addIssue(report, numel(entry.polygons) < 0 || ...
        numel(entry.polygons) > 99, ...
        'Count', 'polygons', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.polygons)
        report = validatepolygons(entry.polygons(childK), report, reference);
    end
    report = addIssue(report, numel(entry.bands) < 1 || ...
        numel(entry.bands) > 99, ...
        'Count', 'bands', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.bands)
        report = validatebands(entry.bands(childK), report, reference);
    end
    report = addIssue(report, isempty(strtrim(char(entry.unires))), ...
        'Required', 'unires', 'Supply UNIRES.', reference);
    [~, valid] = variableDecimalNumber(entry.rex, 6);
    report = addIssue(report, ~valid, 'Encoding', 'rex', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.rey, 6);
    report = addIssue(report, ~valid, 'Encoding', 'rey', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.gsx, 6);
    report = addIssue(report, ~valid, 'Encoding', 'gsx', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = variableDecimalNumber(entry.gsy, 6);
    report = addIssue(report, ~valid, 'Encoding', 'gsy', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.pltfm))), ...
        'Required', 'pltfm', 'Supply PLTFM.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.ins))), ...
        'Required', 'ins', 'Supply INS.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.mod))), ...
        'Required', 'mod', 'Supply MOD.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.prl))), ...
        'Required', 'prl', 'Supply PRL.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.act))), ...
        'Required', 'act', 'Supply ACT.', reference);
    if ~isempty(strtrim(char(entry.uninoa)))
        [~, valid] = variableDecimalNumber(entry.noa, 7);
        report = addIssue(report, ~valid, 'Encoding', 'noa', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.uninoa)))) && ~isnan(entry.noa), ...
        'AbsentField', 'noa', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.uniang)))
        [~, valid] = variableDecimalNumber(entry.ang, 7);
        report = addIssue(report, ~valid, 'Encoding', 'ang', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.uniang)))) && ~isnan(entry.ang), ...
        'AbsentField', 'ang', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unialt)))
        [~, valid] = variableDecimalNumber(entry.alt, 9);
        report = addIssue(report, ~valid, 'Encoding', 'alt', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unialt)))) && ~isnan(entry.alt), ...
        'AbsentField', 'alt', 'Leave the omitted field unset.', reference);
    [~, valid] = treNumber(entry.lonscc, 10, 2, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'lonscc', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.latscc, 10, 2, true, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'latscc', ...
        'Supply a value fitting the encoded precision.', reference);
    if ~isempty(strtrim(char(entry.unisae)))
        [~, valid] = variableDecimalNumber(entry.saz, 7);
        report = addIssue(report, ~valid, 'Encoding', 'saz', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unisae)))) && ~isnan(entry.saz), ...
        'AbsentField', 'saz', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unisae)))
        [~, valid] = variableDecimalNumber(entry.sel, 7);
        report = addIssue(report, ~valid, 'Encoding', 'sel', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unisae)))) && ~isnan(entry.sel), ...
        'AbsentField', 'sel', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unirpy)))
        [~, valid] = variableDecimalNumber(entry.rol, 7);
        report = addIssue(report, ~valid, 'Encoding', 'rol', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unirpy)))) && ~isnan(entry.rol), ...
        'AbsentField', 'rol', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unirpy)))
        [~, valid] = variableDecimalNumber(entry.pit, 7);
        report = addIssue(report, ~valid, 'Encoding', 'pit', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unirpy)))) && ~isnan(entry.pit), ...
        'AbsentField', 'pit', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unirpy)))
        [~, valid] = variableDecimalNumber(entry.yaw, 7);
        report = addIssue(report, ~valid, 'Encoding', 'yaw', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unirpy)))) && ~isnan(entry.yaw), ...
        'AbsentField', 'yaw', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unipxt)))
        [~, valid] = variableDecimalNumber(entry.pxt, 14);
        report = addIssue(report, ~valid, 'Encoding', 'pxt', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unipxt)))) && ~isnan(entry.pxt), ...
        'AbsentField', 'pxt', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unispe)))
        [~, valid] = variableDecimalNumber(entry.ros, 22);
        report = addIssue(report, ~valid, 'Encoding', 'ros', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unispe)))) && ~isnan(entry.ros), ...
        'AbsentField', 'ros', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unispe)))
        [~, valid] = variableDecimalNumber(entry.pis, 22);
        report = addIssue(report, ~valid, 'Encoding', 'pis', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unispe)))) && ~isnan(entry.pis), ...
        'AbsentField', 'pis', 'Leave the omitted field unset.', reference);
    if ~isempty(strtrim(char(entry.unispe)))
        [~, valid] = variableDecimalNumber(entry.yas, 22);
        report = addIssue(report, ~valid, 'Encoding', 'yas', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(~isempty(strtrim(char(entry.unispe)))) && ~isnan(entry.yas), ...
        'AbsentField', 'yas', 'Leave the omitted field unset.', reference);
    report = addIssue(report, numel(entry.auxiliary) < 0 || ...
        numel(entry.auxiliary) > 999, ...
        'Count', 'auxiliary', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.auxiliary)
        report = validateauxiliary(entry.auxiliary(childK), report, reference);
    end
    report = addIssue(report, ~knownPreciseDate(entry.act, 3), ...
        'Metadata', 'act', 'Supply a valid acquisition timestamp with millisecond precision.', reference);
end

function data = writesensors(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField(numel(entry.polygons), 2, 0, false)];
    for childK = 1:numel(entry.polygons)
        data = [data writepolygons(entry.polygons(childK))]; %#ok<AGROW>
    end
    data = [data decimalField(numel(entry.bands), 2, 0, false)];
    for childK = 1:numel(entry.bands)
        data = [data writebands(entry.bands(childK))]; %#ok<AGROW>
    end
    data = [data textField(entry.unires, 3)];
    data = [data variableDecimalNumber(entry.rex, 6)];
    data = [data variableDecimalNumber(entry.rey, 6)];
    data = [data variableDecimalNumber(entry.gsx, 6)];
    data = [data variableDecimalNumber(entry.gsy, 6)];
    data = [data textField(entry.gsl, 12)];
    data = [data textField(entry.pltfm, 8)];
    data = [data textField(entry.ins, 8)];
    data = [data textField(entry.mod, 4)];
    data = [data textField(entry.prl, 5)];
    data = [data textField(entry.sid, 10)];
    data = [data textField(entry.act, 18)];
    data = [data textField(entry.uninoa, 3)];
    if ~isempty(strtrim(char(entry.uninoa)))
        data = [data variableDecimalNumber(entry.noa, 7)];
    end
    data = [data textField(entry.uniang, 3)];
    if ~isempty(strtrim(char(entry.uniang)))
        data = [data variableDecimalNumber(entry.ang, 7)];
    end
    data = [data textField(entry.unialt, 3)];
    if ~isempty(strtrim(char(entry.unialt)))
        data = [data variableDecimalNumber(entry.alt, 9)];
    end
    data = [data treNumber(entry.lonscc, 10, 2, true, false, false)];
    data = [data treNumber(entry.latscc, 10, 2, true, false, false)];
    data = [data textField(entry.unisae, 3)];
    if ~isempty(strtrim(char(entry.unisae)))
        data = [data variableDecimalNumber(entry.saz, 7)];
    end
    if ~isempty(strtrim(char(entry.unisae)))
        data = [data variableDecimalNumber(entry.sel, 7)];
    end
    data = [data textField(entry.unirpy, 3)];
    if ~isempty(strtrim(char(entry.unirpy)))
        data = [data variableDecimalNumber(entry.rol, 7)];
    end
    if ~isempty(strtrim(char(entry.unirpy)))
        data = [data variableDecimalNumber(entry.pit, 7)];
    end
    if ~isempty(strtrim(char(entry.unirpy)))
        data = [data variableDecimalNumber(entry.yaw, 7)];
    end
    data = [data textField(entry.unipxt, 3)];
    if ~isempty(strtrim(char(entry.unipxt)))
        data = [data variableDecimalNumber(entry.pxt, 14)];
    end
    data = [data textField(entry.unispe, 7)];
    if ~isempty(strtrim(char(entry.unispe)))
        data = [data variableDecimalNumber(entry.ros, 22)];
    end
    if ~isempty(strtrim(char(entry.unispe)))
        data = [data variableDecimalNumber(entry.pis, 22)];
    end
    if ~isempty(strtrim(char(entry.unispe)))
        data = [data variableDecimalNumber(entry.yas, 22)];
    end
    data = [data decimalField(numel(entry.auxiliary), 3, 0, false)];
    for childK = 1:numel(entry.auxiliary)
        data = [data writeauxiliary(entry.auxiliary(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readsensors(reader) %#codegen
    entry = newsensors();
    [childCount, reader] = reader.count(2, 3, 99);
    childEntries = repmat(newpolygons(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readpolygons(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.polygons = childEntries; end
    [childCount, reader] = reader.count(2, 15, 99);
    childEntries = repmat(newbands(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readbands(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.bands = childEntries; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unires = value; end
    [value, reader] = reader.number(6, 0, 999999, ...
        false, false);
    if reader.ok, entry.rex = value; end
    [value, reader] = reader.number(6, 0, 999999, ...
        false, false);
    if reader.ok, entry.rey = value; end
    [value, reader] = reader.number(6, 0, 999999, ...
        false, false);
    if reader.ok, entry.gsx = value; end
    [value, reader] = reader.number(6, 0, 999999, ...
        false, false);
    if reader.ok, entry.gsy = value; end
    [value, reader] = reader.text(12, true, false);
    if reader.ok, entry.gsl = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.pltfm = value; end
    [value, reader] = reader.text(8, true, false);
    if reader.ok, entry.ins = value; end
    [value, reader] = reader.text(4, true, false);
    if reader.ok, entry.mod = value; end
    [value, reader] = reader.text(5, true, false);
    if reader.ok, entry.prl = value; end
    [value, reader] = reader.text(10, true, false);
    if reader.ok, entry.sid = value; end
    [value, reader] = reader.text(18, true, false);
    if reader.ok, entry.act = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.uninoa = value; end
    if ~isempty(strtrim(char(entry.uninoa)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.noa = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.uniang = value; end
    if ~isempty(strtrim(char(entry.uniang)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.ang = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unialt = value; end
    if ~isempty(strtrim(char(entry.unialt)))
        [value, reader] = reader.number(9, -99999999, 999999999, ...
            false, false);
        if reader.ok, entry.alt = value; end
    end
    [value, reader] = reader.number(10, -999999.99, 999999.99, ...
        false, false);
    if reader.ok, entry.lonscc = value; end
    [value, reader] = reader.number(10, -999999.99, 999999.99, ...
        false, false);
    if reader.ok, entry.latscc = value; end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unisae = value; end
    if ~isempty(strtrim(char(entry.unisae)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.saz = value; end
    end
    if ~isempty(strtrim(char(entry.unisae)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.sel = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unirpy = value; end
    if ~isempty(strtrim(char(entry.unirpy)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.rol = value; end
    end
    if ~isempty(strtrim(char(entry.unirpy)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.pit = value; end
    end
    if ~isempty(strtrim(char(entry.unirpy)))
        [value, reader] = reader.number(7, -999999, 9999999, ...
            false, false);
        if reader.ok, entry.yaw = value; end
    end
    [value, reader] = reader.text(3, true, false);
    if reader.ok, entry.unipxt = value; end
    if ~isempty(strtrim(char(entry.unipxt)))
        [value, reader] = reader.number(14, -9999999999999, 99999999999999, ...
            false, false);
        if reader.ok, entry.pxt = value; end
    end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.unispe = value; end
    if ~isempty(strtrim(char(entry.unispe)))
        [value, reader] = reader.number(22, -1e+21, 1e+22, ...
            false, false);
        if reader.ok, entry.ros = value; end
    end
    if ~isempty(strtrim(char(entry.unispe)))
        [value, reader] = reader.number(22, -1e+21, 1e+22, ...
            false, false);
        if reader.ok, entry.pis = value; end
    end
    if ~isempty(strtrim(char(entry.unispe)))
        [value, reader] = reader.number(22, -1e+21, 1e+22, ...
            false, false);
        if reader.ok, entry.yas = value; end
    end
    [childCount, reader] = reader.count(3, 28, 999);
    childEntries = repmat(newauxiliary(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readauxiliary(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.auxiliary = childEntries; end
end

function count = lengthsensors(entries) %#codegen
    count = 2;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + lengthpolygons(entry.polygons) + ...
            lengthbands(entry.bands) + ...
            3 + ...
            6 + ...
            6 + ...
            6 + ...
            6 + ...
            12 + ...
            8 + ...
            8 + ...
            4 + ...
            5 + ...
            10 + ...
            18 + ...
            3 + ...
            double(~isempty(strtrim(char(entry.uninoa)))) * (7) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.uniang)))) * (7) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unialt)))) * (9) + ...
            10 + ...
            10 + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unisae)))) * (7) + ...
            double(~isempty(strtrim(char(entry.unisae)))) * (7) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unirpy)))) * (7) + ...
            double(~isempty(strtrim(char(entry.unirpy)))) * (7) + ...
            double(~isempty(strtrim(char(entry.unirpy)))) * (7) + ...
            3 + ...
            double(~isempty(strtrim(char(entry.unipxt)))) * (14) + ...
            7 + ...
            double(~isempty(strtrim(char(entry.unispe)))) * (22) + ...
            double(~isempty(strtrim(char(entry.unispe)))) * (22) + ...
            double(~isempty(strtrim(char(entry.unispe)))) * (22) + ...
            lengthauxiliary(entry.auxiliary);
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

function entry = newbands() %#codegen
    entry = struct( ...
        'bid', NaN, ...
        'ws1', NaN, ...
        'ws2', NaN);
end

function mustBebands(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'bid', ...
                'ws1', ...
                'ws2'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.bid, 0, 99999, true);
        mustBeMetadata(entry.ws1, 0, 99999, true);
        mustBeMetadata(entry.ws2, 0, 99999, true);
    end
end

function report = validatebands(entry, report, reference) %#codegen
    [~, valid] = treNumber(entry.bid, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'bid', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.ws1, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ws1', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.ws2, 5, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'ws2', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, entry.ws2 < entry.ws1, ...
        'Metadata', 'ws1/ws2', 'Order the signal limits.', reference);
end

function data = writebands(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data treNumber(entry.bid, 5, 0, false, false, false)];
    data = [data treNumber(entry.ws1, 5, 0, false, false, false)];
    data = [data treNumber(entry.ws2, 5, 0, false, false, false)];
end

function [entry, reader] = readbands(reader) %#codegen
    entry = newbands();
    [value, reader] = reader.number(5, 0, 99999, ...
        true, false);
    if reader.ok, entry.bid = value; end
    [value, reader] = reader.number(5, 0, 99999, ...
        true, false);
    if reader.ok, entry.ws1 = value; end
    [value, reader] = reader.number(5, 0, 99999, ...
        true, false);
    if reader.ok, entry.ws2 = value; end
end

function count = lengthbands(entries) %#codegen
    count = 2 + 15 * numel(entries);
end

function entry = newauxiliary() %#codegen
    entry = struct( ...
        'api', '', ...
        'apf', '', ...
        'uniapx', '', ...
        'apn', NaN, ...
        'apr', NaN, ...
        'apa', '');
end

function mustBeauxiliary(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 6 || ...
            ~all(isfield(entries, { ...
                'api', ...
                'apf', ...
                'uniapx', ...
                'apn', ...
                'apr', ...
                'apa'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.api, 20);
        mustBeAscii(entry.apf, 1);
        mustBeAscii(entry.uniapx, 7);
        mustBeMetadata(entry.apn, -999999999, 999999999, true);
        mustBeMetadata(entry.apr, -1e+19, 1e+20, false);
        mustBeECS(entry.apa, 20);
    end
end

function report = validateauxiliary(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.api))), ...
        'Required', 'api', 'Supply API.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.apf, {'I', 'R', 'A'})), ...
        'Enumeration', 'apf', 'Use a defined field value.', reference);
    if strcmp(entry.apf, 'I')
        [~, valid] = treNumber(entry.apn, 10, 0, true, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'apn', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(strcmp(entry.apf, 'I')) && ~isnan(entry.apn), ...
        'AbsentField', 'apn', 'Leave the omitted field unset.', reference);
    if strcmp(entry.apf, 'R')
        [~, valid] = variableDecimalNumber(entry.apr, 20);
        report = addIssue(report, ~valid, 'Encoding', 'apr', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(strcmp(entry.apf, 'R')) && ~isnan(entry.apr), ...
        'AbsentField', 'apr', 'Leave the omitted field unset.', reference);
    if strcmp(entry.apf, 'A')
    end
    report = addIssue(report, ~(strcmp(entry.apf, 'A')) && ~isempty(entry.apa), ...
        'AbsentField', 'apa', 'Leave the omitted field unset.', reference);
    report = addIssue(report, startsWith(char(entry.api), ' '), ...
        'Metadata', 'api', 'Do not begin an auxiliary ID with a space.', reference);
end

function data = writeauxiliary(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.api, 20)];
    data = [data textField(entry.apf, 1)];
    data = [data textField(entry.uniapx, 7)];
    if strcmp(entry.apf, 'I')
        data = [data treNumber(entry.apn, 10, 0, true, false, false)];
    end
    if strcmp(entry.apf, 'R')
        data = [data variableDecimalNumber(entry.apr, 20)];
    end
    if strcmp(entry.apf, 'A')
        data = [data textField(entry.apa, 20)];
    end
end

function [entry, reader] = readauxiliary(reader) %#codegen
    entry = newauxiliary();
    [value, reader] = reader.text(20, true, false);
    if reader.ok, entry.api = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.apf = value; end
    [value, reader] = reader.text(7, true, false);
    if reader.ok, entry.uniapx = value; end
    if strcmp(entry.apf, 'I')
        [value, reader] = reader.number(10, -999999999, 999999999, ...
            true, false);
        if reader.ok, entry.apn = value; end
    end
    if strcmp(entry.apf, 'R')
        [value, reader] = reader.number(20, -1e+19, 1e+20, ...
            false, false);
        if reader.ok, entry.apr = value; end
    end
    if strcmp(entry.apf, 'A')
        [value, reader] = reader.text(20, true, true);
        if reader.ok, entry.apa = value; end
    end
end

function count = lengthauxiliary(entries) %#codegen
    count = 3;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 20 + ...
            1 + ...
            7 + ...
            double(strcmp(entry.apf, 'I')) * (10) + ...
            double(strcmp(entry.apf, 'R')) * (20) + ...
            double(strcmp(entry.apf, 'A')) * (20);
    end
end
