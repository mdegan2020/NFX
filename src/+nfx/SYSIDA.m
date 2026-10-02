classdef (Sealed) SYSIDA < nfx.TRE
    %SYSIDA - Platform, payload and sensor identification
    %   OBJ = SYSIDA(Name=VALUE) supplies one or more unpadded identifiers.
    %   The caller supplies registered identifiers; no identity is invented.
    %
    %   SYSIDA functions:
    %       deserialize - Decode an independently editable value
    %       validate    - Check lengths and non-padded identifiers
    %       payload     - Encode identifiers and derived lengths
    %
    %   SYSIDA properties:
    %       cetag       - Constant tag identifier
    %       platform_id - Collection platform identifier
    %       payload_id  - Collection payload identifier
    %       sensor_id   - Sensor identifier
    %
    %   See also TRE, CSDIDA, CSEXRB

    properties (Constant)
        cetag = 'SYSIDA' % Registered tag identifier
    end
    properties
        platform_id {mustBeECS(platform_id, 999)} = '' % Platform identifier
        payload_id {mustBeECS(payload_id, 999)} = '' % Payload identifier
        sensor_id {mustBeECS(sensor_id, 999)} = '' % Sensor identifier
    end
    methods
        function obj = SYSIDA(options) %#codegen
            arguments
                options.?nfx.SYSIDA
            end
            if isfield(options, 'platform_id')
                obj.platform_id = options.platform_id;
            end
            if isfield(options, 'payload_id')
                obj.payload_id = options.payload_id;
            end
            if isfield(options, 'sensor_id')
                obj.sensor_id = options.sensor_id;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AS, Table AS.5-1 (2025-02)';
            report = newReport(reference);
            ids = {char(obj.platform_id), char(obj.payload_id), ...
                char(obj.sensor_id)};
            report = addIssue(report, all(cellfun(@isempty, ids)), ...
                'Required', 'identifiers', 'Supply at least one identifier.', ...
                reference);
            for k = 1:3
                value = ids{k};
                report = addIssue(report, ~isempty(value) && ...
                    (value(1) == ' ' || value(end) == ' '), ...
                    'Padding', 'identifiers', ...
                    'Identifiers must not have leading or trailing spaces.', ...
                    reference);
            end
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            ids = {char(obj.platform_id), char(obj.payload_id), ...
                char(obj.sensor_id)};
            for k = 1:3
                data = [data decimalField(numel(ids{k}), 3, 0, false) ...
                    uint8(ids{k})]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent system identification
            %   OBJ = deserialize(DATA) decodes a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.SYSIDA();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(3, 1, 999);
            [platform, reader] = reader.text(count, false, true);
            [count, reader] = reader.count(3, 1, 999);
            [payload, reader] = reader.text(count, false, true);
            [count, reader] = reader.count(3, 1, 999);
            [sensor, reader] = reader.text(count, false, true);
            if reader.ok
                obj.platform_id = platform;
                obj.payload_id = payload;
                obj.sensor_id = sensor;
            end
            [obj, ok, status] = finishTREDecode(obj, reader, nfx.SYSIDA());
        end
    end
end
