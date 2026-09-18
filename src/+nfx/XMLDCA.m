classdef (Sealed) XMLDCA < nfx.TRE
    %XMLDCA - XML-related content with an optional descriptive subheader
    %   OBJ = XMLDCA(Name=VALUE) stores TREDATA as a uint8 row, retaining
    %   its original XML-related encoding. NFX checks framing and CRC;
    %   schema and application-specific content validation are external.
    %
    %   TRESHL derives from the supplied fields. TRECRC=NaN omits the
    %   CRC-only subheader; TRECRC=99999 includes it without a checksum.
    %   OBJ = OBJ.updateCRC() calculates the checksum for current TREDATA.
    %
    %   See also TRE, File, ImageSegment, TextSegment

    properties (Constant)
        cetag = 'XMLDCA'
    end
    properties
        trecrc {mustBeMetadata(trecrc, 0, 99999, 1)} = NaN
        tredata {mustBeByteRow} = zeros(1, 0, 'uint8')
        treshft {mustBeAscii(treshft, 8)} = ''
        treshdt {mustBeAscii(treshdt, 20)} = ''
        treshrp {mustBeAscii(treshrp, 40)} = ''
        treshsi {mustBeAscii(treshsi, 60)} = ''
        treshsv {mustBeAscii(treshsv, 10)} = ''
        treshsd {mustBeAscii(treshsd, 20)} = ''
        treshtn {mustBeAscii(treshtn, 120)} = ''
        treshlpg {mustBeAscii(treshlpg, 125)} = ''
        treshlpt {mustBeAscii(treshlpt, 25)} = ''
        treshli {mustBeAscii(treshli, 20)} = ''
        treshlin {mustBeAscii(treshlin, 120)} = ''
        treshabs {mustBeAscii(treshabs, 200)} = ''
    end
    properties (Dependent, SetAccess = private)
        treshl
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent XML content record
            %   [OBJ, OK, STATUS] = nfx.XMLDCA.deserialize(PAYLOAD)
            %   returns an unset scalar on failure, without throwing.
            %
            %   See also XMLDCA, XMLDCA.payload
            arguments
                data
            end
            obj = nfx.XMLDCA();
            reader = nfx.internal.TREReader(data);
            [length, reader] = reader.number(4, 0, 773, true);
            if reader.ok && ~any(length == [0 5 283 773])
                reader = reader.fail('InvalidField', ...
                    'Unsupported XMLDCA subheader length.');
            end
            if length > 0 && reader.ok
                [value, reader] = reader.number(5, 0, 99999, true);
                if reader.ok, obj.trecrc = value; end
            end
            if length >= 283 && reader.ok
                [value, reader] = reader.text(8);
                if reader.ok, obj.treshft = value; end
                [value, reader] = reader.text(20);
                if reader.ok, obj.treshdt = value; end
                [value, reader] = reader.text(40);
                if reader.ok, obj.treshrp = value; end
                [value, reader] = reader.text(60);
                if reader.ok, obj.treshsi = value; end
                [value, reader] = reader.text(10);
                if reader.ok, obj.treshsv = value; end
                [value, reader] = reader.text(20);
                if reader.ok, obj.treshsd = value; end
                [value, reader] = reader.text(120);
                if reader.ok, obj.treshtn = value; end
            end
            if length == 773 && reader.ok
                [value, reader] = reader.text(125);
                if reader.ok, obj.treshlpg = value; end
                [value, reader] = reader.text(25);
                if reader.ok, obj.treshlpt = value; end
                [value, reader] = reader.text(20);
                if reader.ok, obj.treshli = value; end
                [value, reader] = reader.text(120);
                if reader.ok, obj.treshlin = value; end
                [value, reader] = reader.text(200);
                if reader.ok, obj.treshabs = value; end
            end
            [value, reader] = reader.take( ...
                numel(reader.data) - reader.position + 1);
            if reader.ok, obj.tredata = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.XMLDCA());
        end
    end
    methods
        function obj = XMLDCA(options) %#codegen
            %XMLDCA - Construct content using specification mnemonics
            arguments
                options.?nfx.XMLDCA
            end
            if isfield(options, 'trecrc')
                obj.trecrc = options.trecrc;
            end
            if isfield(options, 'tredata')
                obj.tredata = options.tredata;
            end
            if isfield(options, 'treshft')
                obj.treshft = options.treshft;
            end
            if isfield(options, 'treshdt')
                obj.treshdt = options.treshdt;
            end
            if isfield(options, 'treshrp')
                obj.treshrp = options.treshrp;
            end
            if isfield(options, 'treshsi')
                obj.treshsi = options.treshsi;
            end
            if isfield(options, 'treshsv')
                obj.treshsv = options.treshsv;
            end
            if isfield(options, 'treshsd')
                obj.treshsd = options.treshsd;
            end
            if isfield(options, 'treshtn')
                obj.treshtn = options.treshtn;
            end
            if isfield(options, 'treshlpg')
                obj.treshlpg = options.treshlpg;
            end
            if isfield(options, 'treshlpt')
                obj.treshlpt = options.treshlpt;
            end
            if isfield(options, 'treshli')
                obj.treshli = options.treshli;
            end
            if isfield(options, 'treshlin')
                obj.treshlin = options.treshlin;
            end
            if isfield(options, 'treshabs')
                obj.treshabs = options.treshabs;
            end
        end
        function value = get.treshl(obj) %#codegen
            %get.treshl - Derive the selected subheader group length
            value = 0;
            if ~isnan(obj.trecrc), value = 5; end
            if ~isempty(obj.treshft) || ...
                    ~isempty(obj.treshdt) || ...
                    ~isempty(obj.treshrp) || ...
                    ~isempty(obj.treshsi) || ...
                    ~isempty(obj.treshsv) || ...
                    ~isempty(obj.treshsd) || ...
                    ~isempty(obj.treshtn)
                value = 283;
            end
            if ~isempty(obj.treshlpg) || ...
                    ~isempty(obj.treshlpt) || ...
                    ~isempty(obj.treshli) || ...
                    ~isempty(obj.treshlin) || ...
                    ~isempty(obj.treshabs)
                value = 773;
            end
        end
        function obj = updateCRC(obj) %#codegen
            %updateCRC - Replace TRECRC using the current data bytes
            obj.trecrc = double(xmlCRC16(obj.tredata));
        end
        function report = validate(obj) %#codegen
            %validate - Check subheader fields, byte count, and checksum
            reference = 'STDI-0002-1 Appendix AE, Table AE-1';
            report = newReport(reference);
            length = obj.treshl;
            report = addIssue(report, ...
                ~isnan(obj.trecrc) && obj.trecrc > 65535 && ...
                obj.trecrc ~= 99999, 'CRC', 'trecrc', ...
                'TRECRC must be 0..65535, 99999, or NaN.', reference);
            if obj.trecrc <= 65535
                report = addIssue(report, ...
                    obj.trecrc ~= double(xmlCRC16(obj.tredata)), ...
                    'CRC', 'trecrc', 'The data checksum does not match.', ...
                    reference);
            end
            if length >= 283
                report = addIssue(report, ...
                    isempty(strtrim(obj.treshft)) || ...
                    isempty(strtrim(obj.treshrp)) || ...
                    isempty(strtrim(obj.treshsi)) || ...
                    isempty(strtrim(obj.treshsv)), 'Required', ...
                    'treshft/treshrp/treshsi/treshsv', ...
                    'Supply the XML type, party, specification and version.', ...
                    reference);
                report = addIssue(report, ...
                    ~validXMLDate(obj.treshdt) || ...
                    ~validXMLDate(obj.treshsd), 'Date', ...
                    'treshdt/treshsd', ...
                    'Supply an ISO date or a UTC date and time.', reference);
            end
            if length == 773
                report = addIssue(report, ...
                    ~validXMLLocation(obj.treshlpg, 5) || ...
                    ~validXMLLocation(obj.treshlpt, 1), 'Location', ...
                    'treshlpg/treshlpt', ...
                    'Use signed decimal locations and a closed polygon.', ...
                    reference);
                report = addIssue(report, ...
                    ~isempty(strtrim(obj.treshli)) && ...
                    isempty(strtrim(obj.treshlin)), 'LocationNamespace', ...
                    'treshli/treshlin', ...
                    'A location identifier requires its namespace.', reference);
            end
            report = addIssue(report, ...
                4 + length + numel(obj.tredata) > 99985, ...
                'TRELength', 'tredata', ...
                'The complete payload cannot exceed 99985 bytes.', reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode the derived subheader and original data
            requireValid(obj.validate());
            length = obj.treshl;
            value = decimalField(length, 4, 0, false);
            if length > 0
                crc = obj.trecrc;
                if isnan(crc), crc = 99999; end
                value = [value decimalField(crc, 5, 0, false)];
            end
            if length >= 283
                value = [value ...
                    textField(obj.treshft, 8) ...
                    textField(obj.treshdt, 20) ...
                    textField(obj.treshrp, 40) ...
                    textField(obj.treshsi, 60) ...
                    textField(obj.treshsv, 10) ...
                    textField(obj.treshsd, 20) ...
                    textField(obj.treshtn, 120) ];
            end
            if length == 773
                value = [value ...
                    textField(obj.treshlpg, 125) ...
                    textField(obj.treshlpt, 25) ...
                    textField(obj.treshli, 20) ...
                    textField(obj.treshlin, 120) ...
                    textField(obj.treshabs, 200) ];
            end
            value = [value obj.tredata];
        end
    end
end
