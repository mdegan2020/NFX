classdef UnknownTRETest < NfxTest
    properties (TestParameter)
        owner = {'file', 'image', 'text'}
        wrapperType = {'CONTXA', 'FSYNWA', 'FASYWA'}
        damage = {'tag', 'length', 'knownPayload', 'wrapperPrefix'}
        collectionArea = {'extended', 'user'}
    end
    methods (Test)
        function opaqueBinaryRoundTripAndRemoval(t, owner)
            [base, image] = fixtureFile();
            image = image.removeTRE(1);
            text = fixtureText('Opaque metadata test');
            switch owner
                case 'image', image = image + nfx.FREESA(7);
                case 'text', text = text + nfx.FREESA(7);
            end
            file = nfx.File(header=base.header) + image + text;
            if strcmp(owner, 'file'), file = file + nfx.FREESA(7); end
            bytes = sourceBytes(t, file);
            at = strfind(char(bytes), 'FREESA00007');
            t.assertNumElements(at, 1);
            bytes(at + (0:5)) = uint8('UNKNWN');
            payload = uint8([0 1 10 32 127 128 255]);
            bytes(at + (11:17)) = payload;
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyFalse(status.metadata_complete);
            report = copy.validate();
            t.verifyTrue(report.valid); t.verifyFalse(report.complete);
            t.verifyTrue(all(strcmp({report.issues.severity}, 'warning')));
            t.verifyFalse(copy.validate(SNIP_COMPLIANT=true).valid);
            switch owner
                case 'file', value = copy;
                case 'image', value = copy.images;
                case 'text', value = copy.texts;
            end
            records = value.tre_records;
            t.verifyEqual(records.tag, 'UNKNWN');
            t.verifyEqual(records.payload, payload);
            view = value.tre(1);
            t.verifyEqual(view.records, records);
            t.verifySubstring(evalc('disp(view)'), 'No concrete decoder');
            reduced = value.removeTRE(records.id);
            t.verifyEmpty(reduced.tre_records);
            t.verifyEqual(value.tre_records, records);
            verifyRewrite(t, copy, bytes);
        end

        function repeatedUnknownIdsRemainIndependent(t)
            [base, image] = fixtureFile();
            image = image + nfx.FREESA(3) + nfx.FREESA(5);
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + image), 'FREESA', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images.tre_ids, [1 2 3]);
            t.verifyEqual(copy.images.treCount('UNKNWN'), 2);
            reduced = copy.replaceImage(1, copy.images.removeTRE(2));
            t.verifyEqual(reduced.images.tre_ids, [1 3]);
            t.verifyEqual(reduced.images.tre_records(2).payload, ...
                repmat(uint8(255), 1, 5));
            output = fullfile(t.folder, 'reduced.ntf'); reduced.write(output);
            [again, ok] = nfx.File.read(output, readAll=true); t.assertTrue(ok);
            t.verifyEqual({again.images.tre_records.payload}, ...
                {reduced.images.tre_records.payload});
        end

        function knownWrappersRetainUnknownLeaves(t, wrapperType)
            [base, image] = fixtureFile(); image = image.removeTRE(1);
            switch wrapperType
                case 'CONTXA'
                    wrapper = nfx.CONTXA(context_type='FR', index_list='1');
                case 'FSYNWA'
                    wrapper = nfx.FSYNWA(start_frame=1, end_frame=1);
                case 'FASYWA'
                    wrapper = nfx.FASYWA( ...
                        start_timestamp='20260915120000.000000000', ...
                        end_timestamp='20260915120001.000000000');
            end
            wrapper = wrapper + nfx.FREESA(5);
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + (image + wrapper)), ...
                'FREESA', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            switch wrapperType
                case 'CONTXA', [decoded, ok] = copy.images.CONTXA;
                case 'FSYNWA', [decoded, ok] = copy.images.FSYNWA;
                case 'FASYWA', [decoded, ok] = copy.images.FASYWA;
            end
            t.assertTrue(ok);
            t.verifyEqual(decoded.tre_records.tag, 'UNKNWN');
            t.verifyFalse(decoded.validate().complete);
            t.verifyEqual(decoded.payload(), copy.images.tre_records.payload);
            records = copy.effectiveTREs(1);
            t.verifyEqual(records.tag, 'UNKNWN');
            verifyRewrite(t, copy, bytes);
        end

        function unknownModelCompanionDoesNotBlockPassThrough(t)
            [base, image] = fixtureFile();
            image = image.removeTRE(1) + fixtureRSMIdentification() + ...
                fixturePolynomial();
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + image), 'RSMIDA', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyFalse(copy.validate().complete);
            verifyRewrite(t, copy, bytes);
            reduced = copy.replaceImage(1, copy.images.removeTRE(1));
            report = reduced.validate();
            t.verifyTrue(report.complete); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'RSMCompanions')));
        end

        function manualTagProbeUsesAnIndependentRecord(t)
            [base, image, rpc] = fixtureFile();
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + image), 'RPC00B', 'UNKNWN');
            [copy, ok] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok);
            probe = copy.images.tre_records(1);
            t.verifyEqual(numel(probe.payload), numel(rpc.payload()));
            probe.tag = 'RPC00B';
            view = nfx.TRERecord(probe); %#ok<NASGU>
            t.verifySubstring(evalc('disp(view)'), 'line_off');
            [decoded, ok] = nfx.RPC00B.deserialize(probe.payload);
            t.assertTrue(ok); t.verifyEqual(decoded.payload(), rpc.payload());
            t.verifyEqual(copy.images.tre_records.tag, 'UNKNWN');
            verifyRewrite(t, copy, bytes);
        end

        function userAreaAndOverflowSurviveWithoutKnownPackingTrigger(t)
            [base, image] = fixtureFile(uint8(1));
            model = fixtureCSEXRB(); model.num_lines = 1; model.num_samples = 1;
            image = image.removeTRE(1) + nfx.FREESA(99974) + ...
                model + nfx.FREESA(99985);
            file = nfx.File(header=base.header) + image + ...
                nfx.FREESA(99974) + model + nfx.FREESA(99985);
            bytes = renameTag(sourceBytes(t, file), 'CSEXRB', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual({copy.images.tre_records.tag}, ...
                {'FREESA', 'UNKNWN', 'FREESA'});
            t.verifyEqual(copy.images.tre_ids, [1 2 3]);
            verifyRewrite(t, copy, bytes);
        end

        function unknownOverflowPayloadsRemainExact(t, owner)
            [base, image] = fixtureFile(); image = image.removeTRE(1);
            text = fixtureText('Overflow');
            file = nfx.File(header=base.header);
            switch owner
                case 'file', file = file + nfx.FREESA(99985);
                case 'image', image = image + nfx.FREESA(99985);
                case 'text', text = text + nfx.FREESA(99985);
            end
            file = file + image + text;
            bytes = renameTag(sourceBytes(t, file), 'FREESA', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyFalse(status.metadata_complete);
            verifyRewrite(t, copy, bytes);
        end

        function uncompressedPixelAssignmentPreservesImportedAreas(t)
            [base, image] = fixtureFile(uint8(1));
            model = fixtureCSEXRB();
            model.num_lines = 1; model.num_samples = 1;
            image = image.removeTRE(1) + nfx.FREESA(99974) + model;
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + image), 'CSEXRB', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            replacement = copy.images;
            replacement.data = replacement.data;
            replacement = replacement.uncompress();
            verifyRewrite(t, copy.replaceImage(1, replacement), bytes);
        end

        function unknownsDoNotSuppressIndependentDESChecks(t)
            [base, image, ~, attitude, ~, ~, covariance] = fixtureGLASFile();
            source = nfx.File(header=base.header) + ...
                (image + nfx.FREESA(1));
            bytes = renameTag(sourceBytes(t, source), 'FREESA', 'UNKNWN');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            covariance.uuid = attitude.uuid;
            duplicate = copy + attitude + covariance;
            report = duplicate.validate();
            t.verifyFalse(report.valid); t.verifyFalse(report.complete);
            t.verifyTrue(any(strcmp({report.issues.id}, 'GLASDuplicateDES')));
            attitude.aisdlvl = 2;
            missing = copy + attitude;
            report = missing.validate();
            t.verifyFalse(report.valid); t.verifyFalse(report.complete);
            t.verifyTrue(any(strcmp({report.issues.id}, ...
                'GLASDisplayAssociation')));
        end

        function unknownsNeverHideMalformedKnownData(t, damage)
            [base, image] = fixtureFile();
            wrapper = nfx.CONTXA(context_type='FR', index_list='1') + nfx.FREESA(5);
            file = nfx.File(header=base.header) + (image + wrapper);
            bytes = renameTag(sourceBytes(t, file), 'FREESA', 'UNKNWN');
            unknown = strfind(char(bytes), 'UNKNWN');
            known = strfind(char(bytes), 'RPC00B');
            wrapped = strfind(char(bytes), 'CONTXA');
            switch damage
                case 'tag', bytes(unknown) = 0;
                case 'length', bytes(unknown + (6:10)) = uint8('99985');
                case 'knownPayload', bytes(known + 11) = uint8('X');
                case 'wrapperPrefix', bytes(wrapped + (11:12)) = uint8('XX');
            end
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.verifyFalse(ok); t.verifyEqual(status.code, 'MalformedFile');
            t.verifyEmpty(copy.images);
        end

        function maximumOpaquePayloadUsesOverflow(t)
            file = fixtureFile() + nfx.FREESA(99985);
            bytes = sourceBytes(t, file);
            at = strfind(char(bytes), 'FREESA99985');
            t.assertNumElements(at, 1);
            bytes(at + (0:10)) = uint8('UNKNWN99999');
            bytes = [bytes zeros(1, 14, 'uint8')];
            lengthAt = strfind(char(bytes(1:500)), '000099996');
            t.assertNumElements(lengthAt, 1);
            bytes(lengthAt + (0:8)) = uint8('000100010');
            bytes(343:354) = uint8(sprintf('%012d', numel(bytes)));
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.tre().byte_count, 99999);
            t.verifyEqual(copy.tre_records.payload(end-13:end), zeros(1, 14, 'uint8'));
            verifyRewrite(t, copy, bytes);
        end

        function unknownPrefixDoesNotInvokeModelSpecificIndexing(t)
            [base, image] = fixtureFile(); image = image.removeTRE(1);
            wrapper = nfx.CONTXA(context_type='FR', index_list='1') + ...
                nfx.FREESA(1) + fixtureRSMIdentification() + fixturePolynomial();
            bytes = renameTag(sourceBytes(t, ...
                nfx.File(header=base.header) + (image + wrapper)), ...
                'FREESA', 'RSMZZZ');
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            records = copy.effectiveTREs(1);
            t.verifyEqual({records.tag}, {'RSMZZZ', 'RSMIDA', 'RSMPCA'});
            verifyRewrite(t, copy, bytes);
        end

        function collectionRetainsUnknownsAndReportsIncompleteValidation(t, collectionArea)
            source = fixtureMIECollection();
            source.blocks(1).image = source.blocks(1).image + nfx.FREESA(3);
            source.manifest_template = nfx.File(header=source.header) + nfx.FREESA(4);
            paths = source.write(t.folder);
            for k = 1:numel(paths)
                bytes = renameTag(readBytes(paths{k}), 'FREESA', 'UNKNWN');
                if strcmp(collectionArea, 'user')
                    [index, valid] = nfx.internal.indexNITF(bytes);
                    t.assertTrue(valid);
                    bytes = moveToUser(bytes, index);
                    for j = 1:numel(index.images)
                        bytes = moveToUser(bytes, index.images(j));
                    end
                end
                writeRaw(paths{k}, bytes);
            end
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyFalse(status.metadata_complete);
            t.verifyFalse(copy.validate().complete);
            output = fullfile(t.folder, 'copy'); mkdir(output);
            actual = copy.write(output);
            for k = 1:numel(paths)
                t.verifyEqual(readBytes(actual{k}), readBytes(paths{k}));
            end
            % Changed metadata must discard the old owner partition hint.
            copy.blocks(1).image = copy.blocks(1).image + nfx.FREESA(5);
            copy.manifest_template = copy.manifest_template + nfx.FREESA(6);
            edited = fullfile(t.folder, 'edited'); mkdir(edited);
            actual = copy.write(edited);
            [again, valid, status] = nfx.MIECollection.read(actual{end});
            t.assertTrue(valid, status.message);
            t.verifyEqual(again.blocks(1).image.treCount('FREESA'), 1);
            t.verifyEqual(again.manifest_template.treCount('FREESA'), 1);
        end
    end
end

function bytes = moveToUser(bytes, entry)
    if entry.extended.length == 0, return, end
    first = entry.extended.offset - 7;
    finish = entry.extended.offset + entry.extended.length;
    bytes(first - 5:finish) = [bytes(first:finish) uint8('00000')];
end

function bytes = sourceBytes(t, file)
    path = fullfile(t.folder, 'source.ntf');
    file.write(path); bytes = readBytes(path);
end

function bytes = renameTag(bytes, old, new)
    positions = strfind(char(bytes), old);
    for at = positions, bytes(at + (0:5)) = uint8(new); end
end

function verifyRewrite(t, file, original)
    path = fullfile(t.folder, 'copy.ntf'); file.write(path);
    t.verifyEqual(readBytes(path), original);
end

function writeRaw(path, bytes)
    fid = fopen(path, 'wb'); cleanup = onCleanup(@() fclose(fid));
    fwrite(fid, bytes, 'uint8');
end
