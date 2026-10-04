classdef JPEG2000
    %JPEG2000 - Experimental lossless NPJE or EPJE OpenJPEG snapshot
    %   OBJ = JPEG2000(DATA,ENCODER) encodes one uint8 or uint16 image frame
    %   using the OpenJPEG 2.5.4 Windows executable at ENCODER. DATA uses
    %   rows-by-columns-by-bands order and retains its native precision.
    %   JPEG2000 with no arguments creates an uninitialized value.
    %
    %   OBJ = JPEG2000(DATA,Backend="mex") uses the optional in-memory MEX.
    %   Omit ENCODER when using MEX. Backend="auto" (default) selects the
    %   executable when ENCODER is supplied, otherwise MEX. Threads defaults
    %   to 1 for either encoder. Run buildOpenJPEGMex to build the MEX once.
    %
    %   OBJ = JPEG2000(...,Profile=VALUE) selects "NPJE" (default) or
    %   "EPJE". Both use 1024-square tiles, six resolutions and 20 layers.
    %   This prototype supports images at least 32 pixels along each axis.
    %   NPJE is limited to 16382 tiles; EPJE to 65535 tiles. EPJE admits at
    %   most 3276 bands and requires packet lengths to fit one PLT per part.
    %   It requires Windows and is outside NFX's Coder compatibility goal.
    %   MemoryWarningBytes defaults to 4 GiB; Inf disables advisory warnings.
    %
    %   JPEG2000 functions:
    %       inspect - Check the bounded prototype codestream structure
    %       decode  - Decode a supported raw codestream to native pixels
    %
    %   JPEG2000 properties:
    %       codestream - Immutable raw JPEG 2000 bytes
    %       profile    - NPJE or EPJE
    %       info       - Parsed codestream geometry and marker information
    %       metrics    - Encoding time and byte counts
    %       j2klra     - Derived original-encoding TRE payload
    %       comrat     - Derived Nxyz achieved bitrate
    %
    %   See also ImageSegment, File

    properties (SetAccess = private)
        codestream = zeros(1,0,'uint8') % Raw compressed image bytes
        profile = '' % Validated profile selection
        info = struct() % Structural inspection, not decoder certification
        metrics = struct() % Encoding metrics; empty fields for imported data
        j2klra = zeros(1,0,'uint8') % Original profile and layer targets
        comrat = '' % Numerically lossless bitrate, one fractional digit
    end
    methods
        function obj = JPEG2000(data, encoder, options)
            arguments
                data {mustBePixels} = zeros(0, 0, 'uint8')
                encoder = ''
                options.Profile {mustBeTextScalar, mustBeMember(options.Profile,{'NPJE','EPJE'})} = 'NPJE'
                options.MemoryWarningBytes = 4 * 2^30
                options.Backend {mustBeTextScalar, mustBeMember(options.Backend, {'auto', 'cli', 'mex'})} = 'auto'
                options.Threads = 1
            end
            if nargin == 0, return, end
            mustBeTextScalar(encoder);
            if ~nfx.internal.validJPEG2000Options('auto', options.Threads)
                error('nfx:OpenJPEGThreads', 'Threads must be a positive int32-range double integer.');
            end
            backend = char(options.Backend);
            if strcmp(backend, 'auto')
                backend = 'mex';
                if strlength(encoder) > 0, backend = 'cli'; end
            end
            if strcmp(backend, 'mex') && strlength(encoder) > 0
                error('nfx:OpenJPEGBackend', 'Omit the executable path when selecting Backend="mex".');
            end
            if isempty(data) || ndims(data) > 3 || min(size(data,1),size(data,2)) < 32 || ...
                    size(data,3) > 16384 || ceil(size(data,1)/1024)*ceil(size(data,2)/1024) > 65535
                error('nfx:JPEG2000Scope','Expected one frame at least 32-by-32, at most 16384 bands and 65535 tiles.');
            end
            if ~nfx.internal.validMemoryWarning(options.MemoryWarningBytes)
                error('nfx:MemoryWarningBytes', 'MemoryWarningBytes must be nonnegative (Inf allowed).');
            end
            obj.profile = char(options.Profile);
            if strcmp(obj.profile,'EPJE') && size(data,3)*20 > 65532
                error('nfx:JPEG2000Scope','EPJE permits at most 3276 bands; packet lengths must also fit one PLT per tile-part.');
            end
            if strcmp(obj.profile,'NPJE') && ceil(size(data,1)/1024)*ceil(size(data,2)/1024) > 16382
                error('nfx:JPEG2000Scope','The NPJE prototype uses one TLM and supports at most 16382 tiles.');
            end
            nativeBytes = numel(data) * (1 + isa(data, 'uint16'));
            estimate = 2 * nativeBytes;
            if strcmp(backend, 'mex'), estimate = estimate + 4 * numel(data); end
            nfx.internal.warnMemory(estimate, ...
                options.MemoryWarningBytes);
            if strcmp(backend, 'mex')
                [obj.codestream, obj.metrics] = encodeOpenJPEGMex( ...
                    data, obj.profile, options.Threads);
            else
                [obj.codestream, obj.metrics] = encodeOpenJPEG( ...
                    data, char(encoder), obj.profile, options.Threads);
            end
            obj.info = inspectJPEG2000(obj.codestream,obj.profile);
            expected = [size(data,1) size(data,2) size(data,3)];
            precision = 8+8*isa(data,'uint16');
            if ~isequal(obj.info.dimensions,expected) || obj.info.precision ~= precision
                error('nfx:JPEG2000Geometry','Encoder output disagrees with the supplied pixels.');
            end
            [obj.j2klra, obj.comrat, ok] = jpeg2000Metadata( ...
                obj.profile, size(data, 3), numel(data), numel(obj.codestream));
            if ~ok
                error('nfx:JPEG2000Bitrate','Achieved bitrate exceeds the J2KLRA field limit.');
            end
        end
    end
    methods (Static, Access = {?nfx.internal.FileReader, ?nfx.ImageSegment})
        function [obj, pixels, ok, status] = restoreRead(data, entry, records, maxPixels, backend, threads)
            %restoreRead - Validate and decode an existing compression snapshot
            if nargin < 5, backend = 'auto'; end
            if nargin < 6, threads = 4; end
            obj = nfx.JPEG2000.empty(1, 0);
            pixels = zeros(0, 0, 'uint8'); ok = false;
            status = nfx.internal.readStatus(); status.scope = 'image';
            status.offset = entry.location.dataOffset;
            layout = entry.layout;
            samples = layout.nrows * layout.ncols * layout.bands;
            if samples > maxPixels
                status.code = 'ResourceLimit';
                status.message = 'Decoded image samples exceed MaxPixels.'; return
            end
            selected = find(strcmp({records.tag}, 'J2KLRA'));
            if ~isscalar(selected) || selected ~= numel(records)
                status.code = 'MalformedFile';
                status.message = 'A compressed image needs one final original J2KLRA record.';
                return
            end
            [layers, valid, child] = nfx.J2KLRA.deserialize(records(selected).payload);
            if ~valid || ~any(layers.orig == [0 2])
                status.code = 'UnsupportedFeature';
                status.message = ['Only original NPJE/EPJE layer metadata is supported. ' child.message];
                return
            end
            profile = 'NPJE';
            if layers.orig == 2, profile = 'EPJE'; end
            % The existing host-only codestream inspector reports exceptions.
            % Translate them at this codec boundary, outside native parsing.
            try
                info = inspectJPEG2000(data, profile);
            catch exception
                status.code = 'MalformedFile'; status.message = exception.message;
                return
            end
            if ~strcmp(layout.imode, 'B') || ...
                    ~isequal(info.dimensions, [layout.nrows layout.ncols layout.bands]) || ...
                    info.precision ~= layout.nbpp || min(info.dimensions(1:2)) < 32
                status.code = 'MalformedFile';
                status.message = 'JPEG2000 geometry disagrees with the image subheader.';
                return
            end
            [payload, comrat, valid] = jpeg2000Metadata( ...
                profile, layout.bands, samples, numel(data));
            if ~valid || ~isequal(payload, records(selected).payload) || ...
                    ~strcmp(comrat, layout.comrat)
                status.code = 'MalformedFile';
                status.message = 'Stored J2KLRA or COMRAT disagrees with the codestream.';
                return
            end
            [pixels, ok, child] = nfx.internal.decodeJPEG2000(data, backend, threads, maxPixels);
            if ~ok
                status.code = child.code; status.message = child.message; return
            end
            if ~(isa(pixels, 'uint8') || isa(pixels, 'uint16')) || ...
                    8 + 8 * isa(pixels, 'uint16') ~= info.precision || ...
                    ~isequal([size(pixels, 1) size(pixels, 2) size(pixels, 3)], info.dimensions) || ...
                    ndims(pixels) > 3
                pixels = zeros(0, 0, 'uint8'); ok = false;
                status.code = 'MalformedFile';
                status.message = 'JPEG2000 decoded samples disagree with the codestream.';
                return
            end
            obj = nfx.JPEG2000(); obj.codestream = data;
            obj.profile = profile; obj.info = info;
            obj.j2klra = payload; obj.comrat = comrat;
            status = nfx.internal.readStatus();
        end
    end
    methods (Static)
        function pixels = decode(data, options)
            %DECODE - Decode a supported raw NPJE or EPJE codestream
            %   PIXELS = nfx.JPEG2000.decode(DATA) validates uint8 row DATA
            %   and returns its native uint8/uint16 rows-by-columns-by-bands
            %   pixels. Backend="auto" uses the MEX when installed, otherwise
            %   MATLAB imread. Backend="mex" or "matlab" forces that backend.
            %   Threads defaults to 4 and controls only the MEX decoder.
            %   MaxPixels bounds decoded samples; its default is FLINTMAX.
            %   MemoryWarningBytes defaults to 4 GiB; Inf disables warnings.
            %
            %   See also inspect, nfx.File.read
            arguments
                data {mustBeByteRow}
                options.Backend = 'auto'
                options.Threads = 4
                options.MaxPixels = flintmax
                options.MemoryWarningBytes = 4 * 2^30
            end
            if ~nfx.internal.validJPEG2000Options(options.Backend, options.Threads) || ...
                    ~nfx.internal.validReadLimit(options.MaxPixels) || ...
                    ~nfx.internal.validMemoryWarning(options.MemoryWarningBytes)
                error('nfx:JPEG2000Options', 'Invalid backend, threads, or memory options.');
            end
            info = inspectJPEG2000(data, 'auto');
            count = prod(info.dimensions);
            if count > options.MaxPixels
                error('nfx:OpenJPEGResourceLimit', 'Decoded samples exceed MaxPixels.');
            end
            nfx.internal.warnMemory(numel(data) + count * (4 + info.precision / 8), ...
                options.MemoryWarningBytes);
            [pixels, ok, status] = nfx.internal.decodeJPEG2000( ...
                data, options.Backend, options.Threads, options.MaxPixels);
            if ~ok, error('nfx:JPEG2000Decode', '%s: %s', status.code, status.message); end
            if ~isequal([size(pixels, 1), size(pixels, 2), size(pixels, 3)], info.dimensions) || ...
                    ~(isa(pixels, 'uint8') || isa(pixels, 'uint16')) || ...
                    8 + 8 * isa(pixels, 'uint16') ~= info.precision || ndims(pixels) > 3
                error('nfx:JPEG2000Geometry', 'Decoded samples disagree with the codestream.');
            end
        end
        function info = inspect(data, profile)
            %INSPECT - Inspect the prototype's lossless profile structure
            %   INFO = INSPECT(DATA,PROFILE) checks raw codestream DATA for
            %   the bounded NPJE or EPJE configuration. Invalid or unsupported
            %   structures error. Entropy-coded sample values are not decoded.
            arguments
                data {mustBeByteRow}
                profile {mustBeTextScalar, mustBeMember(profile,{'NPJE','EPJE'})}
            end
            info = inspectJPEG2000(data,char(profile));
        end
    end
end
