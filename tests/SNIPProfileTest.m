classdef SNIPProfileTest < NfxTest
    methods (Test)
        function suppliedRSMProductWritesIndependentFieldsAndReaderPixels(t)
            file = fixtureSNIP(); report = file.validate(SNIP_COMPLIANT=true);
            t.assertTrue(report.valid,evalc('disp(report.issues)'));
            destination = fullfile(t.folder,[file.header.ftitle '.ntf']); file.write(destination,SNIP_COMPLIANT=true);
            t.verifyEqual(nitfread(destination),file.images(1).data);
            parsed = inspectContainer(destination);
            t.verifyTrue(any(strcmp({parsed.images(1).allTRE.tag},'BANDSB')));
            t.verifyTrue(contains(char(readBytes(destination)),'DOC_ID: NGA.STND.0072_1.2_SNIP_CN1'));
        end
        function genericRPCRemainsValidAndCannotAssertSpectralConformance(t)
            file = fixtureFile(); t.verifyTrue(file.validate().valid);
            t.verifyFalse(file.validate(SNIP_COMPLIANT=true).valid);
        end
        function citationUsesPinnedIdentityAndUnknownCertification(t)
            file = fixtureSNIP(); text = file.texts(1);
            t.verifyEqual(text.header.textid,'SNIPSTD'); t.verifyEqual(text.header.txtalvl,1);
            t.verifyEqual(text.header.txtdt,file.header.fdt);
            t.verifyTrue(contains(text.data,['PRODUCT_CERT_DATE: ----------' char([13 10])]));
            t.verifyTrue(endsWith(text.data,char([13 10])));
            t.verifyEqual(sum(text.data == 10),15); t.verifyEqual(sum(text.data == 13),15);
        end
        function profileFailureAndFilenameMismatchPreserveDestinations(t)
            [file,image] = fixtureSNIP(); filename = fullfile(t.folder,[file.header.ftitle '.ntf']);
            putBytes(filename,uint8('keep'));
            bad = rebuild(file,without(image,'BANDSB'));
            t.verifyError(@() bad.write(filename,SNIP_COMPLIANT=true,Overwrite=true),'nfx:Invalid');
            t.verifyEqual(readBytes(filename),uint8('keep'));
            t.verifyError(@() file.write(fullfile(t.folder,'wrong.ntf'),SNIP_COMPLIANT=true),'nfx:SNIPFilename');
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function eachRequiredRecordAndModelCompanionIsEnforced(t)
            [file,image] = fixtureSNIP();
            tags = {'BANDSB','CSCRNA','HISTOA','ILLUMB','ACFTB','AIMIDB','RSMECB'};
            for k = 1:numel(tags)
                candidate = rebuild(file,without(image,tags{k}));
                t.verifyFalse(candidate.validate(SNIP_COMPLIANT=true).valid,tags{k});
                t.verifyTrue(candidate.validate().valid,tags{k});
            end
            candidate = file.removeTRE(1); t.verifyFalse(candidate.validate(SNIP_COMPLIANT=true).valid);
        end
        function bandOrderWavelengthGroupsAndSpatialValuesAreEnforced(t)
            [file,image,m] = fixtureSNIP();
            bands = m.bands; bands.band(2).cwave = .4;
            verifyIssue(t,rebuild(file,replace(image,'BANDSB',bands)),'SNIPBandOrder');
            bands = m.bands; bands.row_gsd = NaN; bands.row_gsd_unit = '';
            verifyIssue(t,rebuild(file,replace(image,'BANDSB',bands)),'SNIPSpatialResponse');
            bands = m.bands; bands.band(1).fwhm = []; bands.band(2).fwhm = [];
            verifyIssue(t,rebuild(file,replace(image,'BANDSB',bands)),'SNIPSpectralGroups');
            changed = image; changed.header.isubcat = [450 660];
            verifyIssue(t,rebuild(file,changed),'SNIPBandWavelength');
            bands = m.bands; bands.band(2).cwave = 10000;
            verifyIssue(t,rebuild(file,replace(image,'BANDSB',bands)),'SNIPBandWavelength');
        end
        function timeGeometryDatumAndHistoryAreEnforced(t)
            [file,image,m] = fixtureSNIP(); illumination = m.illumination;
            illumination.datetime = '20260915120001';
            verifyIssue(t,rebuild(file,replace(image,'ILLUMB',illumination)),'SNIPIlluminationTime');
            illumination = m.illumination; illumination.sensor_elev = NaN;
            verifyIssue(t,rebuild(file,replace(image,'ILLUMB',illumination)),'SNIPIlluminationGeometry');
            illumination = m.illumination; illumination.vertical_datum_ref = 'Mean Sea Level'; illumination.vertical_ref_code = 'MSL';
            verifyIssue(t,rebuild(file,replace(image,'ILLUMB',illumination)),'SNIPIlluminationDatum');
            history = m.history; history.event.ipcom = 'PROCEV_Format Conversion from MATLAB to NITF';
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPHistoryAlgorithm');
            history = m.history; history.event.obpp = 9;
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPHistoryOutput');
        end
        function suppliedQuicklookPreservesAssociationAndSourceBandComment(t)
            [file,image,m] = fixtureSNIP(); image.header.idlvl = 1;
            h = image.header; h.iid1 = 'QUICK_LOOK'; h.irep = 'MONO'; h.icat = 'VIS'; h.idlvl = 2;
            h.ialvl = 1; h.isubcat = []; h.irepband = cell(1,0); h.nppbh = 7; h.nppbv = 5;
            h.icom = 'Created from band 2, wavelength 650 nm';
            quick = nfx.ImageSegment(image.data(:,:,2),header=h);
            candidate = nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            name = fullfile(t.folder,[file.header.ftitle '.ntf']); candidate.write(name,SNIP_COMPLIANT=true);
            parsed = inspectContainer(name);
            t.verifyEqual([parsed.images(1).fields.idlvl parsed.images(2).fields.idlvl],[2 1]);
            quick.header.icom = 'Created from band 2, wavelength 450 nm';
            candidate = nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1);
            verifyIssue(t,candidate,'SNIPQuicklookComment');
            quick.header.icom = 'Created from band 2, wavelength 650 nm'; quick.header.nppbh = 4;
            candidate = nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1);
            verifyIssue(t,candidate,'SNIPQuicklookBlock');
        end
        function spatialCropNeedsItsHistoryAndParent(t)
            [file,image,m] = fixtureSNIP(); image.data = image.data(2:3,3:5,:);
            chip = fixtureChip(); chip.fi_row = 5; chip.fi_col = 7;
            chip.fi_row_11 = 1.5; chip.fi_row_12 = 1.5; chip.fi_row_21 = 2.5; chip.fi_row_22 = 2.5;
            chip.fi_col_11 = 2.5; chip.fi_col_21 = 2.5; chip.fi_col_12 = 4.5; chip.fi_col_22 = 4.5;
            history = m.history; history.event(2) = history.event(1);
            history.event(2).ipcom = char('PROCEV_Spatially Chipped: Cropped','ALGO_Integer crop 1');
            image = replace(image,'HISTOA',history)+chip;
            mate = struct('source','AG3607','mate_type','FTITLE','mate_id','PARENT SYNTHETIC');
            lineage = nfx.MATESA(cur_source='AG3607',cur_mate_type='FTITLE',cur_file_id=file.header.ftitle, ...
                groups=struct('relationship','PARENT','mates',mate));
            candidate = rebuild(file,image)+lineage; r = candidate.validate(SNIP_COMPLIANT=true);
            t.assertTrue(r.valid,evalc('disp(r.issues)'));
            verifyIssue(t,rebuild(file,image),'SNIPChipParent');
            image = replace(image,'HISTOA',m.history); verifyIssue(t,rebuild(file,image)+lineage,'SNIPChipHistory');
        end
        function glasRequiresEarthFixedSupportAcrossTheAcquisition(t)
            [base,image,m] = fixtureSNIP();
            for tag = {'RSMIDA','RSMPCA','RSMECB'}, image = without(image,tag{1}); end
            e = fixtureCSEXRB('S'); e.sensor_id = 'AG3607'; e.num_lines = 5; e.num_samples = 7;
            e.time_first_line_image = 43200; e.time_image_duration = .5;
            a = fixtureCSATTB(); a.t0_att = '120000.000000000'; a.dt_att = 1;
            p = fixtureCSEPHB(); p.t0_ephem = '120000.000000000'; p.dt_ephem = 1;
            align = fixtureCSSFAB('S'); cov = fixtureCSCSDB();
            file = rebuild(base,image+e)+a+p+align+cov;
            r = file.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            a.dt_att = .1; verifyIssue(t,rebuild(base,image+e)+a+p+align+cov,'SNIPGLASTemporalCoverage');
            a.dt_att = 1; a.eci_ecf_att = 0; a.earth_orientation = fixtureEarthOrientation();
            verifyIssue(t,rebuild(base,image+e)+a+p+align+cov,'SNIPEarthFixed');
            file = nfx.File(header=base.header)+m.dataset+(image+e)+base.texts(1)+a+p+align;
            t.verifyFalse(file.validate(SNIP_COMPLIANT=true).valid);
        end
        function citationContentAndAttachmentAreValidated(t)
            [file,image,m] = fixtureSNIP(); text = file.texts(1);
            text.data = strrep(text.data,'DOC_VERSION: 1.2 CN1','DOC_VERSION: 1.1');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationVersion');
            text = file.texts(1); text.data = text.data(1:end-2);
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationLines');
            text = file.texts(1); text.header.txtdt = '20260915120200';
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationHeader');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image,'SNIPCitationCount');
        end
        function asymmetricBandsAndWavenumbersUseNanometerDisplayFields(t)
            [file,image,m] = fixtureSNIP(); band = m.bands;
            band.band = [nfx.SpectralBand(bandid='B1',nom_wave=8000,lbound=7500,ubound=8500) ...
                nfx.SpectralBand(bandid='B2',nom_wave=5000,lbound=4500,ubound=5500)];
            band.wave_length_unit = 'W'; image.header.isubcat = [1250 2000];
            file = rebuild(file,replace(image,'BANDSB',band));
            r = file.validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
        end
        function adjustedRSMRequiresItsDirectCovariance(t)
            [file,image,m] = fixtureSNIP(); parameters = fixtureRSMParameters();
            adjustment = nfx.RSMAPB(iid=m.identification.iid,edition=m.identification.edition, ...
                tid='SYNTHETIC',parameters=parameters,parval=[0 0]);
            covariance = nfx.RSMDCB(iid=m.identification.iid,edition=m.identification.edition, ...
                tid='SYNTHETIC',parameters=parameters,blocks=nfx.RSMDCB.block(m.identification.iid,eye(2)));
            image = without(image,'RSMECB')+adjustment;
            verifyIssue(t,rebuild(file,image),'SNIPRSMCovariance');
            r = rebuild(file,image+covariance).validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
        end
        function sensrbSoleModelReportsTheUnavailableExternalProfile(t)
            [file,image] = fixtureSNIP();
            for tag = {'RSMIDA','RSMPCA','RSMECB'}, image = without(image,tag{1}); end
            verifyIssue(t,rebuild(file,image+fixtureSensor()),'SNIPSENSRBProfileUnavailable');
            verifyIssue(t,rebuild(file,image+fixtureRPC()),'SNIPGeopositioning');
        end
        function modelAndDatasetIdentityFailuresAreExplicit(t)
            [file,image,m] = fixtureSNIP(); dataset = m.dataset; dataset.platform_code = 'AU';
            verifyIssue(t,nfx.File(header=file.header)+dataset+image+file.texts(1),'SNIPPlatformScope');
            dataset = m.dataset; dataset.product_id = 'G2';
            verifyIssue(t,nfx.File(header=file.header)+dataset+image+file.texts(1),'SNIPDatasetScope');
            dataset = m.dataset; dataset.process_time = '20260915120000';
            verifyIssue(t,nfx.File(header=file.header)+dataset+image+file.texts(1),'SNIPDatasetTime');
            id = m.identification; id.stid = 'WRONG_RSM';
            verifyIssue(t,rebuild(file,replace(image,'RSMIDA',id)),'SNIPRSMSource');
        end
        function anotherIlluminationTimeCanAugmentTheMatchingSet(t)
            [file,image,m] = fixtureSNIP(); other = m.illumination; other.datetime = '20260915120001';
            r = rebuild(file,image+other).validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
        end
        function documentedExampleIsSelfContained(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'examples')));
            file = snipExample(); r = file.validate(SNIP_COMPLIANT=true);
            t.assertTrue(r.valid,evalc('disp(r.issues)'));
            name = fullfile(t.folder,[file.header.ftitle '.ntf']); file.write(name,SNIP_COMPLIANT=true);
            t.verifyEqual(nitfread(name),file.images(1).data);
        end
        function oneCompleteModelAllowsSupplementaryGenericMetadata(t)
            [file,image] = fixtureSNIP(); exposure = fixtureCSEXRB();
            exposure.sensor_id = 'AG3607'; exposure.num_lines = 5; exposure.num_samples = 7;
            r = rebuild(file,image+exposure+fixtureSensor()+fixtureRPC()).validate(SNIP_COMPLIANT=true);
            t.verifyTrue(r.valid,evalc('disp(r.issues)'));
        end
        function framingGLASUsesExactInlineFrameTime(t)
            [base,image] = fixtureSNIP();
            for tag = {'RSMIDA','RSMPCA','RSMECB'}, image = without(image,tag{1}); end
            e = fixtureCSEXRB('F'); e.sensor_id = 'AG3607'; e.num_lines = 5; e.num_samples = 7;
            e.base_timestamp = '20260915115959.999999999'; e.dt_multiplier = uint64(1); e.dt = uint64(1);
            a = fixtureCSATTB(); a.t0_att = '120000.000000000'; a.dt_att = 1;
            p = fixtureCSEPHB(); p.t0_ephem = '120000.000000000'; p.dt_ephem = 1;
            align = fixtureCSSFAB('F'); cov = fixtureCSCSDB();
            file = rebuild(base,image+e)+a+p+align+cov;
            r = file.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            e.base_timestamp = '20260915120001.999999999';
            verifyIssue(t,rebuild(base,image+e)+a+p+align+cov,'SNIPGLASAcquisition');
        end
        function optionalCovarianceAreaFailsTheSoleGLASProfilePath(t)
            [base,image] = fixtureSNIP();
            for tag = {'RSMIDA','RSMPCA','RSMECB'}, image = without(image,tag{1}); end
            e = fixtureCSEXRB('S'); e.sensor_id = 'AG3607'; e.num_lines = 5; e.num_samples = 7;
            e.time_first_line_image = 43200; e.time_image_duration = .5;
            a = fixtureCSATTB(); a.t0_att = '120000.000000000'; a.dt_att = 1;
            p = fixtureCSEPHB(); p.t0_ephem = '120000.000000000'; p.dt_ephem = 1;
            cov = fixtureCSCSDB(); n = cov.parameter_count;
            cov.adj = zeros(1,n); cov.errcov_c4 = eye(n); cov.spdcf_id_adj = ones(1,n);
            verifyIssue(t,rebuild(base,image+e)+a+p+fixtureCSSFAB('S')+cov,'SNIPCovarianceReserved');
        end
        function rgbQuicklookUsesDisplayOrderAndEquivalentTextTypes(t)
            [file,image,m] = fixtureSNIP(); image.header.idlvl = 1;
            h = image.header; h.iid1 = 'QUICK_LOOK'; h.irep = 'RGB'; h.icat = 'VIS'; h.idlvl = 2;
            h.ialvl = 0; h.isubcat = []; h.irepband = {'R','G','B'}; h.nppbh = 7; h.nppbv = 5;
            h.igeolo = string(h.igeolo); h.icom = 'RGB created from bands 2, 1, 2, wavelengths 650, 450, 650 nm';
            quick = nfx.ImageSegment(image.data(:,:,[2 1 2]),header=h);
            candidate = nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            quick.header.isubcat = [650 NaN 650];
            candidate = nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true);
            t.verifyTrue(r.valid,evalc('disp(r.issues)'));
            quick.header.isubcat = [650 123 NaN];
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1),'SNIPQuicklookWavelength');
            quick.header.isubcat = [];
            quick.header.icom = 'RGB created from bands 2, 1, 3, wavelengths 650, 450, 650 nm';
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+quick+image+file.texts(1),'SNIPQuicklookComment');
        end
        function multipleSpectralImagesKeepIndependentIdentity(t)
            [file,image,m] = fixtureSNIP(); first = image; first.header.iid1 = 'MSI1'; first.header.idlvl = 1;
            second = image; second.header.iid1 = 'MSI2'; second.header.iid2 = 'SYNTHETIC SECOND'; second.header.idlvl = 2;
            id = m.identification; id.iid = second.header.iid2; id.edition = 'SECOND';
            polynomial = fixturePolynomial(); polynomial.iid = second.header.iid2; polynomial.edition = id.edition;
            covariance = m.covariance; covariance.iid = second.header.iid2; covariance.edition = id.edition;
            second = replace(replace(replace(second,'RSMIDA',id),'RSMPCA',polynomial),'RSMECB',covariance);
            candidate = nfx.File(header=file.header)+m.dataset+first+second+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            first.header.iid1 = 'MSI:000001'; second.header.iid1 = 'MSI:000002';
            candidate = nfx.File(header=file.header)+m.dataset+first+second+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
            first.header.iid1 = 'MSI:000003';
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+first+second+file.texts(1),'SNIPSortedIdentifiers');
            first.header.iid1 = 'MSI:AZ'; second.header.iid1 = 'MSI:BA';
            candidate = nfx.File(header=file.header)+m.dataset+first+second+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
            first.header.iid1 = 'MSI:9'; second.header.iid1 = 'MSI:10';
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+first+second+file.texts(1),'SNIPSortedIdentifiers');
            first.header.iid1 = 'MSI:09';
            candidate = nfx.File(header=file.header)+m.dataset+first+second+file.texts(1);
            r = candidate.validate(SNIP_COMPLIANT=true); t.verifyTrue(r.valid,evalc('disp(r.issues)'));
            first.header.iid1 = 'MSI:1:1'; second.header.iid1 = 'MSI:1:2';
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+first+second+file.texts(1),'SNIPSortedIdentifiers');
            first.header.iid1 = 'MSI1';
            duplicate = first; duplicate.header.iid1 = 'MSI2'; duplicate.header.idlvl = 2;
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+first+duplicate+file.texts(1),'SNIPImageIdentity');
        end
        function additionalCitationCanOmitUnavailableComponents(t)
            [file,image,m] = fixtureSNIP(); text = file.texts(1); newline = char([13 10]);
            text.data = [text.data 'STANDARD CITATION 2' newline 'DOC_TITLE: Synthetic dataset description' newline ...
                'CUSTODIAN_ORG: NFX TEST' newline];
            candidate = nfx.File(header=file.header)+m.dataset+image+text;
            r = candidate.validate(SNIP_COMPLIANT=true); t.assertTrue(r.valid,evalc('disp(r.issues)'));
            text.data = strrep(text.data,'STANDARD CITATION 2','STANDARD CITATION 3');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationNumber');
        end
        function processingVocabularyAndScopeAreChecked(t)
            [file,image,m] = fixtureSNIP(); history = m.history;
            history.event.ipcom = char('PROCEV_Custom processing','ALGO_Synthetic 1');
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPHistoryEvent');
            history.event.ipcom = char('PROCEV_Geo-rectification','ALGO_Synthetic 1');
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPProcessingScope');
            history.event.ipcom = char('PROCEV_Radiometric Calibration','ALGO_Synthetic 1','NAME_Another originator');
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPHistoryOriginator');
            history.event.ipcom = char('PROCEV_Radiometric Calibration','ALGO_Synthetic 1','PHONE_202-555-9999');
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPHistoryPhone');
        end
        function subsequentHistoryCommentsInheritUnchangedFields(t)
            [file,image,m] = fixtureSNIP(); history = m.history;
            history.event(2) = history.event(1); history.event(2).ipcom = 'ALGO_Updated format converter 2';
            history.event(3) = history.event(2); history.event(3).ipcom = '';
            r = rebuild(file,replace(image,'HISTOA',history)).validate(SNIP_COMPLIANT=true);
            t.verifyTrue(r.valid,evalc('disp(r.issues)'));
            history.event(1).ipcom = char('PROCEV_Geo-rectification','ALGO_Synthetic 1');
            verifyIssue(t,rebuild(file,replace(image,'HISTOA',history)),'SNIPProcessingScope');
        end
        function certificationAndCitationLineGrammarAreRequired(t)
            [file,image,m] = fixtureSNIP(); text = file.texts(1); newline = char([13 10]);
            text.data = strrep(text.data,['PRODUCT_CERT_DATE: ----------' newline],'');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationRequired');
            text = file.texts(1); text.data = strrep(text.data,'i=5612','i=1');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationVersion');
            text = file.texts(1); text.data = strrep(text.data,'DOC_TITLE: National',['DOC_TITLE: National' char(10)]);
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationField');
            text = file.texts(1); text.data = strrep(text.data,['CUSTODIAN_ORG: '],['AUTHOR_NAME: A Person' newline 'CUSTODIAN_ORG: ']);
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationAuthors');
        end
        function indexedCitationContributorsAreSequential(t)
            [file,image,m] = fixtureSNIP(); text = file.texts(1); newline = char([13 10]);
            text.data = [text.data 'STANDARD CITATION 2' newline 'DOC_TITLE: Synthetic dataset description' newline ...
                'AUTHOR_NAME_1: A Person' newline 'AUTHOR_ORG: NFX' newline 'AUTHOR_NAME_2: B Person' newline ...
                'CUSTODIAN_ORG_1: Example One' newline 'CUSTODIAN_URL: https://example.org' newline ...
                'CUSTODIAN_ORG_2: Example Two' newline];
            candidate = nfx.File(header=file.header)+m.dataset+image+text;
            r = candidate.validate(SNIP_COMPLIANT=true);
            t.assertTrue(r.valid,evalc('disp(r.issues)'));
            text.data = strrep(text.data,'AUTHOR_NAME_2','AUTHOR_NAME_3');
            verifyIssue(t,nfx.File(header=file.header)+m.dataset+image+text,'SNIPCitationContributors');
        end
        function optionalBandAndIlluminationGroupsPreserveProfileOffsets(t)
            [file,image] = fixtureSNIP(); bands = fullBandMetadata(); bands.band(2).cwave = .65;
            image = replace(replace(image,'BANDSB',bands),'ILLUMB',fullIllumination());
            r = rebuild(file,image).validate(SNIP_COMPLIANT=true);
            t.verifyTrue(r.valid,evalc('disp(r.issues)'));
        end
    end
end

function result = without(image,tag)
    %without - Remove a complete logical record for a negative fixture
    result = image; ids = image.tre_ids(strcmp(cellstr(image.tre_tags),tag));
    for id = ids, result = result.removeTRE(id); end
end

function result = replace(image,tag,value)
    %replace - Rebuild one validated metadata attachment
    result = without(image,tag)+value;
end

function value = rebuild(file,image)
    %rebuild - Preserve the fixture's dataset identifier and citation
    [~,~,m] = fixtureSNIP(); value = nfx.File(header=file.header)+m.dataset+image+file.texts(1);
end

function verifyIssue(t,file,id)
    %verifyIssue - Check a profile-only failure by its stable identifier
    t.assertTrue(file.validate().valid); report = file.validate(SNIP_COMPLIANT=true);
    t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),evalc('disp(report.issues)'));
end
