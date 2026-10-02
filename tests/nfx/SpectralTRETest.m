classdef SpectralTRETest < NfxTest
    properties (TestParameter)
        cornerKind = {'CSCRNA','FCRNSA'}
    end
    methods (Test)
        function chipMappingLiteralFieldOrder(t)
            value = fixtureChip();
            t.verifyEqual(value.cel,224);
            expected = ['000001.000000000' ...
                '00000000.50000000000.50000000000.50000000002.500' ...
                '00000001.50000000000.50000000001.50000000002.500' ...
                '00000010.50000000020.50000000010.50000000022.500' ...
                '00000011.50000000020.50000000011.50000000022.500' ...
                '0000002000000030'];
            t.verifyEqual(value.payload(),uint8(expected));
            [~,image] = fixtureFile();
            image = image+value;
            t.verifyEqual(image.tre_tags(end,:),'ICHIPB');
        end
        function chipNonmappingZeroFillAndRequiredData(t)
            value = nfx.ICHIPB(xfrm_flag=1);
            t.verifyEqual(value.payload(),uint8(['01' repmat('0',1,222)]));
            value.scale_factor = 1;
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.ICHIPB().validate().valid);
            value = fixtureChip();
            value.scale_factor = 1e-7;
            t.verifyFalse(value.validate().valid);
            value.scale_factor = 1;
            value.fi_col = 22;
            t.verifyFalse(value.validate().valid);
            value.fi_col = 0;
            t.verifyTrue(value.validate().valid);
        end
        function datasetIdentifierLiteralBytesAndDerivedCalendar(t)
            value = nfx.CSDIDA(platform_code='WV',vehicle_id=3,pass=2,operation=17, ...
                sensor_id='GA',product_id='P2',time='20260915120000', ...
                process_time='20260915120100',software_version_number='NFX TEST');
            t.verifyEqual(value.day,15);
            t.verifyEqual(value.month,'SEP');
            t.verifyEqual(value.year,2026);
            t.verifyEqual(char(value.bytes()), ['CSDIDA0007015SEP2026WV0302017GAP20000' ...
                '20260915120000202609151201000001NNNFX TEST  ']);
            value.time = '20240229------';
            t.verifyEqual(value.month,'FEB');
            t.verifyEqual(value.day,29);
            t.verifyTrue(value.validate().valid);
            file = fixtureFile()+value;
            t.verifyEqual(file.tre_tags,'CSDIDA');
            [~,image] = fixtureFile();
            t.verifyError(@() plus(image,value), 'nfx:TREPlacement');
        end
        function datasetIdentificationRejectsUnknownCodesAndInvalidDates(t)
            value = nfx.CSDIDA(platform_code='WV',sensor_id='GA',product_id='P2', ...
                time='20260229120000',process_time='--------------',software_version_number='TEST');
            t.verifyFalse(value.validate().valid);
            value.time = '20260915120000';
            t.verifyTrue(value.validate().valid);
            value.platform_code = 'ZZ';
            t.verifyFalse(value.validate().valid);
            value.platform_code = 'WV'; value.sensor_id = 'ZZ';
            t.verifyFalse(value.validate().valid);
            value.sensor_id = 'GA'; value.product_id = 'Z2';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.CSDIDA().validate().valid);
        end
        function literalCornerPayloadAndOrder(t, cornerKind)
            value = fixtureCorners(cornerKind);
            expected = ['N+40.00000-075.00000+00100.0' ...
                '+40.00000-074.00000+00101.0' ...
                '+39.00000-074.00000+00102.0' ...
                '+39.00000-075.00000+00103.0'];
            t.verifyEqual(value.payload(), uint8(expected));
            t.verifyEqual(value.cel, 109);
            t.verifyEqual(value.bytes(), uint8([cornerKind '00109' expected]));
            value.predict_corners = "Y";
            encoded = value.payload();
            t.verifyEqual(encoded(1), uint8('Y'));
        end
        function cornerBoundsAndRequiredValues(t, cornerKind)
            value = fixtureCorners(cornerKind);
            t.verifyError(@() assignProperty(value,'ulcrn_lat',90.00001), 'nfx:Metadata');
            t.verifyError(@() assignProperty(value,'ulcrn_lon',-180), 'nfx:Metadata');
            t.verifyError(@() assignProperty(value,'ulcrn_ht',10668.1), 'nfx:Metadata');
            t.verifyError(@() assignProperty(value,'ulcrn_lat',single(40)), 'nfx:Metadata');
            value.llcrn_ht = NaN;
            t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.payload(), 'nfx:Invalid');
        end
        function predictedIntelligentCornersHaveOwnerRestrictions(t)
            [file,image] = fixtureFile(uint8(1));
            collection = fixtureCorners('CSCRNA');
            footprint = fixtureCorners('FCRNSA');
            collection.predict_corners = 'I';
            t.verifyFalse(collection.validate().valid);
            footprint.predict_corners = 'I';
            t.verifyTrue(footprint.validate().valid);
            image = image+footprint;
            t.verifyEqual(image.tre_tags(end,:), 'FCRNSA');
            t.verifyError(@() plus(file,footprint), 'nfx:TREPlacement');
            t.verifyError(@() plus(fixtureText(),footprint), 'nfx:TREPlacement');
            footprint.predict_corners = 'Y';
            file = file+footprint;
            t.verifyEqual(file.tre_tags, 'FCRNSA');
            t.verifyError(@() plus(file,fixtureCorners()), 'nfx:TREPlacement');
        end
    end
end
