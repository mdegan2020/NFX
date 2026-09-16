classdef ImageHeader
    %ImageHeader - Metadata and derived layout for one blocked image
    %   OBJ = ImageHeader creates an unset image header with 1024-by-1024
    %   blocks. Set IID1, IDATIM, ISCLAS, IREP, and ICAT before writing.
    %
    %   OBJ = ImageHeader(Name=VALUE) sets editable metadata. This candidate
    %   supports unclassified MONO, RGB, and MULTI images with unsigned
    %   samples, supplied geographic corners, and image comments.
    %
    %   ImageHeader functions:
    %       validate - Check metadata and derived layout
    %       bytes    - Serialize the image subheader
    %
    %   ImageHeader properties:
    %       iid1, idatim, iid2, isorce - Identification and acquisition
    %       isclas                    - Explicit U classification
    %       irep, icat                - Display representation and category
    %       abpp, pjust               - Significant bits and justification
    %       nppbh, nppbv              - Block width and height
    %       nrows, ncols, nbpp        - Derived dimensions and sample width
    %       nbands, xbands            - Derived band-count fields
    %       nbpr, nbpc                - Derived block counts
    %       im, pvtype, ic, imode     - Fixed encoding fields
    %       idlvl, ialvl, iloc, imag  - Composite display placement
    %       icords, igeolo, icom     - Supplied corners and image comments
    %
    %   See also ImageSegment, FileHeader

    properties
        iid1 {mustBeAscii(iid1, 10)} = '' % Required image identifier
        idatim {mustBeAscii(idatim, 14)} = '' % Acquisition UTC or unknown pairs
        tgtid {mustBeAscii(tgtid,17)} = '' % Supplied registered target ID and country
        iid2 {mustBeAscii(iid2, 80)} = '' % Optional image title
        isorce {mustBeAscii(isorce, 42)} = '' % Optional source description
        isclas {mustBeAscii(isclas, 1)} = '' % Explicit classification choice
        irep {mustBeAscii(irep, 8)} = '' % MONO, RGB, or MULTI
        icat {mustBeAscii(icat, 8)} = '' % Caller-supplied image category
        pjust {mustBeAscii(pjust, 1)} = 'R' % Sample justification
        nppbh {mustBeMetadata(nppbh, 1, 8192, 1), mustBeFinite} = 1024 % Block width
        nppbv {mustBeMetadata(nppbv, 1, 8192, 1), mustBeFinite} = 1024 % Block height
        ialvl {mustBeMetadata(ialvl, 0, 998, 1), mustBeFinite} = 0 % Parent display level
        iloc {mustBeLocation} = [0 0] % Row and column offset from parent
        icords {mustBeAscii(icords, 1)} = ' ' % Blank, D decimal degrees, or G DMS
        igeolo {mustBeAscii(igeolo, 60)} = '' % Four supplied corner coordinates
    end
    properties (Dependent)
        abpp % Automatic significant bits, or an explicit acquisition precision
        idlvl % Explicit display level, or a file-assigned default
        icom % Up to nine image comments, one padded row per comment
        irepband % Cell row of display labels; empty input restores defaults
        isubcat % Double row of wavelengths in nm; NaN encodes spaces
    end
    properties (SetAccess = private)
        nrows = 0 % Significant rows derived from pixels
        ncols = 0 % Significant columns derived from pixels
        nbpp = 0 % Storage bits per sample derived from pixels
    end
    properties (Dependent, SetAccess = private)
        nbands % Bands 1 through 9, or zero when XBANDS is present
        xbands % Band count above nine; empty when omitted
        nbpr % Blocks per row
        nbpc % Blocks per column
        nicom % Number of image comments
    end
    properties (Constant)
        im = 'IM' % Image subheader marker
        pvtype = 'INT' % Unsigned integer pixels
        ic = 'NC' % Uncompressed, unmasked imagery
        imode = 'B' % Band interleaved by block
        imag = '1.0' % No display magnification
    end
    properties (Access = private)
        bandCount = 0
        significantBits = NaN
        stats = struct('bits', 1, 'trailing', 8)
        displayLevel = NaN
        defaultDisplayLevel = 1
        comments = repmat(' ', 0, 80)
        bandRepresentations = cell(1,0)
        bandWavelengths = zeros(1,0)
    end
    methods
        function obj = ImageHeader(options) %#codegen
            %ImageHeader - Construct editable image metadata
            arguments
                options.?nfx.ImageHeader
            end
            if isfield(options, 'iid1'), obj.iid1 = options.iid1; end
            if isfield(options, 'idatim'), obj.idatim = options.idatim; end
            if isfield(options, 'tgtid'), obj.tgtid = options.tgtid; end
            if isfield(options, 'iid2'), obj.iid2 = options.iid2; end
            if isfield(options, 'isorce'), obj.isorce = options.isorce; end
            if isfield(options, 'isclas'), obj.isclas = options.isclas; end
            if isfield(options, 'irep'), obj.irep = options.irep; end
            if isfield(options, 'icat'), obj.icat = options.icat; end
            if isfield(options, 'pjust'), obj.pjust = options.pjust; end
            if isfield(options, 'nppbh'), obj.nppbh = options.nppbh; end
            if isfield(options, 'nppbv'), obj.nppbv = options.nppbv; end
            if isfield(options, 'abpp'), obj.abpp = options.abpp; end
            if isfield(options, 'idlvl'), obj.idlvl = options.idlvl; end
            if isfield(options, 'ialvl'), obj.ialvl = options.ialvl; end
            if isfield(options, 'iloc'), obj.iloc = options.iloc; end
            if isfield(options, 'icords'), obj.icords = options.icords; end
            if isfield(options, 'igeolo'), obj.igeolo = options.igeolo; end
            if isfield(options, 'icom'), obj.icom = options.icom; end
            if isfield(options, 'irepband'), obj.irepband = options.irepband; end
            if isfield(options, 'isubcat'), obj.isubcat = options.isubcat; end
        end
        function value = get.irepband(obj) %#codegen
            %get.irepband - Resolve default display labels from representation
            value = obj.bandRepresentations;
            if isempty(value)
                value = repmat({''},1,obj.bandCount);
                if strcmp(obj.irep,'MONO'), value = repmat({'M'},1,obj.bandCount); end
                if strcmp(obj.irep,'RGB') && obj.bandCount == 3, value = {'R','G','B'}; end
            end
        end
        function obj = set.irepband(obj,value) %#codegen
            %set.irepband - Preserve a cell row of supplied band display labels
            if ~iscell(value) || ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 99999
                error('nfx:BandRepresentations','Expected a cell row of band display labels.');
            end
            for k = 1:numel(value), mustBeAscii(value{k},2); end
            obj.bandRepresentations = value;
        end
        function value = get.isubcat(obj) %#codegen
            %get.isubcat - Resolve unspecified band wavelengths to blank fields
            value = obj.bandWavelengths;
            if isempty(value), value = NaN(1,obj.bandCount); end
        end
        function obj = set.isubcat(obj,value) %#codegen
            %set.isubcat - Preserve nonnegative double wavelengths in nanometers
            mustBeGLASMatrix(value,1,99999,999999);
            if any(value < 0), error('nfx:BandWavelengths','Wavelengths must be nonnegative doubles or NaN.'); end
            obj.bandWavelengths = value;
        end
        function value = get.abpp(obj) %#codegen
            %get.abpp - Resolve default significant-bit count
            value = obj.significantBits;
            if isnan(value)
                value = obj.stats.bits;
                if strcmp(obj.pjust, 'L'), value = obj.nbpp; end
            end
        end
        function obj = set.abpp(obj, value) %#codegen
            %set.abpp - Record an explicit significant-bit count
            mustBeMetadata(value, 1, 64, true);
            obj.significantBits = value;
        end
        function value = get.idlvl(obj) %#codegen
            %get.idlvl - Resolve an explicit or file-assigned display level
            value = obj.displayLevel;
            if isnan(value), value = obj.defaultDisplayLevel; end
        end
        function obj = set.idlvl(obj, value) %#codegen
            %set.idlvl - Set a display level; NaN restores automatic assignment
            mustBeMetadata(value, 1, 999, true);
            obj.displayLevel = value;
        end
        function value = get.icom(obj) %#codegen
            %get.icom - Return padded image comment rows
            value = obj.comments;
        end
        function obj = set.icom(obj, value) %#codegen
            %set.icom - Normalize supplied comment rows
            obj.comments = commentRows(value);
        end
        function value = get.nicom(obj) %#codegen
            %get.nicom - Derive the number of comments
            value = size(obj.comments, 1);
        end
        function value = get.nbands(obj) %#codegen
            %get.nbands - Resolve the short band-count field
            value = obj.bandCount;
            if value > 9, value = 0; end
        end
        function value = get.xbands(obj) %#codegen
            %get.xbands - Resolve the conditional extended band count
            value = zeros(1, 0);
            if obj.bandCount > 9, value = obj.bandCount; end
        end
        function value = get.nbpr(obj) %#codegen
            %get.nbpr - Derive horizontal block count
            value = ceil(obj.ncols / obj.nppbh);
        end
        function value = get.nbpc(obj) %#codegen
            %get.nbpc - Derive vertical block count
            value = ceil(obj.nrows / obj.nppbv);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check image metadata and derived layout
            %   REPORT = VALIDATE(OBJ) checks the supported uncompressed
            %   encoding without changing metadata or pixels.
            arguments
                obj (1,1) nfx.ImageHeader
            end
            report = newReport('NITF 2.1 image');
            reference = 'JBP 2025.1 (2026-01 admin), Table 5.13-1';
            id = char(obj.iid1);
            report = addIssue(report, isempty(strtrim(id)) || ...
                any(~((id >= 'A' & id <= 'Z') | (id >= 'a' & id <= 'z') | ...
                (id >= '0' & id <= '9') | id == ' ' | id == '_')), 'Identifier', 'iid1', ...
                'Supply an image identifier containing letters, digits, spaces or underscores.', reference);
            report = addIssue(report, ~validDate(obj.idatim), 'Date', 'idatim', ...
                'Supply CCYYMMDDhhmmss UTC; unknown two-digit parts use --.', reference);
            report = addIssue(report, ~strcmp(obj.isclas, 'U'), 'UnsupportedClassification', ...
                'isclas', 'This candidate requires an explicit U (unclassified).', reference);
            report = addIssue(report, obj.nrows < 1 || obj.nrows > 99999999, ...
                'Dimension', 'nrows', 'Attach pixels with 1 to 99999999 rows.', reference);
            report = addIssue(report, obj.ncols < 1 || obj.ncols > 99999999, ...
                'Dimension', 'ncols', 'Attach pixels with 1 to 99999999 columns.', reference);
            report = addIssue(report, obj.bandCount < 1 || obj.bandCount > 99999, ...
                'Bands', 'nbands', 'Attach pixels with 1 to 99999 bands.', reference);
            report = addIssue(report, obj.nbpr > 9999 || obj.nbpc > 9999, ...
                'Blocks', 'nbpr/nbpc', 'Use block dimensions that require at most 9999 blocks per axis.', reference);
            report = addIssue(report, obj.abpp > obj.nbpp || obj.nbpp == 0, ...
                'UnsupportedBits', 'abpp', 'ABPP must not exceed the native storage width.', reference);
            report = addIssue(report, strcmp(obj.pjust, 'R') && obj.abpp < obj.stats.bits, ...
                'PixelPrecision', 'abpp', 'ABPP cannot represent the largest right-justified sample.', reference);
            report = addIssue(report, strcmp(obj.pjust, 'L') && obj.nbpp-obj.abpp > obj.stats.trailing, ...
                'PixelPadding', 'abpp', 'Left-justified samples require zero low-order padding bits.', reference);
            report = addIssue(report, ~(strcmp(obj.pjust, 'R') || strcmp(obj.pjust, 'L')), ...
                'Justification', 'pjust', 'Use R or L justification.', reference);
            report = addIssue(report, obj.ialvl >= obj.idlvl, 'DisplayAttachment', ...
                'ialvl', 'An overlay display level must exceed its attachment level.', reference);
            report = addIssue(report, ~validCorners(obj.icords, obj.igeolo), 'Corners', ...
                'icords/igeolo', 'Supply valid D or G corner text, or omit both coordinate fields.', reference);
            mono = strcmp(obj.irep, 'MONO');
            rgb = strcmp(obj.irep, 'RGB');
            multi = strcmp(obj.irep, 'MULTI');
            report = addIssue(report, ~(mono || rgb || multi), 'Representation', ...
                'irep', 'Select MONO, RGB, or MULTI.', reference);
            report = addIssue(report, (mono && obj.bandCount ~= 1) || ...
                (rgb && obj.bandCount ~= 3) || (multi && obj.bandCount < 2), ...
                'RepresentationBands', 'irep', 'MONO requires one band; RGB three; MULTI at least two.', reference);
            monoCategories = {'BP','CAT','CCD','DTV','EO','EOVIS','FL','FP','HR', ...
                'HS','IR','ISAR','LEG','LWIR','MAP','MRI','MS','MWIR','NIR', ...
                'OP','PAN','RD','SAR','SL','SWIR','TI','UV','VD','VIS','VNIR','XRAY'};
            rgbCategories = {'CP','EOVIS','DTV','LEG','MAP','OP','PAT','VIS','CCD','MS'};
            multiCategories = {'EOVIS','HS','LWIR','MS','MWIR','NIR','SWIR','UV','VNIR','CAVIS'};
            categoryValid = (mono && any(strcmp(obj.icat, monoCategories))) || ...
                (rgb && any(strcmp(obj.icat, rgbCategories))) || ...
                (multi && any(strcmp(obj.icat, multiCategories)));
            report = addIssue(report, ~categoryValid, 'Category', 'icat', ...
                'Select an image category allowed for IREP by JBP Table 5.13-3.', reference);
            labels = obj.irepband; wavelengths = obj.isubcat;
            report = addIssue(report,numel(labels) ~= obj.bandCount || numel(wavelengths) ~= obj.bandCount, ...
                'BandMetadataCount','irepband/isubcat','Provide one label and wavelength per band, or use empty defaults.',reference);
            for k = 1:numel(labels), labels{k} = strtrim(char(labels{k})); end
            legal = false;
            if mono, legal = all(ismember(labels,{'M',''})); end
            if rgb, legal = numel(labels) == 3 && all(ismember({'R','G','B'},labels)); end
            if multi, legal = all(ismember(labels,{'M','R','G','B','N',''})); end
            legal = legal && sum(strcmp(labels,'R')) <= 1 && sum(strcmp(labels,'G')) <= 1 && sum(strcmp(labels,'B')) <= 1;
            report = addIssue(report,~legal,'BandRepresentation','irepband', ...
                'Use display labels allowed by IREP, with each RGB label at most once; LUT bands are unsupported.',reference);
            for k = 1:numel(wavelengths)
                if ~isnan(wavelengths(k))
                    encoded = str2double(char(bandDecimal(wavelengths(k),6)));
                    report = addIssue(report,wavelengths(k) ~= 0 && encoded == 0,'BandWavelengthPrecision','isubcat', ...
                        'A nonzero wavelength must remain nonzero in its six-byte decimal field.',reference);
                end
            end
        end
        function value = bytes(obj, extensions, overflow, user, userOverflow) %#codegen
            %BYTES - Serialize the image subheader
            %   VALUE = BYTES(OBJ) returns a validated uint8 subheader.
            %
            %   VALUE = BYTES(OBJ,EXTENSIONS) appends framed TRE bytes in the
            %   extended subheader. ImageSegment supplies its snapshots here.
            arguments
                obj (1,1) nfx.ImageHeader
                extensions (1,:) uint8 = zeros(1, 0, 'uint8')
                overflow {mustBeMetadata(overflow, 0, 999, 1), mustBeFinite} = 0
                user (1,:) uint8 = zeros(1,0,'uint8')
                userOverflow {mustBeMetadata(userOverflow,0,999,1), mustBeFinite} = 0
            end
            requireValid(validate(obj));
            area = extensionBytes(extensions, overflow, 99985);
            value = [uint8(obj.im) textField(obj.iid1, 10) ...
                textField(obj.idatim, 14) textField(obj.tgtid, 17) textField(obj.iid2, 80) ...
                uint8('U') textField('', 166) uint8('0') textField(obj.isorce, 42) ...
                decimalField(obj.nrows, 8, 0, false) decimalField(obj.ncols, 8, 0, false) ...
                uint8(obj.pvtype) textField(obj.irep, 8) textField(obj.icat, 8) ...
                decimalField(obj.abpp, 2, 0, false) textField(obj.pjust, 1) textField(obj.icords, 1)];
            if ~strcmp(obj.icords, ' '), value = [value textField(obj.igeolo, 60)]; end
            value = [value decimalField(obj.nicom, 1, 0, false) ...
                reshape(uint8(obj.comments).', 1, []) uint8('NC') decimalField(obj.nbands, 1, 0, false)];
            if obj.bandCount > 9
                value = [value decimalField(obj.bandCount, 5, 0, false)];
            end
            bandBytes = zeros(1, 13*obj.bandCount, 'uint8');
            labels = obj.irepband; wavelengths = obj.isubcat;
            for k = 1:obj.bandCount
                wavelength = textField('',6);
                if ~isnan(wavelengths(k)), wavelength = bandDecimal(wavelengths(k),6); end
                bandBytes(13*k-12:13*k) = [textField(labels{k}, 2) wavelength uint8('N   0')];
            end
            value = [value bandBytes uint8('0B') ...
                decimalField(obj.nbpr, 4, 0, false) decimalField(obj.nbpc, 4, 0, false) ...
                decimalField(obj.nppbh, 4, 0, false) decimalField(obj.nppbv, 4, 0, false) ...
                decimalField(obj.nbpp, 2, 0, false) decimalField(obj.idlvl, 3, 0, false) ...
                decimalField(obj.ialvl, 3, 0, false) decimalField(obj.iloc(1), 5, 0, false) ...
                decimalField(obj.iloc(2), 5, 0, false) uint8('1.0 ') extensionBytes(user,userOverflow,99985) area];
        end
    end
    methods (Access = ?nfx.ImageSegment)
        function obj = derive(obj, data, stats) %#codegen
            %DERIVE - Refresh all pixel-owned structural fields
            obj.nrows = size(data, 1);
            obj.ncols = size(data, 2);
            obj.bandCount = size(data, 3);
            obj.nbpp = 8;
            if isa(data, 'uint16'), obj.nbpp = 16; end
            obj.stats = stats;
        end
    end
    methods (Access = {?nfx.File, ?nfx.ImageSegment})
        function value = explicitLevel(obj) %#codegen
            %explicitLevel - Return the caller's display-level choice
            value = obj.displayLevel;
        end
        function obj = resolveLevel(obj, value) %#codegen
            %resolveLevel - Supply the default chosen by the containing file
            obj.defaultDisplayLevel = value;
        end
    end
end
