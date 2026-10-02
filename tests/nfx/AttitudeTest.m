classdef AttitudeTest < NfxTest
    methods (Test)
        function exactChronologicalScalarLastQuaternionBytes(t)
            value = fixtureCSATTB(); data = value.payload();
            expected = uint8(['1011000.10000000020260915123456.12345678900002' ...
                '+0.000000000000000+0.000000000000000+0.000000000000000+1.000000000000000' ...
                '+0.000000000000000+0.000000000000000+0.600000000000000+0.800000000000000000000000']);
            t.verifyEqual(data,expected); t.verifyEqual(numel(data),199); t.verifyEqual(value.num_att,2);
            samples = str2double(cellstr(reshape(char(data(47:end-9)),18,[]).'));
            t.verifyEqual(reshape(samples,4,[]),[0 0;0 0;0 0.6;1 0.8]);
        end
        function interpolationFieldsFollowTheirConditionalDefinition(t)
            value = fixtureCSATTB();
            for interp = 0:3
                value.interp_type_att = interp;
                if interp < 2, orders = NaN; elseif interp == 2, orders = [3 5 7]; else, orders = [1 3]; end
                for order = orders
                    value.interp_order_att = order; data = value.payload();
                    t.verifyEqual(numel(data),199+(interp >= 2));
                    if interp >= 2, t.verifyEqual(char(data(3)),sprintf('%.0f',order)); end
                end
            end
            value.interp_order_att = 5; t.verifyFalse(value.validate().valid);
            value.interp_type_att = 2; value.interp_order_att = 1; t.verifyFalse(value.validate().valid);
            value.interp_type_att = 1; t.verifyFalse(value.validate().valid);
        end
        function coordinateVersionConditionalsPreserveEachVariant(t)
            value = fixtureCSATTB(); original = value.payload(); value.desver = 1;
            t.verifyEqual(value.payload(),original); value.eci_ecf_att = 0;
            t.verifyTrue(value.validate().valid); t.verifyEqual(numel(value.payload()),199);
            value.desver = 2; t.verifyFalse(value.validate().valid);
            value.earth_orientation = fixtureEarthOrientation(); data = value.payload();
            t.verifyEqual(numel(data),569); t.verifyEqual(data(5:374),value.earth_orientation.bytes());
            value.eci_ecf_att = 1; t.verifyFalse(value.validate().valid);
            value.eci_ecf_att = 0; value.desver = 1; t.verifyFalse(value.validate().valid);
            value.desver = 3; t.verifyFalse(value.validate().valid);
        end
        function quaternionsMustBeSuppliedAndNormalized(t)
            value = fixtureCSATTB(); value.q4(2) = 0.9; t.verifyFalse(value.validate().valid);
            value.q4(2) = NaN; t.verifyFalse(value.validate().valid);
            value.q4 = 1; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.q1 = []; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.q3 = [0 -0.6]; value.q4 = [-1 -0.8];
            t.verifyTrue(value.validate().valid);
            value.q3(2) = sqrt(0.5); value.q4(2) = sqrt(0.5); t.verifyTrue(value.validate().valid);
        end
        function timingAndRequiredMetadataAreValidated(t)
            t.verifyFalse(nfx.CSATTB().validate().valid); value = fixtureCSATTB();
            for name = {'qual_flag_att','interp_type_att','att_type','eci_ecf_att','dt_att'}
                v = value; v.(name{1}) = NaN; t.verifyFalse(v.validate().valid);
            end
            value.date_att = '20260230'; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.t0_att = '240000.000000000'; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.earth_orientation = nfx.EarthOrientation();
            value.eci_ecf_att = 0; t.verifyFalse(value.validate().valid);
            value.earth_orientation = repmat(fixtureEarthOrientation(),1,2); t.verifyFalse(value.validate().valid);
        end
        function sampleShapesClassesAndCountBoundsAreStrict(t)
            t.verifyError(@() nfx.CSATTB(q1=[0;0]),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSATTB(q1=single(0)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSATTB(q1=1.001),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSATTB(q1=zeros(1,100000)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSATTB(dt_att=0),'nfx:Metadata');
            value = fixtureCSATTB(); value.q1 = zeros(1,99999); value.q2 = value.q1;
            value.q3 = value.q1; value.q4 = ones(1,99999); t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.num_att,99999);
        end
        function typedSnapshotRetainsProofAndDetectsAnyRawEdits(t)
            value = fixtureCSATTB(); segment = value.segment();
            t.verifyTrue(segment.verifiedSensor()); t.verifyTrue(segment.validate().valid);
            value.q4(1) = -1; t.verifyNotEqual(segment.data,value.payload());
            other = segment; other.data(1) = uint8('0'); t.verifyFalse(other.verifiedSensor());
            t.verifyFalse(other.validate().valid); other.data = segment.data; t.verifyTrue(other.verifiedSensor());
            other.header.desver = 1; t.verifyFalse(other.validate().valid);
            generic = nfx.DESSegment(segment.data,header=segment.header); t.verifyFalse(generic.verifiedSensor());
            t.verifyTrue(generic.validate().valid);
        end
    end
end
