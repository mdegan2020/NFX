classdef (Sealed) CollectionCriterion
    %CollectionCriterion - Describe one tasked collection constraint
    %   OBJ = CollectionCriterion(Name=VALUE) uses the current CSEXRB registry.
    %   COLLECT_CRITERIA_NAME selects a case-sensitive registered name.
    %   COLLECT_CRITERIA_VALUE is a scalar double for numeric quantities,
    %   or short ASCII text for names, codes and enumerated values.
    %   Units derive from the selected name, including the ECS-A micro sign.
    %
    %   Numeric values use up to 21 bytes. BCS-N values use decimal notation;
    %   BCS-A quantities may use scientific notation. Nonzero underflow fails.
    %   Additional registered names require a verified definition update.
    %
    %   See also CSEXRB, ExploitationInfo, ImagingOperation

    properties
        collect_criteria_name {mustBeAscii(collect_criteria_name,25)} = ''
        collect_criteria_value {mustBeExploitationValue} = NaN
    end
    properties (Dependent, SetAccess = private)
        collect_criteria_unit
    end
    methods
        function obj = CollectionCriterion(options) %#codegen
            %CollectionCriterion - Construct editable value metadata
            arguments
                options.?nfx.CollectionCriterion
            end
            if isfield(options,'collect_criteria_name'), obj.collect_criteria_name = options.collect_criteria_name; end
            if isfield(options,'collect_criteria_value'), obj.collect_criteria_value = options.collect_criteria_value; end
        end
        function value = get.collect_criteria_unit(obj) %#codegen
            %get.collect_criteria_unit - Derive the required registered unit
            value = exploitationDefinition(obj.collect_criteria_name,false);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the registered name, value and numeric encoding
            report = newReport('CSEXRB CollectionCriterion');
            reference = 'STDI-0002-2 Appendix M, Tables M.6-1c/M.6-1d';
            [~,valid] = exploitationValue(obj.collect_criteria_name,obj.collect_criteria_value,false);
            report = addIssue(report,~valid,'ExploitationValue','collect_criteria_name/collect_criteria_value', ...
                'Supply a current registered name and a correctly typed, in-range encodable value.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the name, required unit and typed value with lengths
            requireValid(validate(obj));
            name = uint8(char(obj.collect_criteria_name)); unit = uint8(obj.collect_criteria_unit);
            data = exploitationValue(obj.collect_criteria_name,obj.collect_criteria_value,false);
            value = [decimalField(numel(name),2,0,false) name decimalField(numel(unit),2,0,false) unit ...
                decimalField(numel(data),2,0,false) data];
        end
    end
end
