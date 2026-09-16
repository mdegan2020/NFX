classdef DESHeader
    %DESHeader - Identification and type-specific header bytes for a DES
    %   OBJ = DESHeader(Name=VALUE) sets DESID, DESVER, DESCLAS, and DESSHF.
    %   DESSHF contains caller-supplied uint8 bytes for the named DES format.
    %   Generic validation checks the container; each format needs its own
    %   semantic validation. TRE_OVERFLOW headers are derived by File.
    %
    %   See also DESSegment, File

    properties
        desid {mustBeAscii(desid, 25)} = '' % Registered DES identifier
        desver {mustBeMetadata(desver, 1, 99, 1), mustBeFinite} = 1 % Format version
        desclas {mustBeAscii(desclas, 1)} = '' % Explicit U classification
        desshf {mustBeByteRow} = zeros(1, 0, 'uint8') % Type-specific subheader
    end
    properties (SetAccess = ?nfx.DESSegment)
        desoflw = '' % Derived overflowing metadata area
        desitem = 0 % Derived source segment index; zero for file header
    end
    properties (Dependent, SetAccess = private)
        desshl % Type-specific subheader length
        ldsh % Complete DES subheader length
    end
    methods
        function obj = DESHeader(options) %#codegen
            %DESHeader - Construct editable DES metadata
            arguments
                options.?nfx.DESHeader
            end
            if isfield(options, 'desid'), obj.desid = options.desid; end
            if isfield(options, 'desver'), obj.desver = options.desver; end
            if isfield(options, 'desclas'), obj.desclas = options.desclas; end
            if isfield(options, 'desshf'), obj.desshf = options.desshf; end
        end
        function value = get.desshl(obj) %#codegen
            %get.desshl - Count the type-specific subheader bytes
            value = numel(obj.desshf);
        end
        function value = get.ldsh(obj) %#codegen
            %get.ldsh - Include the conditional overflow-owner fields
            value = 200+obj.desshl+9*strcmp(obj.desid, 'TRE_OVERFLOW');
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check generic header structure and overflow references
            report = newReport('NITF 2.1 DES header');
            reference = 'JBP 2025.1, Tables 5.18-1 and 5.18-2; 5.18.4.2';
            report = addIssue(report, isempty(strtrim(char(obj.desid))), 'Required', ...
                'desid', 'Supply the DES format identifier.', reference);
            report = addIssue(report, ~strcmp(obj.desclas, 'U'), 'UnsupportedClassification', ...
                'desclas', 'Supply an explicit U classification.', reference);
            report = addIssue(report, obj.ldsh > 9998, 'Length', 'desshf', ...
                'DES subheader exceeds 9998 bytes.', reference);
            if strcmp(obj.desid, 'TRE_OVERFLOW')
                validOwner = (any(strcmp(obj.desoflw, {'XHD','UDHD'})) && obj.desitem == 0) || ...
                    (any(strcmp(obj.desoflw, {'IXSHD','UDID','TXSHD'})) && obj.desitem >= 1 && obj.desitem <= 999);
                report = addIssue(report, ~validOwner || obj.desver ~= 1 || obj.desshl ~= 0, ...
                    'OverflowHeader', 'desoflw/desitem', 'TRE_OVERFLOW requires its derived owner, version 1 and no DESSHF.', reference);
            end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize a validated DES header
            requireValid(validate(obj));
            value = [uint8('DE') textField(obj.desid, 25) ...
                decimalField(obj.desver, 2, 0, false) uint8('U') textField('', 166)];
            if strcmp(obj.desid, 'TRE_OVERFLOW')
                value = [value textField(obj.desoflw, 6) decimalField(obj.desitem, 3, 0, false)];
            end
            value = [value decimalField(obj.desshl, 4, 0, false) obj.desshf];
        end
    end
end
