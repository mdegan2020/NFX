classdef PublishedTRETest < NfxTest
    properties (TestParameter)
        tag = {'COMNTA','SYSIDA','S2EVPA','CSPROA','USE00A','EXOPTA', ...
            'SECTGA','STREOB','PATCHB','STDIDC','EXPLTB','MENSRB', ...
            'GEOLOB','MAPLOB','PRJPSB','GRDPSB','BNDPLB','CSEPHA','NBLOCA', ...
            'PIAIMC','PIAEVA','PIAEQA','PIAPEB','PIATGB','PIAPRD', ...
            'ISACPA','ISASIA','ISATPA','ASTORA','IOMAPA', ...
            'REGPTB','REGPTC','ACCPOB','ACCHZB','ACCVTB','CSEXRA','MTIRPB', ...
            'RELCCA','CCINFA','J2KLRB','PIXMTA','FACCBB','SNSPSB','SOURCB', ...
            'RSMAPA','RSMDCA','RSMECA','MITOCA','BCHIPA','ATTPTA','CSSFAA'}
        badInput = {[], uint8([]), 'abc', uint16(1), uint8([1; 2]), ...
            zeros(1, 99986, 'uint8')}
    end
    methods (Test)
        function independentBytesAndTypedDecode(t, tag)
            [tre, expected] = fixturePublishedTRE(tag);
            report = tre.validate();
            t.assertTrue(report.valid, evalc('disp(report.issues)'));
            t.verifyEqual(tre.payload(), expected);
            [copy, ok, status] = tre.deserialize(expected);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.payload(), expected);
            t.verifyClass(copy, ['nfx.' tag]);
        end

        function rejectsInvalidInputWithoutThrowing(t, tag, badInput)
            tre = fixturePublishedTRE(tag);
            [copy, ok, status] = tre.deserialize(badInput);
            t.verifyFalse(ok);
            t.verifyClass(copy, class(tre));
            t.verifyNotEqual(status.code, 'OK');
        end

        function boundedCountsAndTruncation(t, tag)
            tre = fixturePublishedTRE(tag);
            bytes = tre.payload();
            if strcmp(tag, 'COMNTA')
                % Removing the final byte cuts a four-byte UTF-8 scalar.
                cuts = numel(bytes) - 1;
            else
                cuts = unique([1 floor(numel(bytes) / 2) numel(bytes) - 1]);
            end
            for count = cuts
                [~, ok] = tre.deserialize(bytes(1:count));
                t.verifyFalse(ok, sprintf('%s accepted %d bytes', tag, count));
            end
        end

        function snapshotLookupDisplayAndRemoval(t, tag)
            tre = fixturePublishedTRE(tag);
            image = publishedOwner(tag) + tre + tre;
            [copy, ok, status] = image.(tag)(2);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.payload(), tre.payload());
            [copy, ok] = image.(tag)(ID=image.tre_ids(1));
            t.assertTrue(ok);
            t.verifyEqual(copy.payload(), tre.payload());
            image = image.removeTRE(image.tre_ids(1));
            t.verifyEqual(image.treCount(tag), 1);
            [~, ok, status] = image.(tag)(2);
            t.verifyFalse(ok);
            t.verifyNotEqual(status.code, 'OK');
            text = evalc('disp(image.tre(1))');
            t.verifySubstring(text, tag);
            t.verifyFalse(contains(text, 'No concrete decoder'));
            context = 'IS';
            if isa(image, 'nfx.File'), context = 'FH'; end
            wrapper = nfx.CONTXA(context_type=context, index_list='1') + tre;
            [decoded, ok, status] = nfx.CONTXA.deserialize(wrapper.payload());
            t.assertTrue(ok, status.message);
            copy = decoded.(tag)();
            t.verifyEqual(copy.payload(), tre.payload());
        end

        function completeFileRoundTrip(t, tag)
            [file, image] = fixtureFile();
            if strcmp(tag, 'S2EVPA')
                [file, image] = fixtureFile(ones(5, 7, 3, 'uint16'), 'MULTI');
            end
            tre = fixturePublishedTRE(tag);
            if isa(publishedOwner(tag), 'nfx.File')
                file = file + tre;
            else
                image = image + tre;
                file = nfx.File(header=file.header) + image;
            end
            path = fullfile(t.folder, 'published.ntf');
            file.write(path);
            [copy, ok, status] = nfx.File.read(path, readAll=true);
            t.assertTrue(ok, status.message);
            partial = any(strcmp(tag, {'RSMAPA', 'RSMDCA', 'RSMECA', ...
                'BCHIPA', 'ATTPTA', 'NBLOCA', 'J2KLRB', 'CSEPHA', 'PIXMTA'}));
            t.verifyEqual(status.metadata_complete, ~partial);
            if isa(publishedOwner(tag), 'nfx.File')
                [tre, ok] = copy.(tag)();
            else
                [tre, ok] = copy.images(1).(tag)();
            end
            t.assertTrue(ok);
            original = fixturePublishedTRE(tag);
            t.verifyEqual(tre.payload(), original.payload());
            output = fullfile(t.folder, 'roundtrip.ntf');
            copy.write(output);
            t.verifyEqual(readBytes(output), readBytes(path));
        end

        function unicodeRejectsMalformedScalarEncodings(t)
            invalid = {[192 128], [237 160 128], [244 144 128 128], ...
                [240 128 128 128], 128, [226 130], [239 187 191 65], ...
                [65 10 66], [65 13 66]};
            for k = 1:numel(invalid)
                [~, ok] = nfx.COMNTA.deserialize(uint8(invalid{k}));
                t.verifyFalse(ok);
            end
            t.verifyFalse(nfx.COMNTA(comment=char(55296)).validate().valid);
            t.verifyFalse(nfx.COMNTA(comment=char(56320)).validate().valid);
        end

        function declaredVariableCountsAreBoundedBeforeAllocation(t)
            [~, ok] = nfx.S2EVPA.deserialize(uint8('999short'));
            t.verifyFalse(ok);
            [~, ok] = nfx.SYSIDA.deserialize(uint8('999short'));
            t.verifyFalse(ok);
        end

        function damagedFieldsNeverThrow(t, tag)
            tre = fixturePublishedTRE(tag);
            original = tre.payload();
            positions = unique(round(linspace(1, numel(original), 24)));
            for index = positions
                for replacement = uint8([0 57 255])
                    bytes = original;
                    bytes(index) = replacement;
                    [copy, ok, status] = tre.deserialize(bytes);
                    if ok
                        t.verifyEqual(copy.payload(), bytes);
                    else
                        t.verifyNotEqual(status.code, 'OK');
                    end
                end
            end
        end
    end
end

function owner = publishedOwner(tag)
    if any(strcmp(tag, {'PIAPRD', 'MITOCA'}))
        owner = nfx.File();
    else
        owner = nfx.ImageSegment();
    end
end
