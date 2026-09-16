classdef JPEG2000
    %JPEG2000 - Experimental lossless NPJE or EPJE OpenJPEG snapshot
    %   OBJ = JPEG2000(DATA,ENCODER) encodes a still uint8 or uint16 array
    %   using the OpenJPEG 2.5.4 Windows executable at ENCODER. DATA uses
    %   rows-by-columns-by-bands order and retains its native precision.
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
        metrics = struct() % Timings and storage counts for this encoding
        j2klra = zeros(1,0,'uint8') % Original profile and layer targets
        comrat = '' % Numerically lossless bitrate, one fractional digit
    end
    methods
        function obj = JPEG2000(data, encoder, options)
            arguments
                data {mustBePixels}
                encoder {mustBeTextScalar, mustBeNonzeroLengthText}
                options.Profile {mustBeTextScalar, mustBeMember(options.Profile,{'NPJE','EPJE'})} = 'NPJE'
            end
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
            rate = 8*numel(obj.codestream)/numel(data);
            if rate > 37
                error('nfx:JPEG2000Bitrate','Achieved bitrate exceeds the J2KLRA field limit.');
            end
            obj.comrat = sprintf('N%03.0f',round(10*rate));
            targets = [.03125 .0625 .125 .25 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.5 1.7 2 2.3 2.8 3.5 rate];
            obj.j2klra = uint8(sprintf('%1d05%05d020',2*strcmp(obj.profile,'EPJE'),size(data,3)));
            for k = 1:20
                obj.j2klra = [obj.j2klra uint8(sprintf('%03d%09.6f',k-1,targets(k)))];
            end
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
