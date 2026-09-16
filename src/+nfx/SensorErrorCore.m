classdef (Sealed) SensorErrorCore
    %SensorErrorCore - Group CSCSDB sensor errors by their coordinate frames
    %   OBJ = SensorErrorCore(Name=VALUE) sets REF_FRAME_POSITION and
    %   REF_FRAME_ATTITUDE using codes 1-6: ECF, sensor, orbital, TCEF, ECI,
    %   and SCEF. GROUPS holds 1-7 ordered SensorErrorGroup value objects.
    %   NFX preserves supplied reference frames and error allocations.
    %
    %   See also CSCSDB, SensorErrorGroup

    properties
        ref_frame_position {mustBeMetadata(ref_frame_position,1,6,1)} = NaN
        ref_frame_attitude {mustBeMetadata(ref_frame_attitude,1,6,1)} = NaN
        groups {mustBeGLASObjects(groups,'nfx.SensorErrorGroup')} = nfx.SensorErrorGroup.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        num_groups
        parameter_count
        byte_length
    end
    methods
        function obj = SensorErrorCore(options) %#codegen
            %SensorErrorCore - Construct editable frame and error-group metadata
            arguments
                options.?nfx.SensorErrorCore
            end
            if isfield(options,'ref_frame_position'), obj.ref_frame_position = options.ref_frame_position; end
            if isfield(options,'ref_frame_attitude'), obj.ref_frame_attitude = options.ref_frame_attitude; end
            if isfield(options,'groups'), obj.groups = options.groups; end
        end
        function value = get.num_groups(obj) %#codegen
            %get.num_groups - Derive the independent error-group count
            value = numel(obj.groups);
        end
        function value = get.parameter_count(obj) %#codegen
            %get.parameter_count - Count every group's allocated parameters
            value = 0;
            for k = 1:obj.num_groups, value = value+obj.groups(k).parameter_count; end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count frame codes, group count and group bodies
            value = 3;
            for k = 1:obj.num_groups, value = value+obj.groups(k).byte_length; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check known frames and each supplied covariance group
            report = newReport('CSCSDB SensorErrorCore');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,any(isnan([obj.ref_frame_position obj.ref_frame_attitude])), ...
                'Required','ref_frame_position/attitude','Supply both covariance reference frame codes.',reference);
            report = addIssue(report,obj.num_groups < 1 || obj.num_groups > 7,'CoreGroupCount','groups', ...
                'A core contains 1-7 independent sensor error groups.',reference);
            for k = 1:obj.num_groups
                report = mergeReport(report,validate(obj.groups(k)),sprintf('groups(%.0f)',k));
            end
        end
        function value = references(obj) %#codegen
            %REFERENCES - Collect correlation identifiers in group order
            value = zeros(1,0);
            for k = 1:obj.num_groups, value = [value references(obj.groups(k))]; end %#ok<AGROW>
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the two frames and ordered sensor-error groups
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1:3) = [decimalField(obj.ref_frame_position,1,0,false) ...
                decimalField(obj.ref_frame_attitude,1,0,false) decimalField(obj.num_groups,1,0,false)]; at = 3;
            for k = 1:obj.num_groups
                data = bytes(obj.groups(k)); value(at+(1:numel(data))) = data; at = at+numel(data);
            end
        end
    end
end
