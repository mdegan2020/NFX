classdef (Sealed) MICIDA < nfx.TRE
    %MICIDA - Associate supplied camera UUIDs with MIIS core identifiers
    %   OBJ = MICIDA(cameras=CAMERAS) accepts row structs with CAMERA_ID
    %   and CAMERA_CORE_ID fields. Use MICIDA.camera to construct entries.
    %   Counts and text lengths derive from the supplied values.
    %
    %   Core identifiers use MISB ST 1204.3 textual format, including its
    %   check value. Supplied hexadecimal letter case is preserved. Camera
    %   and core identifiers must be unique within an instance, ignoring
    %   letter case. Use further instances for a large camera collection.
    %
    %   MICIDA.coreIdentifier formats supplied UUIDs and computes the check
    %   value. It does not generate UUIDs or establish their provenance.
    %
    %   See also TRE, CAMSDA, File

    properties (Constant)
        cetag = 'MICIDA'
        miis_core_id_version = 1
    end
    properties
        cameras {mustBeMIISCameras} = struct('camera_id',{},'camera_core_id',{})
    end
    properties (Dependent, SetAccess = private)
        num_camera_ids_in_tre
        core_id_length
    end
    methods
        function obj = MICIDA(options) %#codegen
            %MICIDA - Construct editable camera/core-identifier associations
            arguments
                options.?nfx.MICIDA
            end
            if isfield(options,'cameras'), obj.cameras = options.cameras; end
        end
        function value = get.num_camera_ids_in_tre(obj) %#codegen
            %get.num_camera_ids_in_tre - Count supplied camera associations
            value = numel(obj.cameras);
        end
        function value = get.core_id_length(obj) %#codegen
            %get.core_id_length - Count each core identifier's text bytes
            value = zeros(1,numel(obj.cameras));
            for k = 1:numel(value), value(k) = numel(char(obj.cameras(k).camera_core_id)); end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check core syntax, UUID forms, checksums and limits
            report = newReport('STDI-0002 Appendix AF MICIDA; MISB ST 1204.3');
            reference = 'STDI-0002-1 Appendix AF, AF5.3 and Table AF-4';
            count = obj.num_camera_ids_in_tre; lengths = obj.core_id_length;
            report = addIssue(report,count < 1 || count > 999,'CameraCount','cameras', ...
                'Each MICIDA instance requires 1 to 999 camera identifiers.',reference);
            report = addIssue(report,5+39*count+sum(lengths) > 99985,'TRELength','cameras', ...
                'Use further MICIDA instances when the payload exceeds 99985 bytes.',reference);
            cameraIDs = repmat(' ',count,36); coreIDs = repmat(' ',count,127);
            for k = 1:count
                entry = obj.cameras(k); field = sprintf('cameras(%.0f)',k);
                report = addIssue(report,~validUUID(entry.camera_id),'CameraUUID',[field '.camera_id'], ...
                    'Supply a camera UUID in 8-4-4-4-12 hexadecimal form.',reference);
                [valid,reason] = validMIIS(entry.camera_core_id);
                report = addIssue(report,~valid,'MIISCoreIdentifier',[field '.camera_core_id'], ...
                    reason,'MISB ST 1204.3, sections 7-8 and Appendices A-B');
                cameraIDs(k,:) = upper(char(textField(entry.camera_id,36)));
                coreIDs(k,:) = upper(char(textField(entry.camera_core_id,127)));
            end
            report = addIssue(report,size(unique(cameraIDs,'rows'),1) ~= count,'DuplicateCamera','cameras', ...
                'Each camera UUID occurs once in an instance.',reference);
            report = addIssue(report,size(unique(coreIDs,'rows'),1) ~= count,'DuplicateCoreIdentifier','cameras', ...
                'Every camera must have a unique MIIS core identifier.', ...
                'NGA.STND.0044, requirement 1.3-101');
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize derived counts and supplied identifier text
            requireValid(validate(obj));
            count = obj.num_camera_ids_in_tre; lengths = obj.core_id_length;
            value = zeros(1,5+39*count+sum(lengths),'uint8');
            value(1:5) = [uint8('01') decimalField(count,3,0,false)]; offset = 5;
            for k = 1:count
                entry = obj.cameras(k); width = 39+lengths(k);
                value(offset+(1:width)) = [textField(entry.camera_id,36) ...
                    decimalField(lengths(k),3,0,false) uint8(char(entry.camera_core_id))];
                offset = offset+width;
            end
        end
    end
    methods (Static)
        function value = camera(camera_id,camera_core_id) %#codegen
            %CAMERA - Supply one camera and its complete textual core ID
            arguments
                camera_id {mustBeAscii(camera_id,36)}
                camera_core_id {mustBeAscii(camera_core_id,127)}
            end
            value = struct('camera_id',camera_id,'camera_core_id',camera_core_id);
        end
        function value = coreIdentifier(usage,identifiers) %#codegen
            %coreIdentifier - Format supplied UUIDs with a MIIS check value
            %   TEXT = coreIdentifier(USAGE,IDENTIFIERS) takes a double usage
            %   byte and a row cell array of canonical 8-4-4-4-12 UUIDs.
            %   Present components are ordered sensor, platform, window;
            %   usage 2 instead identifies a single minor UUID. Output is
            %   uppercase version-01 text. UUIDs are never generated.
            %
            %   See also MICIDA.camera
            arguments
                usage {mustBeMetadata(usage,0,255,1),mustBeFinite}
                identifiers {mustBeMIISComponents}
            end
            count = numel(identifiers); hexadecimal = '0123456789ABCDEF';
            value = repmat(' ',1,7+40*count);
            value(1:5) = ['01' hexadecimal([floor(usage/16)+1 mod(usage,16)+1]) ':'];
            for k = 1:count
                uuid = upper(char(identifiers{k}));
                if ~validUUID(uuid), error('nfx:MIISCoreIdentifier','Supply canonical UUID text.'); end
                digits = uuid([1:8 10:13 15:18 20:23 25:36]); offset = 5+40*(k-1);
                for group = 1:8
                    value(offset+(group-1)*5+(1:4)) = digits((group-1)*4+(1:4));
                    if group < 8, value(offset+group*5) = '-'; end
                end
                if k < count, value(offset+40) = '/'; end
            end
            value(end-2) = ':';
            content = value(1:end-3);
            content = content((content >= '0' & content <= '9') | (content >= 'A' & content <= 'F'));
            value(end-1:end) = miisCheckValue(content);
            [valid,reason] = validMIIS(value);
            if ~valid, error('nfx:MIISCoreIdentifier','%s',reason); end
        end
    end
end

function mustBeMIISCameras(value) %#codegen
    %mustBeMIISCameras - Require strictly typed camera association rows
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            numel(fieldnames(value)) ~= 2 || ~all(isfield(value,{'camera_id','camera_core_id'}))
        error('nfx:MIISCameras','Supply row structs with camera_id and camera_core_id fields.');
    end
    for k = 1:numel(value)
        mustBeAscii(value(k).camera_id,36); mustBeAscii(value(k).camera_core_id,127);
    end
end

function mustBeMIISComponents(value) %#codegen
    %mustBeMIISComponents - Require one to three supplied UUID text values
    if ~iscell(value) || ~isrow(value) || isempty(value) || numel(value) > 3
        error('nfx:MIISComponents','Supply a row cell array containing one to three UUIDs.');
    end
    for k = 1:numel(value), mustBeAscii(value{k},36); end
end
