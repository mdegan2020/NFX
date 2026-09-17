classdef TREDecodeVariantsTest < NfxTest
    methods (Test)
        function moonPercentageRequiresAnIntegerOrUnknownSentinel(t)
            value = nfx.ILLUMB(lbound=.4, ubound=.7, ...
                datetime='20190621194935', target_lat=36.588, ...
                target_lon=-116.943, target_hgt=NaN, ...
                moon_illum_percent=85);
            payload = value.payload();
            t.assertEqual(char(payload(end - 2:end)), '085');
            payload(end - 2:end) = uint8('1.5');
            [copy, ok, status] = nfx.ILLUMB.deserialize(payload);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidNumber');
            t.verifyEqual(copy, nfx.ILLUMB());
            value.moon_illum_percent = NaN;
            value.sun_azimuth = 0;
            value.sun_elev = 0;
            copy = roundTrip(t, value);
            t.verifyTrue(isnan(copy.moon_illum_percent));
        end

        function complexOrNonfiniteNiirsReturnsStatus(t)
            value = nfx.BANDSB(band=nfx.SpectralBand(niirs=1));
            payload = value.payload();
            for word = {' 1i', '+1i', 'NaN', 'Inf'}
                damaged = payload;
                damaged(end - 2:end) = uint8(word{1});
                [copy, ok, status] = nfx.BANDSB.deserialize(damaged);
                t.verifyFalse(ok);
                t.verifyEqual(status.code, 'InvalidNumber');
                t.verifyEqual(copy, nfx.BANDSB());
            end
        end

        function zeroAndUnknownAircraftSpacingStayDistinct(t)
            value = fixtureAircraft();
            value.row_spacing = 0;
            value.row_spacing_units = 'm';
            decoded = roundTrip(t, value);
            t.verifyEqual(decoded.row_spacing, 0);
            t.verifyTrue(isnan(decoded.col_spacing));
            value.row_spacing = NaN;
            decoded = roundTrip(t, value);
            t.verifyTrue(isnan(decoded.row_spacing));
        end

        function binary32BoundaryAndAsymmetricSpectralFields(t)
            value = fullBandMetadata();
            value.scale_factor = 1e-38;
            value.atmospheric_adjustment_altitude = -1e-38;
            value.band(1).scale_factor = 1e-38;
            value.aux_b(2).apr = [1e-38 -1e-38];
            copy = roundTrip(t, value);
            t.verifyEqual(copy.scale_factor, double(single(1e-38)));
            t.verifyEqual(copy.band(2).niirs, 10);
            band = nfx.SpectralBand(nom_wave=.5, nom_wave_unc=.01, ...
                lbound=.4, ubound=.7);
            roundTrip(t, nfx.BANDSB(band=band, wave_length_unit='U'));
            roundTrip(t, nfx.BANDSB(band=nfx.SpectralBand()));
        end

        function precisionAndUnknownIlluminationGroups(t)
            copy = roundTrip(t, fixtureIllumination());
            t.verifyEqual(copy.coordinate_precision(1:2), [3; 3]);
            value = fullIllumination();
            value.sun_elev = NaN(1, 2);
            value.moon_illum = NaN(2, 2);
            value.coordinate_precision = repmat((0:5).', 1, 2);
            copy = roundTrip(t, value);
            t.verifyEqual(copy.coordinate_precision, value.coordinate_precision);
            t.verifyTrue(all(isnan(copy.sun_elev)));
        end

        function historyKeepsExplicitDecimalPrecision(t)
            event = fullHistoryEvent();
            event.rot_angle = 90.5;
            event.zoomrow = 2.5;
            event.zoomcol = 2;
            event.mag_level = 1;
            event.dra_mult = 1.25;
            event.decimal_places = [1 2 3 4 5];
            copy = roundTrip(t, nfx.HISTOA(systype='TBD', event=event));
            t.verifyEqual(copy.event.decimal_places, event.decimal_places);
            roundTrip(t, nfx.HISTOA(systype='TBD', event=fixtureHistoryEvent()));
            roundTrip(t, nfx.ICHIPB(xfrm_flag=1));
        end

        function groundParametersAndBasisOrdering(t)
            parameters = nfx.RSMParameters(aptyp='G', loctyp='R', ...
                nsfx=1, nsfy=1, nsfz=1, noffx=0, noffy=0, noffz=0, ...
                xuol=100, yuol=200, zuol=300, ...
                xuxl=0, xuyl=-1, xuzl=0, yuxl=1, yuyl=0, yuzl=0, ...
                zuxl=0, zuyl=0, zuzl=1, gsapid={'OFFZ', 'ROTX'});
            copy = roundTrip(t, nfx.RSMAPB(edition='E', tid='T', ...
                parameters=parameters, parval=[4 -3]));
            t.verifyEqual(copy.parameters.gsapid, {'OFFZ', 'ROTX'});
            t.verifyEqual(copy.parameters.xuyl, -1);
            parameters = fixtureRSMParameters();
            parameters.xpwrr = [0 1];
            parameters.ypwrr = [0 0];
            parameters.zpwrr = [0 0];
            parameters.ael = [.6 .8 0; 0 0 1];
            copy = roundTrip(t, nfx.RSMAPB(edition='E', tid='T', ...
                parameters=parameters, parval=[7 8]));
            t.verifyEqual(copy.parameters.ael, parameters.ael);
        end

        function covarianceFormsAndOmittedDefinitions(t)
            correlation = nfx.RSMCorrelation(ac=1, alpc=0, betc=2, tc=5);
            value = nfx.RSMECB(edition='E', tid='T', urr=4, urc=2, ucc=1, ...
                row_correlation=correlation, column_correlation=correlation);
            copy = roundTrip(t, value);
            t.verifyEmpty(copy.parameters);
            value.parameters = fixtureRSMParameters();
            value.subgroups = [nfx.RSMECB.subgroup(4, 1, correlation) ...
                nfx.RSMECB.subgroup([9 3; 3 16], 2, correlation)];
            value.map = [11 12 13; 21 22 23];
            copy = roundTrip(t, value);
            t.verifyEqual(copy.map, value.map);
            t.verifyEqual(copy.subgroups(2).errcvg, [9 3; 3 16]);
            roundTrip(t, nfx.RSMDCB(iid='A', edition='E', tid='T', ...
                blocks=nfx.RSMDCB.block('A', 1)));
        end

        function modelAxesAndGridOffsetsHaveIndependentOrder(t)
            value = fixturePolynomial();
            value.rnpcf = reshape(1:24, 2, 3, 4);
            copy = roundTrip(t, value);
            t.verifyEqual(copy.rnpcf(2, 3, 4), 24);
            value = fixtureRSMGrid();
            value.planes(2) = nfx.RSMGGA.plane( ...
                [1 NaN 3; 4 5 6], [11 12 13; 14 15 NaN], ...
                ixo=-2, iyo=3);
            copy = roundTrip(t, value);
            t.verifyEqual(copy.planes(2), value.planes(2));
            warp = fixtureWarpingSet();
            warp.fl_warp = 2;
            warp.a = [1 2 3; 4 5 6];
            copy = roundTrip(t, nfx.CSWRPB(sensor_type='F', ...
                wrp_interp=1, warp_data=[warp warp]));
            t.verifyEqual(copy.warp_data(2).a, warp.a);
        end

        function exploitationTextNumericAndExactExposureIndices(t)
            value = fixtureCSEXRB('F');
            value.dt_multiplier = intmax('uint64');
            value.dt = intmax('uint64');
            criteria = [nfx.CollectionCriterion( ...
                collect_criteria_name='Spectral Radiance', ...
                collect_criteria_value=1.25), nfx.CollectionCriterion( ...
                collect_criteria_name='Object Name', ...
                collect_criteria_value='example')];
            metrics = [nfx.QualityMetric(quality_metric_name='CE90', ...
                quality_metric_value=1.25, quality_metric_type='M'), ...
                nfx.QualityMetric(quality_metric_name='Invalid Data', ...
                quality_metric_value='False', quality_metric_type='M')];
            operation = nfx.ImagingOperation(cm_id='mode', ...
                sensor_config='config', img_op_id='operation', num_exp=2, ...
                index_in_img_op_id=[intmax('uint64') - uint64(1), ...
                                   intmax('uint64')], ...
                quality_metrics=metrics);
            value.exploitation = nfx.ExploitationInfo(num_img_ops=2, ...
                tgt_name='Example', tgt_type='Point', tgt_lat=-45, ...
                tgt_lon=123, tgt_ht=123.4, collect_criteria=criteria, ...
                img_ops_data=operation);
            copy = roundTrip(t, value);
            t.verifyEqual(copy.exploitation.img_ops_data.index_in_img_op_id, ...
                operation.index_in_img_op_id);
            t.verifyEqual(copy.exploitation.collect_criteria(2).collect_criteria_value, ...
                'example');
            t.verifyEqual(copy.dt_multiplier, intmax('uint64'));
            value.time_stamp_loc = 1;
            value.base_timestamp = '';
            value.number_frames = NaN;
            value.dt = zeros(1, 0, 'uint64');
            value.dt_multiplier = uint64(1);
            roundTrip(t, value);
            roundTrip(t, fixtureCSEXRB('S'));
        end

        function sensorContinuationFailuresAndEncodedUnderflow(t)
            value = fixtureSensor();
            value.uncertainty_data = nfx.SENSRB.uncertainty('06a', 1e-110);
            copy = roundTrip(t, value);
            t.verifyGreaterThan(copy.uncertainty_data.uncertainty_value, 0);
            t.verifyLessThan(copy.uncertainty_data.uncertainty_value, 1e-99);
            value.time_stamped_data = nfx.SENSRB.timeSeries( ...
                '10a', 0:9999, 1:10000);
            records = value.physicalRecords();
            [copy, ok, status] = nfx.SENSRB.deserializeRecords(records);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.physicalRecords(), records);
            [~, ok, status] = nfx.SENSRB.deserialize(records(2).payload);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'MissingContext');
            records(2).payload(5) = uint8('9');
            [copy, ok] = nfx.SENSRB.deserializeRecords(records);
            t.verifyFalse(ok);
            t.verifyEqual(copy, nfx.SENSRB());
        end

        function exampleCanWriteAfterEditing(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples')));
            [image, original, edited] = inspectionExample();
            t.verifyEqual(original.err_bias, 0);
            t.verifyEqual(edited.err_bias, .25);
            base = fixtureFile();
            file = nfx.File(header=base.header) + image;
            path = fullfile(t.folder, 'decoded-edit.ntf');
            file.write(path);
            t.verifyEqual(nitfread(path), image.data);
            t.verifyEqual(image.RPC00B().err_bias, .25);
        end
    end
end

function decoded = roundTrip(t, value)
    %roundTrip - Check canonical bytes before asserting decoded field values
    payload = value.payload();
    [decoded, ok, status] = value.deserialize(payload);
    t.assertTrue(ok, status.message);
    t.verifyEqual(decoded.payload(), payload);
end
