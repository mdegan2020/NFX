classdef RSMDirectCovarianceTest < NfxTest
    properties (TestParameter)
        validCovariance = {0,1,ones(2),[4 2;2 1],diag([1e-110 1e90]), ...
            [1e-110 1e-10;1e-10 1e90]}
        invalidCovariance = {-1,[1 2;2 1],[1 0;1 1],[1 1;1 0], ...
            [1e-110 2e-10;2e-10 1e90],[NaN 0;0 1],[1 -1 1;-1 1 1;1 1 1]}
    end
    methods (Test)
        function minimumPayloadContainsOneScalarAndNoDefinition(t)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('A',1));
            data = char(value.payload()); t.verifyEqual(numel(data),269);
            t.verifyEqual(data(161:165),'01001'); t.verifyEqual(data(166:245),['A' repmat(' ',1,79)]);
            t.verifyEqual(data(246:248),'01N'); t.verifyEqual(data(249:end),'+1.00000000000000E+00');
            t.verifyEqual([value.nrowcb value.nimge],[1 1]); t.verifyEqual(value.incapd,'N');
        end
        function directoryPrecedesDefinitionsAndAllMatrices(t)
            first = nfx.RSMDCB.block('A',[4 2;2 1]);
            second = nfx.RSMDCB.block('B',[11 12 13;21 22 23]);
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',parameters=fixtureRSMParameters(),blocks=[first second]);
            data = char(value.payload()); t.verifyEqual(data(161:165),'02002');
            t.verifyEqual(data(246:248),'02B'); t.verifyEqual(data(328:334),'03Y02IN');
            t.verifyEqual(data(461:473),'N020100001000');
            matrix = str2double(string(reshape(data(474:end),21,[])'))';
            t.verifyEqual(matrix,[4 2 2 1 11 12 13 21 22 23]);
            t.verifyEqual(numel(data),683); t.verifyEqual(value.incapd,'Y');
        end
        function acceptsSemidefiniteMatricesAcrossVeryDifferentScales(t,validCovariance)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('A',validCovariance));
            t.verifyTrue(value.validate().valid); t.verifyNotEmpty(value.payload());
        end
        function rejectsInvalidAutoCovariance(t,invalidCovariance)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('A',invalidCovariance));
            t.verifyFalse(value.validate().valid); t.verifyError(@() value.payload(),'nfx:Invalid');
        end
        function crossCovarianceMayBeRectangularOrNonsymmetric(t)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('B',[1 2 3;4 5 6]));
            t.verifyTrue(value.validate().valid);
            value.blocks = nfx.RSMDCB.block('B',[1 -2;3 4]); t.verifyTrue(value.validate().valid);
            value.blocks = nfx.RSMDCB.block('A',[1 2 3;4 5 6]); t.verifyFalse(value.validate().valid);
        end
        function definitionsAndBlockRowsMustAgree(t)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',parameters=fixtureRSMParameters(),blocks=nfx.RSMDCB.block('A',1));
            t.verifyFalse(value.validate().valid);
            value.blocks = [nfx.RSMDCB.block('A',eye(2)) nfx.RSMDCB.block('B',zeros(3,1))];
            t.verifyFalse(value.validate().valid);
            value.parameters = nfx.RSMParameters(); t.verifyFalse(value.validate().valid);
        end
        function blockIdentifiersCannotBeMissingOrDuplicated(t)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('',1));
            t.verifyFalse(value.validate().valid);
            value.blocks = [nfx.RSMDCB.block('A',1) nfx.RSMDCB.block('A ',1)]; t.verifyFalse(value.validate().valid);
            value.blocks = struct('iidi',{},'crscov',{}); t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.RSMDCB().validate().valid);
        end
        function wholeBlocksRespectPhysicalPayloadLimit(t)
            blocks = repmat(nfx.RSMDCB.block('A',zeros(36)),1,4);
            for k = 1:4, blocks(k).iidi = sprintf('IMAGE %.0f',k); end
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=blocks(1:3));
            t.verifyEqual(value.cel,82060);
            value.blocks = blocks; report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'CovarianceLength')));
        end
        function strictMatricesAndParameterValues(t)
            t.verifyError(@() nfx.RSMDCB.block('A',single(1)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',sparse(1)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',1i),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',Inf),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',[]),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',zeros(37,1)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB.block('A',zeros(1,37)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMDCB(parameters=[]),'nfx:RSMParameters');
            t.verifyError(@() nfx.RSMDCB(blocks=struct()),'nfx:RSMCovarianceBlocks');
            value = nfx.RSMDCB.block('A',1);
            t.verifyError(@() nfx.RSMDCB(blocks=repmat(value,1,1000)),'nfx:RSMCovarianceBlocks');
            t.verifyError(@() nfx.RSMDCB(blocks=[value;value]),'nfx:RSMCovarianceBlocks');
        end
        function encodedCovarianceRejectsNumericUnderflow(t)
            value = nfx.RSMDCB(iid='A',edition='E',tid='T',blocks=nfx.RSMDCB.block('B',1e-114));
            t.verifyFalse(value.validate().valid);
            value.blocks = nfx.RSMDCB.block('A',[1 1-2e-15;1-2e-15 1]); t.verifyTrue(value.validate().valid);
        end
    end
end
