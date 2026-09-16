classdef GLASContainerTest < NfxTest
    methods (Test)
        function fileAndImageUseExtendedThenUserThenOverflow(t)
            [base,image] = fixtureFile(uint8(1)); csexrb = fixtureCSEXRB(); csexrb.num_lines = 1; csexrb.num_samples = 1;
            image = image.removeTRE(1)+nfx.FREESA(99974)+csexrb+nfx.FREESA(99985)+nfx.FREESA(2);
            file = nfx.File(header=base.header)+image+nfx.FREESA(99974)+csexrb+nfx.FREESA(99985)+nfx.FREESA(3);
            name = fullfile(t.folder,'model-areas.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEqual({parsed.tres.tag},{'FREESA'}); t.verifyEqual({parsed.userTRE.tag},{'CSEXRB'});
            t.verifyEqual({parsed.images.tres.tag},{'FREESA'}); t.verifyEqual({parsed.images.userTRE.tag},{'CSEXRB'});
            t.verifyEqual([parsed.overflow parsed.userOverflow parsed.images.overflow parsed.images.userOverflow],[0 1 0 2]);
            t.verifyEqual({parsed.des(1).fields.desoflw,parsed.des(2).fields.desoflw},{'UDHD','UDID'});
            t.verifyEqual(cellfun(@numel,{parsed.allTRE.payload}),[99974 260 99985 3]);
            t.verifyEqual(cellfun(@numel,{parsed.images.allTRE.payload}),[99974 260 99985 2]);
            t.verifyEqual(file.header.lish,image.lish); t.verifyEqual(nitfread(name),image.data);
            t.verifyTrue(isnitf(name)); info = nitfinfo(name); t.verifyNotEmpty(info);
        end
        function twoAreasMayAvoidAnyOverflow(t)
            [base,image] = fixtureFile(uint8(1)); csexrb = fixtureCSEXRB(); csexrb.num_lines = 1; csexrb.num_samples = 1;
            image = image.removeTRE(1)+nfx.FREESA(99974)+csexrb;
            file = nfx.File(header=base.header)+image+nfx.FREESA(99974)+csexrb;
            name = fullfile(t.folder,'two-areas.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEmpty(parsed.des); t.verifyEqual(file.header.lish,100701);
            t.verifyEqual({parsed.images.allTRE.tag},{'FREESA','CSEXRB'});
            t.verifyEqual({parsed.allTRE.tag},{'FREESA','CSEXRB'});
        end
        function indivisibleFirstRecordLeavesAnOverflowPointerOnly(t)
            [base,image] = fixtureFile(uint8(1)); csexrb = fixtureCSEXRB(); csexrb.num_lines = 1; csexrb.num_samples = 1;
            image = image.removeTRE(1)+nfx.FREESA(99985)+csexrb;
            file = nfx.File(header=base.header)+image+nfx.FREESA(99985)+csexrb;
            name = fullfile(t.folder,'indivisible.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEmpty(parsed.tres); t.verifyEmpty(parsed.userTRE); t.verifyEqual(parsed.userOverflow,1);
            t.verifyEmpty(parsed.images.tres); t.verifyEmpty(parsed.images.userTRE); t.verifyEqual(parsed.images.userOverflow,2);
            t.verifyEqual(file.header.lish,442); t.verifyEqual(numel(parsed.images.allTRE),2);
            t.verifyEqual(nitfread(name),image.data);
        end
        function removalRestoresOrdinaryAreaPolicy(t)
            [base,image] = fixtureFile(uint8(1));
            image = image.removeTRE(1)+nfx.FREESA(99974)+fixtureCSEXRB()+nfx.FREESA(1);
            image = image.removeTRE(3);
            file = nfx.File(header=base.header)+image;
            name = fullfile(t.folder,'removed.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEqual(parsed.images.overflow,1); t.verifyEmpty(parsed.images.userTRE); t.verifyEqual(parsed.images.userOverflow,0);
            t.verifyEqual(parsed.des.fields.desoflw,'IXSHD');
        end
        function typedSensorAttachmentCapturesVerifiedSnapshot(t)
            base = fixtureFile(); source = fixtureCSCSDB(); file = base+source; source.cov_version_date = '20260916';
            t.verifyTrue(file.des.verifiedSensor()); t.verifyEqual(file.des.header.desid,'CSCSDB');
            t.verifyEqual(char(file.des.data(1:8)),'20260915'); t.verifyNotEqual(source.payload(),file.des.data);
            file2 = base+source.segment(); t.verifyEqual(char(file2.des.data(1:8)),'20260916');
            t.verifyTrue(file.validate().valid);
        end
        function placementChecksAllNewTRETypes(t)
            base = fixtureFile(); withTRE = base+fixtureCSEXRB(); t.verifyTrue(withTRE.validate().valid);
            t.verifyError(@() fixtureText()+fixtureCSEXRB(),'nfx:TREPlacement');
            rolling = nfx.CSRLSB(rs_dt_1=0,rs_dt_2=0,rs_dt_3=0,rs_dt_4=0);
            warp = nfx.CSWRPB(sensor_type='S',warp_data=fixtureWarpingSet());
            t.verifyError(@() base+rolling,'nfx:TREPlacement'); t.verifyError(@() base+warp,'nfx:TREPlacement');
            [~,image] = fixtureFile(); image = image+rolling+warp; t.verifyEqual(image.tre_tags(end-1:end,:),char('CSRLSB','CSWRPB'));
        end
    end
end
