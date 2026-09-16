classdef RSMIdentificationTest < NfxTest
    methods (Test)
        function exactOffsetsAndOptionalBlanks(t)
            value = fixtureRSMIdentification(); data = value.payload();
            t.verifyEqual(numel(data),1628);
            t.verifyEqual(char(data(241:319)),repmat(' ',1,79));
            t.verifyEqual(char(data(320)),'G');
            t.verifyEqual(char(data(321:572)),repmat(' ',1,252));
            t.verifyEqual(char(data(573:593)),'+0.00000000000000E+00');
            t.verifyEqual(char(data(636:656)),'+1.00000000000000E-02');
            t.verifyEqual(char(data(1077:1139)),repmat(' ',1,63));
            t.verifyEqual(char(data(1140:1187)), ...
                '000000050000000700000000000000040000000000000006');
            t.verifyEqual(char(data(1188:end)),repmat(' ',1,441));
            t.verifyFalse(nfx.RSMIDA().validate().valid);
        end
        function optionalAcquisitionAndLeapSeconds(t)
            value = fixtureRSMIdentification(); value.year = 2024; value.month = 2; value.day = 29;
            value.hour = 23; value.minute = 59; value.second = 60.123456;
            data = value.payload(); t.verifyEqual(char(data(241:261)),'20240229235960.123456');
            value.year = 2025; t.verifyFalse(value.validate().valid);
            value.year = NaN; t.verifyTrue(value.validate().valid);
            value.month = 4; value.day = 31; t.verifyFalse(value.validate().valid);
            value.day = 30; value.nrg = 1; t.verifyFalse(value.validate().valid);
            value.ncg = 7; value.trg = -0.1; value.tcg = 0; t.verifyTrue(value.validate().valid);
        end
        function rectangularFrameMustBeKnownAndRightHanded(t)
            value = fixtureRSMIdentification(); value.grndd = 'R'; t.verifyFalse(value.validate().valid);
            value = rectangular(value); t.verifyTrue(value.validate().valid);
            value.zuzr = -1; t.verifyFalse(value.validate().valid);
            value.zuzr = 1; value.xuxr = 1+1e-11; t.verifyFalse(value.validate().valid);
            value.xuxr = 1; value.grndd = 'G'; t.verifyFalse(value.validate().valid);
        end
        function optionalModelsPreserveCoefficientOrder(t)
            value = fixtureRSMIdentification();
            value.grpx = 0.005; value.grpy = 0.006; t.verifyFalse(value.validate().valid);
            value.grpz = 100; value.ie0 = 10; t.verifyFalse(value.validate().valid);
            fields = {'ie0','ier','iec','ierr','ierc','iecc','ia0','iar','iac','iarr','iarc','iacc'};
            for k = 1:12, value.(fields{k}) = k; end
            % Large illumination angles can preserve a model's continuity.
            value.spx = 0.01; value.svx = 0.02; value.sax = 0.03;
            value.spy = 0.04; value.svy = 0.05; value.say = 0.06;
            value.spz = 1000; value.svz = 20; value.saz = -1;
            data = value.payload();
            t.verifyEqual(str2double(string(reshape(char(data(1188:1439)),21,[])')),(1:12)');
            t.verifyEqual(str2double(string(reshape(char(data(1440:1628)),21,[])')), ...
                [0.01;0.02;0.03;0.04;0.05;0.06;1000;20;-1]);
            value.spy = 2; t.verifyFalse(value.validate().valid);
        end
        function groundDomainHasOrientedPlanarFaces(t)
            value = fixtureRSMIdentification(); value.v4z = 1; t.verifyFalse(value.validate().valid);
            value = fixtureRSMIdentification(); value.v2x = 0; t.verifyFalse(value.validate().valid);
            value = fixtureRSMIdentification(); value.v8x = -0.01; t.verifyFalse(value.validate().valid);
            value = fixtureRSMIdentification();
            % A translated top face forms a valid sheared hexahedron.
            value.v5x = 0.003; value.v6x = 0.013; value.v7x = 0.003; value.v8x = 0.013;
            t.verifyTrue(value.validate().valid);
        end
        function encodingCannotCollapseAValidInputDomain(t)
            value = fixtureRSMIdentification();
            for k = 1:8
                field = sprintf('v%dx',k);
                if any(k == [1 3 5 7]), value.(field) = 1;
                else, value.(field) = 1+eps;
                end
            end
            t.verifyFalse(value.validate().valid);
        end
        function geographicPolesAndLongitudeConvention(t)
            value = fixtureRSMIdentification();
            value.grpx = pi; value.grpy = pi/2; value.grpz = 100;
            data = value.payload(); coords = str2double(string(reshape(char(data(1077:1139)),21,[])'));
            t.verifyLessThanOrEqual(coords(1),pi); t.verifyLessThanOrEqual(coords(2),pi/2);
            t.verifyEqual(coords(2),pi/2,'AbsTol',1e-14);
            value.grndd = 'H'; value.grpx = 2*pi;
            data = value.payload(); t.verifyLessThanOrEqual(str2double(char(data(1077:1097))),2*pi);
            value.grpx = -0.01; t.verifyFalse(value.validate().valid);
            value.grndd = 'G'; value.grpy = -pi/2;
            data = value.payload(); t.verifyGreaterThanOrEqual(str2double(char(data(1098:1118))),-pi/2);
        end
        function imageDomainAndStrictMetadata(t)
            value = fixtureRSMIdentification(); value.maxr = 5; t.verifyFalse(value.validate().valid);
            value.fullr = NaN; t.verifyTrue(value.validate().valid);
            value.minr = 6; t.verifyFalse(value.validate().valid);
            value = fixtureRSMIdentification(); value.grndd = 'C'; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.RSMIDA(v1x=single(0)),'nfx:Metadata');
            t.verifyError(@() nfx.RSMIDA(second=61),'nfx:Metadata');
            t.verifyError(@() nfx.RSMIDA(minr=-1),'nfx:Metadata');
        end
    end
end

function value = rectangular(value)
    value.grndd = 'R'; value.xuor = 6378137; value.yuor = 0; value.zuor = 0;
    value.xuxr = 1; value.xuyr = 0; value.xuzr = 0;
    value.yuxr = 0; value.yuyr = 1; value.yuzr = 0;
    value.zuxr = 0; value.zuyr = 0; value.zuzr = 1;
end
