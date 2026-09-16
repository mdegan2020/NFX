classdef (Sealed) RSMCorrelation
    %RSMCorrelation - Define a supplied RSM covariance correlation function
    %   C = RSMCorrelation(corseg=R,tauseg=T) defines two to nine ordered
    %   breakpoints. R decreases from one to zero, T increases from zero,
    %   and the resulting piecewise-linear function must be convex.
    %
    %   C = RSMCorrelation(ac=A,alpc=ALPHA,betc=BETA,tc=T) instead defines
    %   the CSM four-parameter form: 0 < A <= 1, 0 <= ALPHA < 1,
    %   0 <= BETA <= 10, and T > 0. Values are supplied, not fitted.
    %
    %   TAUSEG and TC use seconds for original-parameter time correlation.
    %   For unmodeled row or column correlation, they use pixel distance.
    %   The same value representation supplies both contexts in RSMECB.
    %
    %   See also RSMECB, RSMParameters

    properties
        corseg {mustBeCorrelationValues(corseg,1)} = zeros(1,0)
        tauseg {mustBeCorrelationValues(tauseg,9.99999999999999e99)} = zeros(1,0)
        ac {mustBeRSMNumber} = NaN
        alpc {mustBeRSMNumber} = NaN
        betc {mustBeRSMNumber} = NaN
        tc {mustBeRSMNumber} = NaN
    end
    properties (Dependent, SetAccess = private)
        acsmc
        ncseg
    end
    methods
        function obj = RSMCorrelation(options) %#codegen
            %RSMCorrelation - Construct editable correlation metadata
            arguments
                options.?nfx.RSMCorrelation
            end
            if isfield(options,'corseg'), obj.corseg = options.corseg; end
            if isfield(options,'tauseg'), obj.tauseg = options.tauseg; end
            if isfield(options,'ac'), obj.ac = options.ac; end
            if isfield(options,'alpc'), obj.alpc = options.alpc; end
            if isfield(options,'betc'), obj.betc = options.betc; end
            if isfield(options,'tc'), obj.tc = options.tc; end
        end
        function value = get.acsmc(obj) %#codegen
            %get.acsmc - Derive which conditional functional form is supplied
            if isempty(obj.corseg) && isempty(obj.tauseg), value = 'Y'; else, value = 'N'; end
        end
        function value = get.ncseg(obj) %#codegen
            %get.ncseg - Derive the number of linear correlation segments
            value = numel(obj.corseg);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check field ranges and the encoded function shape
            [~,report] = encode(obj);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the option flag followed by its conditional fields
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Validate original and rounded correlation definitions
            value = zeros(1,0,'uint8'); report = newReport('RSM correlation function');
            csm = [obj.ac obj.alpc obj.betc obj.tc];
            if obj.acsmc == 'Y'
                [numbers,ok,rounded] = rsmNumbers(csm,false);
                ok = ok && validCSM(csm) && validCSM(rounded);
                report = rsmIssue(report,~ok,'CSMCorrelation','ac/alpc/betc/tc', ...
                    'Supply representable CSM parameters: 0<A<=1, 0<=alpha<1, 0<=beta<=10 and T>0.');
                if ok, value = [uint8('Y') numbers]; end
            else
                report = rsmIssue(report,obj.ncseg < 2 || obj.ncseg ~= numel(obj.tauseg) || any(~isnan(csm)), ...
                    'CorrelationSegments','corseg/tauseg', ...
                    'Supply two to nine matching breakpoint vectors and leave CSM parameters unset.');
                if ~report.valid, return; end
                pairs = [obj.corseg;obj.tauseg];
                [numbers,ok,rounded] = rsmNumbers(pairs,false);
                ok = ok && validPiecewise(pairs) && validPiecewise(rounded);
                report = rsmIssue(report,~ok,'CorrelationShape','corseg/tauseg', ...
                    'Correlation must decrease from one to zero as distance increases from zero, with nonpositive increasing slopes.');
                if ok, value = [uint8('N') uint8(sprintf('%.0f',obj.ncseg)) numbers]; end
            end
        end
    end
end

function valid = validCSM(values) %#codegen
    %validCSM - Apply strict endpoint constraints after numeric formatting
    valid = all(isfinite(values)) && values(1) > 0 && values(1) <= 1 && ...
        values(2) >= 0 && values(2) < 1 && values(3) >= 0 && values(3) <= 10 && values(4) > 0;
end

function valid = validPiecewise(pairs) %#codegen
    %validPiecewise - Compare convex slopes in a scaled distance coordinate
    correlation = pairs(1,:); distance = pairs(2,:);
    valid = all(isfinite(pairs(:))) && correlation(1) == 1 && correlation(end) == 0 && ...
        distance(1) == 0 && all(diff(distance) > 0) && all(diff(correlation) < 0);
    if ~valid, return; end
    % Normalize distances before division to retain a stable slope scale.
    spacing = diff(distance)/distance(end);
    slopes = diff(correlation)./spacing;
    tolerance = 1e-10*max(abs(slopes(1:end-1)),abs(slopes(2:end)));
    valid = all(isfinite(slopes)) && all(diff(slopes) >= -tolerance);
end

function mustBeCorrelationValues(value,maximum) %#codegen
    %mustBeCorrelationValues - Preserve ordinary double breakpoint rows
    if ~isa(value,'double') || ~isreal(value) || issparse(value) || ...
            ~(isrow(value) || isequal(size(value),[0 0])) || numel(value) > 9 || ...
            any(isinf(value) | value < 0 | value > maximum)
        error('nfx:RSMCorrelationValues','Supply a double row of up to nine nonnegative breakpoint values within the field range.');
    end
end
