classdef (Sealed) STDIDC < nfx.TRE
    %STDIDC - Standard image identifier
    %   OBJ = STDIDC(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   STDIDC functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   STDIDC properties:
    %       cetag - Constant tag identifier
    %       acquisition_date - ACQUISITION_DATE metadata
    %       mission - MISSION metadata
    %       pass - PASS metadata
    %       op_num - OP_NUM metadata
    %       start_segment - START_SEGMENT metadata
    %       repro_num - REPRO_NUM metadata
    %       replay_regen - REPLAY_REGEN metadata
    %       blank_fill - BLANK_FILL metadata
    %       start_column - START_COLUMN metadata
    %       start_row - START_ROW metadata
    %       end_segment - END_SEGMENT metadata
    %       end_column - END_COLUMN metadata
    %       end_row - END_ROW metadata
    %       country - COUNTRY metadata
    %       wac - WAC metadata
    %       location - LOCATION metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'STDIDC' % Registered tag identifier
    end
    properties
        acquisition_date {mustBeAscii(acquisition_date, 14)} = '' % ACQUISITION_DATE metadata
        mission {mustBeAscii(mission, 14)} = '' % MISSION metadata
        pass {mustBeAscii(pass, 2)} = '' % PASS metadata
        % OP_NUM metadata
        op_num {mustBeMetadata(op_num, ...
            0, 999, 1)} = 0
        start_segment {mustBeAscii(start_segment, 2)} = 'AA' % START_SEGMENT metadata
        % REPRO_NUM metadata
        repro_num {mustBeMetadata(repro_num, ...
            0, 99, 1)} = 0
        replay_regen {mustBeAscii(replay_regen, 3)} = '000' % REPLAY_REGEN metadata
        blank_fill {mustBeAscii(blank_fill, 1)} = '' % BLANK_FILL metadata
        % START_COLUMN metadata
        start_column {mustBeMetadata(start_column, ...
            1, 999, 1)} = NaN
        % START_ROW metadata
        start_row {mustBeMetadata(start_row, ...
            1, 99999, 1)} = NaN
        end_segment {mustBeAscii(end_segment, 2)} = 'AA' % END_SEGMENT metadata
        % END_COLUMN metadata
        end_column {mustBeMetadata(end_column, ...
            1, 999, 1)} = NaN
        % END_ROW metadata
        end_row {mustBeMetadata(end_row, ...
            1, 99999, 1)} = NaN
        country {mustBeAscii(country, 2)} = '' % COUNTRY metadata
        % WAC metadata
        wac {mustBeMetadata(wac, ...
            1, 1866, 1)} = NaN
        location {mustBeAscii(location, 11)} = '' % LOCATION metadata
    end
    methods
        function obj = STDIDC(options) %#codegen
            arguments
                options.?nfx.STDIDC
            end
            if isfield(options, 'acquisition_date')
                obj.acquisition_date = options.acquisition_date;
            end
            if isfield(options, 'mission')
                obj.mission = options.mission;
            end
            if isfield(options, 'pass')
                obj.pass = options.pass;
            end
            if isfield(options, 'op_num')
                obj.op_num = options.op_num;
            end
            if isfield(options, 'start_segment')
                obj.start_segment = options.start_segment;
            end
            if isfield(options, 'repro_num')
                obj.repro_num = options.repro_num;
            end
            if isfield(options, 'replay_regen')
                obj.replay_regen = options.replay_regen;
            end
            if isfield(options, 'blank_fill')
                obj.blank_fill = options.blank_fill;
            end
            if isfield(options, 'start_column')
                obj.start_column = options.start_column;
            end
            if isfield(options, 'start_row')
                obj.start_row = options.start_row;
            end
            if isfield(options, 'end_segment')
                obj.end_segment = options.end_segment;
            end
            if isfield(options, 'end_column')
                obj.end_column = options.end_column;
            end
            if isfield(options, 'end_row')
                obj.end_row = options.end_row;
            end
            if isfield(options, 'country')
                obj.country = options.country;
            end
            if isfield(options, 'wac')
                obj.wac = options.wac;
            end
            if isfield(options, 'location')
                obj.location = options.location;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix D, Table D-1 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.acquisition_date))), ...
                'Required', 'acquisition_date', 'Supply ACQUISITION_DATE.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.mission))), ...
                'Required', 'mission', 'Supply MISSION.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.pass))), ...
                'Required', 'pass', 'Supply PASS.', reference);
            [~, valid] = treNumber(obj.op_num, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'op_num', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.repro_num, 2, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'repro_num', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.blank_fill, {'', '_'})), ...
                'Enumeration', 'blank_fill', 'Use a defined BLANK_FILL value.', reference);
            [~, valid] = treNumber(obj.start_column, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'start_column', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.start_row, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'start_row', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.end_column, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'end_column', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.end_row, 5, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'end_row', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.wac, 4, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'wac', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.location))), ...
                'Required', 'location', 'Supply LOCATION.', reference);
            report = addIssue(report, ~knownDate(obj.acquisition_date, 14), ...
                'Metadata', 'acquisition_date', 'Supply a complete UTC timestamp.', reference);
            report = addIssue(report, ~validAcquisitionLocation(obj.location, 'minute'), ...
                'Metadata', 'location', 'Supply valid latitude and longitude in minutes.', reference);
            segment = [char(obj.start_segment) char(obj.end_segment)];
            report = addIssue(report, numel(segment) ~= 4 || any(segment < 'A' | segment > 'Z'), ...
                'Metadata', 'start_segment/end_segment', 'Use AA through ZZ segment codes.', reference);
            code = char(obj.pass);
            valid = numel(code) == 2;
            if valid
                valid = (all(code >= '0' & code <= '9')) || ...
                    (code(1) >= 'A' && code(1) <= 'Z' && ...
                     code(2) >= '1' && code(2) <= '9');
            end
            report = addIssue(report, ~valid, ...
                'Metadata', 'pass', 'Use 00 through 99 or A1 through Z9.', reference);
            countryCode = char(obj.country);
            report = addIssue(report, ~isempty(countryCode) && (numel(countryCode) ~= 2 || ...
                any(countryCode < 'A' | countryCode > 'Z')), ...
                'Metadata', 'country', 'Use two uppercase letters or blank.', reference);
            report = addIssue(report, obj.end_row < obj.start_row || obj.end_column < obj.start_column, ...
                'Metadata', 'end_row/end_column', 'The ending block cannot precede the start.', reference);
            payloadLength = 14 + ...
                14 + ...
                2 + ...
                3 + ...
                2 + ...
                2 + ...
                3 + ...
                1 + ...
                3 + ...
                5 + ...
                2 + ...
                3 + ...
                5 + ...
                2 + ...
                4 + ...
                11 + ...
                13;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.acquisition_date, 14)];
            data = [data textField(obj.mission, 14)];
            data = [data textField(obj.pass, 2)];
            data = [data treNumber(obj.op_num, 3, 0, false, false, false)];
            data = [data textField(obj.start_segment, 2)];
            data = [data treNumber(obj.repro_num, 2, 0, false, false, false)];
            data = [data textField(obj.replay_regen, 3)];
            data = [data textField(obj.blank_fill, 1)];
            data = [data treNumber(obj.start_column, 3, 0, false, false, false)];
            data = [data treNumber(obj.start_row, 5, 0, false, false, false)];
            data = [data textField(obj.end_segment, 2)];
            data = [data treNumber(obj.end_column, 3, 0, false, false, false)];
            data = [data treNumber(obj.end_row, 5, 0, false, false, false)];
            data = [data textField(obj.country, 2)];
            data = [data treNumber(obj.wac, 4, 0, false, true, false)];
            data = [data textField(obj.location, 11)];
            data = [data uint8('             ')];
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.STDIDC();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(14, true, false);
            if reader.ok, obj.acquisition_date = value; end
            [value, reader] = reader.text(14, true, false);
            if reader.ok, obj.mission = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.pass = value; end
            [value, reader] = reader.number(3, 0, 999, ...
                true, false);
            if reader.ok, obj.op_num = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.start_segment = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, false);
            if reader.ok, obj.repro_num = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.replay_regen = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.blank_fill = value; end
            [value, reader] = reader.number(3, 1, 999, ...
                true, false);
            if reader.ok, obj.start_column = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.start_row = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.end_segment = value; end
            [value, reader] = reader.number(3, 1, 999, ...
                true, false);
            if reader.ok, obj.end_column = value; end
            [value, reader] = reader.number(5, 1, 99999, ...
                true, false);
            if reader.ok, obj.end_row = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.country = value; end
            [value, reader] = reader.number(4, 1, 1866, ...
                true, true);
            if reader.ok, obj.wac = value; end
            [value, reader] = reader.text(11, true, false);
            if reader.ok, obj.location = value; end
            reader = reader.literal('             ');
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.STDIDC());
        end
    end
end
