classdef AdditionalTRETest < NfxTest
    properties (TestParameter)
        tag = {'GEOPSB','BNDPLC','XMLDCA','SECURA','PIXQLA', ...
            'CSCCGA','MSTGTA','BLOCKA','ENGRDA'}
        owner = {'file','image','text'}
        sharedTag = {'XMLDCA','SECURA','ENGRDA'}
        native = {'uint8','uint16','uint32','uint64', ...
            'int8','int16','int32','int64','single','double'}
        badPolygon = {'crossed','touching','nestedClockwise', ...
            'counterclockwise','reversedEdge','repeatedVertex'}
        xmlGroup = {0, 5, 283, 773}
    end
    methods (Test)
        function publishedFieldLayoutsHaveIndependentBytes(t)
            block = fixtureAdditionalTRE('BLOCKA');
            t.verifyEqual(block.payload(), uint8(['010000000005' ...
                repmat(' ', 1, 106) '010.0']));
            target = fixtureAdditionalTRE('MSTGTA');
            t.verifyEqual(target.payload(), uint8(['00000' repmat(' ', 1, 96)]));
            cloud = fixtureAdditionalTRE('CSCCGA');
            t.verifyEqual(cloud.payload(), uint8([pad('PAN', 18) ...
                pad('PAN', 6) '000000100001000000100001000000200002']));
            quality = fixtureAdditionalTRE('PIXQLA');
            t.verifyEqual(quality.payload(), uint8(['ALL00011' pad('Bad', 40)]));
            engineering = fixtureAdditionalTRE('ENGRDA');
            t.verifyEqual(engineering.payload(), ...
                [uint8([pad('Source', 20) '00101A00020002I2UD00000004']) ...
                uint8([0 1 1 0 255 255 0 2])]);
            xml = nfx.XMLDCA(tredata=uint8('<a/>'));
            t.verifyEqual(xml.payload(), uint8('0000<a/>'));
            security = fixtureAdditionalTRE('SECURA');
            t.verifyEqual(security.payload(), ...
                [uint8(['20260915120000NITF02.10U' repmat(' ', 1, 166)]) ...
                zeros(1, 40, 'uint8') uint8([pad('ARH.XML', 8) ...
                repmat(' ', 1, 8) '00004<a/>'])]);
            polygon = fixtureAdditionalTRE('BNDPLC');
            zero = '000000000000000'; one = '000000000000001';
            t.verifyEqual(polygon.payload(), ...
                uint8(['00120003' zero zero zero one one zero]));
            geo = fixtureAdditionalTRE('GEOPSB');
            expected = ['GEODEG' pad('World Geodetic System 1984', 80) ...
                'WGE ' pad('World Geodetic System 1984', 80) 'WE ' ...
                pad('Geodetic', 80) 'GEOD' pad('Mean Sea', 80) 'MSL ' ...
                '000000000000000' repmat(' ', 1, 83) '0000'];
            t.verifyEqual(geo.payload(), uint8(expected));
        end

        function everyExtensionHasACompleteFileRoundTrip(t, tag)
            file = fileFor(tag);
            path = fullfile(t.folder, 'input.ntf'); file.write(path);
            original = readBytes(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyEqual(status.metadata_complete, ~strcmp(tag, 'SECURA'));
            output = fullfile(t.folder, 'output.ntf'); copy.write(output);
            t.verifyEqual(readBytes(output), original);
        end

        function sharedRecordsKeepTheirOwnerAndRepeatedOrder(t, sharedTag, owner)
            [base, image] = fixtureFile(); image = image.removeTRE(1);
            tre = fixtureAdditionalTRE(sharedTag);
            if strcmp(sharedTag, 'SECURA'), tre.fdattim = base.header.fdt; end
            text = fixtureText('Example');
            file = nfx.File(header=base.header);
            switch owner
                case 'file', file = file + tre + tre;
                case 'image', image = image + tre + tre;
                case 'text', text = text + tre + tre;
            end
            if strcmp(sharedTag, 'SECURA') && ~strcmp(owner, 'file')
                file = file + tre;
            end
            file = file + image + text;
            path = fullfile(t.folder, 'owners.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message);
            switch owner
                case 'file', value = copy;
                case 'image', value = copy.images;
                case 'text', value = copy.texts;
            end
            t.verifyEqual(value.treCount(sharedTag), 2);
            [decoded, ok] = value.(sharedTag)(2); t.assertTrue(ok);
            t.verifyEqual(decoded.payload(), tre.payload());
            t.verifyEqual(value.removeTRE(1).tre_ids, 2);
        end

        function nativeEngineeringMatricesKeepTypeAndOrientation(t, native)
            data = cast([1 2 3; 4 5 6], native);
            if startsWith(native, 'int'), data(1, 2) = -2; end
            if any(strcmp(native, {'single','double'})), data(1, 2) = -2.5; end
            entry = nfx.ENGRDA.entry('Native matrix', data, 'm');
            tre = nfx.ENGRDA(resrc='Sensor', redata=entry);
            [decoded, ok] = nfx.ENGRDA.deserialize(tre.payload());
            t.assertTrue(ok);
            [actual, ok, status] = nfx.ENGRDA.values( ...
                decoded.redata, cast(0, native));
            t.assertTrue(ok, status.message);
            t.verifyClass(actual, native); t.verifyEqual(actual, data);
        end

        function engineeringComplexAndRawWidths(t)
            data = complex(single([1 2; 3 4]), single([-1 -2; -3 -4]));
            entry = nfx.ENGRDA.entry('C', data);
            t.verifyEqual(entry.engdata(1:8), ...
                uint8([63 128 0 0 191 128 0 0]));
            [actual, ok] = nfx.ENGRDA.values(entry, complex(single(0), single(0)));
            t.assertTrue(ok); t.verifyEqual(actual, data);
            entry = nfx.ENGRDA.entry('raw', uint8(1));
            entry.engdts = 3; entry.engdata = uint8([128 0 1]);
            tre = nfx.ENGRDA(resrc='Sensor', redata=entry);
            [decoded, ok] = nfx.ENGRDA.deserialize(tre.payload());
            t.assertTrue(ok); t.verifyEqual(decoded.redata.engdata, entry.engdata);
            [actual, ok] = nfx.ENGRDA.values(entry, uint32(0));
            t.verifyFalse(ok); t.verifyClass(actual, 'uint32'); t.verifyEmpty(actual);
            t.verifyError(@() nfx.ENGRDA.entry('bad', complex(1, 2)), ...
                'nfx:EngineeringType');
            t.verifyError(@() nfx.ENGRDA.entry('huge', zeros(200, 100)), ...
                'nfx:TRELength');
        end

        function engineeringDescriptorFailuresUseStatus(t)
            tre = fixtureAdditionalTRE('ENGRDA'); bytes = tre.payload();
            % Rows, type, width and symbol count must agree with byte data.
            mutations = {struct('at', 31:34, 'value', '0003'), ...
                struct('at', 35, 'value', 'Z'), ...
                struct('at', 36, 'value', '0'), ...
                struct('at', 39:46, 'value', '00000003')};
            for k = 1:numel(mutations)
                bad = bytes; bad(mutations{k}.at) = uint8(mutations{k}.value);
                [~, ok] = nfx.ENGRDA.deserialize(bad); t.verifyFalse(ok);
            end
            tre.redata(2) = tre.redata(1);
            t.verifyFalse(tre.validate().valid);
        end

        function crcMatchesPublishedStanagVectorAndDetectsDamage(t)
            tre = nfx.XMLDCA(tredata=uint8([255 255 255 255 255 255 255 1]));
            tre = tre.updateCRC();
            % STANAG 7023 Annex B, Figure B-1: ...FF01 gives CRC 0026.
            t.verifyEqual(tre.trecrc, 38);
            bytes = tre.payload(); t.verifyEqual(char(bytes(1:9)), '000500038');
            bytes(end) = 2;
            [~, ok, status] = nfx.XMLDCA.deserialize(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'InvalidMetadata');
        end

        function xmlSubheaderGroupsAndLocations(t)
            tre = nfx.XMLDCA(tredata=uint8('<a/>'));
            t.verifyEqual(tre.treshl, 0);
            tre.trecrc = 99999; t.verifyEqual(tre.treshl, 5);
            tre.treshft = 'XML'; tre.treshdt = '2026-09-18T12:00:00Z';
            tre.treshrp = 'NFX'; tre.treshsi = 'Synthetic fixture';
            tre.treshsv = '1'; tre.treshsd = '2026-09-18';
            t.verifyEqual(tre.treshl, 283);
            tre.treshlpt = '+00.00000000+000.00000000';
            tre.treshli = 'ID'; tre.treshlin = 'Example';
            t.verifyEqual(tre.treshl, 773);
            [copy, ok, status] = nfx.XMLDCA.deserialize(tre.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.payload(), tre.payload());
            tre.treshlin = ''; t.verifyFalse(tre.validate().valid);
        end

        function securityEnvelopeAndHeaderPrerequisites(t)
            [base, image] = fixtureFile();
            tre = fixtureAdditionalTRE('SECURA'); tre.fdattim = base.header.fdt;
            file = nfx.File(header=base.header) + (image + tre);
            t.verifyTrue(hasIssue(file.validate(), 'MissingFileSecurity'));
            file = file + tre; report = file.validate();
            t.verifyTrue(report.valid); t.verifyFalse(report.complete);
            t.verifyTrue(hasIssue(report, 'SecurityDocumentUnchecked'));
            h = file.header; h.fdt = '20260916120000'; file.header = h;
            t.verifyTrue(hasIssue(file.validate(), 'SecurityFileDate'));
            tre.secflds(end) = 1; t.verifyFalse(tre.validate().valid);
        end

        function securityMaximumPayloadUsesOverflow(t)
            base = fixtureFile(); tre = fixtureAdditionalTRE('SECURA');
            tre.fdattim = base.header.fdt;
            tre.security = zeros(1, 99737, 'uint8');
            t.verifyEqual(numel(tre.payload()), 99988);
            bytes = tre.bytes();
            t.verifyEqual(char(bytes(7:11)), '99988');
            file = base + tre;
            path = fullfile(t.folder, 'security.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message);
            t.verifyFalse(status.metadata_complete);
            t.verifyEqual(copy.SECURA().security, tre.security);
        end

        function geographicPolygonUnitsAndDependencies(t)
            [base, image] = fixtureFile();
            polygon = fixtureAdditionalTRE('BNDPLC');
            file = nfx.File(header=base.header) + (image + polygon);
            t.verifyTrue(hasIssue(file.validate(), 'MissingGEOPSB'));
            file = file + nfx.GEOPSB(); t.verifyTrue(file.validate().valid);
            polygon.rings.lon = polygon.rings.lon * 3600;
            polygon.rings.lat = polygon.rings.lat * 3600;
            geo = nfx.GEOPSB(uni='SEC');
            file = nfx.File(header=base.header) + geo + (image + polygon);
            t.verifyTrue(file.validate().valid);
            file = file.replaceImage(1, image + polygon + geo);
            t.verifyTrue(hasIssue(file.validate(), 'CoordinateReference'));
            file = nfx.File(header=base.header) + nfx.GEOPSB(typ='MAP', uni='M');
            t.verifyTrue(hasIssue(file.validate(), 'MissingProjection'));
        end

        function invalidPolygonTopologyIsRejected(t, badPolygon)
            outer = struct('lon', [0 0 4 4], 'lat', [0 4 4 0], 'height', []);
            rings = outer;
            switch badPolygon
                case 'crossed', rings.lon = [0 4 0 4];
                case 'touching'
                    rings(2) = struct('lon', [4 4 5 5], ...
                        'lat', [0 1 1 0], 'height', []);
                case 'nestedClockwise'
                    rings(2) = struct('lon', [1 1 2 2], ...
                        'lat', [1 2 2 1], 'height', []);
                case 'counterclockwise', rings.lon = fliplr(rings.lon);
                case 'reversedEdge'
                    rings.lon = [0 0 0 4 4]; rings.lat = [0 4 2 4 0];
                case 'repeatedVertex'
                    rings.lon = [0 0 4 0 4]; rings.lat = [0 4 4 4 0];
            end
            [base, image] = fixtureFile();
            file = nfx.File(header=base.header) + nfx.GEOPSB() + ...
                (image + nfx.BNDPLC(rings));
            t.verifyTrue(hasIssue(file.validate(), 'PolygonTopology'));
        end

        function nestedHolesAndDatelinePolygonsAreSupported(t)
            rings = struct('lon', [0 0 4 4], 'lat', [0 4 4 0], 'height', []);
            rings(2) = struct('lon', [1 2 2 1], 'lat', [1 1 2 2], 'height', []);
            [base, image] = fixtureFile();
            file = nfx.File(header=base.header) + nfx.GEOPSB() + ...
                (image + nfx.BNDPLC(rings));
            t.verifyTrue(file.validate().valid);
            rings = struct('lon', [179 179 -179 -179], ...
                'lat', [0 1 1 0], 'height', []);
            file = nfx.File(header=base.header) + nfx.GEOPSB() + ...
                (image + nfx.BNDPLC(rings));
            t.verifyTrue(file.validate().valid);
        end

        function qualityBitsSurviveZeroPixelsAndBadReferencesFail(t)
            file = fileFor('PIXQLA'); quality = file.images(2);
            quality = quality.removeTRE(1) + nfx.PIXQLA(aisdlvl=1, ...
                pq_condition=char('Bad','Dead','Saturated'));
            t.verifyEqual(quality.header.abpp, 3);
            file = file.replaceImage(2, quality); t.verifyTrue(file.validate().valid);
            quality.header.abpp = 2;
            t.verifyFalse(file.replaceImage(2, quality).validate().valid);
            quality.header.abpp = NaN;
            quality = quality.removeTRE(2) + nfx.PIXQLA(aisdlvl=999, ...
                pq_condition='Bad');
            t.verifyTrue(hasIssue(file.replaceImage(2, quality).validate(), ...
                'QualityAssociation'));
        end

        function qualityCompactFormAndWavelengths(t)
            file = fileFor('PIXQLA'); reference = file.images(1);
            reference.header.isubcat = 550;
            quality = file.images(2); quality.data = zeros(1, 7, 'uint8');
            quality.header.isubcat = 550;
            file = file.replaceImage(1, reference).replaceImage(2, quality);
            t.verifyTrue(file.validate().valid);
            quality.header.isubcat = 600;
            t.verifyTrue(hasIssue(file.replaceImage(2, quality).validate(), ...
                'QualityWavelengths'));
            quality.data = zeros(2, 2, 'uint8');
            t.verifyTrue(hasIssue(file.replaceImage(2, quality).validate(), ...
                'QualityDimensions'));
        end

        function cloudSchemasPreserveLiteralBandCategory(t)
            file = fileFor('CSCCGA'); image = file.images;
            image.data = uint8([0 100; 253 254]);
            image.header.isubcat_text = 'CLDPCT';
            file = file.replaceImage(1, image);
            t.verifyEqual(image.header.abpp, 8);
            path = fullfile(t.folder, 'percent.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true); t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images.header.isubcat_text, 'CLDPCT');
            t.verifyEqual(copy.images.data, image.data);
            image.data(1) = 255;
            t.verifyTrue(hasIssue(file.replaceImage(1, image).validate(), 'CloudPixels'));
            image.data(1) = 101;
            t.verifyTrue(hasIssue(file.replaceImage(1, image).validate(), 'CloudPixels'));
            image.header.isubcat = 500;
            t.verifyFalse(image.header.validate().valid);
        end

        function blockAndTargetRelationships(t)
            [base, image] = fixtureFile();
            target = nfx.MSTGTA(tgt_num=1, tgt_coll=0, ...
                tgt_loc='+00.000000+000.000000');
            repeated = image + target + target;
            file = nfx.File(header=base.header) + repeated;
            t.verifyTrue(hasIssue(file.validate(), 'TargetNumber'));
            repeated = image + nfx.MSTGTA(tgt_num=0) + nfx.MSTGTA(tgt_num=0);
            file = nfx.File(header=base.header) + repeated;
            t.verifyTrue(file.validate().valid);
            block = fixtureAdditionalTRE('BLOCKA'); block.layover_angle = 20;
            file = nfx.File(header=base.header) + (image + block);
            t.verifyTrue(hasIssue(file.validate(), 'BlockRadarFields'));
        end

        function xmlPhysicalLimitsAndOverflow(t, xmlGroup)
            tre = nfx.XMLDCA();
            if xmlGroup >= 5, tre.trecrc = 99999; end
            if xmlGroup >= 283
                tre.treshft = 'XML'; tre.treshdt = '2026-09-18';
                tre.treshrp = 'NFX'; tre.treshsi = 'Fixture';
                tre.treshsv = '1'; tre.treshsd = '2026-09-18T12:00Z';
            end
            if xmlGroup == 773, tre.treshabs = 'Boundary fixture'; end
            tre.tredata = repmat(uint8(255), 1, 99981 - xmlGroup);
            t.verifyEqual(numel(tre.payload()), 99985);
            file = fixtureFile() + tre;
            path = fullfile(t.folder, 'xml-limit.ntf'); file.write(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true); t.assertTrue(ok, status.message);
            t.verifyEqual(copy.XMLDCA().payload(), tre.payload());
            tre.tredata(end + 1) = 0; t.verifyFalse(tre.validate().valid);
        end

        function engineeringExactPhysicalLimit(t)
            entries = nfx.ENGRDA.entry('A', zeros(10, 9990, 'uint8'));
            entries(2) = nfx.ENGRDA.entry('B', zeros(1, 16, 'uint8'));
            tre = nfx.ENGRDA(resrc='Source', redata=entries);
            t.verifyEqual(numel(tre.payload()), 99985);
            [copy, ok, status] = nfx.ENGRDA.deserialize(tre.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.engdatc, [99900 16]);
            tre.redata(2).engmtxc = 17;
            tre.redata(2).engdata(end + 1) = 0;
            t.verifyFalse(tre.validate().valid);
            entry = entries(1); entry.engtyp = {'I','S'};
            [data, ok] = nfx.ENGRDA.values(entry, uint8(0));
            t.verifyFalse(ok); t.verifyEmpty(data);
        end

        function qualityConditionSyntaxAndLimits(t)
            tre = nfx.PIXQLA(aisdlvl=1:998, ...
                pq_condition=char('Cluster_Static_Bad','Isolated_Dynamic_Dead', ...
                'FPA 1'));
            [copy, ok, status] = nfx.PIXQLA.deserialize(tre.payload());
            t.assertTrue(ok, status.message); t.verifyEqual(copy.aisdlvl, 1:998);
            for value = {'bad','Static_Cluster_Bad','FPA 0','Cluster_FPA 1'}
                tre.pq_condition = value{1}; t.verifyFalse(tre.validate().valid);
            end
            tre.pq_condition = char('Bad','Bad');
            t.verifyFalse(tre.validate().valid);
            tre.pq_condition = 'Bad'; tre.aisdlvl = [1 1];
            t.verifyFalse(tre.validate().valid);
        end

        function datumCodesAndPolygonDimensions(t)
            geo = nfx.GEOPSB(dcd='UND', elc='ZZ');
            t.verifyTrue(geo.validate().valid);
            for field = {'dcd','elc','vdcdvr','vdcsda','grd'}
                bad = geo; bad.(field{1}) = '?';
                t.verifyFalse(bad.validate().valid);
            end
            geo.typ = 'MAP'; t.verifyFalse(geo.validate().valid);
            polygon = fixtureAdditionalTRE('BNDPLC');
            polygon.rings.height = [1 2 3];
            [copy, ok] = nfx.BNDPLC.deserialize(polygon.payload());
            t.assertTrue(ok); t.verifyEqual(copy.rings.height, [1 2 3]);
            polygon.rings.height = [1 2]; t.verifyFalse(polygon.validate().valid);
        end

        function activeTargetsAndCornerFormats(t)
            target = nfx.MSTGTA(tgt_num=12, tgt_coll=0, ...
                tgt_loc='123456.78N1234556.78W', tgt_ltiov='202609181200', ...
                tgt_utc='120000Z', tgt_elev=-1000, tgt_elev_unit='m');
            [copy, ok, status] = nfx.MSTGTA.deserialize(target.payload());
            t.assertTrue(ok, status.message); t.verifyEqual(copy.tgt_elev, -1000);
            target.tgt_utc = '246000Z'; t.verifyFalse(target.validate().valid);
            block = fixtureAdditionalTRE('BLOCKA');
            block.frlc_loc = 'N123456.78W1234556.78';
            block.frfc_loc = 'N12--56.--W123----.--';
            [copy, ok, status] = nfx.BLOCKA.deserialize(block.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.frfc_loc, block.frfc_loc);
            block.frlc_loc = '+91.000000+001.000000';
            t.verifyFalse(block.validate().valid);
        end

        function fileContextPolygonsAreValidated(t)
            file = fixtureFile();
            polygon = fixtureAdditionalTRE('BNDPLC');
            wrapper = nfx.CONTXA(context_type='FH', index_list='1') + ...
                nfx.GEOPSB() + polygon;
            wrapped = file + wrapper;
            t.verifyTrue(wrapped.validate().valid);
            polygon.rings.lon = fliplr(polygon.rings.lon);
            wrapper = nfx.CONTXA(context_type='FH', index_list='1') + ...
                nfx.GEOPSB() + polygon;
            wrapped = file + wrapper;
            t.verifyTrue(hasIssue(wrapped.validate(), 'PolygonTopology'));
        end

        function newCompanionsMayRemainOpaque(t)
            file = fileFor('CSCCGA');
            path = fullfile(t.folder, 'opaque-cloud.ntf'); file.write(path);
            bytes = readBytes(path); at = strfind(char(bytes), 'CSCCGA00060');
            t.assertNumElements(at, 1);
            bytes(at + (0:5)) = uint8('UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message); t.verifyFalse(status.metadata_complete);
            output = fullfile(t.folder, 'cloud-copy.ntf'); copy.write(output);
            t.verifyEqual(readBytes(output), bytes);
        end

        function numericCloudReferencesNeedAnUnambiguousLocalTarget(t)
            cloudFile = fileFor('CSCCGA'); cloud = cloudFile.images;
            tre = cloud.CSCCGA(); tre.reg_sensor = '001';
            cloud = cloud.removeTRE(1) + tre;
            [base, image] = fixtureFile(uint8(ones(2)));
            image = image.removeTRE(1);
            unique = nfx.File(header=base.header) + image + cloud;
            t.verifyTrue(hasIssue(unique.validate(), 'CloudReferenceCode'));
            file = nfx.File(header=base.header) + image + image + cloud;
            t.verifyTrue(file.validate().valid);
            overlay = image; h = overlay.header; h.ialvl = 1;
            overlay.header = h;
            alternate = tre; alternate.reg_sensor = '002';
            bad = file.replaceImage(2, overlay);
            bad = bad.replaceImage(3, cloud.removeTRE(2) + alternate);
            t.verifyTrue(hasIssue(bad.validate(), 'CloudReferenceBase'));
            tre.reg_sensor = '999';
            cloud = cloud.removeTRE(2) + tre;
            file = file.replaceImage(3, cloud);
            t.verifyTrue(hasIssue(file.validate(), 'CloudReference'));
            tre.reg_sensor = '003';
            cloud = cloud.removeTRE(3) + tre;
            t.verifyTrue(hasIssue(file.replaceImage(3, cloud).validate(), 'CloudReference'));
        end

        function wrappedQualityDefinitionsSetAutomaticPrecision(t)
            file = fileFor('PIXQLA'); image = file.images(2).removeTRE(1);
            tre = nfx.PIXQLA(all_images=true, ...
                pq_condition=char('Bad','Dead','Saturated'));
            wrapper = nfx.FSYNWA(start_frame=1, end_frame=1) + tre;
            image = image + wrapper;
            t.verifyEqual(image.header.abpp, 3);
            t.verifyTrue(file.replaceImage(2, image).validate().valid);
        end

        function tinyCoordinatesAndUnsupportedGeographicExtent(t)
            polygon = nfx.BNDPLC(struct('lon', [0 0 1e-14], ...
                'lat', [0 1e-14 0], 'height', []));
            bytes = polygon.payload(); t.verifyTrue(any(bytes == uint8('E')));
            [copy, ok] = nfx.BNDPLC.deserialize(bytes);
            t.assertTrue(ok); t.verifyEqual(copy.rings.lon, polygon.rings.lon);
            file = fixtureFile() + nfx.GEOPSB() + polygon;
            t.verifyTrue(file.validate().valid);
            polygon.rings.lon = [-170 -170 10 10];
            polygon.rings.lat = [0 1 1 0];
            file = fixtureFile() + nfx.GEOPSB() + polygon;
            t.verifyTrue(hasIssue(file.validate(), 'PolygonExtentUnsupported'));
        end

        function mixedScalePolygonRingsKeepTheirLocalPrecision(t)
            large = struct('lon', [0 0 10 10], ...
                'lat', [0 10 10 0], 'height', []);
            tiny = struct('lon', 20 + [0 0 1e-6 1e-6], ...
                'lat', [0 1e-6 1e-6 0], 'height', []);
            file = fixtureFile() + nfx.GEOPSB();
            candidate = file + nfx.BNDPLC([large tiny]);
            t.verifyTrue(candidate.validate().valid);
            % The same tiny ring is a hole when nested and reversed.
            tiny.lon = fliplr(tiny.lon - 19);
            tiny.lat = fliplr(tiny.lat + 1);
            candidate = file + nfx.BNDPLC([large tiny]);
            t.verifyTrue(candidate.validate().valid);
            tiny.lon = fliplr(tiny.lon); tiny.lat = fliplr(tiny.lat);
            candidate = file + nfx.BNDPLC([large tiny]);
            t.verifyTrue(hasIssue(candidate.validate(), 'PolygonTopology'));
        end

        function engineeringCharacterDataUsesTheBCSCharacterSet(t)
            data = char([32 126 10 12 13]);
            entry = nfx.ENGRDA.entry('BCS', data);
            tre = nfx.ENGRDA(resrc='Sensor', redata=entry);
            bytes = tre.payload();
            [copy, ok] = nfx.ENGRDA.deserialize(bytes); t.assertTrue(ok);
            [actual, ok] = nfx.ENGRDA.values(copy.redata, ' ');
            t.assertTrue(ok); t.verifyEqual(actual, data);
            for bad = [0 9 31 127 128 255]
                t.verifyError(@() nfx.ENGRDA.entry('BCS', char(bad)), ...
                    'nfx:EngineeringText');
                entry.engdata(end) = uint8(bad); tre.redata = entry;
                t.verifyTrue(hasIssue(tre.validate(), 'EngineeringText'));
                [actual, ok] = nfx.ENGRDA.values(entry, ' ');
                t.verifyFalse(ok); t.verifyClass(actual, 'char');
                t.verifyEmpty(actual);
                malformed = bytes; malformed(end) = uint8(bad);
                [~, ok] = nfx.ENGRDA.deserialize(malformed); t.verifyFalse(ok);
            end
        end

        function malformedVariableContainersReturnStatusOrRejectStorage(t)
            tre = fixtureAdditionalTRE('PIXQLA'); bytes = tre.payload();
            bytes(1:3) = uint8('000');
            [~, ok] = nfx.PIXQLA.deserialize(bytes); t.verifyFalse(ok);
            [~, ok] = nfx.XMLDCA.deserialize(uint8('0001x')); t.verifyFalse(ok);
            [~, ok] = nfx.ENGRDA.values(struct(), uint16(0)); t.verifyFalse(ok);
            t.verifyError(@() nfx.ENGRDA.entry('text', char(128)), ...
                'nfx:EngineeringText');
            t.verifyError(@() nfx.ENGRDA.entry('empty', uint8([])), ...
                'nfx:EngineeringData');
            t.verifyError(@() nfx.ENGRDA(redata=struct()), 'nfx:EngineeringEntries');
            t.verifyError(@() nfx.BNDPLC(struct()), 'nfx:PolygonRings');
            badRing = struct('lon', [0 NaN 1], 'lat', [0 1 0], 'height', []);
            t.verifyError(@() nfx.BNDPLC(badRing), 'nfx:PolygonCoordinates');
            entry = fixtureAdditionalTRE('ENGRDA').redata;
            entry.engtyp = 'Z';
            t.verifyError(@() nfx.ENGRDA(redata=entry), 'nfx:EngineeringEntries');
        end
    end
end

function value = pad(value, count)
    value = [value repmat(' ', 1, count - numel(value))];
end

function value = hasIssue(report, id)
    value = any(strcmp({report.issues.id}, id));
end

function file = fileFor(tag)
    [base, image] = fixtureFile(uint8(reshape(1:35, 5, 7)));
    image = image.removeTRE(1);
    tre = fixtureAdditionalTRE(tag);
    file = nfx.File(header=base.header);
    switch tag
        case 'GEOPSB'
            file = file + tre + image;
        case 'BNDPLC'
            file = file + nfx.GEOPSB() + (image + tre);
        case 'SECURA'
            tre.fdattim = base.header.fdt;
            file = file + tre + (image + tre);
        case 'PIXQLA'
            h = image.header; h.irep = 'NODISPLY'; h.icat = 'PIXQUAL';
            quality = nfx.ImageSegment(zeros(5, 7, 'uint8'), header=h) + tre;
            file = file + image + quality;
        case 'CSCCGA'
            h = image.header; h.irep = 'MONO'; h.icat = 'CLOUD';
            h.iid1 = 'CLOUDCOVER';
            cloud = nfx.ImageSegment(uint8([0 253; 254 255]), header=h) + tre;
            file = file + cloud;
        otherwise
            file = file + (image + tre);
    end
end
