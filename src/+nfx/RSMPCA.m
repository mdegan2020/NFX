classdef (Sealed) RSMPCA < nfx.TRE
    %RSMPCA - Describe rational polynomial coefficients for one image section
    %   OBJ = RSMPCA(Name=VALUE) accepts supplied normalization and
    %   coefficients. RNPCF, RDPCF, CNPCF and CDPCF are double arrays with
    %   dimensions X-by-Y-by-Z, each between one and six. Powers and term
    %   counts derive from these dimensions. A scalar is a constant.
    %
    %   Coefficients serialize with X changing fastest, then Y, then Z.
    %   To provide a linear X term, use a 2-by-1 array; a 1-by-2 array
    %   instead supplies a linear Y term. Zero leading terms are retained.
    %
    %   RFEP and CFEP may be NaN for unavailable fitting errors. All five
    %   normalization scales must be nonzero. Image coordinates refer to
    %   the original full image. No polynomial fitting or evaluation occurs.
    %
    %   See also RSMIDA, RSMPIA, TRE

    properties (Constant)
        cetag = 'RSMPCA'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        rsn {mustBeMetadata(rsn,1,256,1)} = NaN
        csn {mustBeMetadata(csn,1,256,1)} = NaN
        rfep {mustBeRSMNumber} = NaN
        cfep {mustBeRSMNumber} = NaN
        rnrmo {mustBeRSMNumber} = NaN
        cnrmo {mustBeRSMNumber} = NaN
        xnrmo {mustBeRSMNumber} = NaN
        ynrmo {mustBeRSMNumber} = NaN
        znrmo {mustBeRSMNumber} = NaN
        rnrmsf {mustBeRSMNumber} = NaN
        cnrmsf {mustBeRSMNumber} = NaN
        xnrmsf {mustBeRSMNumber} = NaN
        ynrmsf {mustBeRSMNumber} = NaN
        znrmsf {mustBeRSMNumber} = NaN
        rnpcf {mustBeRSMCoefficients} = []
        rdpcf {mustBeRSMCoefficients} = []
        cnpcf {mustBeRSMCoefficients} = []
        cdpcf {mustBeRSMCoefficients} = []
    end
    properties (Dependent, SetAccess = private)
        rnpwrx
        rnpwry
        rnpwrz
        rntrms
        rdpwrx
        rdpwry
        rdpwrz
        rdtrms
        cnpwrx
        cnpwry
        cnpwrz
        cntrms
        cdpwrx
        cdpwry
        cdpwrz
        cdtrms
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable RSMPCA value
            %   [OBJ, OK, STATUS] = nfx.RSMPCA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also RSMPCA, RSMPCA.payload
            arguments
                data
            end
            obj = nfx.RSMPCA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.iid = value;
            end
            [value, reader] = reader.text(40, true, false);
            if reader.ok
                obj.edition = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 256, 1, false);
            if reader.ok
                obj.rsn = value;
            end
            [value, reader] = reader.number( ...
                3, 1, 256, 1, false);
            if reader.ok
                obj.csn = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rfep = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cfep = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rnrmo = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cnrmo = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.xnrmo = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.ynrmo = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.znrmo = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.rnrmsf = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.cnrmsf = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.xnrmsf = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.ynrmsf = value;
            end
            [value, reader] = reader.number( ...
                21, -9.99999999999999e99, 9.99999999999999e99, false, true);
            if reader.ok
                obj.znrmsf = value;
            end
            [powers, reader] = reader.numbers(3, 1, 0, 5, true);
            [count, reader] = reader.count(3, 21, 216);
            [values, reader] = reader.numbers(count, 21, ...
                -9.99999999999999e99, 9.99999999999999e99);
            if reader.ok
                if prod(powers + 1) ~= count
                    reader = reader.fail('InvalidCount', ...
                        'Polynomial dimensions disagree with the coefficient count.');
                else
                    obj.rnpcf = reshape(values, powers + 1);
                end
            end
            [powers, reader] = reader.numbers(3, 1, 0, 5, true);
            [count, reader] = reader.count(3, 21, 216);
            [values, reader] = reader.numbers(count, 21, ...
                -9.99999999999999e99, 9.99999999999999e99);
            if reader.ok
                if prod(powers + 1) ~= count
                    reader = reader.fail('InvalidCount', ...
                        'Polynomial dimensions disagree with the coefficient count.');
                else
                    obj.rdpcf = reshape(values, powers + 1);
                end
            end
            [powers, reader] = reader.numbers(3, 1, 0, 5, true);
            [count, reader] = reader.count(3, 21, 216);
            [values, reader] = reader.numbers(count, 21, ...
                -9.99999999999999e99, 9.99999999999999e99);
            if reader.ok
                if prod(powers + 1) ~= count
                    reader = reader.fail('InvalidCount', ...
                        'Polynomial dimensions disagree with the coefficient count.');
                else
                    obj.cnpcf = reshape(values, powers + 1);
                end
            end
            [powers, reader] = reader.numbers(3, 1, 0, 5, true);
            [count, reader] = reader.count(3, 21, 216);
            [values, reader] = reader.numbers(count, 21, ...
                -9.99999999999999e99, 9.99999999999999e99);
            if reader.ok
                if prod(powers + 1) ~= count
                    reader = reader.fail('InvalidCount', ...
                        'Polynomial dimensions disagree with the coefficient count.');
                else
                    obj.cdpcf = reshape(values, powers + 1);
                end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMPCA());
        end
    end
    methods
        function obj = RSMPCA(options) %#codegen
            %RSMPCA - Construct editable section coefficients
            arguments
                options.?nfx.RSMPCA
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'rsn'), obj.rsn = options.rsn; end
            if isfield(options,'csn'), obj.csn = options.csn; end
            if isfield(options,'rfep'), obj.rfep = options.rfep; end
            if isfield(options,'cfep'), obj.cfep = options.cfep; end
            if isfield(options,'rnrmo'), obj.rnrmo = options.rnrmo; end
            if isfield(options,'cnrmo'), obj.cnrmo = options.cnrmo; end
            if isfield(options,'xnrmo'), obj.xnrmo = options.xnrmo; end
            if isfield(options,'ynrmo'), obj.ynrmo = options.ynrmo; end
            if isfield(options,'znrmo'), obj.znrmo = options.znrmo; end
            if isfield(options,'rnrmsf'), obj.rnrmsf = options.rnrmsf; end
            if isfield(options,'cnrmsf'), obj.cnrmsf = options.cnrmsf; end
            if isfield(options,'xnrmsf'), obj.xnrmsf = options.xnrmsf; end
            if isfield(options,'ynrmsf'), obj.ynrmsf = options.ynrmsf; end
            if isfield(options,'znrmsf'), obj.znrmsf = options.znrmsf; end
            if isfield(options,'rnpcf'), obj.rnpcf = options.rnpcf; end
            if isfield(options,'rdpcf'), obj.rdpcf = options.rdpcf; end
            if isfield(options,'cnpcf'), obj.cnpcf = options.cnpcf; end
            if isfield(options,'cdpcf'), obj.cdpcf = options.cdpcf; end
        end
        function value = get.rnpwrx(obj) %#codegen
            %get.rnpwrx - Derive the maximum X power
            powers = rsmPowers(obj.rnpcf); value = powers(1);
        end
        function value = get.rnpwry(obj) %#codegen
            %get.rnpwry - Derive the maximum Y power
            powers = rsmPowers(obj.rnpcf); value = powers(2);
        end
        function value = get.rnpwrz(obj) %#codegen
            %get.rnpwrz - Derive the maximum Z power
            powers = rsmPowers(obj.rnpcf); value = powers(3);
        end
        function value = get.rntrms(obj) %#codegen
            %get.rntrms - Derive the coefficient count
            value = numel(obj.rnpcf);
        end
        function value = get.rdpwrx(obj) %#codegen
            %get.rdpwrx - Derive the maximum X power
            powers = rsmPowers(obj.rdpcf); value = powers(1);
        end
        function value = get.rdpwry(obj) %#codegen
            %get.rdpwry - Derive the maximum Y power
            powers = rsmPowers(obj.rdpcf); value = powers(2);
        end
        function value = get.rdpwrz(obj) %#codegen
            %get.rdpwrz - Derive the maximum Z power
            powers = rsmPowers(obj.rdpcf); value = powers(3);
        end
        function value = get.rdtrms(obj) %#codegen
            %get.rdtrms - Derive the coefficient count
            value = numel(obj.rdpcf);
        end
        function value = get.cnpwrx(obj) %#codegen
            %get.cnpwrx - Derive the maximum X power
            powers = rsmPowers(obj.cnpcf); value = powers(1);
        end
        function value = get.cnpwry(obj) %#codegen
            %get.cnpwry - Derive the maximum Y power
            powers = rsmPowers(obj.cnpcf); value = powers(2);
        end
        function value = get.cnpwrz(obj) %#codegen
            %get.cnpwrz - Derive the maximum Z power
            powers = rsmPowers(obj.cnpcf); value = powers(3);
        end
        function value = get.cntrms(obj) %#codegen
            %get.cntrms - Derive the coefficient count
            value = numel(obj.cnpcf);
        end
        function value = get.cdpwrx(obj) %#codegen
            %get.cdpwrx - Derive the maximum X power
            powers = rsmPowers(obj.cdpcf); value = powers(1);
        end
        function value = get.cdpwry(obj) %#codegen
            %get.cdpwry - Derive the maximum Y power
            powers = rsmPowers(obj.cdpcf); value = powers(2);
        end
        function value = get.cdpwrz(obj) %#codegen
            %get.cdpwrz - Derive the maximum Z power
            powers = rsmPowers(obj.cdpcf); value = powers(3);
        end
        function value = get.cdtrms(obj) %#codegen
            %get.cdtrms - Derive the coefficient count
            value = numel(obj.cdpcf);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check normalization, coefficients and denominators
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode supplied coefficients in their defined order
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Serialize complete polynomial sections without pruning
            report = newReport('RSM polynomial coefficients');
            report = rsmIssue(report,isempty(strtrim(char(obj.edition))) || ...
                any(isnan([obj.rsn obj.csn])),'Required','edition/rsn/csn', ...
                'Supply a common support-data edition and section numbers.');
            [errors,errorValid] = rsmNumbers([obj.rfep obj.cfep],true);
            report = rsmIssue(report,~errorValid || obj.rfep < 0 || obj.cfep < 0, ...
                'FittingError','rfep/cfep','Fitting errors must be nonnegative or NaN when unavailable.');
            offsets = [obj.rnrmo obj.cnrmo obj.xnrmo obj.ynrmo obj.znrmo];
            scales = [obj.rnrmsf obj.cnrmsf obj.xnrmsf obj.ynrmsf obj.znrmsf];
            [normalization,valid] = rsmNumbers([offsets scales],false);
            report = rsmIssue(report,~valid || any(scales == 0),'Normalization', ...
                'offsets/scales','Supply five known offsets and five representable nonzero scales.');
            [rn,a] = rsmPolynomial(obj.rnpcf); [rd,b] = rsmPolynomial(obj.rdpcf);
            [cn,c] = rsmPolynomial(obj.cnpcf); [cd,d] = rsmPolynomial(obj.cdpcf);
            report = rsmIssue(report,~(a && b && c && d),'Coefficient','rnpcf/rdpcf/cnpcf/cdpcf', ...
                'Each coefficient array must contain known representable values.');
            report = rsmIssue(report,all(obj.rdpcf(:) == 0) || all(obj.cdpcf(:) == 0), ...
                'ZeroDenominator','rdpcf/cdpcf','Neither denominator polynomial may be identically zero.');
            value = [textField(obj.iid,80) textField(obj.edition,40) ...
                uint8(sprintf('%03.0f%03.0f',obj.rsn,obj.csn)) errors normalization rn rd cn cd];
        end
    end
end
