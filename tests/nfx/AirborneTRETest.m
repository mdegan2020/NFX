classdef AirborneTRETest < NfxTest
    properties (TestParameter)
        invalidMission = {'','A123','AA1X','U199','AB123'}
        invalidLocation = {'4030X07515W','4060N07515W','9000N07515W','4030N18000W','4030N07560W'}
    end
    methods (Test)
        function sensorTypeMustMatchIdentifierAndMode(t)
            value = nfx.ACFTB(sensor_id_type='MMFR',sensor_id='PKSAR',mplan=20,pdate='20260915');
            t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.payload(),'nfx:Invalid');
            value.sensor_id_type = 'SAR'; t.verifyTrue(value.validate().valid);
            value.sensor_id = 'GEO123'; value.mplan = 101; t.verifyFalse(value.validate().valid);
            value.sensor_id_type = 'MMFR'; t.verifyTrue(value.validate().valid);
            value.sensor_id = 'MBSAR'; value.mplan = 1; t.verifyFalse(value.validate().valid);
            value.sensor_id = 'ALIRT'; value.mplan = 24; t.verifyFalse(value.validate().valid);
        end
        function mixedModalitySensorUsesItsSelectedMode(t)
            value = nfx.ACFTB(sensor_id_type='SAR',sensor_id='RTNESS',mplan=1,pdate='20260915');
            t.verifyTrue(value.validate().valid);
            value.mplan = 4; t.verifyFalse(value.validate().valid);
            value.sensor_id_type = 'MMFR'; t.verifyTrue(value.validate().valid);
            value.mplan = 1; t.verifyFalse(value.validate().valid);
            value.sensor_id_type = 'SAR'; value.patch_tot = 2;
            t.verifyFalse(value.validate().valid);
        end
        function additionalIdentificationLiteralPayload(t)
            value = nfx.AIMIDB(acquisition_date='20260915120000',mission_no='AB12', ...
                mission_identification='SYNTHETIC',flight_no='A1',op_num=7,current_segment='AB', ...
                repro_num=2,replay='G01',start_tile_column=3,start_tile_row=4,end_segment='AC', ...
                end_tile_column=5,end_tile_row=6,country='US',location='4030N07515W');
            expected = ['20260915120000AB12SYNTHETIC A1007AB02G01 ' ...
                '00300004AC00500006US    4030N07515W' repmat(' ',1,13)];
            t.verifyEqual(value.cel,89);
            t.verifyEqual(value.payload(),uint8(expected));
            value.replay = ''; value.country = ''; value.location = '';
            t.verifyTrue(value.validate().valid);
            t.verifyFalse(nfx.AIMIDB().validate().valid);
        end
        function acquisitionRejectsInvalidMission(t,invalidMission)
            t.verifyInvalid(@() nfx.AIMIDB(acquisition_date='20260915120000',mission_no=invalidMission));
        end
        function acquisitionRejectsInvalidLocation(t,invalidLocation)
            value = nfx.AIMIDB(acquisition_date='20260915120000',location=invalidLocation);
            t.verifyFalse(value.validate().valid);
        end
        function acquisitionDatesFlightsAndSegmentOrder(t)
            value = nfx.AIMIDB(acquisition_date='20260229120000');
            t.verifyFalse(value.validate().valid);
            value.acquisition_date = '20240229120000';
            t.verifyTrue(value.validate().valid);
            value.flight_no = 'A0';
            t.verifyFalse(value.validate().valid);
            value.flight_no = 'Z9'; value.current_segment = 'AB';
            t.verifyFalse(value.validate().valid);
            value.end_segment = '00';
            t.verifyTrue(value.validate().valid);
            value.replay = 'G00';
            t.verifyFalse(value.validate().valid);
            value.replay = 'P99'; value.op_num = NaN;
            t.verifyFalse(value.validate().valid);
        end
        function aircraftLiteralFieldOrderAndNumericPrecision(t)
            value = nfx.ACFTB(ac_msn_id='SYNTHETIC',ac_tail_no='NFXTEST',ac_to='202609151130', ...
                sensor_id_type='MMFR',sensor_id='AG3607',scene_source=0,scnum=123,pdate='20260915',mplan=24, ...
                entloc='+40.12345678-075.12345678',loc_accy=1.25,entelv=123,elv_unit='m', ...
                exitloc='+41.12345678-076.12345678',exitelv=-12,tmap=45.25, ...
                row_spacing=1.25,row_spacing_units='m',col_spacing=200,col_spacing_units='r', ...
                focal_length=25.5,senserial=1234,abswver='TST1',cal_date='20260901');
            expected = ['SYNTHETIC           NFXTEST   202609151130MMFRAG36070000123' ...
                '2026091500000000000024+40.12345678-075.12345678001.25+00123m' ...
                '+41.12345678-076.12345678-00012045.25001.2500m0200.00r025.50001234TST1   202609010000000'];
            t.verifyEqual(value.cel,207);
            t.verifyEqual(value.payload(),uint8(expected));
        end
        function aircraftUnknownSentinelsAreExplicit(t)
            value = fixtureAircraft();
            encoded = value.payload();
            t.verifyEqual(char(encoded(158:179)), '0000000u0000000u999.99');
            t.verifyEqual(char(encoded(113:119)), repmat(' ',1,7));
            value.focal_length = 999.99;
            t.verifyTrue(value.validate().valid);
            value.focal_length = 950;
            t.verifyFalse(value.validate().valid);
        end
        function aircraftCoordinateFormsAndElevationUnits(t)
            value = fixtureAircraft();
            value.entloc = '403015.1234N0751512.3456W';
            t.verifyTrue(value.validate().valid);
            value.entelv = 0;
            t.verifyFalse(value.validate().valid);
            value.elv_unit = 'f';
            t.verifyTrue(value.validate().valid);
            value.entloc = '403060.1234N0751512.3456W';
            t.verifyFalse(value.validate().valid);
            value.entloc = '+90.00000000+180.00000000';
            t.verifyTrue(value.validate().valid);
            value.entloc = '+90.00000001+180.00000000';
            t.verifyFalse(value.validate().valid);
        end
        function aircraftChecksUnitsAndRequiredMetadata(t)
            value = fixtureAircraft();
            value.row_spacing = 1;
            t.verifyFalse(value.validate().valid);
            value.row_spacing_units = 'f';
            t.verifyTrue(value.validate().valid);
            value.row_spacing = 100;
            t.verifyFalse(value.validate().valid);
            value.row_spacing_units = 'r';
            t.verifyTrue(value.validate().valid);
            value.patch_tot = 1;
            t.verifyFalse(value.validate().valid);
            value.patch_tot = 0; value.scnum = 1; value.imhostno = 2;
            t.verifyFalse(value.validate().valid);
            value.scnum = 0;
            t.verifyTrue(value.validate().valid);
            value.pdate = '20260229';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.ACFTB().validate().valid);
            t.verifyError(@() nfx.ACFTB(entelv=single(1)),'nfx:Metadata');
        end
        function sensorSpecificModesAndSourcesUsePublishedValues(t)
            value = nfx.ACFTB(sensor_id_type='SAR',sensor_id='AIP',mplan=18,pdate='20260915',patch_tot=2);
            t.verifyFalse(value.validate().valid);
            value.patch_tot = 1;
            t.verifyTrue(value.validate().valid);
            value.mplan = 7;
            t.verifyFalse(value.validate().valid);
            value.sensor_id = 'DB110'; value.sensor_id_type = 'VHFR'; value.patch_tot = 0;
            value.scene_source = 3;
            t.verifyTrue(value.validate().valid);
            value.scene_source = 4;
            t.verifyFalse(value.validate().valid);
            value.sensor_id = 'GEO123'; value.mplan = 101; value.scene_source = NaN;
            t.verifyTrue(value.validate().valid);
            value.mplan = 100;
            t.verifyFalse(value.validate().valid);
            value.sensor_id = 'BOGUS';
            t.verifyFalse(value.validate().valid);
        end
        function airborneRecordsAttachToImages(t)
            [file,image] = fixtureFile();
            acquisition = nfx.AIMIDB(acquisition_date='20260915120000');
            aircraft = fixtureAircraft();
            image = image+acquisition+aircraft;
            file = nfx.File(header=file.header)+image;
            name = fullfile(t.folder,'airborne-metadata.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual({parsed.images(1).allTRE.tag},{'RPC00B','AIMIDB','ACFTB '});
            t.verifyEqual(parsed.images(1).allTRE(3).payload,aircraft.payload());
            t.verifyError(@() plus(file,acquisition),'nfx:TREPlacement');
        end
    end
    methods (Access = private)
        function verifyInvalid(t,construct)
            %verifyInvalid - Accept either strict assignment or report rejection
            try
                value = construct();
            catch problem
                t.verifyEqual(problem.identifier,'nfx:Text');
                return
            end
            t.verifyFalse(value.validate().valid);
        end
    end
end
