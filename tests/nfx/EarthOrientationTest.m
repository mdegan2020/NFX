classdef EarthOrientationTest < NfxTest
    methods (Test)
        function allThirtyTwoFieldsUseThePublishedOrderAndWidths(t)
            value = fixtureEarthOrientation(); data = value.bytes(); t.verifyEqual(numel(data),370);
            widths = [19 11*ones(1,6) 10 10 11*ones(1,6) 10 10 19 12*ones(1,10) 10*ones(1,4)];
            numbers = [-0.09:0.01:-0.04 100.07 100.08 -0.01:0.01:0.04 100.15 100.16 ...
                0.08:0.01:0.17 100.28 100.29 100.30 100.31];
            at = 1; n = 1;
            for k = 1:numel(widths)
                text = char(data(at:at+widths(k)-1)); at = at+widths(k);
                if k == 1, t.verifyEqual(text,'2460000.12345678901');
                elseif k == 18, t.verifyEqual(text,'2460001.98765432109');
                else, t.verifyEqual(str2double(text),numbers(n),'AbsTol',1e-12); n = n+1; end
            end
        end
        function epochBoundariesPreserveDigitsBelowDoubleResolution(t)
            value = fixtureEarthOrientation(); value.ta_pole = '3000000.00000000000';
            value.tb_ut = '2000000.00000000000'; t.verifyTrue(value.validate().valid);
            value.ta_pole = '3000000.00000000001'; t.verifyFalse(value.validate().valid);
            value.ta_pole = '1999999.99999999999'; t.verifyFalse(value.validate().valid);
            value.ta_pole = '2460000.1234567890X'; t.verifyFalse(value.validate().valid);
            value.ta_pole = '2460000'; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.EarthOrientation(ta_pole=2460000),'nfx:Text');
        end
        function allTransformParametersMustBeSupplied(t)
            t.verifyFalse(nfx.EarthOrientation().validate().valid);
            value = fixtureEarthOrientation(); value.a_pole = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.EarthOrientation(a_pole=1.01),'nfx:Metadata');
            t.verifyError(@() nfx.EarthOrientation(pn4_ut=501),'nfx:Metadata');
        end
    end
end
