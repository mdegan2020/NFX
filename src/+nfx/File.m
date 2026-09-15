classdef File
    %FILE - A NITF file assembled with value semantics
    %   OBJ = FILE creates an empty file. Supply required header metadata,
    %   add one ImageSegment, validate, and write to a filesystem path.
    %
    %   OBJ = FILE(header=HEADER) also supplies a FileHeader value.
    %
    %   FILE functions:
    %       plus     - Append an image value snapshot
    %       validate - Check generic NITF rules or reject unsupported SNIP
    %       write    - Write validated content with overwrite protection
    %
    %   FILE properties:
    %       header - Editable metadata with derived lengths and counts
    %       images - Image value snapshots in insertion order
    %
    %   See also FileHeader, ImageSegment, RPC00B

    properties (Dependent)
        header % Metadata with current lengths, counts, and complexity
    end
    properties (SetAccess = private)
        images % Attached image snapshots
    end
    properties (Access = private)
        headerValue
    end
    methods
        function obj = File(options) %#codegen
            %FILE - Construct an empty file
            arguments
                options.header (1,1) nfx.FileHeader = nfx.FileHeader()
            end
            obj.headerValue = options.header;
            obj.images = nfx.ImageSegment.empty(1, 0);
        end
        function value = get.header(obj) %#codegen
            %get.header - Derive all file-owned structural metadata
            value = obj.headerValue;
            value.numi = numel(obj.images);
            value.hl = 388 + 16*value.numi;
            value.lish = zeros(1, value.numi);
            value.li = zeros(1, value.numi);
            value.clevel = 3;
            for k = 1:value.numi
                value.lish(k) = obj.images(k).lish;
                value.li(k) = obj.images(k).li;
                h = obj.images(k).header;
                extent = max(h.nrows, h.ncols);
                bands = size(obj.images(k).data, 3);
                if extent > 2048 || max(h.nppbh, h.nppbv) > 2048 || bands > 9
                    value.clevel = max(value.clevel, 5);
                end
                if extent > 8192, value.clevel = max(value.clevel, 6); end
                if extent > 65536 || bands > 255 || ...
                        (strcmp(h.irep, 'RGB') && h.nbpp > 8)
                    value.clevel = max(value.clevel, 7);
                end
                if bands > 999, value.clevel = 9; end
            end
            value.fl = value.hl + sum(value.lish) + sum(value.li);
            if value.fl >= 52428800, value.clevel = max(value.clevel, 5); end
            if value.fl >= 1073741824, value.clevel = max(value.clevel, 6); end
            if value.fl >= 2147483648, value.clevel = max(value.clevel, 7); end
            if value.fl >= 10737418240, value.clevel = 9; end
        end
        function obj = set.header(obj, value) %#codegen
            %set.header - Replace editable file metadata
            arguments
                obj (1,1) nfx.File
                value (1,1) nfx.FileHeader
            end
            obj.headerValue = value;
        end
        function obj = plus(obj, image) %#codegen
            %PLUS - Append an image value snapshot
            %   OBJ = OBJ + IMAGE appends IMAGE. Later edits to IMAGE or its
            %   pixels do not change OBJ. The candidate writes one image.
            arguments
                obj (1,1) nfx.File
                image (1,1) nfx.ImageSegment
            end
            if numel(obj.images) >= 999
                error('nfx:ImageCount', 'NITF permits at most 999 image segments.');
            end
            obj.images(end + 1) = image;
        end
        function report = validate(obj, options) %#codegen
            %VALIDATE - Check generic NITF content without changing it
            %   REPORT = VALIDATE(OBJ) checks the supported single-image file.
            %
            %   REPORT = VALIDATE(OBJ,SNIP_COMPLIANT=true) also reports that
            %   SNIP enforcement is not implemented and cannot pass.
            arguments
                obj (1,1) nfx.File
                options.SNIP_COMPLIANT (1,1) {mustBeA(options.SNIP_COMPLIANT, 'logical')} = false
            end
            report = newReport('NITF 2.1');
            report = mergeReport(report, validate(obj.header), 'header.');
            report = addIssue(report, numel(obj.images) ~= 1, 'ImageCount', ...
                'images', 'This candidate writes exactly one image segment.', 'NFX first candidate');
            for k = 1:numel(obj.images)
                report = mergeReport(report, validate(obj.images(k)), sprintf('images(%d).', k));
            end
            if options.SNIP_COMPLIANT
                report.scope = 'NITF 2.1 + SNIP';
                report = addIssue(report, true, 'SNIPNotSupported', 'SNIP_COMPLIANT', ...
                    'SNIP validation and writing are not implemented.', 'NGA.STND.0072 SNIP');
            end
        end
        function write(obj, filename, options) %#codegen
            %WRITE - Write a validated file with destination protection
            %   WRITE(OBJ,FILENAME) writes to a new filesystem path. Metadata
            %   validation finishes before any output file is created.
            %
            %   WRITE(...,Overwrite=true) permits replacing an existing file
            %   after complete output has been prepared in the same folder.
            %
            %   WRITE(...,SNIP_COMPLIANT=true) fails because SNIP enforcement
            %   is not implemented. Ordinary generic output remains supported.
            arguments
                obj (1,1) nfx.File
                filename {mustBeTextScalar, mustBeNonempty}
                options.Overwrite (1,1) {mustBeA(options.Overwrite, 'logical')} = false
                options.SNIP_COMPLIANT (1,1) {mustBeA(options.SNIP_COMPLIANT, 'logical')} = false
            end
            requireValid(validate(obj, SNIP_COMPLIANT=options.SNIP_COMPLIANT));
            destination = char(filename);
            if isempty(destination) || any(destination == '*') || ...
                    any(destination == '?') || any(destination == char(0)) || ...
                    contains(destination, '://') || isfolder(destination)
                error('nfx:Destination', 'Supply a local filename, without wildcards or a directory target.');
            end
            if isfile(destination) && ~options.Overwrite
                error('nfx:Exists', 'Destination exists; use Overwrite=true to replace it.');
            end
            folder = fileparts(destination);
            if isempty(folder), folder = pwd; end
            if ~isfolder(folder)
                error('nfx:Destination', 'The destination folder does not exist.');
            end
            fileHeader = bytes(obj.header);
            imageHeader = subheader(obj.images(1));
            temporary = [tempname(folder) '.nfx-part'];
            cleanup = onCleanup(@() discardTemporary(temporary));
            writeTemporary(obj, temporary, fileHeader, imageHeader);
            % Recheck immediately before publishing the completed output.
            if isfolder(destination)
                error('nfx:Destination', 'The destination became a directory.');
            end
            if isfile(destination) && ~options.Overwrite
                error('nfx:Exists', 'The destination appeared while writing.');
            end
            [ok, message] = movefile(temporary, destination);
            if ~ok
                error('nfx:PublishFailed', 'Could not replace the destination: %s', message);
            end
            clear cleanup
        end
    end
    methods (Access = private)
        function writeTemporary(obj, filename, fileHeader, imageHeader) %#codegen
            %writeTemporary - Close output before publication, including on errors
            output = nfx.internal.OutputFile(filename);
            cleanup = onCleanup(@() delete(output));
            fid = output.id;
            count = writeBytes(fid, fileHeader) + writeBytes(fid, imageHeader);
            count = count + writePixels(obj.images(1), fid);
            if count ~= obj.header.fl || ftell(fid) ~= obj.header.fl
                error('nfx:WriteFailed', 'Output length does not match the calculated file length.');
            end
            closeStatus = close(output);
            if closeStatus ~= 0
                error('nfx:WriteFailed', 'The filesystem could not close the completed output.');
            end
            clear cleanup
        end
    end
end

function discardTemporary(filename) %#codegen
    %discardTemporary - Remove only an unfinished temporary output
    if isfile(filename), delete(filename); end
end
