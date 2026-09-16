classdef BandMetadataTest < NfxTest
    methods (Test)
        function minimalCubeHasLiteralBinaryAndUnknownFields(t)
            value = nfx.BANDSB(band=nfx.SpectralBand());
            expected = [uint8(['00001RAW' repmat(' ',1,21) 'D']) ...
                uint8([63 128 0 0 0 0 0 0]) uint8(repmat('------- ',1,4)) zeros(1,52,'uint8')];
            t.verifyEqual(value.payload(),expected);
            t.verifyEqual(value.cel,122); t.verifyEqual(value.count,1);
            t.verifyEqual(value.existence_mask,0);
            value.band = nfx.SpectralBand(bandid="",start_time="",row_gsd_unit="");
            value.radiometric_adjustment_surface = "";
            t.verifyEqual(value.payload(),expected);
            t.verifyFalse(nfx.BANDSB().validate().valid);
        end
        function independentDecoderCoversBinaryFloatsAndEveryCompatibleGroup(t)
            value = fullBandMetadata(); p = value.payload(); out = inspectBANDSB(p);
            t.verifyEqual(value.cel,980);
            t.verifyEqual(p(119:122),uint8([254 247 255 193]));
            t.verifyEqual(p(31:38),uint8([63 0 0 0 192 0 0 0]));
            t.verifyEqual(out.mask,hex2dec('FEF7FFC1'));
            t.verifyEqual(out.count,2); t.verifyEqual(out.scale_factor,.5); t.verifyEqual(out.additive_factor,-2);
            t.verifyEqual(out.altitude,1000); t.verifyEqual(out.diameter,10);
            t.verifyEqual(out.data_fld_1,uint8(255:-1:208)); t.verifyEqual(out.data_fld_2,uint8(128:159));
            a = out.band{1}; b = out.band{2};
            t.verifyEqual(strtrim(a.bandid),'BAND ONE'); t.verifyEqual(strtrim(b.bandid),'BAND TWO');
            t.verifyEqual(a.niirs,'---'); t.verifyEqual(b.niirs,'+++');
            t.verifyEqual([a.bad_band a.focal_len b.focal_len],[1 200 250]);
            t.verifyEqual([a.fwhm a.fwhm_unc a.nom_wave a.nom_wave_unc],[.05 .001 .45 .002]);
            t.verifyEqual([a.scale_factor a.additive_factor],[2 -1]);
            t.verifyEqual(a.start_time,'260915120000.001'); t.verifyEqual(b.start_time,'26----120000.---');
            t.verifyEqual([a.int_time b.int_time a.caldrk a.calibration_sensitivity],[.00001 999999 .1 .01]);
            t.verifyEqual([a.row_gsd a.row_gsd_unc a.col_gsd a.col_gsd_unc],[.25 .001 .5 .01]);
            t.verifyEqual([a.row_gsd_unit a.col_gsd_unit],'MR');
            t.verifyEqual([a.bknoise a.scnnoise],[.002 .003]);
            t.verifyEqual([a.spt_resp_function_row a.spt_resp_unc_row a.spt_resp_function_col a.spt_resp_unc_col],[.4 .002 .6 .003]);
            t.verifyEqual([a.spt_resp_unit_row a.spt_resp_unit_col],'MR');
            t.verifyEqual(a.data_fld_3,uint8(0:15)); t.verifyEqual(a.data_fld_4,uint8(16:39));
            t.verifyEqual(a.data_fld_5,uint8(40:71)); t.verifyEqual(a.data_fld_6,uint8(72:119));
            t.verifyEqual([out.aux_b{1}.values{:}],[-12 9999999999]);
            t.verifyEqual([out.aux_b{2}.values{:}],[.5 -2]);
            t.verifyEqual(strtrim(out.aux_b{3}.values{2}),'green');
            t.verifyEqual(out.aux_c{1}.values{1},-999999999);
            t.verifyEqual(out.aux_c{2}.values{1},.25);
            t.verifyEqual(strtrim(out.aux_c{3}.values{1}),'clear');
        end
        function symmetricFieldsHaveSpecifiedPrecisionAndUnknownAltitude(t)
            band = nfx.SpectralBand(niirs=9.9,cwave=.00001,lbound=.00001,ubound=10000);
            value = nfx.BANDSB(band=band,wave_length_unit="W", ...
                radiometric_adjustment_surface="EARTH SURFACE",row_gsd=.001,row_gsd_unit="M", ...
                diameter=8999.99,col_gsd=9999.99,col_gsd_unit='R');
            out = inspectBANDSB(value.payload());
            t.verifyTrue(isnan(out.altitude)); t.verifyEqual(out.row_gsd,.001); t.verifyEqual(out.col_gsd,9999.99);
            t.verifyEqual(out.diameter,8999.99); t.verifyEqual(out.band{1}.niirs,'9.9');
            t.verifyEqual([out.band{1}.cwave out.band{1}.lbound out.band{1}.ubound],[.00001 .00001 10000]);
        end
        function masksRejectIncompleteAndIncompatibleSpectralGroups(t)
            t.verifyFalse(nfx.SpectralBand(cwave=.5,fwhm=.1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(cwave=.5,nom_wave=.5).validate().valid);
            t.verifyFalse(nfx.SpectralBand(fwhm=.1,lbound=.4,ubound=.6).validate().valid);
            t.verifyFalse(nfx.SpectralBand(fwhm_unc=.1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(nom_wave_unc=.1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(row_gsd_unc=.1,col_gsd_unc=.1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(spt_resp_unc_row=.1,spt_resp_unc_col=.1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(lbound=.6,ubound=.4).validate().valid);
            t.verifyFalse(nfx.SpectralBand(scale_factor=2).validate().valid);
            t.verifyFalse(nfx.SpectralBand(lbound=.4).validate().valid);
            t.verifyFalse(nfx.SpectralBand(caldrk=1).validate().valid);
            t.verifyFalse(nfx.SpectralBand(bknoise=1).validate().valid);
        end
        function allBandGroupsMustShareOneLayoutAndUniqueIdentifiers(t)
            value = nfx.BANDSB(band=[nfx.SpectralBand(niirs=1) nfx.SpectralBand()]);
            t.verifyFalse(value.validate().valid);
            value.band = repmat(nfx.SpectralBand(bandid='B1'),1,2);
            t.verifyFalse(value.validate().valid);
            value.band(2).bandid = 'B2';
            t.verifyTrue(value.validate().valid);
            value.band(2).bandid = ' ';
            t.verifyFalse(value.validate().valid);
        end
        function valuesRejectWrongTypesMissingNumbersAndInvalidCalendar(t)
            t.verifyError(@() nfx.SpectralBand(focal_len=uint32(10)),'nfx:MetadataArray');
            t.verifyError(@() nfx.SpectralBand(cwave=[1 2]),'nfx:OptionalMetadata');
            t.verifyError(@() nfx.BANDSB(data_fld_1=zeros(1,48)),'nfx:ByteField');
            t.verifyError(@() nfx.BANDSB(band=1),'nfx:SpectralBands');
            t.verifyFalse(nfx.SpectralBand(focal_len=NaN).validate().valid);
            t.verifyFalse(nfx.SpectralBand(start_time='260229120000.000').validate().valid);
            t.verifyTrue(nfx.SpectralBand(start_time='240229------.---').validate().valid);
            t.verifyFalse(nfx.SpectralBand(start_time='261315120000.000').validate().valid);
            t.verifyFalse(nfx.SpectralBand(start_time='260915120060.000').validate().valid);
            t.verifyFalse(nfx.SpectralBand(start_time='260915120000-000').validate().valid);
            t.verifyFalse(nfx.SpectralBand(scale_factor=1e-39,additive_factor=0).validate().valid);
            t.verifyFalse(nfx.SpectralBand(row_gsd=1,row_gsd_unit='Q',col_gsd=1,col_gsd_unit='M').validate().valid);
        end
        function cubeUnitAltitudeAndFieldPresenceRulesAreEnforced(t)
            value = nfx.BANDSB(band=nfx.SpectralBand());
            value.radiometric_quantity = 'REFLECTANCE'; t.verifyFalse(value.validate().valid);
            value.radiometric_quantity_unit = 'P'; t.verifyTrue(value.validate().valid);
            value.radiometric_quantity_unit = 'M'; t.verifyFalse(value.validate().valid);
            value.radiometric_quantity = 'RAW'; value.radiometric_quantity_unit = 'D';
            value.row_gsd = 1; t.verifyFalse(value.validate().valid);
            value.row_gsd_unit = 'M'; t.verifyTrue(value.validate().valid);
            value.radiometric_adjustment_surface = 'WITHIN ATMOSPHERE'; t.verifyFalse(value.validate().valid);
            value.atmospheric_adjustment_altitude = 10; t.verifyTrue(value.validate().valid);
            value.radiometric_adjustment_surface = 'EARTH SURFACE'; t.verifyFalse(value.validate().valid);
            value.atmospheric_adjustment_altitude = NaN;
            value.wave_length_unit = 'U'; t.verifyFalse(value.validate().valid);
            value.band = nfx.SpectralBand(cwave=.5); t.verifyTrue(value.validate().valid);
            value.diameter = NaN; t.verifyFalse(value.validate().valid);
        end
        function auxiliaryValuesHaveExactCountsTypesAndSelectedFormat(t)
            value = fullBandMetadata();
            value.aux_b(1).apn = 1; t.verifyFalse(value.validate().valid);
            value.aux_b(1).apn = [1 2]; value.aux_b(1).apr = [1 2]; t.verifyFalse(value.validate().valid);
            value.aux_b(1).apr = []; value.aux_b(1).bapf = 'X'; t.verifyFalse(value.validate().valid);
            value.aux_b(1).bapf = 'I'; value.aux_b(1).ubap = ''; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.BANDSB(aux_b=struct('bapf','I')),'nfx:BandAuxiliary');
            t.verifyError(@() nfx.BANDSB(aux_b=struct('bapf','I','ubap','UNIT','apn',single(1),'apr',[],'apa','')),'nfx:MetadataArray');
            value = fullBandMetadata(); value.aux_c(1).apn = NaN;
            t.verifyFalse(value.validate().valid);
            value = fullBandMetadata(); value.aux_b(2).apr = [1e-39 1];
            t.verifyFalse(value.validate().valid);
        end
        function payloadLimitIsCheckedBeforeSerialization(t)
            band = nfx.SpectralBand(data_fld_6=zeros(1,48,'uint8'));
            value = nfx.BANDSB(band=repmat(band,1,2080));
            t.verifyEqual(value.cel,99962);
            value.band(end+1) = band;
            t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.payload(),'nfx:Invalid');
        end
        function attachmentSnapshotsPreserveByteOrderAndRemoval(t)
            [file,image] = fixtureFile();
            originalIds = image.tre_ids;
            value = fullBandMetadata(); before = value.payload();
            image = image+value; id = image.tre_ids(end);
            value.band(1).bad_band = 0;
            t.verifyEqual(image.tre_records(end).payload,before);
            image = image.removeTRE(id); t.verifyEqual(image.tre_ids,originalIds);
            t.verifyError(@() plus(file,value),'nfx:TREPlacement');
            wrapper = nfx.FSYNWA(start_frame_number=1)+value;
            image = image+wrapper; t.verifyEqual(image.tre_tags(end,:),'FSYNWA');
        end
    end
end
