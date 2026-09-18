classdef (Sealed) SECURA < nfx.TRE
    %SECURA - Extended security document and copied owner security fields
    %   OBJ = SECURA(Name=VALUE) captures SECURITY as a uint8 byte row.
    %   SECSTD identifies ARH.XML or ADP-4774; SECCOMP is blank or GZIP.
    %   NFX checks the container and its copied header fields. Validation
    %   of the security document against its registered schema is external.
    %
    %   The supported file profile is unclassified NITF 2.1. FDATTIM must
    %   match the owning file's FDT. SECFLDS contains its owner's 167
    %   security bytes followed by forty zero bytes. If any segment carries
    %   SECURA, the file header must also carry SECURA. NFX does not silently
    %   update copied fields when a file changes.
    %
    %   See also TRE, File, ImageSegment, TextSegment

    properties (Constant)
        cetag = 'SECURA'
    end
    properties
        fdattim {mustBeAscii(fdattim, 14)} = ''
        formatver {mustBeAscii(formatver, 9)} = 'NITF02.10'
        secflds {mustBeByteRow} = [uint8('U') ...
            repmat(uint8(' '), 1, 166) zeros(1, 40, 'uint8')]
        secstd {mustBeAscii(secstd, 8)} = ''
        seccomp {mustBeAscii(seccomp, 8)} = ''
        security {mustBeByteRow} = zeros(1, 0, 'uint8')
    end
    properties (Dependent, SetAccess = private)
        seclen
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode security framing and unchanged data bytes
            %   [OBJ, OK, STATUS] = nfx.SECURA.deserialize(PAYLOAD)
            %   returns an unset scalar object on failure.
            %
            %   See also SECURA, SECURA.payload
            arguments
                data
            end
            obj = nfx.SECURA();
            reader = nfx.internal.TREReader(data, 99988);
            [date, reader] = reader.text(14, false);
            [version, reader] = reader.text(9, false);
            [fields, reader] = reader.take(207);
            [standard, reader] = reader.text(8);
            [compression, reader] = reader.text(8);
            [length, reader] = reader.count(5, 1, 99737);
            [bytes, reader] = reader.take(length);
            if reader.ok
                obj.fdattim = date;
                obj.formatver = version;
                obj.secflds = fields;
                obj.secstd = standard;
                obj.seccomp = compression;
                obj.security = bytes;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.SECURA());
        end
    end
    methods
        function obj = SECURA(options) %#codegen
            %SECURA - Construct explicitly supplied security metadata
            arguments
                options.?nfx.SECURA
            end
            if isfield(options, 'fdattim'), obj.fdattim = options.fdattim; end
            if isfield(options, 'formatver')
                obj.formatver = options.formatver;
            end
            if isfield(options, 'secflds'), obj.secflds = options.secflds; end
            if isfield(options, 'secstd'), obj.secstd = options.secstd; end
            if isfield(options, 'seccomp'), obj.seccomp = options.seccomp; end
            if isfield(options, 'security'), obj.security = options.security; end
        end
        function value = get.seclen(obj) %#codegen
            %get.seclen - Derive the stored security data length
            value = numel(obj.security);
        end
        function report = validate(obj) %#codegen
            %validate - Check the supported container and copied field format
            reference = 'STDI-0002-1 Appendix AI, Tables AI-1 and AI-2';
            report = newReport(reference);
            report = addIssue(report, ~validDate(obj.fdattim), 'Date', ...
                'fdattim', 'Supply the associated file FDT.', reference);
            report = addIssue(report, ~strcmp(obj.formatver, 'NITF02.10'), ...
                'FormatVersion', 'formatver', ...
                'This profile supports NITF02.10.', reference);
            expected = [uint8('U') repmat(uint8(' '), 1, 166) ...
                zeros(1, 40, 'uint8')];
            report = addIssue(report, ~isequal(obj.secflds, expected), ...
                'SecurityFields', 'secflds', ...
                'Supply the supported unclassified security fields and fill.', ...
                reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.secstd, {'ARH.XML', 'ADP-4774'})), ...
                'SecurityStandard', 'secstd', ...
                'Use ARH.XML or ADP-4774.', reference);
            report = addIssue(report, ...
                ~isempty(strtrim(obj.seccomp)) && ...
                ~strcmp(obj.seccomp, 'GZIP'), 'SecurityCompression', ...
                'seccomp', 'Use blank or GZIP.', reference);
            report = addIssue(report, obj.seclen > 99737, 'TRELength', ...
                'security', 'Security data cannot exceed 99737 bytes.', reference);
            report = mergeReport(report, unverifiedSecurityDocument(), '');
        end
        function value = payload(obj) %#codegen
            %payload - Encode the security container without changing content
            requireValid(obj.validate());
            value = [textField(obj.fdattim, 14) ...
                textField(obj.formatver, 9) obj.secflds ...
                textField(obj.secstd, 8) textField(obj.seccomp, 8) ...
                decimalField(obj.seclen, 5, 0, false) obj.security];
        end
    end
end
