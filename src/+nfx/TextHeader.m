classdef TextHeader
    %TextHeader - Metadata for a standard NITF text segment
    %   OBJ = TextHeader(Name=VALUE) sets TEXTID, TXTDT, TXTITL, TSCLAS,
    %   and TXTALVL. Supply an explicit U classification and a UTC timestamp.
    %
    %   See also TextSegment, File

    properties
        textid {mustBeAscii(textid, 7)} = '' % Application-defined identifier
        txtalvl {mustBeMetadata(txtalvl, 0, 998, 1), mustBeFinite} = 0 % Attachment level
        txtdt {mustBeAscii(txtdt, 14)} = '' % Origination UTC or unknown pairs
        txtitl {mustBeAscii(txtitl, 80)} = '' % Optional title
        tsclas {mustBeAscii(tsclas, 1)} = '' % Explicit U classification
    end
    properties (Constant)
        te = 'TE'
        txtfmt = 'STA'
    end
    methods
        function obj = TextHeader(options) %#codegen
            %TextHeader - Construct editable text metadata
            arguments
                options.?nfx.TextHeader
            end
            if isfield(options, 'textid'), obj.textid = options.textid; end
            if isfield(options, 'txtalvl'), obj.txtalvl = options.txtalvl; end
            if isfield(options, 'txtdt'), obj.txtdt = options.txtdt; end
            if isfield(options, 'txtitl'), obj.txtitl = options.txtitl; end
            if isfield(options, 'tsclas'), obj.tsclas = options.tsclas; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check text metadata without changing it
            report = newReport('NITF 2.1 text header');
            reference = 'JBP 2025.1, Table 5.17-1';
            report = addIssue(report, ~validDate(obj.txtdt), 'Date', 'txtdt', ...
                'Supply CCYYMMDDhhmmss UTC, with -- for unknown pairs.', reference);
            report = addIssue(report, ~strcmp(obj.tsclas, 'U'), 'UnsupportedClassification', ...
                'tsclas', 'Supply an explicit U classification.', reference);
        end
        function value = bytes(obj, extensions, overflow) %#codegen
            %BYTES - Serialize the text subheader and selected extended area
            arguments
                obj (1,1) nfx.TextHeader
                extensions (1,:) uint8 = zeros(1, 0, 'uint8')
                overflow {mustBeMetadata(overflow, 0, 999, 1), mustBeFinite} = 0
            end
            requireValid(validate(obj));
            value = [uint8('TE') textField(obj.textid, 7) ...
                decimalField(obj.txtalvl, 3, 0, false) textField(obj.txtdt, 14) ...
                textField(obj.txtitl, 80) uint8('U') textField('', 166) uint8('0STA') ...
                extensionBytes(extensions, overflow, 9713)];
        end
    end
end
