classdef RPC00BTest < NfxTest
    properties (TestParameter)
        invalidScalar = {'A', "3", single(2), uint16(2), [1 2], 1+1i, Inf, -1, 1.5}
        invalidVector = {zeros(2,10), zeros(1,19), zeros(1,21), ...
            single(zeros(1,20)), repmat('A',1,20), ones(1,20)*1i, [Inf zeros(1,19)]}
        coefficientCase = struct( ...
            'zero', {struct('value', 0, 'text', '+0.000000E+0')}, ...
            'negative', {struct('value', -1.25, 'text', '-1.250000E+0')}, ...
            'large', {struct('value', 9.999999e9, 'text', '+9.999999E+9')}, ...
            'small', {struct('value', 1e-9, 'text', '+1.000000E-9')}, ...
            'roundCarry', {struct('value', 9.9999996, 'text', '+1.000000E+1')})
        invalidCoefficient = {NaN, 1e-10, -1e-10, 1e10, 9.9999999e9}
        coefficientGroup = {'line_num_coeff','line_den_coeff','samp_num_coeff','samp_den_coeff'}
    end
    methods (Test)
        function unsetStateIsInvalid(t)
            rpc = nfx.RPC00B();
            report = rpc.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.field}, 'line_off')));
            t.verifyTrue(any(strcmp({report.issues.field}, 'samp_den_coeff(20)')));
            t.verifyError(@() rpc.bytes(), 'nfx:Invalid');
        end
        function exactEnvelopeAndScalarFields(t)
            rpc = fixtureRPC();
            encoded = rpc.bytes();
            expected = ['1' '0000.00' '0000.00' '000123' '00045' ...
                '+12.3456' '-098.7654' '-0123' '001000' '02000' ...
                '+01.2500' '-002.5000' '+0500'];
            t.verifyClass(encoded, 'uint8');
            t.verifySize(encoded, [1 1052]);
            t.verifyEqual(char(encoded(1:11)), 'RPC00B01041');
            t.verifyEqual(char(encoded(12:92)), expected);
            t.verifyEqual(rpc.cel, 1041);
            t.verifyEqual(rpc.ascii(), char(encoded(12:end)));
        end
        function scalarAssignmentsRejectConversion(t, invalidScalar)
            rpc = fixtureRPC();
            t.verifyError(@() assignProperty(rpc, 'line_off', invalidScalar), 'nfx:Metadata');
            t.verifyError(@() nfx.RPC00B(line_off=invalidScalar), 'nfx:Metadata');
        end
        function coefficientVectorShapeAndType(t, invalidVector)
            t.verifyError(@() nfx.RPC00B(line_num_coeff=invalidVector), 'nfx:Coefficients');
        end
        function coefficientFormatting(t, coefficientCase)
            rpc = fixtureRPC();
            rpc.line_num_coeff(3) = coefficientCase.value;
            text = rpc.ascii();
            t.verifyEqual(text(106:117), coefficientCase.text);
        end
        function coefficientLocationInReport(t, invalidCoefficient, coefficientGroup)
            rpc = fixtureRPC();
            rpc.(coefficientGroup)(7) = invalidCoefficient;
            report = rpc.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.field}, [coefficientGroup '(7)'])));
            t.verifyError(@() rpc.payload(), 'nfx:Invalid');
        end
        function coefficientGroupsAndOrder(t)
            rpc = fixtureRPC();
            rpc.line_num_coeff = 1:20;
            rpc.line_den_coeff = 21:40;
            rpc.samp_num_coeff = -(41:60);
            rpc.samp_den_coeff = -(61:80);
            text = rpc.ascii();
            t.verifyEqual(text(82:105), '+1.000000E+0+2.000000E+0');
            t.verifyEqual(text(310:333), '+2.000000E+1+2.100000E+1');
            t.verifyEqual(text(550:573), '+4.000000E+1-4.100000E+1');
            t.verifyEqual(text(790:813), '-6.000000E+1-6.100000E+1');
            t.verifyEqual(text(1030:1041), '-8.000000E+1');
        end
        function columnsAndIndexedEdits(t)
            rpc = fixtureRPC();
            expected = rpc.bytes();
            rpc.line_num_coeff = rpc.line_num_coeff.';
            t.verifyEqual(rpc.bytes(), expected);
            rpc.line_num_coeff(2) = -3;
            t.verifyEqual(rpc.line_num_coeff(2), -3);
        end
        function roundingCannotEraseScale(t)
            rpc = fixtureRPC();
            rpc.lat_scale = 0.000049;
            rpc.height_scale = 0;
            report = rpc.validate();
            t.verifyFalse(report.valid);
            t.verifyEqual(sum(strcmp({report.issues.id}, 'ZeroScale')), 2);
            t.verifyError(@() rpc.bytes(), 'nfx:Invalid');
        end
        function roundingCannotEraseErrorEstimate(t)
            rpc = fixtureRPC();
            rpc.err_bias = 0.001;
            rpc.err_rand = 0.0049;
            report = rpc.validate();
            t.verifyFalse(report.valid);
            t.verifyEqual(sum(strcmp({report.issues.id}, 'ErrorPrecision')), 2);
            t.verifyError(@() rpc.bytes(), 'nfx:Invalid');
            rpc.err_bias = 0;
            rpc.err_rand = 0.0051;
            text = rpc.ascii();
            t.verifyEqual(text(2:15), '0000.000000.01');
        end
        function negativeScalesAreSpecifiedValues(t)
            rpc = fixtureRPC();
            rpc.lat_scale = -1;
            rpc.height_scale = -500;
            t.verifyTrue(rpc.validate().valid);
            text = rpc.ascii();
            t.verifyEqual(text(77:81), '-0500');
        end
        function zeroDenominatorRejected(t)
            rpc = fixtureRPC();
            rpc.line_den_coeff(:) = 0;
            rpc.samp_den_coeff(:) = 0;
            report = rpc.validate();
            t.verifyEqual(sum(strcmp({report.issues.id}, 'ZeroDenominator')), 2);
        end
        function scalarBoundaries(t)
            rpc = fixtureRPC();
            rpc.err_bias = 9999.99;
            rpc.err_rand = 1.234;
            rpc.lat_off = 90;
            rpc.long_off = -180;
            text = rpc.ascii();
            t.verifyEqual(text(2:15), '9999.990001.23');
            t.verifyEqual(text(27:43), '+90.0000-180.0000');
            t.verifyError(@() nfx.RPC00B(lat_off=90.0001), 'nfx:Metadata');
        end
    end
end
