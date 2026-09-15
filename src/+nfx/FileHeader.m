classdef FileHeader
    %FileHeader - Metadata and derived structure of a NITF 2.1 file
    %   OBJ = FileHeader creates an unset file header. Supply OSTAID, FDT,
    %   and an explicit FSCLAS of U for this unclassified candidate.
    %
    %   OBJ = FileHeader(Name=VALUE) sets editable metadata. A FILE owns and
    %   refreshes lengths and counts; callers cannot assign structural fields.
    %
    %   FileHeader functions:
    %       validate - Check metadata and layout
    %       bytes    - Serialize a validated header
    %
    %   FileHeader properties:
    %       ostaid, fdt, ftitle - Origin, UTC creation time, and title
    %       fsclas             - Explicit U classification
    %       fscop, fscpys       - Copy tracking; zero means not tracked
    %       fbkgc              - Three double-valued background components
    %       oname, ophone      - Optional originator details
    %       fhdr, fver, stype   - Fixed NITF version identifiers
    %       clevel, fl, hl     - Derived complexity and byte lengths
    %       numi, lish, li     - Derived image count and length vectors
    %       numt, ltsh, lt     - Derived text count and length vectors
    %       numdes, ldsh, ld   - Derived DES count and length vectors
    %
    %   See also File, ImageHeader

    properties
        ostaid {mustBeAscii(ostaid, 10)} = '' % Required originating station
        fdt {mustBeAscii(fdt, 14)} = '' % Required creation UTC or unknown pairs
        ftitle {mustBeAscii(ftitle, 80)} = '' % Optional file title
        fsclas {mustBeAscii(fsclas, 1)} = '' % Explicit classification choice
        fscop {mustBeMetadata(fscop, 0, 99999, 1), mustBeFinite} = 0 % Copy number
        fscpys {mustBeMetadata(fscpys, 0, 99999, 1), mustBeFinite} = 0 % Number of copies
        fbkgc {mustBeColor} = [0 0 0] % Red, green, and blue components
        oname {mustBeAscii(oname, 24)} = '' % Optional originator name
        ophone {mustBeAscii(ophone, 18)} = '' % Optional originator phone
    end
    properties (Constant)
        fhdr = 'NITF' % File profile
        fver = '02.10' % File version
        stype = 'BF01' % Standard type
    end
    properties (SetAccess = ?nfx.File)
        clevel = 3 % Derived complexity level
        fl = 388 % Derived complete file length
        hl = 388 % Derived header length
        numi = 0 % Derived image segment count
        lish = zeros(1, 0) % Derived image subheader lengths
        li = zeros(1, 0) % Derived image data lengths
        numt = 0 % Derived text count
        ltsh = zeros(1, 0) % Derived text subheader lengths
        lt = zeros(1, 0) % Derived text data lengths
        numdes = 0 % Derived DES count, including automatic overflow
        ldsh = zeros(1, 0) % Derived DES subheader lengths
        ld = zeros(1, 0) % Derived DES data lengths
    end
    properties (Access = ?nfx.File)
        xhd = zeros(1, 0, 'uint8')
        xhdlofl = 0
    end
    methods
        function obj = FileHeader(options) %#codegen
            %FileHeader - Construct editable file metadata
            arguments
                options.?nfx.FileHeader
            end
            if isfield(options, 'ostaid'), obj.ostaid = options.ostaid; end
            if isfield(options, 'fdt'), obj.fdt = options.fdt; end
            if isfield(options, 'ftitle'), obj.ftitle = options.ftitle; end
            if isfield(options, 'fsclas'), obj.fsclas = options.fsclas; end
            if isfield(options, 'fscop'), obj.fscop = options.fscop; end
            if isfield(options, 'fscpys'), obj.fscpys = options.fscpys; end
            if isfield(options, 'fbkgc'), obj.fbkgc = options.fbkgc; end
            if isfield(options, 'oname'), obj.oname = options.oname; end
            if isfield(options, 'ophone'), obj.ophone = options.ophone; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check file metadata and structural limits
            %   REPORT = VALIDATE(OBJ) returns a report without changing OBJ.
            arguments
                obj (1,1) nfx.FileHeader
            end
            report = newReport('NITF 2.1 file header');
            reference = 'JBP 2025.1 (2026-01 admin), Table 5.11-1';
            report = addIssue(report, isempty(strtrim(char(obj.ostaid))), ...
                'Required', 'ostaid', 'Supply the originating station identifier.', reference);
            report = addIssue(report, ~validDate(obj.fdt), 'Date', 'fdt', ...
                'Supply CCYYMMDDhhmmss UTC; unknown two-digit parts use --.', reference);
            report = addIssue(report, ~strcmp(obj.fsclas, 'U'), 'UnsupportedClassification', ...
                'fsclas', 'This candidate requires an explicit U (unclassified).', reference);
            report = addIssue(report, obj.fscpys > 0 && obj.fscop > obj.fscpys, ...
                'Copies', 'fscop', 'Copy number exceeds the tracked number of copies.', reference);
            report = addIssue(report, obj.fl > 999999999998 || obj.hl > 999999 || ...
                any(obj.lish > 999998) || any(obj.li > 9999999998) || ...
                any(obj.ltsh > 9998) || any(obj.lt > 99998) || ...
                any(obj.ldsh > 9998) || any(obj.ld > 999999998), 'Length', ...
                'fl/hl/segment lengths', 'Content exceeds a NITF length field.', reference);
            report = addIssue(report, obj.numi > 999 || obj.numt > 999 || obj.numdes > 999, ...
                'SegmentCount', 'numi/numt/numdes', 'Each segment type permits at most 999 entries.', reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize a validated file header
            %   VALUE = BYTES(OBJ) returns a uint8 row. Obtain OBJ from a FILE
            %   to include that file's automatically calculated layout.
            arguments
                obj (1,1) nfx.FileHeader
            end
            requireValid(validate(obj));
            value = [uint8(obj.fhdr) uint8(obj.fver) ...
                decimalField(obj.clevel, 2, 0, false) uint8(obj.stype) ...
                textField(obj.ostaid, 10) textField(obj.fdt, 14) textField(obj.ftitle, 80) ...
                uint8('U') textField('', 166) decimalField(obj.fscop, 5, 0, false) ...
                decimalField(obj.fscpys, 5, 0, false) uint8('0') uint8(obj.fbkgc(:).') ...
                textField(obj.oname, 24) textField(obj.ophone, 18) ...
                decimalField(obj.fl, 12, 0, false) decimalField(obj.hl, 6, 0, false) ...
                decimalField(obj.numi, 3, 0, false)];
            imageTable = zeros(1, 16*obj.numi, 'uint8');
            for k = 1:obj.numi
                imageTable(16*k-15:16*k) = [decimalField(obj.lish(k), 6, 0, false) ...
                    decimalField(obj.li(k), 10, 0, false)];
            end
            textTable = zeros(1, 9*obj.numt, 'uint8');
            for k = 1:obj.numt
                textTable(9*k-8:9*k) = [decimalField(obj.ltsh(k), 4, 0, false) ...
                    decimalField(obj.lt(k), 5, 0, false)];
            end
            desTable = zeros(1, 13*obj.numdes, 'uint8');
            for k = 1:obj.numdes
                desTable(13*k-12:13*k) = [decimalField(obj.ldsh(k), 4, 0, false) ...
                    decimalField(obj.ld(k), 9, 0, false)];
            end
            value = [value imageTable uint8('000000') decimalField(obj.numt, 3, 0, false) ...
                textTable decimalField(obj.numdes, 3, 0, false) desTable uint8('00000000') ...
                extensionBytes(obj.xhd, obj.xhdlofl, 99985)];
        end
    end
end

function mustBeColor(value) %#codegen
    %mustBeColor - Validate three double-valued byte components
    if ~isa(value, 'double') || ~isreal(value) || ~isvector(value) || ...
            numel(value) ~= 3 || any(~isfinite(value)) || ...
            any(value < 0 | value > 255 | fix(value) ~= value)
        error('nfx:Color', 'Expected three integer-valued doubles in [0, 255].');
    end
end
