classdef IlluminationTest < NfxTest
    methods (Test)
        function verticalReferencesExistExactlyWhenAnyHeightIsKnown(t)
            value = nfx.ILLUMB(lbound=.4,ubound=.7,datetime='20190621194935', ...
                target_lat=36.588,target_lon=-116.943,sun_azimuth=180,sun_elev=76.8);
            encoded = value.payload();
            t.verifyEqual(encoded(247:330),repmat(uint8(' '),1,84));
            t.verifyEqual(encoded(372:385),repmat(uint8(' '),1,14));
            value.target_hgt = NaN;
            t.verifyEqual(value.payload(),encoded);
            value.vertical_datum_ref = 'Geodetic'; value.vertical_ref_code = 'GEOD';
            t.verifyFalse(value.validate().valid);
            value.target_hgt = 10; t.verifyTrue(value.validate().valid);
            value = fullIllumination(); value.target_hgt = [NaN 100];
            parsed = inspectILLUMB(value.payload());
            t.verifyEqual(strtrim(parsed.vertical_ref_code),'GEOD');
            t.verifyTrue(isnan(parsed.target_hgt(1))); t.verifyEqual(parsed.target_hgt(2),100);
            value.target_hgt = [NaN NaN]; t.verifyFalse(value.validate().valid);
            value.vertical_datum_ref = ''; value.vertical_ref_code = '';
            t.verifyTrue(value.validate().valid);
        end
        function solarGeometryMatchesPublishedLayoutAndPrecision(t)
            value = fixtureIllumination();
            encoded = value.payload();
            t.verifyEqual(value.cel,395);
            t.verifyEqual(value.existence_mask,4194304);
            t.verifyEqual(encoded(45:76),uint8('4.0000000000E-017.0000000000E-01'));
            t.verifyEqual(encoded(331:333),uint8([64 0 0]));
            t.verifyEqual(char(encoded(337:371)),'20190621194935+36.588----116.943---');
            parsed = inspectILLUMB(encoded);
            t.verifyEqual(parsed.sun_azimuth,180); t.verifyEqual(parsed.sun_elev,76.8);
            t.verifyEqual(parsed.target_hgt,-57);
            t.verifyEqual(parsed.target_lat_text,'+36.588---');
            t.verifyEqual(parsed.target_lon_text,'-116.943---');
            t.verifyEqual(uint8(parsed.band_unit(1:2)),uint8([181 109]));
        end
        function fullMaskPreservesSetBandAndOtherSourceOrder(t)
            value = fullIllumination();
            t.verifyEqual(value.existence_mask,16776960);
            t.verifyEqual(value.cel,1410);
            parsed = inspectILLUMB(value.payload());
            t.verifyEqual([parsed.num_bands parsed.num_others parsed.num_coms parsed.num_illum_sets],[2 2 1 2]);
            t.verifyEqual(parsed.sun_azimuth,[180 181]); t.verifyEqual(parsed.sun_elev,[50 51]);
            t.verifyEqual(parsed.moon_azimuth,[200 201]); t.verifyEqual(parsed.moon_elev,[20 21]);
            t.verifyEqual(parsed.moon_phase_angle,[-50 50]); t.verifyEqual(parsed.moon_illum_percent,[85 86]);
            t.verifyEqual(parsed.other_azimuth,[10 11;12 13]); t.verifyEqual(parsed.other_elev,[30 31;32 33]);
            t.verifyEqual(parsed.sensor_azimuth,[70 71]); t.verifyEqual(parsed.sensor_elev,[80 81]);
            t.verifyEqual(parsed.cats_angle,[90 91]); t.verifyEqual(parsed.catm_angle,[95 96]);
            t.verifyEqual(parsed.sun_glint_lat,[10 11]); t.verifyEqual(parsed.sun_glint_lon,[20 21]);
            t.verifyEqual(parsed.moon_glint_lat,[30 31]); t.verifyEqual(parsed.moon_glint_lon,[40 41]);
            t.verifyEqual(parsed.sol_lun_dist_adjust,[1 1.1]);
            t.verifyEqual(parsed.sun_illum,[1 2;3 4]); t.verifyEqual(parsed.moon_illum,[5 6;7 8]);
            t.verifyEqual(parsed.tot_sunmoon_illum,[6 8;10 12]);
            t.verifyEqual(parsed.other_illum,reshape(11:18,2,2,2));
            t.verifyEqual(parsed.other_illum_method,reshape('PMPMMPMP',2,2,2));
            t.verifyEqual(parsed.sun_illum_method,['PM';'MP']); t.verifyEqual(parsed.moon_illum_method,['MP';'PM']);
            t.verifyEqual(parsed.art_illum_min,[21 22;23 24]); t.verifyEqual(parsed.art_illum_max,[31 32;33 34]);
            t.verifyEqual(parsed.art_illum_method,['PP';'MM']);
            t.verifyEqual(uint8(parsed.comment(1,1:4)),uint8([67 97 102 233]));
        end
        function omittedAndUnknownFieldsRemainDistinct(t)
            value = fixtureIllumination();
            value.moon_azimuth = NaN;
            parsed = inspectILLUMB(value.payload());
            t.verifyTrue(isnan(parsed.moon_azimuth)); t.verifyTrue(isnan(parsed.moon_elev));
            value.rad_quantity = 'RADIANCE'; value.radq_unit = 'W/(m m sr)';
            value.sun_illum_method = 'P';
            parsed = inspectILLUMB(value.payload());
            t.verifyTrue(isnan(parsed.sun_illum));
            value.sun_illum_method = ''; value.sun_illum = NaN;
            t.verifyFalse(value.validate().valid);
            value.sun_illum = []; value.sun_azimuth = NaN; value.sun_elev = NaN;
            t.verifyFalse(value.validate().valid);
        end
        function quantitiesRequireExplicitUnitsAndOrderedRanges(t)
            value = fixtureIllumination();
            value.sun_illum = 1; value.sun_illum_method = 'M';
            t.verifyFalse(value.validate().valid);
            value.rad_quantity = 'RADIANCE'; value.radq_unit = 'W';
            t.verifyFalse(value.validate().valid);
            value.radq_unit = 'W/(m m sr)';
            t.verifyTrue(value.validate().valid);
            value.art_illum_method = 'P'; value.art_illum_min = 10; value.art_illum_max = 9;
            t.verifyFalse(value.validate().valid);
            value.art_illum_max = 11;
            t.verifyTrue(value.validate().valid);
        end
        function coordinateAndTimestampPrecisionValidateWithoutInventingData(t)
            value = fixtureIllumination();
            value.coordinate_precision = zeros(6,1);
            parsed = inspectILLUMB(value.payload());
            t.verifyEqual(parsed.target_lat_text,'+37.------');
            t.verifyEqual(parsed.target_lon_text,'-117.------');
            value.datetime = '20260229------';
            t.verifyFalse(value.validate().valid);
            value.datetime = '20240229------';
            t.verifyTrue(value.validate().valid);
            value.datetime = '20260915120---';
            t.verifyTrue(value.validate().valid);
            value.datetime = '2026--15120000';
            t.verifyFalse(value.validate().valid);
            value.datetime = '20260915120000'; value.target_lat = NaN;
            t.verifyFalse(value.validate().valid);
        end
        function datumRegistryPairsAndBlankVerticalReference(t)
            value = fixtureIllumination();
            value.ellipsoid_code = 'RF';
            t.verifyFalse(value.validate().valid);
            value.geo_datum_code = 'NAR'; value.geo_datum = 'North American 1983';
            value.ellipsoid_name = 'Geodetic Reference System 1980';
            t.verifyTrue(value.validate().valid);
            value.geo_datum_code = 'WGE'; value.ellipsoid_code = 'WGE';
            value.geo_datum = 'World Geodetic System 1984'; value.ellipsoid_name = 'World Geodetic System 1984';
            t.verifyTrue(value.validate().valid);
            value.geo_datum_code = 'BAD';
            t.verifyFalse(value.validate().valid);
            value.geo_datum_code = 'WGE'; value.vertical_ref_code = ''; value.vertical_datum_ref = '';
            t.verifyFalse(value.validate().valid);
            value.target_hgt = NaN;
            t.verifyTrue(value.validate().valid);
        end
        function arrayShapesGlintPairsAndSourceNamesAreChecked(t)
            value = fixtureIllumination();
            value.ubound = [.7 .8];
            t.verifyFalse(value.validate().valid);
            value.ubound = .3;
            t.verifyFalse(value.validate().valid);
            value.ubound = .7; value.sun_glint_lat = 20;
            t.verifyFalse(value.validate().valid);
            value.sun_glint_lon = 30;
            t.verifyTrue(value.validate().valid);
            value.other_azimuth = 20;
            t.verifyFalse(value.validate().valid);
            value.other_name = 'VENUS';
            t.verifyTrue(value.validate().valid);
            value.other_name = 'UNKNOWN';
            t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.ILLUMB(target_lat=single(1)),'nfx:MetadataArray');
            t.verifyError(@() nfx.ILLUMB(sun_illum_method='X'),'nfx:IlluminationMethod');
        end
        function totalLengthHonorsThePhysicalTREBoundary(t)
            value = nfx.ILLUMB(lbound=[.4 .5 .6],ubound=[.5 .6 .7], ...
                datetime=repmat('20260915120000',995,1),target_lat=zeros(1,995),target_lon=zeros(1,995), ...
                sun_illum=ones(3,995),sun_illum_method=repmat('P',3,995),rad_quantity='RADIANT_FLUX',radq_unit='W');
            t.verifyEqual(value.cel,99980);
            value.datetime = repmat('20260915120000',996,1);
            value.target_lat = zeros(1,996); value.target_lon = zeros(1,996);
            value.sun_illum = ones(3,996); value.sun_illum_method = repmat('P',3,996);
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.ILLUMB().validate().valid);
        end
        function chronologicalSetsAndAsynchronousWrapperRoundTrip(t)
            value = fullIllumination();
            value.datetime = ["20260915120001" "20260915120000"];
            t.verifyFalse(value.validate().valid);
            value = fixtureIllumination();
            wrapper = nfx.FASYWA(start_timestamp='20190621194935.---------', ...
                end_timestamp='20190621194936.---------')+value;
            t.verifyTrue(wrapper.validate().valid);
            file = fixtureFile()+wrapper;
            name = fullfile(t.folder,'illumination.ntf'); file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.allTRE(1).tag,'FASYWA');
            t.verifyEqual(parsed.allTRE(1).payload(49:end),value.bytes());
        end
    end
end
