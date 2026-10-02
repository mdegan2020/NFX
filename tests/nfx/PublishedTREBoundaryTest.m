classdef PublishedTREBoundaryTest < NfxTest
    methods (Test)
        function decimalSpacingRejectsUnderflow(t)
            grid = nfx.GRDPSB.gridsEntry();
            grid.bad = 'GRID'; grid.lod = 1e-11; grid.lad = 1;
            grid.lso = 0; grid.pso = 0;
            tre = nfx.GRDPSB(grids=grid);
            roundTrip(t, tre);
            grid.lod = 1e-12; tre.grids = grid;
            t.verifyFalse(tre.validate().valid);
        end

        function tableOfContentsSharesComponentLayout(t)
            tre = fixturePublishedTRE('MITOCA');
            second = tre.components; second.component_id = 'D';
            tre.components = [tre.components second];
            location = '+12.000000-123.000000';
            expected = uint8(['001001S---000------000001000001CAMERAEO  001' ...
                '000001V' repmat(location, 1, 4) ...
                '002000000010000000200001.000010C' repmat(location, 1, 4) ...
                'D' repmat(location, 1, 4)]);
            t.verifyEqual(tre.payload(), expected);
            [copy, ok, status] = nfx.MITOCA.deserialize(expected);
            t.assertTrue(ok, status.message);
            t.verifyEqual({copy.components.component_id}, {'C', 'D'});
            tre.components = repmat(second, 1, 20);
            roundTrip(t, tre);
            tre.components(2).component_index_type = 1;
            tre.components(2).ish_index = 1;
            t.verifyFalse(tre.validate().valid);
        end

        function engineeringTransformsCheckEffectiveImageBands(t)
            [file, image] = fixtureFile();
            tre = nfx.S2EVPA(first_band=2, last_band=2);
            candidate = image + tre;
            report = candidate.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'EngineeringBandRange')));
            tre.first_band = 1; tre.last_band = 1;
            candidate = image + tre + tre;
            report = candidate.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'EngineeringBandOverlap')));
            candidate = image + tre + fixturePublishedTRE('PIXMTA');
            report = candidate.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'EngineeringTransformConflict')));
            wrapped = nfx.CONTXA(context_type='IS', index_list='1') + tre + tre;
            candidateFile = file + wrapped;
            report = candidateFile.validate();
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'EngineeringBandOverlap')));
            [~, rgb] = fixtureFile(ones(5, 7, 3, 'uint16'), 'MULTI');
            second = nfx.S2EVPA(first_band=2, last_band=3);
            candidate = rgb + tre + second;
            t.verifyTrue(candidate.validate().valid);
        end

        function mappingMethodsUseNetworkByteOrder(t)
            tre = nfx.IOMAPA(s2=2);
            t.verifyEqual(tre.payload(), uint8('000002'));
            roundTrip(t, tre);
            tre = nfx.IOMAPA(map_select=1, s1=0, output_map=0:4095);
            bytes = tre.payload();
            t.verifyEqual(bytes(11:18), uint8([0 0 0 1 0 2 0 3]));
            t.verifyEqual(bytes(end-3:end), uint8([15 254 15 255]));
            roundTrip(t, tre);
            tre.output_map = (0:4095)';
            t.verifyFalse(tre.validate().valid);
            tre = nfx.IOMAPA(map_select=3, s1=0, xob=[1 4095], ...
                out_b=repmat([1; -2; 0; 0; 0; 0], 1, 3));
            bytes = tre.payload();
            t.verifyEqual(bytes(11:19), uint8('300014095'));
            t.verifyEqual(bytes(20:27), uint8([63 128 0 0 192 0 0 0]));
            roundTrip(t, tre);
            tre.xob = [2 1];
            t.verifyFalse(tre.validate().valid);
        end

        function largeBinaryOffsetsAndOverflow(t)
            tre = nfx.NBLOCA(frame_1_offset=999999, ...
                offsets=repmat(4294967295, 1, 24995));
            bytes = tre.payload();
            t.verifyNumElements(bytes, 99988);
            t.verifyEqual(bytes(end-3:end), uint8([255 255 255 255]));
            roundTrip(t, tre);
            records = tre.physicalRecords();
            t.verifyEqual(records.payload, bytes);
            tre.offsets(end + 1) = 1;
            t.verifyFalse(tre.validate().valid);
            bytes(5:8) = 255;
            [~, ok] = nfx.NBLOCA.deserialize(bytes);
            t.verifyFalse(ok);
        end

        function variableUnicodeFieldsUseByteLengths(t)
            tre = nfx.RELCCA(relsours=char(233), relccstd='ISO', ...
                rcolstd='TEST', coalid='Coalition', coalcc='US', ...
                relccodes='US');
            bytes = tre.payload();
            t.verifyEqual(bytes(9:14), uint8([48 48 48 50 195 169]));
            roundTrip(t, tre);
            tre.coalid = '';
            t.verifyFalse(tre.validate().valid);
            tre.coalcc = '';
            roundTrip(t, tre);
            tre.reldate = '20--1002';
            roundTrip(t, tre);
            tre.reldate = '20260229';
            t.verifyFalse(tre.validate().valid);
            tre = nfx.COMNTA(comment=['A' char(65279) 'B']);
            roundTrip(t, tre);
        end

        function countryDetailsRemainOpaqueAndBounded(t)
            tre = fixturePublishedTRE('CCINFA');
            entry = tre.codes(1);
            entry.detail = uint8('<country>US</country>');
            tre.codes = entry;
            roundTrip(t, tre);
            entry.detail_cmpr = 'G';
            entry.detail = uint8([31 139 8 0]);
            tre.codes = entry;
            roundTrip(t, tre);
            entry.detail_cmpr = 'X'; tre.codes = entry;
            t.verifyFalse(tre.validate().valid);
        end

        function registrationConditionalAccuracyFields(t)
            tre = fixturePublishedTRE('REGPTC');
            point = tre.points(1);
            point.uniaah = 'M'; point.aah = 1.25;
            point.uniaav = 'M'; point.aav = 2.5;
            tre.points = [point point];
            roundTrip(t, tre);
            point.uniaah = ''; tre.points = point;
            t.verifyFalse(tre.validate().valid);
            point.aah = NaN; tre.points = point;
            roundTrip(t, tre);
            point.uniaah = '   '; tre.points = point;
            roundTrip(t, tre);
            point.aah = 1; tre.points = point;
            t.verifyFalse(tre.validate().valid);
        end

        function sensorAuxiliaryTypesAndConditionalMeasurements(t)
            tre = fixturePublishedTRE('SNSPSB');
            aux = repmat(nfx.SNSPSB.auxiliaryEntry(), 1, 3);
            aux(1).api = 'Integer'; aux(1).apf = 'I'; aux(1).apn = -7;
            aux(2).api = 'Real'; aux(2).apf = 'R'; aux(2).apr = 1.25;
            aux(3).api = 'Text'; aux(3).apf = 'A'; aux(3).apa = 'Example';
            sensor = tre.sensors(1); sensor.auxiliary = aux;
            sensor.uninoa = 'DEG'; sensor.noa = 45;
            sensor.unialt = 'M'; sensor.alt = 10000;
            tre.sensors = [sensor sensor];
            roundTrip(t, tre);
            sensor.auxiliary(1).apr = 3;
            tre.sensors = sensor;
            t.verifyFalse(tre.validate().valid);
            sensor.auxiliary(1).apr = NaN;
            sensor.unialt = '   '; sensor.alt = NaN;
            tre.sensors = sensor;
            roundTrip(t, tre);
            sensor.alt = 1; tre.sensors = sensor;
            t.verifyFalse(tre.validate().valid);
        end

        function bandMappingAlternativesAndContinuation(t)
            tre = fixturePublishedTRE('BCHIPA');
            current = tre.current_bands;
            current.mapping_type = 'FORMULAIC';
            current.original.weight = NaN;
            current.formula = 'B1 * 2'; tre.current_bands = current;
            roundTrip(t, tre);
            current.mapping_type = 'INSERTION';
            current.original = repmat(nfx.BCHIPA.originalEntry(), 1, 0);
            current.formula = ''; tre.current_bands = current;
            roundTrip(t, tre);
            tre.num_insts = 2; tre.instance = 2; tre.include_a = 'N';
            tre.tot_orig_bands = NaN; tre.tot_curr_bands = NaN;
            tre.bwp_is = zeros(1, 0);
            roundTrip(t, tre);
            tre.instance = 1;
            t.verifyFalse(tre.validate().valid);
        end

        function attributedPointsUseGlobalAndLocalWidths(t)
            tre = fixturePublishedTRE('ATTPTA');
            constant = nfx.ATTPTA.global_constantsEntry();
            constant.att_id = 'CONST'; constant.att_value = 'value';
            constant.as = 'TEST'; tre.global_constants = constant;
            definition = nfx.ATTPTA.local_variablesEntry();
            definition.att_id = 'LOCAL'; definition.att_len = 3;
            definition.as = 'TEST';
            group = tre.groups; group.local_variables = definition;
            group.points.diy = '--------';
            group.points.lva = struct('value', 'ABC');
            group.points = [group.points group.points];
            group.points(2).gva.value = 'NO';
            tre.groups = [group group];
            copy = roundTrip(t, tre);
            t.verifyEqual(copy.groups(2).points(2).gva.value, 'NO');
            group.points(2).lva.value = 'LONG'; tre.groups = group;
            t.verifyFalse(tre.validate().valid);
        end

        function oldRSMCovarianceBranchesAndPSD(t)
            row = repmat(nfx.RSMECA.row_correlationsEntry(), 1, 2);
            row(1).ucorsr = 1; row(1).utausr = 0;
            row(2).ucorsr = 0; row(2).utausr = 1;
            column = repmat(nfx.RSMECA.column_correlationsEntry(), 1, 2);
            column(1).ucorsc = 1; column(1).utausc = 0;
            column(2).ucorsc = 0; column(2).utausc = 1;
            tre = nfx.RSMECA(edition='TEST', incluc='Y', ...
                urr=1, urc=0, ucc=2, row_correlations=row, ...
                column_correlations=column);
            roundTrip(t, tre);
            tre.urc = 2;
            t.verifyFalse(tre.validate().valid);
            tre = fixturePublishedTRE('RSMDCA');
            other = tre.images; other.iidi = 'OTHER';
            tre.images = [tre.images other]; tre.dercov = [1 0.5 2];
            roundTrip(t, tre);
            tre.dercov = [1 2 1];
            t.verifyFalse(tre.validate().valid);
        end

        function cssfaPreservesOffsetPrecision(t)
            tre = fixturePublishedTRE('CSSFAA');
            tre.bands = repmat(tre.bands, 1, 9);
            bytes = tre.payload();
            t.verifyNumElements(bytes, 955);
            roundTrip(t, tre);
            tre.bands(1).oppoff_x = '+99.999';
            roundTrip(t, tre);
            tre.bands(1).oppoff_x = '+100.00';
            t.verifyFalse(tre.validate().valid);
            tre.bands(1).oppoff_x = '+1e0000';
            t.verifyFalse(tre.validate().valid);
        end
    end
end

function copy = roundTrip(t, tre)
    report = tre.validate();
    t.assertTrue(report.valid, evalc('disp(report.issues)'));
    bytes = tre.payload();
    [copy, ok, status] = tre.deserialize(bytes);
    t.assertTrue(ok, status.message);
    t.verifyEqual(copy.payload(), bytes);
end
