classdef (Sealed) GEOPSB < nfx.TRE
    %GEOPSB - Geopositioning datum and coordinate system metadata
    %   OBJ = GEOPSB(Name=VALUE) supplies an editable metadata value.
    %   Field names follow the specification mnemonics. Numeric
    %   metadata uses double; omitted optional numbers use NaN.
    %
    %   See also ImageSegment, TRERecord

    properties (Constant)
        cetag = 'GEOPSB'
    end
    properties
        typ {mustBeAscii(typ, 3)} = 'GEO'
        uni {mustBeAscii(uni, 3)} = 'DEG'
        dag {mustBeAscii(dag, 80)} = 'World Geodetic System 1984'
        dcd {mustBeAscii(dcd, 4)} = 'WGE'
        ell {mustBeAscii(ell, 80)} = 'World Geodetic System 1984'
        elc {mustBeAscii(elc, 3)} = 'WE'
        dvr {mustBeAscii(dvr, 80)} = 'Geodetic'
        vdcdvr {mustBeAscii(vdcdvr, 4)} = 'GEOD'
        sda {mustBeAscii(sda, 80)} = 'Mean Sea'
        vdcsda {mustBeAscii(vdcsda, 4)} = 'MSL'
        zor {mustBeMetadata(zor, 0, 999999999999999, 1)} = 0
        grd {mustBeAscii(grd, 3)} = ''
        grn {mustBeAscii(grn, 80)} = ''
        zna {mustBeMetadata(zna, -999, 9999, 1)} = 0
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable GEOPSB value
            %   [OBJ, OK, STATUS] = nfx.GEOPSB.deserialize(PAYLOAD)
            %   accepts payload bytes without the tag/length envelope.
            %   Failure returns a default scalar object and OK=false.
            %
            %   See also GEOPSB, GEOPSB.payload
            arguments
                data
            end
            obj = nfx.GEOPSB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.typ = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.uni = value; end
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.dag = value; end
            [value, reader] = reader.text(4, true, false);
            if reader.ok, obj.dcd = value; end
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.ell = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.elc = value; end
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.dvr = value; end
            [value, reader] = reader.text(4, true, false);
            if reader.ok, obj.vdcdvr = value; end
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.sda = value; end
            [value, reader] = reader.text(4, true, false);
            if reader.ok, obj.vdcsda = value; end
            [value, reader] = reader.number( ...
                15, 0, 999999999999999, true, false);
            if reader.ok, obj.zor = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.grd = value; end
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.grn = value; end
            [value, reader] = reader.number( ...
                4, -999, 9999, true, false);
            if reader.ok, obj.zna = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.GEOPSB());
        end
    end
    methods
        function obj = GEOPSB(options) %#codegen
            %GEOPSB - Construct metadata from specification mnemonics
            arguments
                options.?nfx.GEOPSB
            end
            if isfield(options, 'typ')
                obj.typ = options.typ;
            end
            if isfield(options, 'uni')
                obj.uni = options.uni;
            end
            if isfield(options, 'dag')
                obj.dag = options.dag;
            end
            if isfield(options, 'dcd')
                obj.dcd = options.dcd;
            end
            if isfield(options, 'ell')
                obj.ell = options.ell;
            end
            if isfield(options, 'elc')
                obj.elc = options.elc;
            end
            if isfield(options, 'dvr')
                obj.dvr = options.dvr;
            end
            if isfield(options, 'vdcdvr')
                obj.vdcdvr = options.vdcdvr;
            end
            if isfield(options, 'sda')
                obj.sda = options.sda;
            end
            if isfield(options, 'vdcsda')
                obj.vdcsda = options.vdcsda;
            end
            if isfield(options, 'zor')
                obj.zor = options.zor;
            end
            if isfield(options, 'grd')
                obj.grd = options.grd;
            end
            if isfield(options, 'grn')
                obj.grn = options.grn;
            end
            if isfield(options, 'zna')
                obj.zna = options.zna;
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check required fields and encoded formats
            reference = 'STDI-0002-1 Appendix P, Table P-2 (2024-04)';
            report = newReport(reference);
            report = addIssue(report, isnan(obj.zor), ...
                'Required', 'zor', 'Supply ZOR.', reference);
            report = addIssue(report, isnan(obj.zna), ...
                'Required', 'zna', 'Supply ZNA.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.typ, {'MAP', 'GEO', 'DIG'})) || ...
                ~any(strcmp(obj.uni, {'M', 'SEC', 'DEG'})) || ...
                (strcmp(obj.typ, 'MAP') && ~strcmp(obj.uni, 'M')) || ...
                (strcmp(obj.typ, 'GEO') && strcmp(obj.uni, 'M')), ...
                'CoordinateSystem', 'typ/uni', ...
                'Supply compatible coordinate type and units.', reference);
            report = addIssue(report, ...
                isempty(strtrim(obj.dag)) || isempty(strtrim(obj.dcd)) || ...
                isempty(strtrim(obj.ell)) || isempty(strtrim(obj.elc)), ...
                'Datum', 'dag/dcd/ell/elc', ...
                'Supply datum and ellipsoid names and codes.', reference);
            report = addIssue(report, ...
                ~validGEOPSCode(obj.dcd, 'datum') || ...
                ~validGEOPSCode(obj.elc, 'ellipsoid') || ...
                (~isempty(strtrim(obj.vdcdvr)) && ...
                    ~validGEOPSCode(obj.vdcdvr, 'vertical')) || ...
                (~isempty(strtrim(obj.vdcsda)) && ...
                    ~validGEOPSCode(obj.vdcsda, 'sounding')) || ...
                (~isempty(strtrim(obj.grd)) && ...
                    ~validGEOPSCode(obj.grd, 'grid')), ...
                'CoordinateCode', 'dcd/elc/vdcdvr/vdcsda/grd', ...
                'Use a registered Appendix P code or its other/unknown code.', ...
                reference);
            report = addIssue(report, ...
                xor(isempty(strtrim(obj.dvr)), ...
                    isempty(strtrim(obj.vdcdvr))) || ...
                xor(isempty(strtrim(obj.sda)), ...
                    isempty(strtrim(obj.vdcsda))), ...
                'Datum', 'dvr/vdcdvr/sda/vdcsda', ...
                'Supply each datum name and code together.', reference);
            report = addIssue(report, isempty(strtrim(obj.grd)) && ...
                (~isempty(strtrim(obj.grn)) || obj.zna ~= 0), ...
                'Grid', 'grd/grn/zna', ...
                'An unspecified grid has no description or zone.', reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode the fixed 443-byte record
            requireValid(obj.validate());
            value = [ ...
                textField(obj.typ, 3) ...
                textField(obj.uni, 3) ...
                textField(obj.dag, 80) ...
                textField(obj.dcd, 4) ...
                textField(obj.ell, 80) ...
                textField(obj.elc, 3) ...
                textField(obj.dvr, 80) ...
                textField(obj.vdcdvr, 4) ...
                textField(obj.sda, 80) ...
                textField(obj.vdcsda, 4) ...
                decimalField(obj.zor, 15, 0, false) ...
                textField(obj.grd, 3) ...
                textField(obj.grn, 80) ...
                decimalField(obj.zna, 4, 0, false)];
        end
    end
end
