classdef RSMAdjustmentTest < NfxTest
    properties (TestParameter)
        groundID = {'OFFX','OFFY','OFFZ','ROTX','ROTY','ROTZ','SCAL', ...
            'XRTX','XRTY','XRTZ','YRTX','YRTY','YRTZ','ZRTX','ZRTY','ZRTZ'}
    end
    methods (Test)
        function minimumPayloadAndVectorOrder(t)
            p = fixtureRSMParameters(); p.xpwrc = []; p.ypwrc = []; p.zpwrc = [];
            value = nfx.RSMAPB(edition='EDITION',tid='ADJUSTMENT',parameters=p,parval=-1.25);
            data = char(value.payload()); t.verifyEqual(numel(data),321);
            t.verifyEqual(data(161:164),'01IN');
            t.verifyEqual(data(291:300),'N010100000');
            t.verifyEqual(data(301:321),'-1.25000000000000E+00');
            p = fixtureRSMParameters(); p.xpwrr = [1 0]; p.ypwrr = [0 2]; p.zpwrr = [0 3];
            value.parameters = p; value.parval = [11 12 21]; data = char(value.payload());
            t.verifyEqual(data(291:306),'N030210002301000');
            t.verifyEqual(str2double(string(reshape(data(307:end),21,[])'))',[11 12 21]);
        end
        function eachGroundIdentifierHasItsExactToken(t,groundID)
            p = rectangularParameters(); p.aptyp = 'G'; p.gsapid = {groundID};
            data = char(p.bytes());
            t.verifyEqual(data(1:4),'01GR');
            t.verifyEqual(data(383:end),['N01' groundID]);
            t.verifyEqual(p.ngsap,1);
        end
        function fullGroundParameterOrderIsPreserved(t)
            p = rectangularParameters(); p.aptyp = 'G';
            p.gsapid = {'ZRTZ','OFFX','YRTX','ROTY'};
            value = nfx.RSMAPB(edition='E',tid='T',parameters=p,parval=[4 3 2 1]);
            data = char(value.payload()); t.verifyEqual(data(543:561),'N04ZRTZOFFXYRTXROTY');
            t.verifyEqual(str2double(string(reshape(data(562:end),21,[])'))',[4 3 2 1]);
        end
        function rectangularFrameIsSerializedByWGSComponents(t)
            p = rectangularParameters(); p.aptyp = 'G'; p.gsapid = {'OFFX'};
            p.xuol = 100; p.yuol = 200; p.zuol = 300;
            p.xuxl = 0; p.xuyl = -1; p.xuzl = 0;
            p.yuxl = 1; p.yuyl = 0; p.yuzl = 0;
            data = char(p.bytes());
            frame = str2double(string(reshape(data(131:382),21,[])'))';
            t.verifyEqual(frame,[100 200 300 0 -1 0 1 0 0 0 0 1]);
            p.zuzl = -1; t.verifyFalse(p.validate().valid);
            p.zuzl = 1; p.xuyl = -1.0001; t.verifyFalse(p.validate().valid);
        end
        function rectangularBasisMapsSpecifiedToActiveOrder(t)
            p = fixtureRSMParameters();
            p.xpwrr = [0 1]; p.ypwrr = [0 0]; p.zpwrr = [0 0];
            p.ael = [0.6 0.8 0;0 0 1];
            value = nfx.RSMAPB(edition='E',tid='T',parameters=p,parval=[7 8]);
            data = char(value.payload());
            t.verifyEqual([p.npar p.nbasis p.nisap p.nisapr p.nisapc],[2 3 3 2 1]);
            t.verifyEqual(p.apbase,'Y'); t.verifyEqual(data(291:308),'Y03020001000100003');
            matrix = str2double(string(reshape(data(309:434),21,[])'))';
            t.verifyEqual(matrix,[0.6 0.8 0 0 0 1]);
            t.verifyEqual(str2double(string(reshape(data(435:end),21,[])'))',[7 8]);
        end
        function maximumBasisCountAndPublishedPayloadLimit(t)
            p = fixtureRSMParameters();
            [x,y,z] = ind2sub([6 6 6],1:99);
            p.xpwrr = x-1; p.ypwrr = y-1; p.zpwrr = z-1;
            p.xpwrc = []; p.ypwrc = []; p.zpwrc = []; p.ael = [eye(13) zeros(13,86)];
            value = nfx.RSMAPB(edition='E',tid='T',parameters=p,parval=zeros(1,13));
            t.verifyTrue(value.validate().valid); t.verifyEqual(p.nbasis,99);
            t.verifyEqual(value.cel,27896);
            p = rectangularParameters(); p.xpwrr = x(1:36)-1; p.ypwrr = y(1:36)-1; p.zpwrr = z(1:36)-1;
            p.ael = eye(36); value.parameters = p; value.parval = zeros(1,36);
            t.verifyTrue(p.validate().valid); t.verifyFalse(value.validate().valid);
            t.verifyTrue(any(strcmp({value.validate().issues.id},'AdjustmentLength')));
        end
        function descriptorsAreValuesAndEditsDoNotAlias(t)
            p = fixtureRSMParameters(); value = nfx.RSMAPB(edition='E',tid='T',parameters=p,parval=[0 0]);
            p.nsfx = 2; t.verifyEqual(value.parameters.nsfx,1);
            value.parameters.nsfx = 3; t.verifyEqual(p.nsfx,2);
        end
        function invalidDefinitionsAndValueCounts(t)
            t.verifyFalse(nfx.RSMAPB().validate().valid);
            p = fixtureRSMParameters(); p.ypwrr = []; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.nsfx = 0; t.verifyFalse(p.validate().valid);
            p.nsfx = -1; t.verifyTrue(p.validate().valid);
            p = fixtureRSMParameters(); p.aptyp = 'X'; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.loctyp = 'X'; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.xuol = 0; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.gsapid = {'OFFX'}; t.verifyFalse(p.validate().valid);
            p = rectangularParameters(); p.aptyp = 'G'; p.gsapid = {'OFFX','OFFX'}; t.verifyFalse(p.validate().valid);
            p.gsapid = {'OFFX'}; p.xpwrr = 0; p.ypwrr = 0; p.zpwrr = 0; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.aptyp = 'G'; t.verifyFalse(p.validate().valid);
            p = fixtureRSMParameters(); p.xpwrr = [0 0]; p.ypwrr = [0 0]; p.zpwrr = [0 0]; t.verifyFalse(p.validate().valid);
            value = nfx.RSMAPB(edition='E',tid='T',parameters=fixtureRSMParameters(),parval=0); t.verifyFalse(value.validate().valid);
            value.parval = [NaN 0]; t.verifyFalse(value.validate().valid);
            value.parval = [1e-114 0]; t.verifyFalse(value.validate().valid);
        end
        function basisRequiresIndependentOrthonormalRows(t)
            p = fixtureRSMParameters(); p.ael = [1 0;1 0]; t.verifyFalse(p.validate().valid);
            p.ael = 2*eye(2); t.verifyFalse(p.validate().valid);
            p.ael = [eye(2);0 0]; t.verifyFalse(p.validate().valid);
            p.ael = [1 0 0]; t.verifyFalse(p.validate().valid);
            p.ael = [1 0]; t.verifyTrue(p.validate().valid);
            p.ael = [1 1e-6]; t.verifyTrue(p.validate().valid);
            p.ael = [1 1e-4]; t.verifyFalse(p.validate().valid);
        end
        function inputTypesAndHardLimits(t)
            t.verifyError(@() nfx.RSMParameters(xpwrr=single(1)),'nfx:RSMPowers');
            t.verifyError(@() nfx.RSMParameters(xpwrr=[0;1]),'nfx:RSMPowers');
            t.verifyError(@() nfx.RSMParameters(xpwrr=NaN),'nfx:RSMPowers');
            t.verifyError(@() nfx.RSMParameters(xpwrr=6),'nfx:RSMPowers');
            t.verifyError(@() nfx.RSMParameters(xpwrr=zeros(1,100)),'nfx:RSMPowers');
            t.verifyError(@() nfx.RSMParameters(gsapid="OFFX"),'nfx:RSMGroundIDs');
            t.verifyError(@() nfx.RSMParameters(gsapid={'BAD!'}),'nfx:RSMGroundIDs');
            t.verifyError(@() nfx.RSMParameters(gsapid=repmat({'OFFX'},1,17)),'nfx:RSMGroundIDs');
            t.verifyError(@() nfx.RSMParameters(ael=single(1)),'nfx:RSMBasis');
            t.verifyError(@() nfx.RSMParameters(ael=NaN),'nfx:RSMBasis');
            t.verifyError(@() nfx.RSMParameters(ael=zeros(37,1)),'nfx:RSMBasis');
            t.verifyError(@() nfx.RSMParameters(ael=zeros(1,100)),'nfx:RSMBasis');
            t.verifyError(@() nfx.RSMParameters(ael=zeros(36,37)),'nfx:RSMBasis');
            t.verifyError(@() nfx.RSMAPB(parameters=struct()),'nfx:RSMParameters');
            t.verifyError(@() nfx.RSMAPB(parval=single(1)),'nfx:RSMVector');
            t.verifyError(@() nfx.RSMAPB(parval=zeros(1,37)),'nfx:RSMVector');
        end
    end
end

function p = rectangularParameters()
    %rectangularParameters - Supply an identity Local rectangular frame
    p = nfx.RSMParameters(loctyp='R',nsfx=1,nsfy=1,nsfz=1, ...
        noffx=0,noffy=0,noffz=0,xuol=0,yuol=0,zuol=0, ...
        xuxl=1,xuyl=0,xuzl=0,yuxl=0,yuyl=1,yuzl=0,zuxl=0,zuyl=0,zuzl=1);
end
