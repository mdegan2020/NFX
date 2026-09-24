classdef ReaderAcceptanceTest < NfxTest
    properties (TestParameter)
        model = {'RSM', 'GLAS_S', 'GLAS_F'}
    end
    methods (Test)
        function supportedSNIPProductsRemainProfileValid(t, model)
            source = profileFile(model);
            name = [source.header.ftitle '.ntf']; path = fullfile(t.folder, name);
            source.write(path, SNIP_COMPLIANT=true);
            [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message); t.verifyTrue(copy.context_complete);
            report = copy.validate(SNIP_COMPLIANT=true);
            t.assertTrue(report.valid, evalc('disp(report.issues)'));
            t.verifyEqual(copy.images.data, source.images.data);
            t.verifyEqual(copy.texts.data, source.texts.data);
            t.verifyEqual(copy.effectiveTREs(1), source.effectiveTREs(1));
            output = fullfile(t.folder, 'copy'); mkdir(output);
            copy.write(fullfile(output, name), SNIP_COMPLIANT=true);
            t.verifyEqual(readBytes(fullfile(output, name)), readBytes(path));
            t.verifyEqual(nitfread(path), copy.images.data);
        end

        function genericReadingDoesNotAssertAProfile(t)
            source = fixtureFile(); path = fullfile(t.folder, 'ordinary.ntf');
            source.write(path); [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message); t.verifyTrue(copy.validate().valid);
            t.verifyFalse(copy.validate(SNIP_COMPLIANT=true).valid);
        end

        function replacingAnImagePreservesAllOtherOwners(t)
            [base, first] = fixtureFile(); [~, second] = fixtureFile(uint8([3 2 1]));
            rawDES = nfx.DESSegment(uint8([0 255 3]), header= ...
                nfx.DESHeader(desid='TEST', desclas='U', desshf=uint8([1 2])));
            source = nfx.File(header=base.header) + first + second + ...
                (fixtureText('Retain this text') + nfx.FREESA(9800)) + ...
                rawDES + nfx.FREESA(99985);
            path = fullfile(t.folder, 'original.ntf'); source.write(path);
            [original, ok, status] = nfx.File.read(path, readAll=true); t.assertTrue(ok, status.message);
            image = original.images(1); rpc = image.RPC00B(); rpc.err_bias = 2.5;
            image = image.removeTRE(image.tre_ids(1)) + rpc;
            image.header.icom = 'Edited first image';
            edited = original.replaceImage(1, image);
            t.verifyEqual(original.images(1).RPC00B().err_bias, 0);
            t.verifyEqual(edited.images(1).RPC00B().err_bias, 2.5);
            t.verifyEqual(edited.images(2), original.images(2));
            t.verifyEqual(edited.tre_records, original.tre_records);
            t.verifyEqual(edited.texts, original.texts); t.verifyEqual(edited.des, original.des);
            destination = fullfile(t.folder, 'edited.ntf'); edited.write(destination);
            [copy, ok, status] = nfx.File.read(destination, readAll=true); t.assertTrue(ok, status.message);
            t.verifyEqual(copy.images(1).header.icom, image.header.icom);
            t.verifyEqual(copy.images(2).data, second.data);
            t.verifyEqual(copy.des(1).data, rawDES.data);
            t.verifyEqual(copy.texts.data, original.texts.data);
            t.verifyError(@() original.replaceImage(3, image), 'nfx:ImageIndex');
        end

        function replacementInvalidatesCapturedCollectionContext(t)
            collection = fixtureMIECollection(); rpc = fixtureRPC();
            wrapper = nfx.CONTXA(context_type='CS', index_list='1') + ...
                (nfx.CONTXA(context_type='TI', index_list='1') + ...
                    (nfx.CONTXA(context_type='TB', index_list='1') + rpc));
            collection.manifest_template = nfx.File(header=collection.header) + wrapper;
            files = collection.plan(); file = files(2).file;
            t.verifyTrue(file.context_complete);
            edited = file.replaceImage(1, file.images(1));
            t.verifyFalse(edited.context_complete);
            report = edited.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id}, 'CollectionContextChanged')));
        end

        function readingExampleRunsWithoutPrivateFixtures(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'examples')));
            [original, edited] = readingExample(t.folder);
            t.verifyEqual(readBytes(fullfile(t.folder, 'reader-source.ntf')), ...
                readBytes(fullfile(t.folder, 'reader-copy.ntf')));
            t.verifyEqual(edited.images(1).RPC00B().err_bias, 1.5);
            t.verifyEqual(original.images(1).RPC00B().err_bias, 0.25);
            t.verifyEqual(edited.images(2).data, original.images(2).data);
        end
    end
end

function file = profileFile(model)
    [base, image, metadata] = fixtureSNIP(); file = base;
    if strcmp(model, 'RSM'), return, end
    for tag = {'RSMIDA', 'RSMPCA', 'RSMECB'}
        records = image.tre_records; ids = [records(strcmp({records.tag}, tag{1})).id];
        for id = ids, image = image.removeTRE(id); end
    end
    kind = model(end); exploitation = fixtureCSEXRB(kind);
    exploitation.sensor_id = 'AG3607'; exploitation.num_lines = 5;
    exploitation.num_samples = 7;
    if kind == 'S'
        exploitation.time_first_line_image = 43200;
        exploitation.time_image_duration = 0.5;
    else
        exploitation.base_timestamp = '20260915115959.999999999';
        exploitation.dt_multiplier = uint64(1); exploitation.dt = uint64(1);
    end
    attitude = fixtureCSATTB(); attitude.t0_att = '120000.000000000'; attitude.dt_att = 1;
    ephemeris = fixtureCSEPHB(); ephemeris.t0_ephem = '120000.000000000'; ephemeris.dt_ephem = 1;
    file = nfx.File(header=base.header) + metadata.dataset + ...
        (image + exploitation) + base.texts(1) + attitude + ephemeris + ...
        fixtureCSSFAB(kind) + fixtureCSCSDB();
end
