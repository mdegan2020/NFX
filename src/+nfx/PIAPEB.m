classdef (Sealed) PIAPEB < nfx.TRE
    %PIAPEB - Imagery access person metadata
    %   OBJ = PIAPEB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIAPEB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIAPEB properties:
    %       cetag - Constant tag identifier
    %       lastnme - LASTNME metadata
    %       firstnme - FIRSTNME metadata
    %       midnme - MIDNME metadata
    %       dob - DOB metadata
    %       assoctry - ASSOCTRY metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIAPEB' % Registered tag identifier
    end
    properties
        lastnme {mustBeAscii(lastnme, 28)} = '' % LASTNME metadata
        firstnme {mustBeAscii(firstnme, 28)} = '' % FIRSTNME metadata
        midnme {mustBeAscii(midnme, 28)} = '' % MIDNME metadata
        dob {mustBeAscii(dob, 8)} = '' % DOB metadata
        assoctry {mustBeAscii(assoctry, 2)} = '' % ASSOCTRY metadata
    end
    methods
        function obj = PIAPEB(options) %#codegen
            arguments
                options.?nfx.PIAPEB
            end
            if isfield(options, 'lastnme')
                obj.lastnme = options.lastnme;
            end
            if isfield(options, 'firstnme')
                obj.firstnme = options.firstnme;
            end
            if isfield(options, 'midnme')
                obj.midnme = options.midnme;
            end
            if isfield(options, 'dob')
                obj.dob = options.dob;
            end
            if isfield(options, 'assoctry')
                obj.assoctry = options.assoctry;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-11 (2025-06)';
            report = newReport(reference);
            date = char(obj.dob);
            report = addIssue(report, ~isempty(date) && (numel(date) ~= 8 || ...
                any(date < '0' | date > '9')), ...
                'Metadata', 'dob', 'Supply the eight-digit birth date or blank.', reference);
            payloadLength = 28 + ...
                28 + ...
                28 + ...
                8 + ...
                2;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.lastnme, 28)];
            data = [data textField(obj.firstnme, 28)];
            data = [data textField(obj.midnme, 28)];
            data = [data textField(obj.dob, 8)];
            data = [data textField(obj.assoctry, 2)];
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
            obj = nfx.PIAPEB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(28, true, false);
            if reader.ok, obj.lastnme = value; end
            [value, reader] = reader.text(28, true, false);
            if reader.ok, obj.firstnme = value; end
            [value, reader] = reader.text(28, true, false);
            if reader.ok, obj.midnme = value; end
            [value, reader] = reader.text(8, true, false);
            if reader.ok, obj.dob = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.assoctry = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIAPEB());
        end
    end
end
