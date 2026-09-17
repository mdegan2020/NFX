classdef (Sealed) CAMSDA < nfx.TRE
    %CAMSDA - Camera-set layout and layer definitions
    %   OBJ = CAMSDA(camera_sets=SETS) accepts row structs containing a
    %   cameras field. Each cameras value is a row struct array with fields
    %   camera_id, camera_desc, layer_id, idlvl, ialvl, iloc, nrows, and ncols.
    %
    %   Counts derive from the supplied arrays. For a partial collection,
    %   supply FIRST_CAMERA_SET_IN_TRE and the collection's NUM_CAMERA_SETS.
    %   Automatic NUM_CAMERA_SETS assumes the last supplied set is the final
    %   set. Camera UUIDs are supplied by the caller and are never generated.
    %
    %   See also TRE, File, MIMCSA

    properties (Constant)
        cetag = 'CAMSDA'
    end
    properties
        camera_sets {mustBeCameraSets} = struct('cameras', {})
        first_camera_set_in_tre {mustBeMetadata(first_camera_set_in_tre, 1, 999, 1), mustBeFinite} = 1
    end
    properties (Dependent)
        num_camera_sets
    end
    properties (Dependent, SetAccess = private)
        num_camera_sets_in_tre
        num_cameras_in_set
    end
    properties (Access = private)
        totalSets = NaN
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable CAMSDA value
            %   [OBJ, OK, STATUS] = nfx.CAMSDA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also CAMSDA, CAMSDA.payload
            arguments
                data
            end
            obj = nfx.CAMSDA();
            reader = nfx.internal.TREReader(data);
            [total, reader] = reader.number(3, 1, 999, true);
            [count, reader] = reader.count(3, 187, 534);
            [first, reader] = reader.number(3, 1, 999, true);
            camera = struct('camera_id', '', 'camera_desc', '', 'layer_id', '', ...
                'idlvl', NaN, 'ialvl', NaN, 'iloc', [0 0], ...
                'nrows', NaN, 'ncols', NaN);
            sets = repmat(struct('cameras', repmat(camera, 1, 0)), 1, count);
            for k = 1:count
                [number, reader] = reader.count(3, 184, 543);
                cameras = repmat(camera, 1, number);
                for j = 1:number
                    [cameras(j).camera_id, reader] = reader.text(36);
                    [cameras(j).camera_desc, reader] = reader.text(80);
                    [cameras(j).layer_id, reader] = reader.text(36);
                    [cameras(j).idlvl, reader] = reader.number(3, 1, 999, true);
                    [cameras(j).ialvl, reader] = reader.number(3, 0, 998, true);
                    [cameras(j).iloc, reader] = reader.numbers(2, 5, 0, 99999, true);
                    [cameras(j).nrows, reader] = reader.number(8, 1, 99999999, true);
                    [cameras(j).ncols, reader] = reader.number(8, 1, 99999999, true);
                end
                sets(k).cameras = cameras;
            end
            if reader.ok
                obj.num_camera_sets = total;
                obj.first_camera_set_in_tre = first;
                obj.camera_sets = sets;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.CAMSDA());
        end
    end
    methods
        function obj = CAMSDA(options) %#codegen
            %CAMSDA - Construct editable camera-set definitions
            arguments
                options.?nfx.CAMSDA
            end
            if isfield(options, 'camera_sets'), obj.camera_sets = options.camera_sets; end
            if isfield(options, 'first_camera_set_in_tre'), obj.first_camera_set_in_tre = options.first_camera_set_in_tre; end
            if isfield(options, 'num_camera_sets'), obj.num_camera_sets = options.num_camera_sets; end
        end
        function value = get.num_camera_sets(obj) %#codegen
            %get.num_camera_sets - Resolve supplied or inferred total set count
            value = obj.totalSets;
            if isnan(value), value = obj.first_camera_set_in_tre+obj.num_camera_sets_in_tre-1; end
        end
        function obj = set.num_camera_sets(obj, value) %#codegen
            %set.num_camera_sets - Supply a collection total; NaN restores inference
            mustBeMetadata(value,1,999,true);
            obj.totalSets = value;
        end
        function value = get.num_camera_sets_in_tre(obj) %#codegen
            %get.num_camera_sets_in_tre - Count supplied camera sets
            value = numel(obj.camera_sets);
        end
        function value = get.num_cameras_in_set(obj) %#codegen
            %get.num_cameras_in_set - Count cameras in each supplied set
            value = zeros(1,obj.num_camera_sets_in_tre);
            for k = 1:numel(value), value(k) = numel(obj.camera_sets(k).cameras); end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check set counts, UUIDs and supplied camera layout
            report = newReport('STDI-0002 Appendix AF CAMSDA');
            reference = 'STDI-0002-1 Appendix AF, AF5.2 and Table AF-3';
            counts = obj.num_cameras_in_set;
            report = addIssue(report, obj.num_camera_sets < 1 || obj.num_camera_sets > 999 || ...
                obj.num_camera_sets_in_tre < 1 || obj.num_camera_sets_in_tre > 534 || ...
                obj.first_camera_set_in_tre+obj.num_camera_sets_in_tre-1 > obj.num_camera_sets, ...
                'CameraSetCount', 'camera_sets', 'The included set range must fit the declared collection.', reference);
            report = addIssue(report, any(counts < 1 | counts > 543), 'CameraCount', ...
                'camera_sets.cameras', 'Each camera set permits 1 to 543 cameras.', reference);
            report = addIssue(report, 9+3*numel(counts)+184*sum(counts) > 99985, ...
                'TRELength', 'camera_sets', 'Use further CAMSDA instances to describe the remaining sets.', reference);
            identifiers = repmat(' ',sum(counts),36);
            index = 0;
            for k = 1:numel(obj.camera_sets)
                for m = 1:numel(obj.camera_sets(k).cameras)
                    camera = obj.camera_sets(k).cameras(m);
                    field = sprintf('camera_sets(%d).cameras(%d)',k,m);
                    report = addIssue(report, ~validUUID(camera.camera_id), 'CameraUUID', ...
                        [field '.camera_id'], 'Supply a valid 8-4-4-4-12 camera UUID.', reference);
                    report = addIssue(report, isempty(strtrim(char(camera.layer_id))), 'Required', ...
                        [field '.layer_id'], 'Supply a nonblank layer identifier.', reference);
                    report = addIssue(report, any(isnan([camera.idlvl camera.ialvl camera.nrows camera.ncols])), ...
                        'Required', field, 'Supply every camera layout value.', reference);
                    report = addIssue(report, camera.ialvl >= camera.idlvl, 'DisplayAttachment', ...
                        [field '.ialvl'], 'Camera display level must exceed its attachment level.', reference);
                    index = index+1;
                    identifiers(index,:) = lower(char(textField(camera.camera_id,36)));
                end
            end
            report = addIssue(report, size(unique(identifiers,'rows'),1) ~= size(identifiers,1), ...
                'DuplicateCamera', 'camera_sets', 'Each camera UUID belongs to one camera set.', ...
                'NGA.STND.0044, requirement 1.0-03');
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode fixed-size camera definitions and derived counts
            requireValid(validate(obj));
            counts = obj.num_cameras_in_set;
            value = zeros(1,9+3*numel(counts)+184*sum(counts),'uint8');
            value(1:9) = [decimalField(obj.num_camera_sets,3,0,false) ...
                decimalField(obj.num_camera_sets_in_tre,3,0,false) ...
                decimalField(obj.first_camera_set_in_tre,3,0,false)];
            offset = 9;
            for k = 1:numel(obj.camera_sets)
                value(offset+1:offset+3) = decimalField(counts(k),3,0,false);
                offset = offset+3;
                for m = 1:counts(k)
                    camera = obj.camera_sets(k).cameras(m);
                    value(offset+1:offset+184) = [textField(camera.camera_id,36) ...
                        textField(camera.camera_desc,80) textField(camera.layer_id,36) ...
                        decimalField(camera.idlvl,3,0,false) decimalField(camera.ialvl,3,0,false) ...
                        decimalField(camera.iloc(1),5,0,false) decimalField(camera.iloc(2),5,0,false) ...
                        decimalField(camera.nrows,8,0,false) decimalField(camera.ncols,8,0,false)];
                    offset = offset+184;
                end
            end
        end
    end
