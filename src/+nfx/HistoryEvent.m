classdef (Sealed) HistoryEvent
    %HistoryEvent - One supplied pixel-processing event in a HISTOA record
    %   EVENT = HistoryEvent(Name=VALUE) describes input/output precision and
    %   applied processing. Set each operation flag and its conditional fields
    %   together. Unused conditional numeric fields remain NaN.
    %
    %   IPCOM accepts up to nine 80-character comments. DECIMAL_PLACES gives
    %   fractional digit counts for ROT_ANGLE, ZOOMROW, ZOOMCOL, MAG_LEVEL,
    %   and DRA_MULT, respectively. No pixel processing is performed here.
    %
    %   See also HISTOA, ImageSegment

    properties
        pdate {mustBeAscii(pdate,14)} = ''
        psite {mustBeAscii(psite,10)} = ''
        pas {mustBeAscii(pas,10)} = ''
        ibpp {mustBeMetadata(ibpp,1,64,1)} = NaN
        ipvtype {mustBeAscii(ipvtype,3)} = 'INT'
        inbwc {mustBeAscii(inbwc,10)} = 'NONE000000'
        disp_flag {mustBeMetadata(disp_flag,0,3,1)} = NaN
        rot_flag {mustBeMetadata(rot_flag,0,1,1)} = 0
        rot_angle {mustBeMetadata(rot_angle,0,359.9999,0)} = NaN
        asym_flag {mustBeMetadata(asym_flag,0,1,1)} = NaN
        zoomrow {mustBeMetadata(zoomrow,0,99.9999,0)} = NaN
        zoomcol {mustBeMetadata(zoomcol,0,99.9999,0)} = NaN
        proj_flag {mustBeMetadata(proj_flag,0,1,1)} = 0
        sharp_flag {mustBeMetadata(sharp_flag,0,1,1)} = 0
        sharpfam {mustBeMetadata(sharpfam,-1,99,1)} = NaN
        sharpmem {mustBeMetadata(sharpmem,-1,99,1)} = NaN
        mag_flag {mustBeMetadata(mag_flag,0,1,1)} = 0
        mag_level {mustBeMetadata(mag_level,0,99.9999,0)} = NaN
        dra_flag {mustBeMetadata(dra_flag,0,2,1)} = 0
        dra_mult {mustBeMetadata(dra_mult,0,999.999,0)} = NaN
        dra_sub {mustBeMetadata(dra_sub,-9999,9999,1)} = NaN
        ttc_flag {mustBeMetadata(ttc_flag,0,1,1)} = 0
        ttcfam {mustBeMetadata(ttcfam,-1,99,1)} = NaN
        ttcmem {mustBeMetadata(ttcmem,-1,99,1)} = NaN
        devlut_flag {mustBeMetadata(devlut_flag,0,1,1)} = 0
        obpp {mustBeMetadata(obpp,1,64,1)} = NaN
        opvtype {mustBeAscii(opvtype,3)} = 'INT'
        outbwc {mustBeAscii(outbwc,10)} = 'NONE000000'
        decimal_places {mustBePrecision} = [4 4 4 4 3]
    end
    properties (Dependent)
        ipcom
    end
    properties (Dependent, SetAccess = private)
        nipcom
        byte_count
    end
    properties (Access = private)
        comments = repmat(' ',0,80)
    end
    methods
        function obj = HistoryEvent(options) %#codegen
            %HistoryEvent - Construct an editable processing event
            arguments
                options.?nfx.HistoryEvent
            end
            if isfield(options,'pdate'), obj.pdate = options.pdate; end
            if isfield(options,'psite'), obj.psite = options.psite; end
            if isfield(options,'pas'), obj.pas = options.pas; end
            if isfield(options,'ibpp'), obj.ibpp = options.ibpp; end
            if isfield(options,'ipvtype'), obj.ipvtype = options.ipvtype; end
            if isfield(options,'inbwc'), obj.inbwc = options.inbwc; end
            if isfield(options,'disp_flag'), obj.disp_flag = options.disp_flag; end
            if isfield(options,'rot_flag'), obj.rot_flag = options.rot_flag; end
            if isfield(options,'rot_angle'), obj.rot_angle = options.rot_angle; end
            if isfield(options,'asym_flag'), obj.asym_flag = options.asym_flag; end
            if isfield(options,'zoomrow'), obj.zoomrow = options.zoomrow; end
            if isfield(options,'zoomcol'), obj.zoomcol = options.zoomcol; end
            if isfield(options,'proj_flag'), obj.proj_flag = options.proj_flag; end
            if isfield(options,'sharp_flag'), obj.sharp_flag = options.sharp_flag; end
            if isfield(options,'sharpfam'), obj.sharpfam = options.sharpfam; end
            if isfield(options,'sharpmem'), obj.sharpmem = options.sharpmem; end
            if isfield(options,'mag_flag'), obj.mag_flag = options.mag_flag; end
            if isfield(options,'mag_level'), obj.mag_level = options.mag_level; end
            if isfield(options,'dra_flag'), obj.dra_flag = options.dra_flag; end
            if isfield(options,'dra_mult'), obj.dra_mult = options.dra_mult; end
            if isfield(options,'dra_sub'), obj.dra_sub = options.dra_sub; end
            if isfield(options,'ttc_flag'), obj.ttc_flag = options.ttc_flag; end
            if isfield(options,'ttcfam'), obj.ttcfam = options.ttcfam; end
            if isfield(options,'ttcmem'), obj.ttcmem = options.ttcmem; end
            if isfield(options,'devlut_flag'), obj.devlut_flag = options.devlut_flag; end
            if isfield(options,'obpp'), obj.obpp = options.obpp; end
            if isfield(options,'opvtype'), obj.opvtype = options.opvtype; end
            if isfield(options,'outbwc'), obj.outbwc = options.outbwc; end
            if isfield(options,'decimal_places'), obj.decimal_places = options.decimal_places; end
            if isfield(options,'ipcom'), obj.ipcom = options.ipcom; end
        end
        function value = get.ipcom(obj) %#codegen
            %get.ipcom - Return padded processing comment rows
            value = obj.comments;
        end
        function obj = set.ipcom(obj,value) %#codegen
            %set.ipcom - Normalize comment rows while preserving their order
            obj.comments = commentRows(value);
        end
        function value = get.nipcom(obj) %#codegen
            %get.nipcom - Derive the number of comment records
            value = size(obj.comments,1);
        end
        function value = get.byte_count(obj) %#codegen
            %get.byte_count - Derive the event length from conditional flags
            value = 74+80*obj.nipcom+8*(obj.rot_flag == 1)+14*(obj.asym_flag == 1)+ ...
                4*(obj.sharp_flag == 1)+7*(obj.mag_flag == 1)+12*(obj.dra_flag == 1)+4*(obj.ttc_flag == 1);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check required, conditional and explanatory metadata
            report = newReport('STDI-0002 Appendix L processing event');
            reference = 'STDI-0002-1 Appendix L, L.4.1 and Tables L-3/L-4';
            report = addIssue(report,~knownDate(obj.pdate,14) || isempty(strtrim(char(obj.psite))) || ...
                isempty(strtrim(char(obj.pas))),'Required','pdate/psite/pas', ...
                'Supply a known UTC processing time, site and application.',reference);
            report = addIssue(report,~pixelType(obj.ipvtype,obj.ibpp) || ~pixelType(obj.opvtype,obj.obpp), ...
                'PixelRepresentation','ibpp/ipvtype/obpp/opvtype', ...
                'Use INT/SI up to 16 bits, R=32, C=64, B=1, or U with 1 to 64 bits.',reference);
            [inValid,inComment] = historyCompression(obj.inbwc,false);
            [outValid,outComment] = historyCompression(obj.outbwc,false);
            report = addIssue(report,~inValid || ~outValid,'CompressionCode','inbwc/outbwc', ...
                'Use complete published compression-operation codes and trailing zero groups.',reference);
            report = addIssue(report,any(isnan([obj.rot_flag obj.proj_flag obj.sharp_flag ...
                obj.mag_flag obj.dra_flag obj.ttc_flag obj.devlut_flag])), ...
                'Required','processing flags','Supply every nonblank processing flag.',reference);
            flags = [obj.rot_flag obj.asym_flag obj.asym_flag obj.sharp_flag obj.sharp_flag ...
                obj.mag_flag obj.dra_flag obj.dra_flag obj.ttc_flag obj.ttc_flag];
            values = [obj.rot_angle obj.zoomrow obj.zoomcol obj.sharpfam obj.sharpmem ...
                obj.mag_level obj.dra_mult obj.dra_sub obj.ttcfam obj.ttcmem];
            report = addIssue(report,any((flags == 1) ~= ~isnan(values)), ...
                'ConditionalField','processing parameters', ...
                'Supply each conditional value exactly when its operation flag is one.',reference);
            needsComment = obj.proj_flag == 1 || obj.mag_flag == 1 || inComment || outComment || ...
                any([obj.sharpfam obj.sharpmem obj.ttcfam obj.ttcmem] == -1);
            report = addIssue(report,needsComment && ~any(obj.comments(:) ~= ' '), ...
                'ProcessingComment','ipcom','Explain projection, magnification, custom kernels or unknown compression.',reference);
            floating = [obj.rot_angle obj.zoomrow obj.zoomcol obj.mag_level obj.dra_mult];
            widths = [8 7 7 7 7];
            maxima = [359.9999 99.9999 99.9999 99.9999 999.999];
            for k = 1:5
                encoded = sprintf('%0*.*f',widths(k),obj.decimal_places(k),floating(k));
                report = addIssue(report,~isnan(floating(k)) && ...
                    (numel(encoded) ~= widths(k) || str2double(encoded) > maxima(k)), ...
                    'DecimalPrecision','decimal_places', ...
                    'The chosen precision must fit each field and keep its rounded value within range.',reference);
            end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize the event with only its applicable fields
            requireValid(validate(obj));
            value = zeros(1,obj.byte_count,'uint8');
            head = [textField(obj.pdate,14) textField(obj.psite,10) textField(obj.pas,10) ...
                decimalField(obj.nipcom,1,0,false) reshape(uint8(obj.comments.'),1,[]) ...
                decimalField(obj.ibpp,2,0,false) textField(obj.ipvtype,3) textField(obj.inbwc,10) ...
                blankDecimal(obj.disp_flag,1,0,false) decimalField(obj.rot_flag,1,0,false)];
            at = numel(head); value(1:at) = head;
            if obj.rot_flag == 1
                value(at+1:at+8) = decimalField(obj.rot_angle,8,obj.decimal_places(1),false); at = at+8;
            end
            value(at+1) = blankDecimal(obj.asym_flag,1,0,false); at = at+1;
            if obj.asym_flag == 1
                value(at+1:at+14) = [decimalField(obj.zoomrow,7,obj.decimal_places(2),false) ...
                    decimalField(obj.zoomcol,7,obj.decimal_places(3),false)]; at = at+14;
            end
            value(at+1:at+2) = [decimalField(obj.proj_flag,1,0,false) decimalField(obj.sharp_flag,1,0,false)]; at = at+2;
            if obj.sharp_flag == 1
                value(at+1:at+4) = [decimalField(obj.sharpfam,2,0,false) decimalField(obj.sharpmem,2,0,false)]; at = at+4;
            end
            value(at+1) = decimalField(obj.mag_flag,1,0,false); at = at+1;
            if obj.mag_flag == 1
                value(at+1:at+7) = decimalField(obj.mag_level,7,obj.decimal_places(4),false); at = at+7;
            end
            value(at+1) = decimalField(obj.dra_flag,1,0,false); at = at+1;
            if obj.dra_flag == 1
                value(at+1:at+12) = [decimalField(obj.dra_mult,7,obj.decimal_places(5),false) ...
                    decimalField(obj.dra_sub,5,0,true)]; at = at+12;
            end
            value(at+1) = decimalField(obj.ttc_flag,1,0,false); at = at+1;
            if obj.ttc_flag == 1
                value(at+1:at+4) = [decimalField(obj.ttcfam,2,0,false) decimalField(obj.ttcmem,2,0,false)]; at = at+4;
            end
            value(at+1:end) = [decimalField(obj.devlut_flag,1,0,false) decimalField(obj.obpp,2,0,false) ...
                textField(obj.opvtype,3) textField(obj.outbwc,10)];
        end
    end
end

function valid = pixelType(type,bits) %#codegen
    %pixelType - Check the representation limits specific to HISTOA
    type = strtrim(char(type));
    valid = (any(strcmp(type,{'INT','SI'})) && bits >= 1 && bits <= 16) || ...
        (strcmp(type,'R') && bits == 32) || (strcmp(type,'C') && bits == 64) || ...
        (strcmp(type,'B') && bits == 1) || (strcmp(type,'U') && bits >= 1 && bits <= 64);
end

function mustBePrecision(value) %#codegen
    %mustBePrecision - Require five exact double precision settings
    if ~isa(value,'double') || ~isequal(size(value),[1 5]) || ~isreal(value) || ...
            issparse(value) || any(~isfinite(value) | value < 1 | value > [6 5 5 5 5] | fix(value) ~= value)
        error('nfx:DecimalPrecision','Supply a double row of five positive fractional digit counts that fit the fields.');
    end
end
