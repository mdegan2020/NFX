classdef (Sealed) ENGRDA < nfx.TRE
    %ENGRDA - Self-describing engineering records with native byte storage
    %   OBJ = ENGRDA(RESRC=SOURCE, REDATA=ENTRIES) stores a homogeneous
    %   row of structs. Each entry contains ENGLBL, ENGMTXC, ENGMTXR,
    %   ENGTYP, ENGDTS, ENGDATU and ENGDATA, using lower-case names.
    %   ENGDATA is a uint8 row in big-endian, row-major wire order.
    %   Counts and label lengths derive from these fields.
    %
    %   ENTRY = nfx.ENGRDA.entry(LABEL, DATA, UNITS) packs a native MATLAB
    %   matrix. [DATA, OK, STATUS] = nfx.ENGRDA.values(ENTRY, PROTOTYPE)
    %   decodes to the explicitly supplied type, such as uint16(0).
    %   Complex convenience conversion supports complex single values;
    %   the one-digit byte-width field cannot encode complex doubles.
    %
    %   See also TRE, File, ImageSegment

    properties (Constant)
        cetag = 'ENGRDA'
    end
    properties
        resrc {mustBeAscii(resrc, 20)} = ''
        redata {mustBeEngineeringEntries} = emptyEngineeringEntries()
    end
    properties (Dependent, SetAccess = private)
        recnt
        engln
        engdatc
    end
    methods (Static)
        function value = entry(label, data, units) %#codegen
            %entry - Pack a matrix as one self-describing engineering entry
            %   ENTRY = nfx.ENGRDA.entry(LABEL, DATA, UNITS) preserves
            %   numeric sample types and matrix orientation. UNITS defaults
            %   to UD (undefined). Character data uses type A.
            %
            %   See also ENGRDA, ENGRDA.values
            arguments
                label {mustBeAscii(label, 99)}
                data
                units {mustBeAscii(units, 2)} = 'UD'
            end
            if ~ismatrix(data) || isempty(data) || issparse(data) || ...
                    any(size(data) > 9999)
                error('nfx:EngineeringData', ...
                    'Supply a nonempty full matrix of at most 9999 by 9999.');
            end
            [~, width] = engineeringPrototype(data);
            if 45 + numel(char(label)) + numel(data) * width > 99985
                error('nfx:TRELength', ...
                    'One engineering entry cannot exceed 99985 bytes.');
            end
            [bytes, kind, width] = engineeringBytes(data);
            value = struct('englbl', char(label), ...
                'engmtxc', double(size(data, 2)), ...
                'engmtxr', double(size(data, 1)), 'engtyp', kind, ...
                'engdts', width, 'engdatu', char(units), 'engdata', bytes);
            mustBeEngineeringEntries(value);
        end
        function [value, ok, status] = values(entry, prototype) %#codegen
            %values - Decode using an explicit scalar output type
            %   [VALUE, OK, STATUS] = nfx.ENGRDA.values(ENTRY, PROTOTYPE)
            %   returns a matrix in the prototype's class and complexity.
            %   Failure returns an empty matrix of that same type.
            %
            %   See also ENGRDA, ENGRDA.entry
            arguments
                entry
                prototype
            end
            value = repmat(prototype, 0, 0);
            ok = false;
            status = decodeStatus('InvalidInput', ...
                'Supply one valid entry and a matching scalar prototype.');
            if ~isscalar(prototype) || ~isstruct(entry) || ...
                    ~isscalar(entry) || ...
                    ~all(isfield(entry, {'englbl', 'engmtxc', 'engmtxr', ...
                    'engtyp', 'engdts', 'engdatu', 'engdata'}))
                return
            end
            [kind, width] = engineeringPrototype(prototype);
            textType = (ischar(entry.engtyp) && isrow(entry.engtyp) && ...
                isscalar(entry.engtyp)) || ...
                (isstring(entry.engtyp) && isscalar(entry.engtyp) && ...
                ~ismissing(entry.engtyp) && strlength(entry.engtyp) == 1);
            if width == 0 || ~isa(entry.engdata, 'uint8') || ...
                    ~isrow(entry.engdata) || ~textType || ...
                    ~strcmp(entry.engtyp, kind) || ...
                    ~isequal(entry.engdts, width) || ...
                    ~isa(entry.engmtxc, 'double') || ...
                    ~isa(entry.engmtxr, 'double') || ...
                    ~isscalar(entry.engmtxc) || ~isscalar(entry.engmtxr) || ...
                    ~isreal(entry.engmtxc) || ~isreal(entry.engmtxr)
                return
            end
            dims = [entry.engmtxr entry.engmtxc];
            if any(~isfinite(dims) | dims < 1 | dims > 9999 | ...
                    fix(dims) ~= dims) || ...
                    numel(entry.engdata) ~= prod(dims) * width
                return
            end
            bytes = entry.engdata;
            if kind == 'A' && ~validBCSData(bytes), return; end
            sequence = engineeringValues(bytes, prototype, width);
            value = reshape(sequence, entry.engmtxc, entry.engmtxr).';
            ok = true;
            status = decodeStatus();
        end
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode engineering descriptors and exact bytes
            %   [OBJ, OK, STATUS] = nfx.ENGRDA.deserialize(PAYLOAD)
            %   returns an unset scalar object on failure.
            %
            %   See also ENGRDA, ENGRDA.payload
            arguments
                data
            end
            obj = nfx.ENGRDA();
            reader = nfx.internal.TREReader(data);
            [name, reader] = reader.text(20);
            [count, reader] = reader.count(3, 24, 999);
            entries = emptyEngineeringEntries();
            for k = 1:count
                [label, reader] = reader.sizedText(2, 99);
                [cols, reader] = reader.number(4, 1, 9999, true);
                [rows, reader] = reader.number(4, 1, 9999, true);
                [kind, reader] = reader.choice('BISRCA');
                [width, reader] = reader.number(1, 1, 9, true);
                [units, reader] = reader.text(2, false);
                [symbols, reader] = reader.number(8, 1, 99999932, true);
                [bytes, reader] = reader.take(symbols * width);
                if ~reader.ok, break; end
                if symbols ~= rows * cols
                    reader = reader.fail('EngineeringDimensions', ...
                        'The symbol count must equal rows times columns.');
                    break
                end
                entries(end + 1) = struct('englbl', label, ...
                    'engmtxc', cols, 'engmtxr', rows, 'engtyp', kind, ...
                    'engdts', width, 'engdatu', units, 'engdata', bytes);
            end
            if reader.ok
                obj.resrc = name;
                obj.redata = entries;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ENGRDA());
        end
    end
    methods
        function obj = ENGRDA(options) %#codegen
            %ENGRDA - Construct ordered engineering entries
            arguments
                options.?nfx.ENGRDA
            end
            if isfield(options, 'resrc'), obj.resrc = options.resrc; end
            if isfield(options, 'redata'), obj.redata = options.redata; end
        end
        function value = get.recnt(obj) %#codegen
            %get.recnt - Derive the entry count
            value = numel(obj.redata);
        end
        function value = get.engln(obj) %#codegen
            %get.engln - Derive label lengths in entry order
            value = zeros(1, obj.recnt);
            for k = 1:obj.recnt
                value(k) = numel(char(obj.redata(k).englbl));
            end
        end
        function value = get.engdatc(obj) %#codegen
            %get.engdatc - Derive symbol counts from dimensions
            value = zeros(1, obj.recnt);
            for k = 1:obj.recnt
                value(k) = obj.redata(k).engmtxc * obj.redata(k).engmtxr;
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check descriptor consistency and physical limits
            reference = 'STDI-0002-1 Appendix N, Tables N-1 and N-2';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(obj.resrc)), ...
                'Required', 'resrc', 'Supply the source system name.', reference);
            report = addIssue(report, obj.recnt < 1, 'RecordCount', ...
                'redata', 'Supply at least one engineering entry.', reference);
            count = 23;
            for k = 1:obj.recnt
                e = obj.redata(k);
                label = char(e.englbl);
                report = addIssue(report, isempty(strtrim(label)), ...
                    'EngineeringLabel', 'redata.englbl', ...
                    'Supply a nonblank unique label.', reference);
                for j = 1:k - 1
                    report = addIssue(report, ...
                        strcmp(label, obj.redata(j).englbl), ...
                        'DuplicateLabel', 'redata.englbl', ...
                        'Labels within one ENGRDA must be unique.', reference);
                end
                symbols = e.engmtxc * e.engmtxr;
                report = addIssue(report, ...
                    numel(e.engdata) ~= symbols * e.engdts, ...
                    'EngineeringDimensions', 'redata.engdata', ...
                    'Data bytes must match rows, columns and element width.', ...
                    reference);
                kind = char(e.engtyp);
                validType = (kind == 'A' && e.engdts == 1) || ...
                    any(kind == 'BIS') || ...
                    (kind == 'R' && any(e.engdts == [4 8])) || ...
                    (kind == 'C' && e.engdts == 8);
                report = addIssue(report, ~validType, 'EngineeringType', ...
                    'redata.engtyp/engdts', ...
                    'Use a compatible byte width and IEEE numeric type.', ...
                    reference);
                report = addIssue(report, kind == 'A' && ...
                    ~validBCSData(e.engdata), 'EngineeringText', ...
                    'redata.engdata', 'Type A requires BCS characters.', ...
                    reference);
                count = count + 22 + numel(label) + numel(e.engdata);
            end
            report = addIssue(report, count > 99985, 'TRELength', ...
                'redata', 'Engineering records exceed 99985 payload bytes.', ...
                reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode descriptors and unchanged big-endian values
            requireValid(obj.validate());
            value = [textField(obj.resrc, 20) ...
                decimalField(obj.recnt, 3, 0, false)];
            for k = 1:obj.recnt
                e = obj.redata(k);
                value = [value ...
                    decimalField(numel(char(e.englbl)), 2, 0, false) ...
                    uint8(char(e.englbl)) ...
                    decimalField(e.engmtxc, 4, 0, false) ...
                    decimalField(e.engmtxr, 4, 0, false) ...
                    uint8(char(e.engtyp)) decimalField(e.engdts, 1, 0, false) ...
                    textField(e.engdatu, 2) ...
                    decimalField(e.engmtxc * e.engmtxr, 8, 0, false) ...
                    e.engdata]; %#ok<AGROW>
            end
        end
    end
end