end

function mustBeCameraSets(value) %#codegen
    %mustBeCameraSets - Require concrete set and camera structs with strict types
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~isfield(value,'cameras') || numel(fieldnames(value)) ~= 1
        error('nfx:CameraSets', 'Supply camera-set row structs with a cameras field.');
    end
    for k = 1:numel(value)
        cameras = value(k).cameras;
        if ~isstruct(cameras) || ~(isrow(cameras) || isempty(cameras)) || ...
                ~all(isfield(cameras,{'camera_id','camera_desc','layer_id','idlvl','ialvl','iloc','nrows','ncols'})) || ...
                numel(fieldnames(cameras)) ~= 8
            error('nfx:CameraSets', 'Supply camera UUID, description, layer and layout fields.');
        end
        for m = 1:numel(cameras)
            camera = cameras(m);
            mustBeAscii(camera.camera_id,36);
            mustBeAscii(camera.camera_desc,80);
            mustBeAscii(camera.layer_id,36);
            mustBeMetadata(camera.idlvl,1,999,true);
            mustBeMetadata(camera.ialvl,0,998,true);
            mustBeLocation(camera.iloc);
            mustBeMetadata(camera.nrows,1,99999999,true);
            mustBeMetadata(camera.ncols,1,99999999,true);
        end
    end
end
