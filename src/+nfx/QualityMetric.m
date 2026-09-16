classdef (Sealed) QualityMetric
    %QualityMetric - Describe a predicted, tasked or measured image quality value
    %   OBJ = QualityMetric(Name=VALUE) uses the current CSEXRB registry.
    %   QUALITY_METRIC_NAME selects a case-sensitive registered name.
    %   QUALITY_METRIC_VALUE is a scalar double for numeric quantities,
    %   or short ASCII text for names, codes and enumerated values.
    %   Units derive from the selected name, including the ECS-A micro sign.
    %
    %   Numeric values use up to 21 bytes. BCS-N values use decimal notation;
    %   BCS-A quantities may use scientific notation. Nonzero underflow fails.
    %   Additional registered names require a verified definition update.
    %
    %   See also CSEXRB, ExploitationInfo, ImagingOperation

    properties
        quality_metric_name {mustBeAscii(quality_metric_name,25)} = ''
        quality_metric_value {mustBeExploitationValue} = NaN
        quality_metric_type {mustBeAscii(quality_metric_type,1)} = ''
    end
    properties (Dependent, SetAccess = private)
        quality_metric_unit
    end
    methods
        function obj = QualityMetric(options) %#codegen
            %QualityMetric - Construct editable value metadata
            arguments
                options.?nfx.QualityMetric
            end
            if isfield(options,'quality_metric_name'), obj.quality_metric_name = options.quality_metric_name; end
            if isfield(options,'quality_metric_value'), obj.quality_metric_value = options.quality_metric_value; end
            if isfield(options,'quality_metric_type'), obj.quality_metric_type = options.quality_metric_type; end
        end
        function value = get.quality_metric_unit(obj) %#codegen
            %get.quality_metric_unit - Derive the required registered unit
            value = exploitationDefinition(obj.quality_metric_name,true);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the registered name, value and numeric encoding
            report = newReport('CSEXRB QualityMetric');
            reference = 'STDI-0002-2 Appendix M, Tables M.6-1c/M.6-1d';
            [~,valid] = exploitationValue(obj.quality_metric_name,obj.quality_metric_value,true);
            report = addIssue(report,~valid,'ExploitationValue','quality_metric_name/quality_metric_value', ...
                'Supply a current registered name and a correctly typed, in-range encodable value.',reference);
            report = addIssue(report,~any(strcmp(obj.quality_metric_type,{'P','T','M'})), ...
                'MetricType','quality_metric_type','Use P (predicted), T (tasked), or M (measured).',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the name, required unit and typed value with lengths
            requireValid(validate(obj));
            name = uint8(char(obj.quality_metric_name)); unit = uint8(obj.quality_metric_unit);
            data = exploitationValue(obj.quality_metric_name,obj.quality_metric_value,true);
            value = [decimalField(numel(name),2,0,false) name decimalField(numel(unit),2,0,false) unit ...
                uint8(char(obj.quality_metric_type)) decimalField(numel(data),2,0,false) data];
        end
    end
end
