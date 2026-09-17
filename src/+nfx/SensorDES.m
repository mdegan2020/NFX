classdef (Abstract) SensorDES
    %SensorDES - Typed construction and snapshot contract for GLAS/GFM DESs
    %   Concrete subclasses hold editable metadata and validate their format.
    %   SEGMENT captures a verified nfx.DESSegment value for File attachment.
    %   UUID identifies the whole DES. AISDLVL lists current image display
    %   levels, or ALL_IMAGES=true associates the DES with every image.
    %   Optional ASSOC_ELEM_UUID entries can identify external elements.
    %
    %   DESVER selects a supported definition version. DESCLAS must be U.
    %   Subheader counts and reserved lengths derive from supplied metadata.
    %
    %   See also CSATTB, CSEPHB, CSSFAB, CSCSDB, DESSegment

    properties (Abstract, Constant)
        desid
    end
    properties
        uuid {mustBeAscii(uuid,36)} = ''
        aisdlvl {mustBeSensorLevels} = zeros(1,0)
        all_images {mustBeLogicalScalar} = false
        assoc_elem_uuid {mustBeSensorUUIDs} = cell(1,0)
        desver {mustBeMetadata(desver,1,99,1)} = 2
        desclas {mustBeAscii(desclas,1)} = 'U'
    end
    methods (Abstract)
        report = validate(obj)
        value = payload(obj)
    end
    methods
        function header = subheader(obj) %#codegen
            %SUBHEADER - Encode validated common GLAS/GFM association metadata
            requireValid(headerReport(obj));
            if obj.all_images
                count = uint8('ALL');
            else
                count = decimalField(numel(obj.aisdlvl),3,0,false);
            end
            value = [textField(obj.uuid,36) count];
            for k = 1:numel(obj.aisdlvl)
                value = [value decimalField(obj.aisdlvl(k),3,0,false)]; %#ok<AGROW>
            end
            value = [value decimalField(numel(obj.assoc_elem_uuid),3,0,false)];
            for k = 1:numel(obj.assoc_elem_uuid)
                value = [value textField(obj.assoc_elem_uuid{k},36)]; %#ok<AGROW>
            end
            header = nfx.DESHeader(desid=obj.desid,desver=obj.desver,desclas=obj.desclas, ...
                desshf=[value uint8('0000')]);
        end
        function value = segment(obj) %#codegen
            %SEGMENT - Capture a validated sensor DES as immutable proof bytes
            %   The returned DESSegment retains its ordinary DATA/HEADER API.
            %   Changes to those bytes invalidate its typed verification;
            %   edit this sensor descriptor and capture a new segment instead.
            requireValid(validate(obj));
            value = nfx.DESSegment.fromSensor(payload(obj),subheader(obj));
        end
    end
    methods (Static, Access = protected)
        function [obj, reader] = readHeader(obj, header) %#codegen
            %readHeader - Validate concrete DES identity and common associations
            reader = nfx.internal.TREReader(uint8(0));
            if ~isa(header, 'nfx.DESHeader') || ~isscalar(header) || ...
                    ~strcmp(header.desid, obj.desid) || ~strcmp(header.desclas, 'U')
                reader = reader.fail('InvalidHeader', ...
                    'Supply the matching unclassified DESHeader.'); return
            end
            obj.desver = header.desver; obj.desclas = header.desclas;
            reader = nfx.internal.TREReader(header.desshf);
            [text, reader] = reader.text(36, false);
            if reader.ok, obj.uuid = text; end
            [text, reader] = reader.text(3, false);
            if reader.ok && strcmp(text, 'ALL')
                obj.all_images = true;
            elseif reader.ok
                count = str2double(text);
                if any(text < '0' | text > '9') || count < 1 || count > 998
                    reader = reader.fail('InvalidHeader', 'Invalid associated image count.');
                else
                    [levels, reader] = reader.numbers(count, 3, 1, 999, true);
                    if reader.ok, obj.aisdlvl = levels; end
                end
            end
            [count, reader] = reader.count(3, 36, 276);
            ids = cell(1, count);
            for k = 1:count, [ids{k}, reader] = reader.text(36, false); end
            if reader.ok, obj.assoc_elem_uuid = ids; end
            reader = reader.literal('0000'); reader = reader.finish();
            if reader.ok
                report = obj.headerReport();
                if ~report.valid
                    reader = reader.fail('InvalidHeader', report.issues(1).message);
                elseif ~isequal(obj.subheader(), header)
                    reader = reader.fail('NoncanonicalHeader', ...
                        'DES subheader is outside the supported NFX encoding.');
                end
            end
        end
    end
    methods (Access = protected)
        function report = headerReport(obj) %#codegen
            %headerReport - Validate shared metadata without guessing ownership
            report = newReport('GLAS/GFM DES subheader');
            reference = 'STDI-0002-2 Appendix M, Tables M.6-4 through M.6-7';
            report = addIssue(report,~validUUID(obj.uuid),'DESUUID','uuid','Supply a canonical DES UUID.',reference);
            count = numel(obj.aisdlvl);
            report = addIssue(report,(obj.all_images && count ~= 0) || ...
                (~obj.all_images && (count < 1 || count > 998)), ...
                'AssociatedImages','aisdlvl/all_images','Use ALL_IMAGES with no list, or 1-998 display levels.',reference);
            report = addIssue(report,numel(unique(obj.aisdlvl)) ~= count,'DuplicateDisplayLevel','aisdlvl', ...
                'Associate each image display level once.',reference);
            report = addIssue(report,numel(obj.assoc_elem_uuid) > 276,'AssociatedElements','assoc_elem_uuid', ...
                'At most 276 associated element UUIDs fit the specified count.',reference);
            for k = 1:numel(obj.assoc_elem_uuid)
                report = addIssue(report,~validUUID(obj.assoc_elem_uuid{k}),'ElementUUID','assoc_elem_uuid', ...
                    'Supply canonical UUIDs for associated elements.',reference);
                for j = 1:k-1
                    report = addIssue(report,strcmpi(obj.assoc_elem_uuid{k},obj.assoc_elem_uuid{j}), ...
                        'DuplicateElement','assoc_elem_uuid','Associate each element UUID once.',reference);
                end
            end
            report = addIssue(report,isnan(obj.desver),'Required','desver','Supply the supported definition version.',reference);
            report = addIssue(report,~strcmp(obj.desclas,'U'),'UnsupportedClassification','desclas', ...
                'Supply an explicit U classification.',reference);
            report = addIssue(report,246+3*count+36*numel(obj.assoc_elem_uuid) > 9998, ...
                'SubheaderLength','aisdlvl/assoc_elem_uuid','The complete DES subheader must fit 9998 bytes.',reference);
        end
    end
end

function mustBeSensorLevels(value) %#codegen
    %mustBeSensorLevels - Require exact display levels in a double row
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || ...
            any(~isfinite(value) | fix(value) ~= value | value < 1 | value > 999)
        error('nfx:SensorLevels','Expected a double row of image display levels 1-999.');
    end
end

function mustBeSensorUUIDs(value) %#codegen
    %mustBeSensorUUIDs - Require a cell row of UUID text
    if ~iscell(value) || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:SensorUUIDs','Expected a cell row of UUIDs.');
    end
    for k = 1:numel(value), mustBeAscii(value{k},36); end
end
