classdef EphemerisTest < NfxTest
    methods (Test)
        function exactChronologicalPositionBytes(t)
            value = fixtureCSEPHB(); expected = uint8(['1011000.20000000020260915123456.98765432100002' ...
                '+07000000.00+00000100.00-00000100.00+07000001.00+00000200.00-00000200.00000000000']);
            t.verifyEqual(value.payload(),expected); t.verifyEqual(value.num_ephem,2);
            t.verifyEqual(value.reserved_len,0); t.verifyEqual(value.accel_provided,'N');
            t.verifyEqual(value.segment().ld,127);
        end
        function velocityAreaUsesDerivedMaskAndLengths(t)
            value = fixtureCSEPHB(); value.vel_x = [1 4]; value.vel_y = [2 5]; value.vel_z = [3 6];
            data = value.payload();
            expected = uint8(['000000085011000000073N' ...
                '+00000001.00+00000002.00+00000003.00+00000004.00+00000005.00+00000006.00']);
            t.verifyEqual(data(119:end),expected); t.verifyEqual(value.reserved_len,85);
            t.verifyEqual(numel(data),212); t.verifyEqual(value.accel_provided,'N');
        end
        function accelerationInterleavesAfterEachVelocity(t)
            value = fixtureCSEPHB(); value.vel_x = [1 4]; value.vel_y = [2 5]; value.vel_z = [3 6];
            value.accel_x = [7 10]; value.accel_y = [8 11]; value.accel_z = [9 12];
            data = value.payload(); t.verifyEqual(char(data(119:140)),'000000157011000000145Y');
            numbers = str2double(cellstr(reshape(char(data(141:end)),12,[]).')).';
            t.verifyEqual(numbers,[1 2 3 7 8 9 4 5 6 10 11 12]);
            t.verifyEqual(value.reserved_len,157); t.verifyEqual(value.accel_provided,'Y');
        end
        function bothCoordinateVersionsAndInterpolationConditionals(t)
            value = fixtureCSEPHB(); original = value.payload(); value.desver = 1;
            t.verifyEqual(value.payload(),original); value.eci_ecf_ephem = 0;
            t.verifyTrue(value.validate().valid); t.verifyEqual(numel(value.payload()),127);
            value.desver = 2; t.verifyFalse(value.validate().valid); value.earth_orientation = fixtureEarthOrientation();
            data = value.payload(); t.verifyEqual(data(5:374),value.earth_orientation.bytes());
            t.verifyEqual(numel(data),497); value.eci_ecf_ephem = 1; t.verifyFalse(value.validate().valid);
            value.eci_ecf_ephem = 0; value.desver = 1; t.verifyFalse(value.validate().valid);
            value = fixtureCSEPHB(); value.interp_type_eph = 1; t.verifyEqual(numel(value.payload()),127);
            value.interp_type_eph = 2;
            for order = [3 5 7]
                value.interp_order_eph = order; data = value.payload();
                t.verifyEqual(char(data(3)),sprintf('%.0f',order)); t.verifyEqual(numel(data),128);
            end
            value.interp_order_eph = 4; t.verifyFalse(value.validate().valid);
            value.interp_type_eph = 0; t.verifyFalse(value.validate().valid);
            value.desver = 3; t.verifyFalse(value.validate().valid);
        end
        function derivativeGroupsMustBeCompleteAndAligned(t)
            value = fixtureCSEPHB(); value.vel_x = [1 2]; t.verifyFalse(value.validate().valid);
            value.vel_y = [1 2]; value.vel_z = [1 2]; t.verifyTrue(value.validate().valid);
            value.accel_x = [1 2]; t.verifyFalse(value.validate().valid);
            value.accel_y = [1 2]; value.accel_z = [1 2]; t.verifyTrue(value.validate().valid);
            value.accel_z = [1 NaN]; t.verifyFalse(value.validate().valid);
            value.accel_z = [1 2]; value.vel_x = []; value.vel_y = []; value.vel_z = [];
            t.verifyFalse(value.validate().valid); value = fixtureCSEPHB();
            value.ephem_z = [NaN NaN]; t.verifyFalse(value.validate().valid);
            value.ephem_z = 0; t.verifyFalse(value.validate().valid); value.ephem_x = [];
            t.verifyFalse(value.validate().valid);
        end
        function requiredTimingAndFlagsHaveNoInventedDefaults(t)
            t.verifyFalse(nfx.CSEPHB().validate().valid); value = fixtureCSEPHB();
            for name = {'qual_flag_eph','interp_type_eph','ephem_flag','eci_ecf_ephem','dt_ephem'}
                v = value; v.(name{1}) = NaN; t.verifyFalse(v.validate().valid);
            end
            value.date_ephem = ''; t.verifyFalse(value.validate().valid);
            value = fixtureCSEPHB(); value.t0_ephem = '999999.000000000'; t.verifyFalse(value.validate().valid);
            value = fixtureCSEPHB(); value.eci_ecf_ephem = 0;
            value.earth_orientation = nfx.EarthOrientation(); t.verifyFalse(value.validate().valid);
            value.earth_orientation = repmat(fixtureEarthOrientation(),1,2); t.verifyFalse(value.validate().valid);
        end
        function nativeDoubleShapesAndBoundarySamples(t)
            t.verifyError(@() nfx.CSEPHB(ephem_x=single(1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSEPHB(ephem_x=[1;2]),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSEPHB(ephem_x=1e8),'nfx:GLASMatrix');
            t.verifyError(@() nfx.CSEPHB(dt_ephem=0),'nfx:Metadata');
            value = fixtureCSEPHB(); value.ephem_x = [-99999999.99 99999999.99];
            data = value.payload(); t.verifyEqual(char(data(47:58)),'-99999999.99');
            t.verifyEqual(char(data(83:94)),'+99999999.99');
            value.ephem_x = zeros(1,99999); value.ephem_y = value.ephem_x; value.ephem_z = value.ephem_x;
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.num_ephem,99999);
        end
        function ephemerisSnapshotDoesNotFollowLaterDescriptorEdits(t)
            value = fixtureCSEPHB(); segment = value.segment(); original = segment.data;
            value.ephem_x(1) = 1; t.verifyEqual(segment.data,original); t.verifyTrue(segment.verifiedSensor());
            t.verifyNotEqual(value.payload(),original);
        end
    end
end
