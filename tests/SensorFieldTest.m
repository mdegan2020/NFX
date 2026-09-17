classdef SensorFieldTest < NfxTest
    properties (TestParameter)
        field = sensorSampleCases()
    end
    methods (Test)
        function allEligibleTimeAndPixelTypes(t,field)
            value = fixtureSensor();
            value.time_stamped_data = nfx.SENSRB.timeSeries(field.type,-0.5,field.sample);
            value.pixel_referenced_data = nfx.SENSRB.pixelSeries(field.type,1.25,-0.75,field.sample);
            out = inspectSENSRB(value.payload());
            t.verifyEqual(out.series.type,field.type); t.verifyEqual(out.series.time,-0.5);
            t.verifyEqual(out.pixels.type,field.type); t.verifyEqual(out.pixels.row,1.25);
            t.verifyEqual(out.pixels.column,-0.75); t.verifyEqual(out.series.value,out.pixels.value);
            [decoded,ok,status] = nfx.SENSRB.deserialize(value.payload());
            t.assertTrue(ok,status.message);
            t.verifyEqual(decoded.payload(),value.payload());
            if isnumeric(field.sample)
                t.verifyEqual(str2double(out.series.value),field.sample,'AbsTol',1e-10);
            else
                t.verifyEqual(strtrim(out.series.value),field.sample);
            end
        end
        function unknownDynamicValuesAndTypeMismatchesAreRejected(t,field)
            value = fixtureSensor();
            value.time_stamped_data = nfx.SENSRB.timeSeries(field.type,0,NaN);
            t.verifyFalse(value.validate().valid);
            if isnumeric(field.sample), wrong = 'TEXT'; else, wrong = 1; end
            if ischar(wrong)
                % Direct sample structs also exercise field width rejection.
                sample = struct('numeric',[],'text',wrong);
                value.time_stamped_data.time_stamp_value = sample;
            else
                value.time_stamped_data = nfx.SENSRB.timeSeries(field.type,0,wrong);
            end
            t.verifyFalse(value.validate().valid);
        end
    end
end

function cases = sensorSampleCases()
    %sensorSampleCases - Literal examples for all dynamically eligible fields
    groups = { ...
        {'Visible',2,3,0.2,0.3,35,20,30,'Y'}, ...
        {'mm',0.01,-0.02,1e-8,2e-10,-3e-12,1,4e-10,5e-10,6e-8,7e-8,'20260801'}, ...
        {'Single Frame','000',2,3,2,3,0,0,1,1,6,1,0,0,1,0,0,1,1}, ...
        {0,1.5,2}, {40,-105,1000,0,0,0}, {1,0,0,0,'Y',0,0,0}, ...
        {1,0,0,0,1,0,0,0,1}, {0,0,0,1}, {50,0,0}};
    cases = struct();
    for m = 1:numel(groups)
        for j = 1:numel(groups{m})
            type = sprintf('%02d%c',m+1,96+j);
            cases.(['i' type]) = struct('type',type,'sample',groups{m}{j});
        end
    end
end
