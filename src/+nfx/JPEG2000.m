classdef JPEG2000
    %JPEG2000 - Experimental lossless NPJE or EPJE OpenJPEG snapshot
    %   OBJ = JPEG2000(DATA,ENCODER) encodes a still uint8 or uint16 array
    %   using the OpenJPEG 2.5.4 Windows executable at ENCODER. DATA uses
    %   rows-by-columns-by-bands order and retains its native precision.
    %   JPEG2000 with no arguments creates an uninitialized value.
    %
    %   OBJ = JPEG2000(...,Profile=VALUE) selects "NPJE" (default) or
    %   "EPJE". Both use 1024-square tiles, six resolutions and 20 layers.
    %   This prototype supports images at least 32 pixels along each axis.
    %   NPJE is limited to 16382 tiles; EPJE to 65535 tiles. EPJE admits at
    %   most 3276 bands and requires packet lengths to fit one PLT per part.
    %   It requires Windows and is outside NFX's Coder compatibility goal.
    %
    %   JPEG2000 functions:
    %       inspect - Check the bounded prototype codestream structure
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
            end
            if nargin == 0, return, end
            mustBeTextScalar(encoder); mustBeNonzeroLengthText(encoder);
            if isempty(data) || ndims(data) > 3 || min(size(data,1),size(data,2)) < 32 || ...
                    size(data,3) > 16384 || ceil(size(data,1)/1024)*ceil(size(data,2)/1024) > 65535
                error('nfx:JPEG2000Scope','Expected a still image at least 32-by-32, at most 16384 bands and 65535 tiles.');
            end
            obj.profile = char(options.Profile);
            if strcmp(obj.profile,'EPJE') && size(data,3)*20 > 65532
                error('nfx:JPEG2000Scope','EPJE permits at most 3276 bands; packet lengths must also fit one PLT per tile-part.');
            end
            if strcmp(obj.profile,'NPJE') && ceil(size(data,1)/1024)*ceil(size(data,2)/1024) > 16382
                error('nfx:JPEG2000Scope','The NPJE prototype uses one TLM and supports at most 16382 tiles.');
            end
            [obj.codestream,obj.metrics] = encodeOpenJPEG(data,char(encoder),obj.profile);
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
    methods (Static, Access = ?nfx.internal.FileReader)
        function [obj, pixels, ok, status] = restoreRead(data, entry, records, maxPixels)
            %restoreRead - Validate and decode an existing compression snapshot
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
            [pixels, ok, child] = nfx.internal.decodeJPEG2000(data);
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
