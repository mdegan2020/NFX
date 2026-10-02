classdef RSMGridTest < NfxTest
    properties (TestParameter)
        digits = {1,2,3}
        interpolation = {0,1,2,3,NaN}
    end
    methods (Test)
        function minimumPayloadAndSignedReferenceLayout(t)
            value = fixtureRSMGrid(); value.refrow = -99999999; value.refcol = 99999999;
            data = char(value.payload()); t.verifyEqual(numel(data),390);
            t.verifyEqual(data(121:126),'001001'); t.verifyEqual(data(127:169),repmat(' ',1,43));
            t.verifyEqual(data(170:172),'002');
            t.verifyEqual(data(299:322),'-99999999+99999999030311');
            t.verifyEqual(data(323:330),'+000+000');
            t.verifyEqual(data(331:360),'002002000000000010010000010010');
            t.verifyEqual(data(361:end),data(331:360));
            t.verifyEqual([value.npln value.tnumrd value.tnumcd],[2 3 3]);
        end
        function rowMajorOrderVariesYFastestAndPairsCoordinates(t)
            value = fixtureRSMGrid(); value.planes(1) = nfx.RSMGGA.plane( ...
                [11 12 13;21 22 23],[61 62 63;71 72 73]);
            data = char(value.payload()); t.verifyEqual(data(331:336),'002003');
            t.verifyEqual(data(337:372),'110610120620130630210710220720230730');
            t.verifyEqual(data(373:378),'002002');
            t.verifyEqual(numel(data),402);
        end
        function planeOffsetsAreAllBeforePointMatrices(t)
            value = fixtureRSMGrid();
            value.planes(2).ixo = -999; value.planes(2).iyo = 999;
            value.planes(3) = nfx.RSMGGA.plane(zeros(3,2),ones(3,2),ixo=8,iyo=-7);
            data = char(value.payload());
            t.verifyEqual(data(170:172),'003'); t.verifyEqual(data(323:338),'-999+999+008-007');
            t.verifyEqual(data(339:344),'002002'); t.verifyEqual(data(399:404),'003002');
            t.verifyEqual(numel(data),440);
        end
        function fractionalDigitsDetermineQuantizationAndCarryWidth(t,digits)
            value = fixtureRSMGrid(); value.fnumrd = digits; value.fnumcd = digits;
            for k = 1:value.npln
                value.planes(k).rcoord(:) = 0; value.planes(k).ccoord(:) = 0;
            end
            value.planes(1).rcoord(1,1) = 999.6/10^digits;
            value.planes(1).ccoord(1,1) = 998.6/10^digits;
            data = char(value.payload());
            t.verifyEqual([value.tnumrd value.tnumcd],[4 3]);
            t.verifyEqual(data(317:322),sprintf('0403%.0f%.0f',digits,digits));
            t.verifyEqual(data(337:343),'1000999');
        end
        function independentUnknownCoordinatesUseFullWidthSpaces(t)
            value = fixtureRSMGrid(); value.planes(1).rcoord(:) = NaN;
            value.planes(1).ccoord(1,2) = NaN;
            data = char(value.payload());
            t.verifyEqual(data(337:348),'   000      ');
            t.verifyEqual(data(349:360),'   000   010');
        end
        function interpolationAndErrorMetadata(t,interpolation)
            value = fixtureRSMGrid(); value.intord = interpolation;
            data = char(value.payload());
            if isnan(interpolation), t.verifyEqual(data(169),' ');
            else, t.verifyEqual(data(169),sprintf('%.0f',interpolation)); end
            value.ggrfep = 0.01; value.ggcfep = 0;
            t.verifyEqual(value.validate().valid,~isnan(interpolation));
            value.intord = 1; value.ggrfep = -1;
            t.verifyFalse(value.validate().valid);
        end
        function largestCoordinateWidthAndOverflow(t)
            value = fixtureRSMGrid(); value.planes(1).rcoord(1,1) = 9999999999.9;
            t.verifyEqual(value.tnumrd,11); data = char(value.payload());
            t.verifyEqual(data(337:347),'99999999999');
            value.planes(1).rcoord(1,1) = 1e10; t.verifyFalse(value.validate().valid);
            value.planes(1).rcoord(1,1) = realmax; t.verifyFalse(value.validate().valid);
        end
        function byteLimitRejectsOversizedGridBeforeAllocation(t)
            value = fixtureRSMGrid(); plane = nfx.RSMGGA.plane(zeros(91),zeros(91));
            value.planes = [plane plane]; t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.cel,99714);
            plane = nfx.RSMGGA.plane(zeros(92),zeros(92)); value.planes = [plane plane];
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'GridLength')));
            t.verifyError(@() value.payload(),'nfx:Invalid');
        end
        function missingAndInconsistentMetadata(t)
            t.verifyFalse(nfx.RSMGGA().validate().valid);
            value = fixtureRSMGrid(); value.planes = value.planes(1); t.verifyFalse(value.validate().valid);
            value = fixtureRSMGrid(); value.planes(1).ixo = 1; t.verifyFalse(value.validate().valid);
            value = fixtureRSMGrid(); value.planes(2).iyo = NaN; t.verifyFalse(value.validate().valid);
            value = fixtureRSMGrid(); value.deltaz = 0; t.verifyFalse(value.validate().valid);
            value.deltaz = 1e-114; t.verifyFalse(value.validate().valid);
            value = fixtureRSMGrid(); value.fnumrd = NaN; t.verifyFalse(value.validate().valid);
        end
        function strictPlaneTypesShapesAndBounds(t)
            t.verifyError(@() nfx.RSMGGA.plane(single(zeros(2)),zeros(2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(sparse(2,2),zeros(2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(complex(ones(2),ones(2)),zeros(2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(-ones(2),zeros(2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(inf(2),zeros(2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(zeros(1,2),zeros(1,2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(zeros(1000,2),zeros(1000,2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(zeros(2,2,2),zeros(2,2,2)),'nfx:RSMGridMatrix');
            t.verifyError(@() nfx.RSMGGA.plane(zeros(2,3),zeros(3,2)),'nfx:RSMGridShape');
            t.verifyError(@() nfx.RSMGGA.plane(zeros(2),zeros(2),ixo=1000),'nfx:Metadata');
            t.verifyError(@() nfx.RSMGGA(planes=struct('rcoord',zeros(2))),'nfx:RSMPlanes');
            plane = nfx.RSMGGA.plane(zeros(2),zeros(2));
            t.verifyError(@() nfx.RSMGGA(planes=repmat(plane,1,1000)),'nfx:RSMPlanes');
            t.verifyError(@() nfx.RSMGGA(planes=[plane;plane]),'nfx:RSMPlanes');
        end
    end
end
