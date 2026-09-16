classdef (Sealed) GLASCorrelation
    %GLASCorrelation - Supply one weighted CSCSDB correlation component
    %   OBJ = GLASCorrelation(Name=VALUE) selects SPDCF_FAM=0 for the CSM
    %   four-parameter form, =1 for piecewise-linear data, or =2 for damped
    %   cosine data. SPDCF_WEIGHT supplies this component's contribution.
    %
    %   Piecewise data use PL_MAX_COR and PL_TAU_MAX_COR rows with 2-10
    %   entries. Correlations decrease, starting positive, while tau starts
    %   at zero and increases. The last correlation remains constant for
    %   unbounded tau. NFX encodes supplied parameters without fitting them
    %   or establishing the sensor model's scientific conformance.
    %
    %   See also SPDCF, CSCSDB, RSMCorrelation

    properties
        spdcf_fam {mustBeMetadata(spdcf_fam,0,2,1)} = NaN
        spdcf_weight {mustBeMetadata(spdcf_weight,0,1,0)} = NaN
        fp_a {mustBeMetadata(fp_a,0.000001,1,0)} = NaN
        fp_alpha {mustBeMetadata(fp_alpha,0,1,0)} = NaN
        fp_beta {mustBeMetadata(fp_beta,0,10,0)} = NaN
        fp_t {mustBeMetadata(fp_t,0.000001,9.99999999999999e99,0)} = NaN
        pl_max_cor {mustBeCorrelationRow(pl_max_cor,1)} = zeros(1,0)
        pl_tau_max_cor {mustBeCorrelationRow(pl_tau_max_cor,9.99999999999999e99)} = zeros(1,0)
        dc_a {mustBeMetadata(dc_a,0.000001,1,0)} = NaN
        dc_t {mustBeMetadata(dc_t,0.000001,9.99999999999999e99,0)} = NaN
        dc_p {mustBeMetadata(dc_p,0.000001,9.99999999999999e99,0)} = NaN
    end
    properties (Dependent, SetAccess = private)
        num_segs
        byte_length
    end
    methods
        function obj = GLASCorrelation(options) %#codegen
            %GLASCorrelation - Construct editable correlation parameters
            arguments
                options.?nfx.GLASCorrelation
            end
            if isfield(options,'spdcf_fam'), obj.spdcf_fam = options.spdcf_fam; end
            if isfield(options,'spdcf_weight'), obj.spdcf_weight = options.spdcf_weight; end
            if isfield(options,'fp_a'), obj.fp_a = options.fp_a; end
            if isfield(options,'fp_alpha'), obj.fp_alpha = options.fp_alpha; end
            if isfield(options,'fp_beta'), obj.fp_beta = options.fp_beta; end
            if isfield(options,'fp_t'), obj.fp_t = options.fp_t; end
            if isfield(options,'pl_max_cor'), obj.pl_max_cor = options.pl_max_cor; end
            if isfield(options,'pl_tau_max_cor'), obj.pl_tau_max_cor = options.pl_tau_max_cor; end
            if isfield(options,'dc_a'), obj.dc_a = options.dc_a; end
            if isfield(options,'dc_t'), obj.dc_t = options.dc_t; end
            if isfield(options,'dc_p'), obj.dc_p = options.dc_p; end
        end
        function value = get.num_segs(obj) %#codegen
            %get.num_segs - Derive the number of piecewise starting points
            value = numel(obj.pl_max_cor);
        end
        function value = get.byte_length(obj) %#codegen
            %get.byte_length - Count family, weight and selected parameters
            value = 6;
            if obj.spdcf_fam == 0, value = value+46; end
            if obj.spdcf_fam == 1, value = value+2+29*obj.num_segs; end
            if obj.spdcf_fam == 2, value = value+50; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the selected form, monotonicity and encoded values
            report = newReport('CSCSDB correlation component');
            reference = 'STDI-0002-2 Appendix M, Table M.6-5';
            report = addIssue(report,any(isnan([obj.spdcf_fam obj.spdcf_weight])), ...
                'Required','spdcf_fam/spdcf_weight','Select the correlation family and its weight.',reference);
            csm = [obj.fp_a obj.fp_alpha obj.fp_beta obj.fp_t]; cosine = [obj.dc_a obj.dc_t obj.dc_p];
            report = addIssue(report,(obj.spdcf_fam == 0 && any(isnan(csm))) || ...
                (obj.spdcf_fam ~= 0 && any(~isnan(csm))),'CSMParameters','fp_a/alpha/beta/t', ...
                'The four CSM parameters appear together and only for family zero.',reference);
            report = addIssue(report,(obj.spdcf_fam == 2 && any(isnan(cosine))) || ...
                (obj.spdcf_fam ~= 2 && any(~isnan(cosine))),'CosineParameters','dc_a/t/p', ...
                'The three damped-cosine parameters appear together and only for family two.',reference);
            if obj.spdcf_fam == 1
                count = obj.num_segs;
                valid = count >= 2 && count <= 10 && numel(obj.pl_tau_max_cor) == count && ...
                    all(isfinite(obj.pl_max_cor)) && glasScientificValid(obj.pl_tau_max_cor);
                if valid
                    correlations = round(obj.pl_max_cor*1e6)/1e6;
                    [~,~,tau] = rsmNumbers(obj.pl_tau_max_cor,false);
                    valid = obj.pl_max_cor(1) > 0 && all(diff(obj.pl_max_cor) < 0) && ...
                        obj.pl_tau_max_cor(1) == 0 && all(diff(obj.pl_tau_max_cor) > 0) && ...
                        correlations(1) > 0 && all(diff(correlations) < 0) && all(diff(tau) > 0);
                end
                report = addIssue(report,~valid,'PiecewiseCorrelation','pl_max_cor/pl_tau_max_cor', ...
                    'Supply 2-10 distinct increasing tau values from zero and decreasing correlations from a positive value, also after encoding.',reference);
            else
                report = addIssue(report,~isempty(obj.pl_max_cor) || ~isempty(obj.pl_tau_max_cor), ...
                    'UnusedPiecewise','pl_max_cor/pl_tau_max_cor','Piecewise data appear only for family one.',reference);
            end
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode a weighted component in the selected family
            requireValid(validate(obj));
            value = [decimalField(obj.spdcf_fam,1,0,false) decimalField(obj.spdcf_weight,5,3,false)];
            if obj.spdcf_fam == 0
                value = [value decimalField(obj.fp_a,8,6,false) decimalField(obj.fp_alpha,8,6,false) ...
                    decimalField(obj.fp_beta,9,6,false) rsmNumber(obj.fp_t,false)];
            elseif obj.spdcf_fam == 1
                value = [value decimalField(obj.num_segs,2,0,false)];
                for k = 1:obj.num_segs
                    value = [value decimalField(obj.pl_max_cor(k),8,6,false) rsmNumber(obj.pl_tau_max_cor(k),false)]; %#ok<AGROW>
                end
            else
                value = [value decimalField(obj.dc_a,8,6,false) rsmNumber(obj.dc_t,false) rsmNumber(obj.dc_p,false)];
            end
        end
    end
end

function mustBeCorrelationRow(value,maximum) %#codegen
    %mustBeCorrelationRow - Require bounded nonnegative double sample rows
    mustBeGLASMatrix(value,1,10,maximum);
    if any(value < 0), error('nfx:GLASCorrelation','Correlation values and tau must be nonnegative.'); end
end
