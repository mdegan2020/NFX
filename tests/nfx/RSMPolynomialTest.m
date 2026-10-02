classdef RSMPolynomialTest < NfxTest
    properties (TestParameter)
        axisCase = struct('x',1,'y',2,'z',3)
        numericCase = struct('zero',0,'negative',-1.25,'minimum',1e-113, ...
            'negativeMinimum',-1e-113,'small',2.5e-106,'normalSmall',1e-99,'maximum',9.99999999999999e99)
    end
    methods (Test)
        function affineModelHasExactLayoutAndAxisPowers(t)
            value = fixturePolynomial(); data = value.payload();
            t.verifyEqual(value.cel,528);
            t.verifyEqual(char(data(121:126)),'001001');
            t.verifyEqual(char(data(127:168)),repmat(' ',1,42));
            t.verifyEqual(char(data(379:384)),'100002');
            t.verifyEqual(char(data(385:405)),'+0.00000000000000E+00');
            t.verifyEqual(char(data(406:426)),'+1.00000000000000E+00');
            t.verifyEqual(char(data(454:459)),'010002');
            t.verifyEqual([value.rnpwrx value.rnpwry value.rnpwrz value.rntrms],[1 0 0 2]);
            t.verifyEqual([value.cnpwrx value.cnpwry value.cnpwrz value.cntrms],[0 1 0 2]);
            t.verifyTrue(value.validate().valid);
        end
        function eachDimensionDeterminesItsOwnPower(t,axisCase)
            value = fixturePolynomial(); shape = [1 1 1]; shape(axisCase) = 6;
            value.rnpcf = reshape(1:6,shape);
            actual = [value.rnpwrx value.rnpwry value.rnpwrz]; expected = [0 0 0]; expected(axisCase) = 5;
            t.verifyEqual(actual,expected); t.verifyEqual(value.rntrms,6);
            data = value.payload(); t.verifyEqual(char(data(379:384)),sprintf('%.0f%.0f%.0f006',expected));
            t.verifyEqual(str2double(string(reshape(char(data(385:510)),21,[])')),(1:6)');
        end
        function tensorOrderIsXThenYThenZ(t)
            value = fixturePolynomial(); coefficients = zeros(2,3,2);
            for x = 1:2, for y = 1:3, for z = 1:2, coefficients(x,y,z) = 100*x+10*y+z; end, end, end
            value.rnpcf = coefficients; data = value.payload();
            t.verifyEqual(char(data(379:384)),'121012');
            actual = str2double(string(reshape(char(data(385:636)),21,[])'))';
            t.verifyEqual(actual,[111 211 121 221 131 231 112 212 122 222 132 232]);
        end
        function minimumAndMaximumPayloadSizes(t)
            value = fixturePolynomial(); value.rnpcf = 0; value.cnpcf = 0;
            t.verifyEqual(value.cel,486);
            value.rnpcf = ones(6,6,6); value.rdpcf = ones(6,6,6);
            value.cnpcf = ones(6,6,6); value.cdpcf = ones(6,6,6);
            t.verifyEqual(value.cel,18546);
            t.verifyEqual([value.rntrms value.rdtrms value.cntrms value.cdtrms],[216 216 216 216]);
            t.verifyEqual([value.rdpwrx value.rdpwry value.rdpwrz value.cdpwrx value.cdpwry value.cdpwrz],5*ones(1,6));
        end
        function signedNumericRangeAndSmallUnnormalizedMantissa(t,numericCase)
            value = fixturePolynomial(); value.rnpcf = numericCase; data = value.payload();
            field = char(data(385:405));
            t.verifyEqual(numel(field),21); t.verifyEqual(str2double(field),numericCase,'RelTol',1e-14);
            t.verifyNotEmpty(regexp(field,'^[+-]\d\.\d{14}E[+-]\d{2}$','once'));
            if numericCase ~= 0 && abs(numericCase) < 1e-99, t.verifyEqual(field(18:21),'E-99'); end
        end
        function invalidCoefficientsScalesAndErrors(t)
            t.verifyFalse(nfx.RSMPCA().validate().valid);
            value = fixturePolynomial(); value.rdpcf = 0; t.verifyFalse(value.validate().valid);
            value = fixturePolynomial(); value.cdpcf = zeros(2,2); t.verifyFalse(value.validate().valid);
            value = fixturePolynomial(); value.rnrmsf = 0; t.verifyFalse(value.validate().valid);
            value.rnrmsf = -1; t.verifyTrue(value.validate().valid);
            value.rnpcf = 1e-114; t.verifyFalse(value.validate().valid);
            value.rnpcf = NaN; t.verifyFalse(value.validate().valid);
            value = fixturePolynomial(); value.rfep = -0.1; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.RSMPCA(rnpcf=zeros(7,1)),'nfx:RSMCoefficients');
            t.verifyError(@() nfx.RSMPCA(rnpcf=zeros(2,2,2,2)),'nfx:RSMCoefficients');
            t.verifyError(@() nfx.RSMPCA(rnpcf=single(1)),'nfx:MetadataArray');
        end
        function sectionIdentifiersSharePublishedLayout(t)
            polynomial = nfx.RSMPIA(edition='TEST',rnis=2,cnis=3,rssiz=2.5,cssiz=7/3, ...
                r0=0,rx=1,ry=2,rz=3,rxx=4,rxy=5,rxz=6,ryy=7,ryz=8,rzz=9, ...
                c0=10,cx=11,cy=12,cz=13,cxx=14,cxy=15,cxz=16,cyy=17,cyz=18,czz=19);
            grid = nfx.RSMGIA(edition='TEST',grnis=2,gcnis=3,grssiz=2.5,gcssiz=7/3, ...
                gr0=0,grx=1,gry=2,grz=3,grxx=4,grxy=5,grxz=6,gryy=7,gryz=8,grzz=9, ...
                gc0=10,gcx=11,gcy=12,gcz=13,gcxx=14,gcxy=15,gcxz=16,gcyy=17,gcyz=18,gczz=19);
            data = polynomial.payload(); t.verifyEqual(data,grid.payload());
            t.verifyEqual(numel(data),591); t.verifyEqual(polynomial.tnis,6); t.verifyEqual(grid.gtnis,6);
            t.verifyEqual(char(data(541:549)),'002003006');
            t.verifyEqual(str2double(string(reshape(char(data(121:540)),21,[])')),(0:19)');
            polynomial.rnis = 256; polynomial.cnis = 1; t.verifyTrue(polynomial.validate().valid);
            polynomial.cnis = 2; t.verifyFalse(polynomial.validate().valid);
            grid.grssiz = 0; t.verifyFalse(grid.validate().valid);
            t.verifyFalse(nfx.RSMPIA().validate().valid); t.verifyFalse(nfx.RSMGIA().validate().valid);
        end
    end
end
