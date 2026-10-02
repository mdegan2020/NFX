classdef (Sealed) PIATGB < nfx.TRE
    %PIATGB - Imagery access target metadata
    %   OBJ = PIATGB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIATGB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIATGB properties:
    %       cetag - Constant tag identifier
    %       tgtutm - TGTUTM metadata
    %       piatgaid - PIATGAID metadata
    %       piactry - PIACTRY metadata
    %       piacat - PIACAT metadata
    %       tgtgeo - TGTGEO metadata
    %       datum - DATUM metadata
    %       tgtname - TGTNAME metadata
    %       percover - PERCOVER metadata
    %       tgtlat - Latitude text retaining blank fractional precision
    %       tgtlon - Longitude text retaining blank fractional precision
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIATGB' % Registered tag identifier
    end
    properties
        tgtutm {mustBeAscii(tgtutm, 15)} = '' % TGTUTM metadata
        piatgaid {mustBeAscii(piatgaid, 15)} = '' % PIATGAID metadata
        piactry {mustBeAscii(piactry, 2)} = '' % PIACTRY metadata
        % PIACAT metadata
        piacat {mustBeMetadata(piacat, ...
            0, 99999, 1)} = NaN
        tgtgeo {mustBeAscii(tgtgeo, 15)} = '' % TGTGEO metadata
        datum {mustBeAscii(datum, 3)} = '' % DATUM metadata
        tgtname {mustBeAscii(tgtname, 38)} = '' % TGTNAME metadata
        % PERCOVER metadata
        percover {mustBeMetadata(percover, ...
            0, 100, 1)} = NaN
        tgtlat {mustBeAscii(tgtlat, 10)} = '' % Latitude text retaining blank fractional precision
        tgtlon {mustBeAscii(tgtlon, 11)} = '' % Longitude text retaining blank fractional precision
    end
    methods
        function obj = PIATGB(options) %#codegen
            arguments
                options.?nfx.PIATGB
            end
            if isfield(options, 'tgtutm')
                obj.tgtutm = options.tgtutm;
            end
            if isfield(options, 'piatgaid')
                obj.piatgaid = options.piatgaid;
            end
            if isfield(options, 'piactry')
                obj.piactry = options.piactry;
            end
            if isfield(options, 'piacat')
                obj.piacat = options.piacat;
            end
            if isfield(options, 'tgtgeo')
                obj.tgtgeo = options.tgtgeo;
            end
            if isfield(options, 'datum')
                obj.datum = options.datum;
            end
            if isfield(options, 'tgtname')
                obj.tgtname = options.tgtname;
            end
            if isfield(options, 'percover')
                obj.percover = options.percover;
            end
            if isfield(options, 'tgtlat')
                obj.tgtlat = options.tgtlat;
            end
            if isfield(options, 'tgtlon')
                obj.tgtlon = options.tgtlon;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-8 (2025-06)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.piacat, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'piacat', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.percover, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'percover', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ~validPartialAngle(obj.tgtlat, 90) || ...
                ~validPartialAngle(obj.tgtlon, 180), ...
                'Metadata', 'tgtlat/tgtlon', 'Supply signed degrees with optional trailing blanks.', reference);
            report = addIssue(report, ~validPIAGeo(obj.tgtgeo), ...
                'Metadata', 'tgtgeo', 'Supply ddmmssNdddmmssE coordinates or blank.', reference);
            payloadLength = 15 + ...
                15 + ...
                2 + ...
                5 + ...
                15 + ...
                3 + ...
                38 + ...
                3 + ...
                10 + ...
                11;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.tgtutm, 15)];
            data = [data textField(obj.piatgaid, 15)];
            data = [data textField(obj.piactry, 2)];
            data = [data treNumber(obj.piacat, 5, 0, false, true, false)];
            data = [data textField(obj.tgtgeo, 15)];
            data = [data textField(obj.datum, 3)];
            data = [data textField(obj.tgtname, 38)];
            data = [data treNumber(obj.percover, 3, 0, false, true, false)];
            data = [data textField(obj.tgtlat, 10)];
            data = [data textField(obj.tgtlon, 11)];
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
            obj = nfx.PIATGB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.tgtutm = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.piatgaid = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.piactry = value; end
            [value, reader] = reader.number(5, 0, 99999, ...
                true, true);
            if reader.ok, obj.piacat = value; end
            [value, reader] = reader.text(15, true, false);
            if reader.ok, obj.tgtgeo = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.datum = value; end
            [value, reader] = reader.text(38, true, false);
            if reader.ok, obj.tgtname = value; end
            [value, reader] = reader.number(3, 0, 100, ...
                true, true);
            if reader.ok, obj.percover = value; end
            [value, reader] = reader.text(10, true, false);
            if reader.ok, obj.tgtlat = value; end
            [value, reader] = reader.text(11, true, false);
            if reader.ok, obj.tgtlon = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIATGB());
        end
    end
end
