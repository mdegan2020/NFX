classdef (Sealed) AIMIDB < nfx.TRE
    %AIMIDB - Additional airborne image acquisition identifiers
    %   OBJ = AIMIDB(Name=VALUE) supplies the 89-byte acquisition record.
    %   ACQUISITION_DATE is a fully known UTC timestamp. LOCATION retains
    %   ddmmNdddmmE text; blank LOCATION/COUNTRY/REPLAY values remain blank.
    %   Reserved fields are generated as spaces.
    %
    %   Unknown mission/flight values default to their specified sentinels.
    %   Tile indices describe the supplied imaging operation; they are not
    %   inferred from the stored segment when the original operation differs.
    %
    %   See also ACFTB, ImageHeader, CSDIDA

    properties (Constant)
        cetag = 'AIMIDB'
    end
    properties
        acquisition_date {mustBeAscii(acquisition_date,14)} = ''
        mission_no {mustBeAscii(mission_no,4)} = 'UNKN'
        mission_identification {mustBeAscii(mission_identification,10)} = 'NOT AVAIL.'
        flight_no {mustBeAscii(flight_no,2)} = '00'
        op_num {mustBeMetadata(op_num,0,999,1)} = 0
        current_segment {mustBeAscii(current_segment,2)} = 'AA'
        repro_num {mustBeMetadata(repro_num,0,99,1)} = 0
        replay {mustBeAscii(replay,3)} = '000'
        start_tile_column {mustBeMetadata(start_tile_column,1,99,1)} = 1
        start_tile_row {mustBeMetadata(start_tile_row,1,99999,1)} = 1
        end_segment {mustBeAscii(end_segment,2)} = 'AA'
        end_tile_column {mustBeMetadata(end_tile_column,1,99,1)} = 1
        end_tile_row {mustBeMetadata(end_tile_row,1,99999,1)} = 1
        country {mustBeAscii(country,2)} = ''
        location {mustBeAscii(location,11)} = ''
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable AIMIDB value
            %   [OBJ, OK, STATUS] = nfx.AIMIDB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also AIMIDB, AIMIDB.payload
            arguments
                data
            end
            obj = nfx.AIMIDB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(14, true, false);
            if reader.ok
                obj.acquisition_date = value;
            end
            [value, reader] = reader.text(4, true, false);
            if reader.ok
                obj.mission_no = value;
            end
            [value, reader] = reader.text(10, true, false);
            if reader.ok
                obj.mission_identification = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.flight_no = value;
            end
            [value, reader] = reader.number( ...
                3, 0, 999, 1, false);
            if reader.ok
                obj.op_num = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.current_segment = value;
            end
            [value, reader] = reader.number( ...
                2, 0, 99, 1, false);
            if reader.ok
                obj.repro_num = value;
            end
            [value, reader] = reader.text(3, true, false);
            if reader.ok
                obj.replay = value;
            end
            reader = reader.literal(' ');
            [value, reader] = reader.number( ...
                3, 1, 99, 1, false);
            if reader.ok
                obj.start_tile_column = value;
            end
            [value, reader] = reader.number( ...
                5, 1, 99999, 1, false);
            if reader.ok
                obj.start_tile_row = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.end_segment = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 99, 1, false);
            if reader.ok
                obj.end_tile_column = value;
            end
            [value, reader] = reader.number( ...
                5, 1, 99999, 1, false);
            if reader.ok
                obj.end_tile_row = value;
            end
            [value, reader] = reader.text(2, true, false);
            if reader.ok
                obj.country = value;
            end
            reader = reader.literal('    ');
            [value, reader] = reader.text(11, true, false);
            if reader.ok
                obj.location = value;
            end
            reader = reader.literal('             ');
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.AIMIDB());
        end
    end
    methods
        function obj = AIMIDB(options) %#codegen
            %AIMIDB - Construct editable image acquisition identifiers
            arguments
                options.?nfx.AIMIDB
            end
            if isfield(options,'acquisition_date'), obj.acquisition_date = options.acquisition_date; end
            if isfield(options,'mission_no'), obj.mission_no = options.mission_no; end
            if isfield(options,'mission_identification'), obj.mission_identification = options.mission_identification; end
            if isfield(options,'flight_no'), obj.flight_no = options.flight_no; end
            if isfield(options,'op_num'), obj.op_num = options.op_num; end
            if isfield(options,'current_segment'), obj.current_segment = options.current_segment; end
            if isfield(options,'repro_num'), obj.repro_num = options.repro_num; end
            if isfield(options,'replay'), obj.replay = options.replay; end
            if isfield(options,'start_tile_column'), obj.start_tile_column = options.start_tile_column; end
            if isfield(options,'start_tile_row'), obj.start_tile_row = options.start_tile_row; end
            if isfield(options,'end_segment'), obj.end_segment = options.end_segment; end
            if isfield(options,'end_tile_column'), obj.end_tile_column = options.end_tile_column; end
            if isfield(options,'end_tile_row'), obj.end_tile_row = options.end_tile_row; end
            if isfield(options,'country'), obj.country = options.country; end
            if isfield(options,'location'), obj.location = options.location; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check dates, code forms, operation indices and location
            report = newReport('STDI-0002 Appendix E AIMIDB');
            reference = 'STDI-0002-1 Appendix E, E.3.1.2 and Table E-3';
            report = addIssue(report,~knownDate(obj.acquisition_date,14),'AcquisitionDate', ...
                'acquisition_date','Supply a fully known UTC acquisition date and time.',reference);
            mission = char(obj.mission_no);
            valid = strcmp(mission,'UNKN') || (numel(mission) == 4 && ...
                (letters(mission(1:2)) || strcmp(mission(1:2),'U0')) && all(mission(3:4) >= '0' & mission(3:4) <= '9'));
            report = addIssue(report,~valid,'MissionCode','mission_no','Use PPNN, U0NN, or UNKN.',reference);
            text = strtrim(char(obj.mission_identification));
            report = addIssue(report,isempty(text),'Required','mission_identification', ...
                'Supply a mission identifier or NOT AVAIL.',reference);
            flight = char(obj.flight_no);
            valid = strcmp(flight,'00') || (numel(flight) == 2 && ...
                (flight(1) == '0' || letters(flight(1))) && flight(2) >= '1' && flight(2) <= '9');
            report = addIssue(report,~valid,'FlightNumber','flight_no','Use 00, 01-09, or A1-Z9.',reference);
            current = char(obj.current_segment); last = char(obj.end_segment);
            valid = numel(current) == 2 && letters(current) && ...
                (strcmp(last,'00') || (numel(last) == 2 && letters(last)));
            report = addIssue(report,~valid,'SegmentCode','current_segment/end_segment', ...
                'Use AA-ZZ segment codes; an unknown ending segment uses 00.',reference);
            if valid && ~strcmp(last,'00')
                report = addIssue(report,any(last ~= current) && ...
                    last(find(last ~= current,1)) < current(find(last ~= current,1)), ...
                    'SegmentOrder','end_segment','The ending segment must not precede the current segment.',reference);
            end
            replayCode = strtrim(char(obj.replay));
            valid = isempty(replayCode) || strcmp(replayCode,'000') || (numel(replayCode) == 3 && ...
                any(replayCode(1) == 'GPT') && all(replayCode(2:3) >= '0' & replayCode(2:3) <= '9') && ~strcmp(replayCode(2:3),'00'));
            report = addIssue(report,~valid,'Replay','replay','Use blank, 000, G01-G99, P01-P99 or T01-T99.',reference);
            countryCode = char(obj.country);
            report = addIssue(report,~isempty(strtrim(countryCode)) && ~(numel(countryCode) == 2 && letters(countryCode)), ...
                'Country','country','Supply a two-letter country code or leave it blank.',reference);
            report = addIssue(report,~validAcquisitionLocation(obj.location,'minute'), ...
                'Location','location','Supply ddmmNdddmmE coordinates or blank.',reference);
            report = addIssue(report,any(isnan([obj.op_num obj.repro_num obj.start_tile_column ...
                obj.start_tile_row obj.end_tile_column obj.end_tile_row])), ...
                'Required','numeric fields','Supply every required operation/tile value.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize exact field order and reserved spaces
            requireValid(validate(obj));
            value = [textField(obj.acquisition_date,14) textField(obj.mission_no,4) ...
                textField(obj.mission_identification,10) textField(obj.flight_no,2) ...
                decimalField(obj.op_num,3,0,false) textField(obj.current_segment,2) ...
                decimalField(obj.repro_num,2,0,false) textField(obj.replay,3) uint8(' ') ...
                decimalField(obj.start_tile_column,3,0,false) decimalField(obj.start_tile_row,5,0,false) ...
                textField(obj.end_segment,2) decimalField(obj.end_tile_column,3,0,false) ...
                decimalField(obj.end_tile_row,5,0,false) textField(obj.country,2) textField('',4) ...
                textField(obj.location,11) textField('',13)];
        end
    end
end

function value = letters(text) %#codegen
    %letters - Recognize uppercase Latin letters
    value = all(text >= 'A' & text <= 'Z');
end
