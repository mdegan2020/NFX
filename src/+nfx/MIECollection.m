classdef MIECollection
    %MIECollection - Assemble original-resolution uncompressed motion files
    %   OBJ = MIECollection(base_name=NAME,header=HEADER,layers=LAYERS,
    %   camera_sets=SETS,camera_ids=IDS,intervals=INTERVALS) supplies collection
    %   definitions using MIMCSA, CAMSDA, MICIDA and TMINTA value arrays.
    %   Append MotionBlock values with +, or supply BLOCKS at construction.
    %
    %   PLAN(OBJ) returns named NITF File values for inspection. Counts,
    %   camera-to-segment references, file groups and manifest text derive
    %   from the complete collection. WRITE(OBJ,FOLDER) preflights every file
    %   before publication and writes the manifest last.
    %
    %   FILE_TEMPLATES is a row struct array with CAMERA_SET_INDEX,
    %   TIME_INTERVAL_INDEX and FILE fields. Each FILE supplies a complete
    %   header and optional TRE/text/DES snapshots, without image segments
    %   or collection-definition TREs. Unspecified groups use HEADER.
    %   MANIFEST_TEMPLATE optionally supplies one File for manifest metadata.
    %
    %   QUICKLOOKS contains supplied still images with MTIMSA associations
    %   and selection comments. All are copied into the generated manifest.
    %   Set MANIFEST_MTIMFA=true to include every block mapping there too.
    %
    %   This profile preserves uint8/uint16 pixels and supplied metadata.
    %   It performs no compression, resampling or sensor-model evaluation.
    %
    %   See also MotionBlock, File, MTIMSA

    properties
        base_name {mustBeAscii(base_name,240)} = ''
        header (1,1) nfx.FileHeader = nfx.FileHeader()
        layers {mustBeMIEObjects(layers,'nfx.MIMCSA')} = nfx.MIMCSA.empty(1,0)
        camera_sets {mustBeMIEObjects(camera_sets,'nfx.CAMSDA')} = nfx.CAMSDA.empty(1,0)
        camera_ids {mustBeMIEObjects(camera_ids,'nfx.MICIDA')} = nfx.MICIDA.empty(1,0)
        intervals {mustBeMIEObjects(intervals,'nfx.TMINTA')} = nfx.TMINTA.empty(1,0)
        blocks {mustBeMIEObjects(blocks,'nfx.MotionBlock')} = nfx.MotionBlock.empty(1,0)
        quicklooks {mustBeMIEObjects(quicklooks,'nfx.ImageSegment')} = nfx.ImageSegment.empty(1,0)
        file_templates {mustBeMIETemplates} = struct('camera_set_index',{},'time_interval_index',{},'file',{})
        manifest_template {mustBeMIEObjects(manifest_template,'nfx.File')} = nfx.File.empty(1,0)
        manifest {mustBeLogicalScalar} = true
        manifest_mtimfa {mustBeLogicalScalar} = false
    end
    methods
        function obj = MIECollection(options) %#codegen
            %MIECollection - Construct editable collection definitions
            arguments
                options.?nfx.MIECollection
            end
            if isfield(options,'base_name'), obj.base_name = options.base_name; end
            if isfield(options,'header'), obj.header = options.header; end
            if isfield(options,'layers'), obj.layers = options.layers; end
            if isfield(options,'camera_sets'), obj.camera_sets = options.camera_sets; end
            if isfield(options,'camera_ids'), obj.camera_ids = options.camera_ids; end
            if isfield(options,'intervals'), obj.intervals = options.intervals; end
            if isfield(options,'blocks'), obj.blocks = options.blocks; end
            if isfield(options,'quicklooks'), obj.quicklooks = options.quicklooks; end
            if isfield(options,'file_templates'), obj.file_templates = options.file_templates; end
            if isfield(options,'manifest_template'), obj.manifest_template = options.manifest_template; end
            if isfield(options,'manifest'), obj.manifest = options.manifest; end
            if isfield(options,'manifest_mtimfa'), obj.manifest_mtimfa = options.manifest_mtimfa; end
        end
        function obj = plus(obj,block) %#codegen
            %PLUS - Append a supplied temporal block by value
            arguments
                obj (1,1) nfx.MIECollection
                block (1,1) nfx.MotionBlock
            end
            obj.blocks(end+1) = block;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the entire planned collection before output
            arguments
                obj (1,1) nfx.MIECollection
            end
            [~,report] = completePlan(obj);
        end
        function files = plan(obj) %#codegen
            %PLAN - Return validated filename and File values without writing
            %   FILES is a struct row with filename, file, camera_set_index,
            %   time_interval_index and manifest fields, in filename-list
            %   order. Changes to a returned File leave OBJ unchanged.
            arguments
                obj (1,1) nfx.MIECollection
            end
            [files,report] = completePlan(obj); requireValid(report);
        end
        function published = write(obj,folder,options) %#codegen
            %WRITE - Validate all outputs, then publish files and the manifest
            %   PATHS = WRITE(OBJ,FOLDER) returns published paths in write
            %   order. Overwrite=true permits per-file replacement.
            %   A later failure reports the paths already published; output
            %   protection applies per file, not to the collection as a unit.
            arguments
                obj (1,1) nfx.MIECollection
                folder {mustBeTextScalar,mustBeNonempty}
                options.Overwrite {mustBeLogicalScalar} = false
            end
            files = plan(obj); folder = char(folder);
            if ~isfolder(folder), error('nfx:Destination','The collection folder must already exist.'); end
            paths = cell(1,numel(files));
            for k = 1:numel(files)
                paths{k} = fullfile(folder,files(k).filename);
                if isfolder(paths{k}), error('nfx:Destination','A collection destination is a directory: %s',paths{k}); end
                if isfile(paths{k}) && ~options.Overwrite
                    error('nfx:Exists','A collection destination exists: %s',paths{k});
                end
            end
            order = [find(~[files.manifest]) find([files.manifest])];
            published = publishCollection(files,paths,order,options.Overwrite);
        end
    end
    methods (Access = private)
        function [files,report] = completePlan(obj) %#codegen
            %completePlan - Bind all collection contexts before file preflight
            [files,report] = mieCollectionPlan(obj);
            report.scope = 'NFX-MIE-NC1 complete collection';
            if ~report.valid, return; end
            inputs = collectionContextInputs(files);
            for k = 1:numel(files)
                if inputs(k).required, files(k).file = bindContext(files(k).file,inputs(k)); end
                report = mergeReport(report,validate(files(k).file),sprintf('files(%.0f).',k));
            end
        end
    end
end

function mustBeMIETemplates(value) %#codegen
    %mustBeMIETemplates - Require indexed file templates without conversion
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~all(isfield(value,{'camera_set_index','time_interval_index','file'})) || numel(fieldnames(value)) ~= 3
        error('nfx:MIETemplates','Supply camera_set_index/time_interval_index/file row structs.');
    end
    for k = 1:numel(value)
        mustBeMetadata(value(k).camera_set_index,1,999,1);
        mustBeMetadata(value(k).time_interval_index,1,999999,1);
        if ~isa(value(k).file,'nfx.File') || ~isscalar(value(k).file)
            error('nfx:MIETemplates','Each template must contain one NFX File.');
        end
    end
end
