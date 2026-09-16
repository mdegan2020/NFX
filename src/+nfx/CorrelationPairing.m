classdef (Sealed) CorrelationPairing
    %CorrelationPairing - Associate a CSCSDB SPDCF with other sensor IDs
    %   OBJ = CorrelationPairing(Name=VALUE) supplies SPDCF_ID and a cell row
    %   SENSOR_ID containing 1-99 registered sensor IDs. The single value
    %   'ALL' selects every sensor pairing. IDs remain provider supplied.
    %   SensorErrorGroup uses this descriptor in its BASIC_PF/PL and POST_PF/PL
    %   groups, which determine the corresponding wire-field prefixes.
    %
    %   See also SensorErrorGroup, SPDCF, CSCSDB

    properties
        spdcf_id {mustBeMetadata(spdcf_id,1,99,1)} = NaN
        sensor_id {mustBeSensorNames} = cell(1,0)
    end
    properties (Dependent, SetAccess = private)
        byte_length
    end
    methods
        function obj = CorrelationPairing(options) %#codegen
            %CorrelationPairing - Construct editable correlation associations
            arguments
                options.?nfx.CorrelationPairing
            end
            if isfield(options,'spdcf_id'), obj.spdcf_id = options.spdcf_id; end
            if isfield(options,'sensor_id'), obj.sensor_id = options.sensor_id; end
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count the ID, pair count and sensor names
            value = 4+6*numel(obj.sensor_id);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check explicit sensor names or a sole ALL selector
            report = newReport('CSCSDB sensor pairing');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            count = numel(obj.sensor_id);
            report = addIssue(report,isnan(obj.spdcf_id) || count < 1 || count > 99, ...
                'CorrelationPairing','spdcf_id/sensor_id','Supply a SPDCF ID and 1-99 sensor identifiers.',reference);
            names = repmat(' ',count,6);
            for k = 1:count
                text = strtrim(char(obj.sensor_id{k})); names(k,1:numel(text)) = text;
                report = addIssue(report,isempty(text) || (strcmp(text,'ALL') && count ~= 1), ...
                    'SensorPairingName','sensor_id','Use nonblank registered sensor IDs, or ALL by itself.',reference);
            end
            report = addIssue(report,size(unique(names,'rows'),1) ~= count,'DuplicateSensorPairing','sensor_id', ...
                'Each sensor appears once in the pairing list.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the SPDCF ID and ordered sensor identifiers
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1:4) = [decimalField(obj.spdcf_id,2,0,false) decimalField(numel(obj.sensor_id),2,0,false)];
            for k = 1:numel(obj.sensor_id), value(4+(k-1)*6+(1:6)) = textField(obj.sensor_id{k},6); end
        end
    end
end

function mustBeSensorNames(value) %#codegen
    %mustBeSensorNames - Require unconverted sensor ID text in a cell row
    if ~iscell(value) || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:SensorNames','Expected a cell row of sensor identifiers.');
    end
    for k = 1:numel(value), mustBeAscii(value{k},6); end
end
