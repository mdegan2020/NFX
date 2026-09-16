classdef (Sealed) SPDCF
    %SPDCF - Identify a weighted CSCSDB correlation function
    %   OBJ = SPDCF(Name=VALUE) holds SPDCF_ID and an ordered COMPONENTS row
    %   of GLASCorrelation values. The 1-99 component weights must sum to one
    %   before and after serialization at the specified three-decimal precision.
    %   SPDCF_P derives from the number of supplied components.
    %
    %   See also GLASCorrelation, CSCSDB

    properties
        spdcf_id {mustBeMetadata(spdcf_id,1,99,1)} = NaN
        components {mustBeGLASObjects(components,'nfx.GLASCorrelation')} = nfx.GLASCorrelation.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        spdcf_p
        byte_length
    end
    methods
        function obj = SPDCF(options) %#codegen
            %SPDCF - Construct an editable weighted correlation definition
            arguments
                options.?nfx.SPDCF
            end
            if isfield(options,'spdcf_id'), obj.spdcf_id = options.spdcf_id; end
            if isfield(options,'components'), obj.components = options.components; end
        end
        function value = get.spdcf_p(obj) %#codegen
            %get.spdcf_p - Derive the number of constituent components
            value = numel(obj.components);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count the identifier, count and all constituents
            value = 4;
            for k = 1:obj.spdcf_p, value = value+obj.components(k).byte_length; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check component count, values and encoded weight sums
            report = newReport('CSCSDB SPDCF');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,isnan(obj.spdcf_id),'Required','spdcf_id','Supply an identifier from 1 through 99.',reference);
            report = addIssue(report,obj.spdcf_p < 1 || obj.spdcf_p > 99,'CorrelationComponents','components', ...
                'Supply 1-99 correlation components.',reference);
            weights = zeros(1,obj.spdcf_p);
            for k = 1:obj.spdcf_p
                report = mergeReport(report,validate(obj.components(k)),sprintf('components(%.0f)',k));
                weights(k) = obj.components(k).spdcf_weight;
            end
            report = addIssue(report,any(isnan(weights)) || abs(sum(weights)-1) > 1e-12 || ...
                sum(round(weights*1000)) ~= 1000,'CorrelationWeights','components.spdcf_weight', ...
                'Component weights must sum to one before and after three-decimal encoding.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the SPDCF identifier and ordered weighted components
            requireValid(validate(obj)); value = zeros(1,obj.byte_length,'uint8');
            value(1:4) = [decimalField(obj.spdcf_id,2,0,false) decimalField(obj.spdcf_p,2,0,false)]; at = 4;
            for k = 1:obj.spdcf_p
                data = bytes(obj.components(k)); value(at+(1:numel(data))) = data; at = at+numel(data);
            end
        end
    end
end
