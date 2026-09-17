classdef StorageShapeTest < NfxTest
    properties (TestParameter)
        commentCount = {0, 1, 9}
        payloadLength = {1, 251, 99985}
    end
    methods (Test)
        function commentsRetainOnlyActiveRows(t, commentCount)
            [~, image] = fixtureFile(uint8(1));
            rows = repmat('A', commentCount, 80);
            image.header.icom = rows;
            t.verifyEqual(image.header.icom, rows);
            t.verifyEqual(image.header.nicom, commentCount);
            bytes = image.header.bytes();
            t.verifyEqual(bytes(373), uint8('0') + uint8(commentCount));
            t.verifyEqual(bytes(374:373 + 80 * commentCount), ...
                reshape(uint8(rows).', 1, []));
            t.verifyEqual(char(bytes(374 + 80 * commentCount: ...
                375 + 80 * commentCount)), 'NC');
        end

        function shrinkingAndClearingCommentsDiscardInactiveRows(t)
            header = nfx.ImageHeader(icom=repmat('Z', 9, 80));
            snapshot = header;
            header.icom = 'short';
            t.verifyEqual(header.icom, ['short' repmat(' ', 1, 75)]);
            t.verifyEqual(header.nicom, 1);
            header.icom = '';
            t.verifySize(header.icom, [0 80]);
            t.verifyEqual(header.nicom, 0);
            t.verifyEqual(header, nfx.ImageHeader());
            t.verifyEqual(snapshot.icom, repmat('Z', 9, 80));
            header.icom = ["first", "second"];
            t.verifyEqual(header.icom, ...
                ['first ' repmat(' ', 1, 74); ...
                 'second' repmat(' ', 1, 74)]);
        end

        function multipleImagesRetainShapesAndNativeClasses(t)
            [base, first] = fixtureFile(uint8([1 2; 3 4]));
            [~, second] = fixtureFile(uint16([256 65535 0]));
            third = first;
            first.header.icom = 'one';
            second.header.icom = repmat('B', 9, 80);
            file = nfx.File(header=base.header) + first + second + third;
            filename = fullfile(t.folder, 'different-comments.ntf');
            file.write(filename);
            parsed = inspectContainer(filename);
            t.verifyEqual(parsed.images(1).fields.icom, first.header.icom);
            t.verifyEqual(parsed.images(2).fields.icom, second.header.icom);
            t.verifySize(parsed.images(3).fields.icom, [0 80]);
            t.verifyClass(file.images(1).data, 'uint8');
            t.verifyClass(file.images(2).data, 'uint16');
            t.verifySize(file.images(1).data, [2 2]);
            t.verifySize(file.images(2).data, [1 3]);
        end

        function commonRecordsRetainIndependentPayloadLengths(t, payloadLength)
            records = nfx.internal.emptyTRERecords();
            t.verifySize(records, [1 0]);
            records(1) = struct('tag', 'FREESA', ...
                'payload', uint8(17), 'id', 1);
            records(2) = struct('tag', 'FREESA', ...
                'payload', repmat(uint8(42), 1, payloadLength), 'id', 2);
            store = nfx.internal.TREStore.fromSnapshots(records);
            t.verifyEqual(store.records, records);
            t.verifySize(store.records(1).payload, [1 1]);
            t.verifySize(store.records(2).payload, [1 payloadLength]);
            view = nfx.TRERecord(store.records(2));
            t.verifyEqual(view.byte_count, payloadLength);
            records(2).payload(1) = 0;
            t.verifyEqual(view.records(1).payload(1), uint8(42));
            t.verifyEmpty(nfx.TRERecord(42).records);
        end

        function ownersDoNotShareDefaultStores(t)
            first = nfx.ImageSegment() + nfx.FREESA(7);
            second = nfx.ImageSegment();
            t.verifyEmpty(second.tre_records);
            t.verifyEqual(first.treCount('FREESA'), 1);
            t.verifyEmpty(nfx.File().tre_records);
            t.verifyEmpty(nfx.TextSegment().tre_records);
            t.verifyEmpty(nfx.FSYNWA().tre_records);
            t.verifyEmpty(nfx.MotionBlock().image.data);
        end
    end
end
