classdef GLASFileTest < NfxTest
    methods (Test)
        function scannerAndFramerWriteFourTypedDESsAndRoundTrip(t)
            for type = 'SF'
                [file,image,x,a,e,s,c] = fixtureGLASFile(type);
                t.verifyTrue(file.validate().valid); name = fullfile(t.folder,['glas-' type '.ntf']); file.write(name);
                parsed = inspectContainer(name); t.verifyEqual({parsed.images.allTRE.tag},{'CSEXRB'});
                t.verifyEqual(parsed.images.allTRE.payload,x.payload());
                expected = {a.payload(),e.payload(),s.payload(),c.payload()};
                for k = 1:4
                    t.verifyEqual(parsed.des(k).data,expected{k}); t.verifyEqual(parsed.des(k).fields.desshf(1:36),uint8(x.assoc_des_uuid{k}));
                end
                t.verifyEqual(nitfread(name),image.data); t.verifyTrue(isnitf(name));
                t.verifyEqual(file.header.numdes,4); info = nitfinfo(name); t.verifyNotEmpty(info);
            end
        end
        function documentedExampleRunsWithoutReferenceFiles(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'examples')));
            file = glasExample(); t.verifyTrue(file.validate().valid); name = fullfile(t.folder,'example.ntf'); file.write(name);
            t.verifyEqual(nitfread(name),reshape(uint16(1:35),5,7));
        end
        function incompleteLevelZeroModelsAreAllowed(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid};
            file = nfx.File(header=base.header)+(image+x)+a; t.verifyTrue(file.validate().valid);
            file = nfx.File(header=base.header)+image+a; t.verifyTrue(file.validate().valid);
            file = nfx.File(header=base.header)+image+x+a; t.verifyTrue(file.validate().valid);
        end
        function forwardUUIDsMustResolveAndTypedProofCannotBeForged(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile();
            file = nfx.File(header=base.header)+(image+x)+a+e+s;
            verifyIssue(t,file,'GLASMissingDES');
            raw = nfx.DESSegment(c.payload(),header=c.subheader()); file = file+raw; verifyIssue(t,file,'GLASMissingDES');
            copy = c.segment(); copy.data(1) = uint8('1'); file = nfx.File(header=base.header)+(image+x)+a+e+s+copy;
            verifyIssue(t,file,'TypedDESChanged'); verifyIssue(t,file,'GLASMissingDES');
        end
        function fileHeaderExploitationIsUniqueAndProtectsDestination(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid};
            name = fullfile(t.folder,'existing.ntf'); good = nfx.File(header=base.header)+image+x+a;
            good.write(name); before = readBytes(name);
            for different = [false true]
                second = x;
                if different, second.image_uuid = '10000000-0000-4000-8000-000000000002'; end
                file = good+second; verifyIssue(t,file,'GLASMultiplicity');
                t.verifyError(@() file.write(name,Overwrite=true),'nfx:Invalid');
                t.verifyEqual(readBytes(name),before);
            end
        end
        function independentPlanesDoNotInheritDisplayOffsets(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid}; a.aisdlvl = [1 2];
            second = image; second.header.idlvl = 2; second.header.ialvl = 1; second.header.iloc = [0 64];
            x2 = x; x2.image_uuid = '10000000-0000-4000-8000-000000000002';
            file = nfx.File(header=base.header)+(image+x)+(second+x2)+a;
            t.verifyTrue(file.validate().valid); name = fullfile(t.folder,'offset-planes.ntf'); file.write(name);
            parsed = inspectContainer(name); t.verifyEqual(numel(parsed.images),2);
            image.data = image.data(1:5,1:7); image.header.iloc = [1 1]; a.aisdlvl = 1;
            file = nfx.File(header=base.header)+(image+x)+a; verifyIssue(t,file,'GLASImageDimensions');
        end
        function segmentedPlaneBoundsAreTranslationInvariant(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid}; a.aisdlvl = [1 2];
            image.data = image.data(1:16,:); image.header.iloc = [10 20];
            second = image; second.header.idlvl = 2; second.header.ialvl = 1; second.header.iloc = [16 0];
            file = nfx.File(header=base.header)+(image+x)+(second+x)+a;
            t.verifyTrue(file.validate().valid); file.write(fullfile(t.folder,'translated-plane.ntf'));
            second.header.iloc = [17 0]; file = nfx.File(header=base.header)+(image+x)+(second+x)+a;
            verifyIssue(t,file,'GLASImageDimensions');
        end
        function mappedChipDoesNotMoveItsOriginalPlaneOrigin(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid}; a.aisdlvl = [1 2];
            chip = image; chip.data = chip.data(1:5,1:7); chip.header.idlvl = 2;
            chip = chip+x+chipMapping(); image.header.iloc = [10 20];
            file = nfx.File(header=base.header)+(image+x)+chip+a;
            t.verifyTrue(file.validate().valid); file.write(fullfile(t.folder,'original-and-chip.ntf'));
            image.data = image.data(1:16,:);
            file = nfx.File(header=base.header)+(image+x)+chip+a; verifyIssue(t,file,'GLASImageDimensions');
        end
        function duplicateDESUUIDsAndDisplayListsAreRejected(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile(); c.uuid = a.uuid;
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASDuplicateDES');
            a.aisdlvl = 2; file = nfx.File(header=base.header)+image+a; verifyIssue(t,file,'GLASDisplayAssociation');
            other = image; other.header.idlvl = 2;
            x.assoc_des_uuid = {a.uuid}; file = nfx.File(header=base.header)+(image+x)+other+a; verifyIssue(t,file,'GLASForwardDisplay');
            a.aisdlvl = []; a.all_images = true; file = nfx.File(header=base.header)+(image+x)+other+a; t.verifyTrue(file.validate().valid);
            file = nfx.File(header=base.header)+a; verifyIssue(t,file,'GLASDisplayAssociation');
        end
        function reverseElementIdentifiersMayRemainExternal(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile();
            a.assoc_elem_uuid = {'AAAAAAAA-0000-4000-8000-000000000001'};
            e.assoc_elem_uuid = {'BBBBBBBB-0000-4000-8000-000000000001'};
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; t.verifyTrue(file.validate().valid);
        end
        function sharedModelsFollowExplicitAndAllImageAssociations(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile(); second = image; second.header.idlvl = 2;
            x2 = x; x2.image_uuid = '10000000-0000-4000-8000-000000000002';
            a.aisdlvl = [1 2]; e.aisdlvl = [1 2]; s.aisdlvl = [1 2]; c.aisdlvl = []; c.all_images = true;
            file = nfx.File(header=base.header)+(image+x)+(second+x2)+a+e+s+c; t.verifyTrue(file.validate().valid);
        end
        function segmentedPlanesUseCCSBoundsAndPreserveMetadata(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid}; a.aisdlvl = [1 2];
            image.data = image.data(1:16,:); second = image; second.header.idlvl = 2;
            second.header.ialvl = 1; second.header.iloc = [16 0];
            file = nfx.File(header=base.header)+(image+x)+(second+x)+a; t.verifyTrue(file.validate().valid);
            second.header.iloc = [17 0]; file = nfx.File(header=base.header)+(image+x)+(second+x)+a; verifyIssue(t,file,'GLASImageDimensions');
            second.header.iloc = [16 0]; changed = x; changed.cloud_cover = 0;
            file = nfx.File(header=base.header)+(image+x)+(second+changed)+a; verifyIssue(t,file,'GLASPlaneIdentity');
        end
        function originalDimensionsAndChipMappingMustAgree(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid}; x.num_lines = 40;
            file = nfx.File(header=base.header)+(image+x)+a; verifyIssue(t,file,'GLASImageDimensions');
            chip = chipMapping(); image.data = image.data(1:5,1:7); x.num_lines = 32;
            file = nfx.File(header=base.header)+(image+x+chip)+a; t.verifyTrue(file.validate().valid);
            chip.fi_row = 33; file = nfx.File(header=base.header)+(image+x+chip)+a; verifyIssue(t,file,'GLASChipDimensions');
            chip = chipMapping(); chip.op_row_22 = 6.5; file = nfx.File(header=base.header)+(image+x+chip)+a;
            verifyIssue(t,file,'GLASChipGeometry');
            chip = chipMapping(); file = nfx.File(header=base.header)+(image+x+chip+chip)+a; verifyIssue(t,file,'GLASChipMultiplicity');
        end
        function knownPrimaryTargetAndTimeMustMatchImageHeader(t)
            [base,image,x,a] = fixtureGLASFile(); x.assoc_des_uuid = {a.uuid};
            x.exploitation = nfx.ExploitationInfo(num_img_ops=1,tgt_id='OBJ123456789012US',tgt_date_time='20260915120000');
            file = nfx.File(header=base.header)+(image+x)+a; verifyIssue(t,file,'GLASTarget');
            image.header.tgtid = x.exploitation.tgt_id;
            file = nfx.File(header=base.header)+(image+x)+a; t.verifyTrue(file.validate().valid);
            image.header.idatim = '20260915120001'; file = nfx.File(header=base.header)+(image+x)+a; verifyIssue(t,file,'GLASTargetTime');
        end
        function modelSensorTypesAndRollingShutterMustAgree(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F'); rolling = nfx.CSRLSB(rs_dt_1=0,rs_dt_2=1,rs_dt_3=1,rs_dt_4=0);
            file = nfx.File(header=base.header)+(image+x+rolling)+a+e+s+c; verifyIssue(t,file,'GLASRollingShutter');
            x.rolling_shutter_flag = 1; file = nfx.File(header=base.header)+(image+x+rolling)+a+e+s+c; t.verifyTrue(file.validate().valid);
            scanner = fixtureCSSFAB('S'); file = nfx.File(header=base.header)+(image+x)+a+e+scanner+c; verifyIssue(t,file,'GLASSensorType');
            warp = nfx.CSWRPB(sensor_type='S',warp_data=fixtureWarpingSet());
            file = nfx.File(header=base.header)+(image+x+warp)+a+e+s+c; verifyIssue(t,file,'GLASWarpingSensor');
        end
        function warpingRequiresTheCompatibleFramerCalibration(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F'); set = fixtureWarpingSet(); set.fl_warp = 0.5;
            warp = nfx.CSWRPB(sensor_type='F',wrp_interp=0,warp_data=set);
            file = nfx.File(header=base.header)+(image+x+warp)+a+e+s+c; verifyIssue(t,file,'GLASWarpingAlignment');
            s = fixtureCSSFAB('F',1); file = nfx.File(header=base.header)+(image+x+warp)+a+e+s+c;
            % The fixture has a 1-by-2 fiducial array; replace it explicitly.
            for k = 0:7, field = sprintf('ls_fid_trans_t%d',k); s.fiducial_transform.(field) = s.fiducial_transform.(field)(1); end
            file = nfx.File(header=base.header)+(image+x+warp)+a+e+s+c; t.verifyTrue(file.validate().valid);
        end
        function explicitBandIdentitiesAndWavelengthUnitsBindToImage(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile();
            image.data = repmat(image.data,1,1,3); image.header.irep = 'MULTI'; image.header.icat = 'MS';
            image.header.irepband = {'R','G','B'}; image.header.isubcat = [650 550 450];
            s.bands = [nfx.SensorBand(band_index=1,irepband='R',isubcat=0.65) ...
                nfx.SensorBand(band_index=2,irepband='G',isubcat=0.55) nfx.SensorBand(band_index=3,irepband='B',isubcat=0.45)];
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; t.verifyTrue(file.validate().valid);
            image.header.irepband = {'B','R','G'}; image.header.isubcat = [450 650 550];
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; t.verifyTrue(file.validate().valid);
            s.bands(1).isubcat = 0.7; file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASBandAssociation');
        end
        function framingCountsAndTelescopeTransformsMustAgree(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F'); x.number_frames = 2; x.dt = uint64(1);
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASFrameCount');
            x.number_frames = 1; s.telescope = fixtureTelescopeOptics();
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASTelescopeFrames');
            for k = 0:7, field = sprintf('tele_trans_t%d',k); s.telescope.(field) = s.telescope.(field)(1); end
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; t.verifyTrue(file.validate().valid);
        end
        function duplicateModelsAndMissingFrameTimingFailHonestly(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F');
            file = nfx.File(header=base.header)+(image+x+x)+a+e+s+c; verifyIssue(t,file,'GLASMultiplicity');
            x.time_stamp_loc = 1; x.number_frames = NaN; x.base_timestamp = '';
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASFrameTiming');
            wrapper = nfx.FSYNWA(); wrapper = wrapper+x;
            file = nfx.File(header=base.header)+(image+wrapper)+a+e+s+c; verifyIssue(t,file,'GLASFrameTiming');
        end
        function externalFrameTimingSuppliesTheModelCount(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F'); x.time_stamp_loc = 1; x.number_frames = NaN; x.base_timestamp = '';
            timing = nfx.MTIMSA(image_seg_index=1,camera_set_index=0,time_interval_index=0,temp_block_index=0, ...
                base_timestamp='20260915120000.000000001',number_frames=1);
            file = nfx.File(header=base.header)+(image+x+timing)+a+e+s+c; t.verifyTrue(file.validate().valid);
            timing.number_frames = 2; timing.dt = uint64(1);
            file = nfx.File(header=base.header)+(image+x+timing)+a+e+s+c; verifyIssue(t,file,'GLASFrameCount');
        end
        function coordinateVariantsPreserveTheirSuppliedFrames(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile(); a.eci_ecf_att = 0; a.earth_orientation = fixtureEarthOrientation();
            e.eci_ecf_ephem = 0; e.earth_orientation = fixtureEarthOrientation();
            a.interp_type_att = 3; a.interp_order_att = 1; e.interp_type_eph = 2; e.interp_order_eph = 3;
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; t.verifyTrue(file.validate().valid);
            t.verifyEqual(file.des(1).data,a.payload()); t.verifyEqual(file.des(2).data,e.payload());
        end
        function bandMatchingRejectsQuantizationToZeroAndAmbiguity(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile(); image.header.isubcat = 1e-5;
            s.bands = nfx.SensorBand(band_index=1,irepband='M',isubcat=0);
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASBandAssociation');
            image.header.isubcat = []; image.data = repmat(image.data,1,1,2); image.header.irep = 'MULTI'; image.header.icat = 'MS';
            s.bands = nfx.SensorBand(band_index=3);
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'GLASBandAssociation');
            image.header.isubcat = 550;
            file = nfx.File(header=base.header)+(image+x)+a+e+s+c; verifyIssue(t,file,'BandMetadataCount');
        end
    end
end

function verifyIssue(t,file,id)
    report = file.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end

function chip = chipMapping()
    chip = nfx.ICHIPB(xfrm_flag=0,scale_factor=1,anamrph_corr=0,scanblk_num=0, ...
        op_row_11=0.5,op_col_11=0.5,op_row_12=0.5,op_col_12=6.5, ...
        op_row_21=4.5,op_col_21=0.5,op_row_22=4.5,op_col_22=6.5, ...
        fi_row_11=10.5,fi_col_11=20.5,fi_row_12=10.5,fi_col_12=26.5, ...
        fi_row_21=14.5,fi_col_21=20.5,fi_row_22=14.5,fi_col_22=26.5,fi_row=32,fi_col=64);
end
