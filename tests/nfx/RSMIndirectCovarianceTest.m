classdef RSMIndirectCovarianceTest < NfxTest
    properties (TestParameter)
        timeDomain = {0,1,2}
        badDate = {'20250229','20261301','20260001','20260100','00000101','20260230','2026022X'}
    end
    methods (Test)
        function originalUpperTriangleAndMapHaveIndependentRowMajorOrder(t)
            covariance = [4 1 2;1 9 3;2 3 16]; correlation = piecewise();
            value = nfx.RSMECB(iid='A',edition='E',tid='T',cvdate='20240229', ...
                parameters=fixtureRSMParameters(),subgroups=nfx.RSMECB.subgroup(covariance,0,correlation), ...
                map=[11 12 13;21 22 23]);
            data = char(value.payload()); t.verifyEqual(numel(data),658);
            t.verifyEqual(data(161:174),'YN030120240229'); t.verifyEqual(data(175:178),'02IN');
            t.verifyEqual(data(318:319),'03');
            t.verifyEqual(str2double(string(reshape(data(320:445),21,[])'))',[4 1 2 9 3 16]);
            t.verifyEqual(data(446:448),'0N2');
            t.verifyEqual(str2double(string(reshape(data(449:532),21,[])'))',[1 0 0 1]);
            t.verifyEqual(str2double(string(reshape(data(533:end),21,[])'))',[11 12 13 21 22 23]);
        end
        function subgroupsPreserveTimeDomainsAndIndependentCovarianceOrder(t,timeDomain)
            correlation = csm();
            subgroups = [nfx.RSMECB.subgroup(4,timeDomain,correlation) ...
                nfx.RSMECB.subgroup([9 3;3 16],timeDomain,correlation)];
            value = nfx.RSMECB(edition='E',tid='T',parameters=fixtureRSMParameters(), ...
                subgroups=subgroups,map=[1 0 0;0 1 1]);
            data = char(value.payload()); t.verifyEqual(numel(data),703);
            t.verifyEqual(data(163:174),['0302' repmat(' ',1,8)]);
            t.verifyEqual(data(318:319),'01'); t.verifyEqual(str2double(data(320:340)),4);
            t.verifyEqual(data(341:342),[sprintf('%.0f',timeDomain) 'Y']);
            t.verifyEqual(data(427:428),'02');
            t.verifyEqual(str2double(string(reshape(data(429:491),21,[])'))',[9 3 16]);
            t.verifyEqual([value.nparo value.ign value.npar],[3 2 2]);
        end
        function unmodeledPiecewiseCovarianceHasBothSpatialFunctions(t)
            value = unmodeled(); data = char(value.payload());
            t.verifyEqual(numel(data),396); t.verifyEqual(data(161:162),'NY');
            t.verifyEqual(str2double(string(reshape(data(163:225),21,[])'))',[4 2 1]);
            t.verifyEqual(data(226:227),'N2'); t.verifyEqual(data(312),'2');
            t.verifyEqual(str2double(string(reshape(data(228:311),21,[])'))',[1 0 0 1]);
            t.verifyEqual(str2double(string(reshape(data(313:396),21,[])'))',[1 0 0 2]);
        end
        function unmodeledCSMUsesOneFlagAndTwoParameterGroups(t)
            value = unmodeled(); value.row_correlation = csm();
            value.column_correlation = nfx.RSMCorrelation(ac=0.5,alpc=0.2,betc=4,tc=8);
            data = char(value.payload()); t.verifyEqual(numel(data),394); t.verifyEqual(data(226),'Y');
            t.verifyEqual(str2double(string(reshape(data(227:end),21,[])'))',[1 0 2 5 0.5 0.2 4 8]);
        end
        function bothCovarianceModulesCanBeSupplied(t)
            value = unmodeled(); value.parameters = fixtureRSMParameters();
            value.subgroups = nfx.RSMECB.subgroup(eye(2),0,piecewise()); value.map = eye(2);
            data = char(value.payload()); t.verifyEqual(data(161:162),'YY');
            t.verifyEqual(numel(data),787); t.verifyTrue(value.validate().valid);
        end
        function originalCovarianceMustBePositiveDefinite(t)
            value = indirect(); value.subgroups(1).errcvg = ones(2); t.verifyFalse(value.validate().valid);
            value.subgroups(1).errcvg = zeros(2); t.verifyFalse(value.validate().valid);
            value.subgroups(1).errcvg = [1 0;1 1]; t.verifyFalse(value.validate().valid);
            value.subgroups(1).errcvg = diag([1e-110 1e90]); t.verifyTrue(value.validate().valid);
            value.subgroups(1).errcvg = [1 1-2e-16;1-2e-16 1];
            t.verifyFalse(value.validate().valid);
        end
        function unmodeledCovarianceMayBeZeroOrSingular(t)
            value = unmodeled(); t.verifyTrue(value.validate().valid);
            value.urr = 0; value.urc = 0; value.ucc = 0; t.verifyTrue(value.validate().valid);
            value.urc = 1; t.verifyFalse(value.validate().valid);
            value.urc = 0; value.urr = -1; t.verifyFalse(value.validate().valid);
        end
        function subgroupAndMapCountsAreChecked(t)
            value = indirect(); value.map = zeros(1,2); t.verifyFalse(value.validate().valid);
            value.map = zeros(2,3); t.verifyFalse(value.validate().valid);
            value.map = eye(2); value.map(1,1) = NaN; t.verifyFalse(value.validate().valid);
            value = indirect(); value.subgroups = [nfx.RSMECB.subgroup(eye(27),0,piecewise()) ...
                nfx.RSMECB.subgroup(eye(27),0,piecewise())]; value.map = zeros(2,53);
            t.verifyFalse(value.validate().valid);
            value = indirect(); value.subgroups = nfx.RSMECB.subgroup(eye(53),0,piecewise()); value.map = zeros(2,53);
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.nparo,53);
        end
        function covarianceVersionDateMustBeARealCalendarDate(t,badDate)
            value = indirect(); value.cvdate = badDate; t.verifyFalse(value.validate().valid);
        end
        function correlationFormsCannotBeMixedWithinAModule(t)
            value = indirect(); value.subgroups = [nfx.RSMECB.subgroup(1,0,piecewise()) nfx.RSMECB.subgroup(1,1,csm())];
            t.verifyFalse(value.validate().valid);
            value = unmodeled(); value.column_correlation = csm(); t.verifyFalse(value.validate().valid);
            value = indirect(); value.subgroups(1).tcdf = NaN; t.verifyFalse(value.validate().valid);
            value.subgroups(1).tcdf = 0; value.subgroups(1).correlation = nfx.RSMCorrelation(); t.verifyFalse(value.validate().valid);
        end
        function partialModulesFailInsteadOfBeingOmitted(t)
            t.verifyFalse(nfx.RSMECB().validate().valid);
            t.verifyFalse(nfx.RSMECB(edition='E',tid='T',cvdate='20260101').validate().valid);
            t.verifyFalse(nfx.RSMECB(edition='E',tid='T',parameters=fixtureRSMParameters()).validate().valid);
            value = unmodeled(); value.column_correlation = nfx.RSMCorrelation.empty(1,0); t.verifyFalse(value.validate().valid);
            value = unmodeled(); value.urr = NaN; t.verifyFalse(value.validate().valid);
            value = indirect(); value.parameters = nfx.RSMParameters(); t.verifyFalse(value.validate().valid);
        end
        function strictInputTypesAndShapes(t)
            t.verifyError(@() nfx.RSMECB.subgroup(ones(2,3),0,piecewise()),'nfx:RSMCovarianceShape');
            t.verifyError(@() nfx.RSMECB.subgroup(eye(54),0,piecewise()),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMECB.subgroup(eye(2),3,piecewise()),'nfx:Metadata');
            t.verifyError(@() nfx.RSMECB.subgroup(eye(2),0,struct()),'nfx:RSMCorrelation');
            t.verifyError(@() nfx.RSMECB(subgroups=struct()),'nfx:RSMSubgroups');
            group = nfx.RSMECB.subgroup(1,0,piecewise());
            t.verifyError(@() nfx.RSMECB(subgroups=repmat(group,1,37)),'nfx:RSMSubgroups');
            t.verifyError(@() nfx.RSMECB(subgroups=[group;group]),'nfx:RSMSubgroups');
            t.verifyError(@() nfx.RSMECB(map=single(1)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMECB(map=zeros(37,1)),'nfx:RSMMatrix');
            t.verifyError(@() nfx.RSMECB(row_correlation=[]),'nfx:RSMCorrelation');
        end
    end
end

function value = piecewise()
    %piecewise - Supply two time/distance correlation breakpoints
    value = nfx.RSMCorrelation(corseg=[1 0],tauseg=[0 1]);
end

function value = csm()
    %csm - Supply four correlation parameters
    value = nfx.RSMCorrelation(ac=1,alpc=0,betc=2,tc=5);
end

function value = indirect()
    %indirect - Supply one original covariance subgroup and its mapping
    value = nfx.RSMECB(edition='E',tid='T',parameters=fixtureRSMParameters(), ...
        subgroups=nfx.RSMECB.subgroup(eye(2),0,piecewise()),map=eye(2));
end

function value = unmodeled()
    %unmodeled - Supply a singular positive semidefinite spatial covariance
    column = nfx.RSMCorrelation(corseg=[1 0],tauseg=[0 2]);
    value = nfx.RSMECB(edition='E',tid='T',urr=4,urc=2,ucc=1, ...
        row_correlation=piecewise(),column_correlation=column);
end
