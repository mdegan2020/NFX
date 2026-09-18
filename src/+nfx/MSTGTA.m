classdef (Sealed) MSTGTA < nfx.TRE
    %MSTGTA - Planned target information associated with an image
    %   OBJ = MSTGTA(Name=VALUE) supplies an editable metadata value.
    %   Field names follow the specification mnemonics. Numeric
    %   metadata uses double; omitted optional numbers use NaN.
    %
    %   See also ImageSegment, TRERecord

    properties (Constant)
        cetag = 'MSTGTA'
    end
    properties
        tgt_num {mustBeMetadata(tgt_num, 0, 99999, 1)} = NaN
        tgt_id {mustBeAscii(tgt_id, 12)} = ''
        tgt_be {mustBeAscii(tgt_be, 15)} = ''
        tgt_pri {mustBeMetadata(tgt_pri, 1, 999, 1)} = NaN
        tgt_req {mustBeAscii(tgt_req, 12)} = ''
        tgt_ltiov {mustBeAscii(tgt_ltiov, 12)} = ''
        tgt_type {mustBeMetadata(tgt_type, 0, 9, 1)} = NaN
        tgt_coll {mustBeMetadata(tgt_coll, 0, 9, 1)} = NaN
        tgt_cat {mustBeMetadata(tgt_cat, 10000, 99999, 1)} = NaN
        tgt_utc {mustBeAscii(tgt_utc, 7)} = ''
        tgt_elev {mustBeMetadata(tgt_elev, -1000, 30000, 1)} = NaN
        tgt_elev_unit {mustBeAscii(tgt_elev_unit, 1)} = ''
        tgt_loc {mustBeAscii(tgt_loc, 21)} = ''
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable MSTGTA value
            %   [OBJ, OK, STATUS] = nfx.MSTGTA.deserialize(PAYLOAD)
            %   accepts payload bytes without the tag/length envelope.
            %   Failure returns a default scalar object and OK=false.
            %
            %   See also MSTGTA, MSTGTA.payload
            arguments
                data
            end
            obj = nfx.MSTGTA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number( ...
                5, 0, 99999, true, false);
            if reader.ok, obj.tgt_num = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.tgt_id = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.tgt_be = value; end
            [value, reader] = reader.number( ...
                3, 1, 999, true, true);
            if reader.ok, obj.tgt_pri = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.tgt_req = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.tgt_ltiov = value; end
            [value, reader] = reader.number( ...
                1, 0, 9, true, true);
            if reader.ok, obj.tgt_type = value; end
            [value, reader] = reader.number( ...
                1, 0, 9, true, obj.tgt_num == 0);
            if reader.ok, obj.tgt_coll = value; end
            [value, reader] = reader.number( ...
                5, 10000, 99999, true, true);
            if reader.ok, obj.tgt_cat = value; end
            [value, reader] = reader.text(7, true, false);
            if reader.ok, obj.tgt_utc = value; end
            [value, reader] = reader.number( ...
                6, -1000, 30000, true, true);
            if reader.ok, obj.tgt_elev = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.tgt_elev_unit = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.tgt_loc = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MSTGTA());
        end
    end
    methods
        function obj = MSTGTA(options) %#codegen
            %MSTGTA - Construct metadata from specification mnemonics
            arguments
                options.?nfx.MSTGTA
            end
            if isfield(options, 'tgt_num')
                obj.tgt_num = options.tgt_num;
            end
            if isfield(options, 'tgt_id')
                obj.tgt_id = options.tgt_id;
            end
            if isfield(options, 'tgt_be')
                obj.tgt_be = options.tgt_be;
            end
            if isfield(options, 'tgt_pri')
                obj.tgt_pri = options.tgt_pri;
            end
            if isfield(options, 'tgt_req')
                obj.tgt_req = options.tgt_req;
            end
            if isfield(options, 'tgt_ltiov')
                obj.tgt_ltiov = options.tgt_ltiov;
            end
            if isfield(options, 'tgt_type')
                obj.tgt_type = options.tgt_type;
            end
            if isfield(options, 'tgt_coll')
                obj.tgt_coll = options.tgt_coll;
            end
            if isfield(options, 'tgt_cat')
                obj.tgt_cat = options.tgt_cat;
            end
            if isfield(options, 'tgt_utc')
                obj.tgt_utc = options.tgt_utc;
            end
            if isfield(options, 'tgt_elev')
                obj.tgt_elev = options.tgt_elev;
            end
            if isfield(options, 'tgt_elev_unit')
                obj.tgt_elev_unit = options.tgt_elev_unit;
            end
            if isfield(options, 'tgt_loc')
                obj.tgt_loc = options.tgt_loc;
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check required fields and encoded formats
            reference = 'STDI-0002-1 Appendix E, Table E-16 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isnan(obj.tgt_num), ...
                'Required', 'tgt_num', 'Supply TGT_NUM.', reference);
            report = addIssue(report, obj.tgt_num ~= 0 && isnan(obj.tgt_coll), ...
                'Required', 'tgt_coll', 'Supply TGT_COLL.', reference);
            date = char(obj.tgt_ltiov);
            report = addIssue(report, ...
                ~isempty(strtrim(date)) && ~knownDate(date, 12), ...
                'Date', 'tgt_ltiov', 'Use CCYYMMDDhhmm or leave blank.', ...
                reference);
            clock = char(obj.tgt_utc);
            validClock = isempty(strtrim(clock));
            if numel(clock) == 7
                validClock = clock(7) == 'Z' && ...
                    all(clock(1:6) >= '0' & clock(1:6) <= '9') && ...
                    str2double(clock(1:2)) <= 23 && ...
                    str2double(clock(3:4)) <= 59 && ...
                    str2double(clock(5:6)) <= 59;
            end
            report = addIssue(report, ~validClock, 'Time', 'tgt_utc', ...
                'Use hhmmssZ or leave blank.', reference);
            unit = char(obj.tgt_elev_unit);
            validUnit = (isnan(obj.tgt_elev) && isempty(strtrim(unit))) || ...
                (~isnan(obj.tgt_elev) && any(strcmp(unit, {'f', 'm'})));
            report = addIssue(report, ~validUnit, 'ElevationUnit', ...
                'tgt_elev/tgt_elev_unit', ...
                'Supply f or m with an elevation, or omit both fields.', ...
                reference);
            report = addIssue(report, ...
                obj.tgt_num ~= 0 && ...
                ~validLocation21(obj.tgt_loc, false, false, false), ...
                'Location', 'tgt_loc', ...
                'Supply decimal or hemisphere-last DMS coordinates.', ...
                reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode the fixed 101-byte record
            requireValid(obj.validate());
            value = [ ...
                decimalField(obj.tgt_num, 5, 0, false) ...
                textField(obj.tgt_id, 12) ...
                textField(obj.tgt_be, 15) ...
                blankDecimal(obj.tgt_pri, 3, 0, false) ...
                textField(obj.tgt_req, 12) ...
                textField(obj.tgt_ltiov, 12) ...
                blankDecimal(obj.tgt_type, 1, 0, false) ...
                blankDecimal(obj.tgt_coll, 1, 0, false) ...
                blankDecimal(obj.tgt_cat, 5, 0, false) ...
                textField(obj.tgt_utc, 7) ...
                blankDecimal(obj.tgt_elev, 6, 0, true) ...
                textField(obj.tgt_elev_unit, 1) ...
                textField(obj.tgt_loc, 21)];
        end
    end
end
