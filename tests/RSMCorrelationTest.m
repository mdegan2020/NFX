classdef RSMCorrelationTest < NfxTest
    properties (TestParameter)
        validCSM = {[1 0 0 1],[0.1 0.9 10 2],[1e-113 0 1 1e-113],[1 0.999999999999999 10 9.99999999999999e99]}
        invalidCSM = {[0 0 0 1],[1.1 0 0 1],[1 -1 0 1],[1 1 0 1], ...
            [1 0 -1 1],[1 0 10.1 1],[1 0 0 0],[1 0 0 -1],[NaN 0 0 1], ...
            [1e-114 0 0 1],[1 1-eps 0 1]}
    end
    methods (Test)
        function validCSMParametersHaveFourOrderedNumbers(t,validCSM)
            value = nfx.RSMCorrelation(ac=validCSM(1),alpc=validCSM(2),betc=validCSM(3),tc=validCSM(4));
            data = char(value.bytes()); t.verifyEqual(data(1),'Y'); t.verifyEqual(numel(data),85);
            t.verifyEqual(str2double(string(reshape(data(2:end),21,[])'))',validCSM,'RelTol',1e-14);
            t.verifyEqual(value.ncseg,0);
        end
        function invalidCSMParametersFailHonestyChecks(t,invalidCSM)
            value = nfx.RSMCorrelation(ac=invalidCSM(1),alpc=invalidCSM(2),betc=invalidCSM(3),tc=invalidCSM(4));
            t.verifyFalse(value.validate().valid); t.verifyError(@() value.bytes(),'nfx:Invalid');
        end
        function piecewiseBreakpointsAreInterleavedInOrder(t)
            value = nfx.RSMCorrelation(corseg=[1 0.5 0],tauseg=[0 1 3]); data = char(value.bytes());
            t.verifyEqual(data(1:2),'N3'); t.verifyEqual(numel(data),128);
            t.verifyEqual(str2double(string(reshape(data(3:end),21,[])'))',[1 0 0.5 1 0 3]);
            t.verifyEqual(value.acsmc,'N'); t.verifyEqual(value.ncseg,3);
        end
        function piecewiseShapeRequiresConvexity(t)
            value = nfx.RSMCorrelation(corseg=[1 0.9 0],tauseg=[0 1 2]); t.verifyFalse(value.validate().valid);
            value.corseg = [1 0.5 0]; t.verifyTrue(value.validate().valid);
            value.corseg = [1 0.5 0.5]; t.verifyFalse(value.validate().valid);
            value.corseg = [0.9 0.5 0]; t.verifyFalse(value.validate().valid);
            value.corseg = [1 0.5 0]; value.tauseg = [1 2 3]; t.verifyFalse(value.validate().valid);
            value.tauseg = [0 1 1]; t.verifyFalse(value.validate().valid);
            value.tauseg = [0 1 1+eps]; t.verifyFalse(value.validate().valid);
            value.tauseg = [0 1 2]; value.ac = 1; t.verifyFalse(value.validate().valid);
        end
        function distantAndTinyTimesRemainRepresentable(t)
            value = nfx.RSMCorrelation(corseg=[1 0],tauseg=[0 1e-113]); t.verifyTrue(value.validate().valid);
            value.tauseg = [0 1e99]; t.verifyTrue(value.validate().valid);
            value.corseg = [1 0.5 0]; value.tauseg = [0 1e-113 1e99]; t.verifyTrue(value.validate().valid);
            value.corseg = [1 0.6 0.5 0]; value.tauseg = [0 1e-113 1 2];
            t.verifyFalse(value.validate().valid);
        end
        function vectorShapesAndMissingValues(t)
            t.verifyFalse(nfx.RSMCorrelation().validate().valid);
            value = nfx.RSMCorrelation(corseg=[1 0],tauseg=0); t.verifyFalse(value.validate().valid);
            value.tauseg = [0 NaN]; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.RSMCorrelation(corseg=single([1 0])),'nfx:RSMCorrelationValues');
            t.verifyError(@() nfx.RSMCorrelation(corseg=[1;0]),'nfx:RSMCorrelationValues');
            t.verifyError(@() nfx.RSMCorrelation(corseg=linspace(1,0,10)),'nfx:RSMCorrelationValues');
            t.verifyError(@() nfx.RSMCorrelation(corseg=[1 -0.1]),'nfx:RSMCorrelationValues');
        end
    end
end
