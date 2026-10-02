classdef WarpingTest < NfxTest
    methods (Test)
        function scannerMinimumUsesBothConstantCoefficients(t)
            value = nfx.CSWRPB(sensor_type='S',warp_data=fixtureWarpingSet());
            expected = uint8(['1S' sprintf('%07.0f',1:8) '0000' ...
                '+1.00000000000000E+00+2.00000000000000E+00' '00000']);
            t.verifyEqual(value.payload(),expected); t.verifyEqual(value.cel,109);
            t.verifyEqual(value.bytes(),[uint8('CSWRPB00109') expected]);
            t.verifyEqual(value.num_sets_warp_data,1);
        end
        function coefficientOrdersAndLinePowerOrderAreDerived(t)
            data = fixtureWarpingSet(); data.a = [1 3 5;2 4 6]; data.b = [7 8];
            value = nfx.CSWRPB(sensor_type='S',warp_data=data); payload = value.payload();
            t.verifyEqual(char(payload(59:62)),'1201');
            coefficients = str2double(cellstr(reshape(char(payload(63:end-5)),21,[]).')).';
            t.verifyEqual(coefficients,1:8); t.verifyEqual(value.cel,235);
            t.verifyEqual([data.line_poly_order_m1 data.line_poly_order_m2 data.samp_poly_order_n1 data.samp_poly_order_n2],[1 2 0 1]);
        end
        function framingConditionalsAndSetOrderArePreserved(t)
            first = fixtureWarpingSet(); first.fl_warp = 0.5; second = first; second.fl_warp = 1.5; second.a = -3;
            value = nfx.CSWRPB(sensor_type="F",wrp_interp=1,warp_data=[first second]); payload = value.payload();
            t.verifyEqual(char(payload(1:14)),'2F100.50000000');
            t.verifyEqual(char(payload(117:127)),'01.50000000');
            t.verifyEqual(char(payload(188:208)),'-3.00000000000000E+00');
            t.verifyEqual(value.cel,234); t.verifyEqual(char(payload(end-4:end)),'00000');
            value.wrp_interp = 0; t.verifyTrue(value.validate().valid);
        end
        function unusedOrMissingFocalAndInterpolationDataFail(t)
            data = fixtureWarpingSet(); value = nfx.CSWRPB(sensor_type='F',warp_data=data);
            t.verifyFalse(value.validate().valid); value.wrp_interp = 0; t.verifyFalse(value.validate().valid);
            data.fl_warp = 1; value.warp_data = data; t.verifyTrue(value.validate().valid);
            value.sensor_type = 'S'; t.verifyFalse(value.validate().valid); value.wrp_interp = NaN;
            t.verifyFalse(value.validate().valid); data.fl_warp = NaN; value.warp_data = data;
            t.verifyTrue(value.validate().valid); value.sensor_type = 'X'; t.verifyFalse(value.validate().valid);
        end
        function unknownAndUnrepresentableValuesFail(t)
            t.verifyFalse(nfx.CSWRPB().validate().valid);
            data = nfx.WarpingSet(); t.verifyFalse(data.validate().valid);
            data = fixtureWarpingSet(); data.a = NaN; t.verifyFalse(data.validate().valid);
            data.a = 1e-114; t.verifyFalse(data.validate().valid); data.a = 1e-113;
            t.verifyTrue(data.validate().valid); data.offset_line = NaN; t.verifyFalse(data.validate().valid);
        end
        function shapesAndNumericClassesAreStrict(t)
            t.verifyError(@() nfx.WarpingSet(a=ones(11,1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.WarpingSet(a=single(1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.WarpingSet(a=1e100),'nfx:GLASMatrix');
            t.verifyError(@() nfx.WarpingSet(offset_line=0),'nfx:Metadata');
            t.verifyError(@() nfx.CSWRPB(warp_data=struct()),'nfx:WarpingSets');
            t.verifyError(@() nfx.CSWRPB(warp_data=repmat(fixtureWarpingSet(),2,1)),'nfx:WarpingSets');
            t.verifyError(@() nfx.CSWRPB(wrp_interp=2),'nfx:Metadata');
        end
        function scannerAndFramerSetCountLimitsApply(t)
            data = fixtureWarpingSet(); value = nfx.CSWRPB(sensor_type='S',warp_data=[data data]);
            t.verifyFalse(value.validate().valid);
            data.fl_warp = 1; data.a = ones(10,10); data.b = ones(10,10);
            sets = repmat(data,1,9); for k = 1:9, sets(k).fl_warp = k; end
            value = nfx.CSWRPB(sensor_type='F',wrp_interp=0,warp_data=sets);
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.cel,38447);
            value.warp_data(10) = data; t.verifyFalse(value.validate().valid);
        end
        function descriptorSerializationRequiresAValidSensorContext(t)
            data = fixtureWarpingSet();
            t.verifyError(@() data.bytes('X'),'nfx:SensorType');
            t.verifyError(@() data.bytes('F'),'nfx:WarpingFocalLength');
            data.fl_warp = 1; t.verifyError(@() data.bytes('S'),'nfx:WarpingFocalLength');
        end
        function valueSetEditsDoNotChangeTheContainingTRE(t)
            data = fixtureWarpingSet(); value = nfx.CSWRPB(sensor_type='S',warp_data=data);
            original = value.payload(); data.a = 5; t.verifyEqual(value.payload(),original);
            value.warp_data = data; t.verifyNotEqual(value.payload(),original);
        end
    end
end
