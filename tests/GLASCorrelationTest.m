classdef GLASCorrelationTest < NfxTest
    methods (Test)
        function fourParameterAndCosineBytesFollowTheTable(t)
            value = csm(); expected = uint8('01.0001.0000000.25000002.000000+3.00000000000000E+00');
            t.verifyEqual(value.bytes(),expected); t.verifyEqual(value.byte_length,52);
            value = cosine(); expected = uint8('21.0000.500000+1.00000000000000E+01+2.00000000000000E+01');
            t.verifyEqual(value.bytes(),expected); t.verifyEqual(value.byte_length,56);
        end
        function piecewiseFinalCorrelationMayBeNonzero(t)
            value = piecewise(); expected = uint8(['11.000030.800000+0.00000000000000E+00' ...
                '0.500000+2.00000000000000E+00' '0.200000+5.00000000000000E+00']);
            t.verifyEqual(value.bytes(),expected); t.verifyEqual(value.byte_length,95); t.verifyEqual(value.num_segs,3);
            value.pl_max_cor = [0.8 0.7 0.2]; t.verifyTrue(value.validate().valid);
        end
        function piecewiseCountsOrderAndRoundedMonotonicity(t)
            value = piecewise(); value.pl_tau_max_cor = [1 2 5]; t.verifyFalse(value.validate().valid);
            value = piecewise(); value.pl_tau_max_cor = [0 5 2]; t.verifyFalse(value.validate().valid);
            value = piecewise(); value.pl_max_cor = [0.8 0.8 0.2]; t.verifyFalse(value.validate().valid);
            value.pl_max_cor = [0.8 0.7999999 0.2]; t.verifyFalse(value.validate().valid);
            value = piecewise(); value.pl_max_cor = [NaN 0.5 0.2]; t.verifyFalse(value.validate().valid);
            value = piecewise(); value.pl_tau_max_cor = [0 1]; t.verifyFalse(value.validate().valid);
            value.pl_max_cor = [0.8 0]; t.verifyTrue(value.validate().valid);
            value.pl_max_cor = 0.8; value.pl_tau_max_cor = 0; t.verifyFalse(value.validate().valid);
            value.pl_max_cor = linspace(1,0,10); value.pl_tau_max_cor = 0:9;
            t.verifyTrue(value.validate().valid); t.verifyEqual(numel(value.bytes()),298);
            value.pl_tau_max_cor(2) = 1e-114; t.verifyFalse(value.validate().valid);
        end
        function conditionalFamiliesMustBeCompleteAndExclusive(t)
            t.verifyFalse(nfx.GLASCorrelation().validate().valid);
            value = csm(); value.fp_a = NaN; t.verifyFalse(value.validate().valid);
            value = csm(); value.dc_a = 1; t.verifyFalse(value.validate().valid);
            value = csm(); value.pl_max_cor = [1 0]; t.verifyFalse(value.validate().valid);
            value = cosine(); value.dc_p = NaN; t.verifyFalse(value.validate().valid);
            value = cosine(); value.fp_t = 1; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.GLASCorrelation(fp_t=0),'nfx:Metadata');
            t.verifyError(@() nfx.GLASCorrelation(pl_tau_max_cor=-1),'nfx:GLASCorrelation');
            t.verifyError(@() nfx.GLASCorrelation(pl_max_cor=ones(1,11)),'nfx:GLASMatrix');
        end
        function weightedFunctionPreservesComponentOrder(t)
            first = csm(); first.spdcf_weight = 0.25; second = cosine(); second.spdcf_weight = 0.75;
            value = nfx.SPDCF(spdcf_id=9,components=[first second]);
            t.verifyEqual(value.bytes(),[uint8('0902') first.bytes() second.bytes()]);
            t.verifyEqual(value.spdcf_p,2); t.verifyEqual(value.byte_length,112);
            first.fp_t = 10; t.verifyNotEqual(first.bytes(),value.components(1).bytes());
        end
        function weightsMustSumToOneAfterTheirThreeDecimalEncoding(t)
            part = csm(); part.spdcf_weight = 1/3;
            value = nfx.SPDCF(spdcf_id=1,components=repmat(part,1,3)); t.verifyFalse(value.validate().valid);
            value.components(1).spdcf_weight = 0.333; value.components(2).spdcf_weight = 0.333;
            value.components(3).spdcf_weight = 0.334; t.verifyTrue(value.validate().valid);
            value.components(3).spdcf_weight = 0.335; t.verifyFalse(value.validate().valid);
            value.components(3).spdcf_weight = NaN; t.verifyFalse(value.validate().valid);
        end
        function topLevelIdentifiersAndComponentCounts(t)
            t.verifyFalse(nfx.SPDCF().validate().valid); value = nfx.SPDCF(spdcf_id=1,components=csm());
            t.verifyTrue(value.validate().valid); value.spdcf_id = NaN; t.verifyFalse(value.validate().valid);
            value.spdcf_id = 1; part = csm(); part.spdcf_weight = 0;
            value.components = [csm() repmat(part,1,98)]; t.verifyTrue(value.validate().valid);
            value.components(100) = part; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.SPDCF(spdcf_id=100),'nfx:Metadata');
            t.verifyError(@() nfx.SPDCF(components=struct()),'nfx:GLASObjects');
        end
    end
end

function value = csm()
    value = nfx.GLASCorrelation(spdcf_fam=0,spdcf_weight=1,fp_a=1,fp_alpha=0.25,fp_beta=2,fp_t=3);
end
function value = cosine()
    value = nfx.GLASCorrelation(spdcf_fam=2,spdcf_weight=1,dc_a=0.5,dc_t=10,dc_p=20);
end
function value = piecewise()
    value = nfx.GLASCorrelation(spdcf_fam=1,spdcf_weight=1,pl_max_cor=[0.8 0.5 0.2],pl_tau_max_cor=[0 2 5]);
end
