classdef TREInspectionTest < NfxTest
    properties (TestParameter)
        tag = {'RPC00B', 'ACFTB', 'AIMIDB', 'CSCRNA', 'FCRNSA', ...
            'ICHIPB', 'FREESA', 'MIMCSA', 'CAMSDA', 'MICIDA', ...
            'MTIMSA', 'MTIMFA', 'TMINTA', 'MATESA', 'CSRLSB', ...
            'RSMIDA', 'RSMPCA', 'RSMPIA', 'RSMGGA', 'RSMGIA', ...
            'RSMAPB', 'RSMDCB', 'RSMECB', 'BANDSB', 'ILLUMB', ...
            'HISTOA', 'CSEXRB', 'SENSRB', 'CSWRPB', 'CSDIDA', ...
            'FSYNWA', 'FASYWA', 'CONTXA'}
        badIndex = {0, -1, NaN, Inf, 1.5, [1 2], single(1), ...
            uint64(1), '1', "1", 1i, sparse(1), flintmax}
        badID = {-1, NaN, Inf, 1.5, [1 2], single(1), ...
            uint64(1), '1', "1", 1i, sparse(1), flintmax}
    end

    methods (Test)
        function nestedEnvelopeLengthsMustBeCanonical(t)
            inner = nfx.FSYNWA() + nfx.FREESA(1);
            outer = nfx.CONTXA(context_type='IS', index_list='1') + inner;
            payload = outer.payload();
            % Eight context bytes + eleven envelope bytes + eighteen frame
            % bytes + six tag bytes place the nested five-digit length.
            t.assertEqual(char(payload(44:48)), '00001');
            for word = {' 0001', '1E+00', '+0001'}
                damaged = payload;
                damaged(44:48) = uint8(word{1});
                [copy, ok, status] = nfx.CONTXA.deserialize(damaged);
                t.verifyFalse(ok);
                t.verifyEqual(status.code, 'NoncanonicalPayload');
                t.verifyEqual(copy, nfx.CONTXA());
            end
        end

        function wrappedConcreteValuesSurviveNestedReconstruction(t, tag)
            original = fixtureDecodableTRE(tag);
            context = 'IS';
            if isa(ownerFor(tag), 'nfx.File')
                context = 'FH';
            end
            wrapper = nfx.CONTXA(context_type=context, index_list='1') + ...
                original;
            if strcmp(tag, 'MTIMSA')
                % Segment timing has no legal wrapped placement.
                t.verifyFalse(wrapper.validate().valid);
                return
            end
            outer = nfx.CONTXA(context_type='FH', index_list='1') + wrapper;
            [copy, ok, status] = nfx.CONTXA.deserialize(outer.payload());
            t.assertTrue(ok, status.message);
            wrapperCopy = copy.getCONTXA;
            method = tag;
            if any(strcmp(tag, {'CONTXA', 'FSYNWA', 'FASYWA'}))
                method = ['get' tag];
            end
            [decoded, ok, status] = wrapperCopy.(method)(ID=1);
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.payload(), original.payload());
            t.verifyEqual(wrapperCopy.treCount(tag), 1);
            t.verifyEqual(wrapperCopy.tre(1).records.payload, ...
                original.payload());
            t.verifyEqual(copy.payload(), outer.payload());
        end

        function wrappedSensorGroupLimitRetainsOneIdentity(t)
            sensor = fixtureSensor();
            sensor.time_stamped_data = repmat( ...
                nfx.SENSRB.timeSeries('06a', 0, 40), 1, 100);
            wrapper = nfx.FSYNWA() + sensor + nfx.FREESA(1);
            [copy, ok, status] = nfx.FSYNWA.deserialize(wrapper.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.treCount(), 2);
            t.verifyEqual(copy.treCount('SENSRB'), 1);
            t.verifyEqual(copy.tre(1).physical_count, 2);
            t.verifyEqual(copy.SENSRB().physicalRecords(), ...
                sensor.physicalRecords());
            copy = copy.removeTRE(1);
            t.verifyEqual(copy.tre_ids, 2);
            t.verifyEqual(copy.FREESA().count, 1);
        end

        function repeatedTypedAccessAndStableIDs(t, tag)
            original = fixtureDecodableTRE(tag);
            owner = ownerFor(tag);
            owner = owner + original + nfx.FREESA(1) + original;
            firstID = owner.tre_ids(1);
            lastID = owner.tre_ids(3);
            occurrence = 2;
            if strcmp(tag, 'FREESA')
                occurrence = 3;
            end
            [decoded, ok, status] = owner.(tag)(occurrence);
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.payload(), original.payload());
            [byID, ok, status] = owner.(tag)(ID=lastID);
            t.assertTrue(ok, status.message);
            t.verifyEqual(byID.payload(), original.payload());
            owner = owner.removeTRE(firstID);
            t.verifyEqual(owner.tre_ids(end), lastID);
            [decoded, ok] = owner.(tag)(occurrence - 1);
            t.assertTrue(ok);
            t.verifyEqual(decoded.payload(), original.payload());
            [record, ok] = owner.tre(ID=lastID);
            t.assertTrue(ok);
            t.verifyEqual(record.id, lastID);
            t.verifyEqual(record.records.payload, original.payload());
            text = evalc('disp(record)');
            t.verifySubstring(text, tag);
            t.verifyFalse(contains(text, 'No concrete decoder'));
            t.verifyLessThan(numel(text), 15000);
        end

        function everyMissingTypedAccessorReturnsItsConcreteDefault(t, tag)
            owner = ownerFor(tag);
            [decoded, ok, status] = owner.(tag);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'NotFound');
            t.verifyEqual(decoded, feval(['nfx.' tag]));
        end

        function invalidOccurrenceDoesNotThrow(t, badIndex)
            image = nfx.ImageSegment() + fixtureRPC();
            [rpc, ok, status] = image.RPC00B(badIndex);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidSelector');
            t.verifyEqual(rpc, nfx.RPC00B());
            [record, ok, status] = image.tre(badIndex);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidSelector');
            t.verifyEmpty(record.records);
        end

        function invalidIdentityDoesNotThrow(t, badID)
            image = nfx.ImageSegment() + fixtureRPC();
            [rpc, ok, status] = image.RPC00B(ID=badID);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidSelector');
            t.verifyEqual(rpc, nfx.RPC00B());
        end

        function missingWrongTypeAndConflictingSelectionAreDistinct(t)
            image = nfx.ImageSegment() + fixtureRPC() + nfx.FREESA(3);
            [~, ok, status] = image.RPC00B(ID=2);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'NotFound');
            [~, ok, status] = image.RPC00B(2, ID=1);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidSelector');
            [record, ok] = image.tre(ID=99);
            t.verifyFalse(ok);
            t.verifyEqual(record.byte_count, 0);
            t.verifyTrue(isnan(record.id));
            t.verifyEmpty(record.tag);
            t.verifySubstring(evalc('disp(record)'), 'no attachment');
        end

        function countsIncludeDirectAttachmentsAndSurvivingOrder(t)
            image = nfx.ImageSegment() + fixtureRPC() + ...
                nfx.FREESA(1) + fixtureRPC() + (nfx.FSYNWA() + fixtureRPC());
            t.verifyEqual(image.treCount(), 4);
            t.verifyEqual(image.treCount("RPC00B"), 2);
            t.verifyEqual(image.treCount('MTIMSA'), 0);
            [count, ok, status] = image.treCount(["RPC00B" "FREESA"]);
            t.verifyEqual(count, 0);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'InvalidSelector');
            image = image.removeTRE(1);
            t.verifyEqual(image.tre(2).id, 3);
            t.verifyEqual(image.treCount('RPC00B'), 1);
        end

        function decodedAndRecordCopiesCannotMutateStoredSnapshots(t)
            original = fixtureRPC();
            image = nfx.ImageSegment() + original;
            saved = image.tre_records;
            rpc = image.RPC00B;
            rpc.line_num_coeff(1) = 55;
            rpc.line_off = 900;
            record = image.tre(1);
            raw = record.records;
            raw.payload(:) = 0;
            t.verifyEqual(image.tre_records, saved);
            t.verifyEqual(record.records, saved);
            image = image.removeTRE(1) + rpc;
            t.verifyEqual(image.RPC00B().line_off, 900);
            t.verifyEqual(image.tre_ids, 2);
        end

        function textOwnerUsesTheSameTypedAndViewAPI(t)
            text = nfx.TextSegment() + fixtureCorners('FCRNSA') + ...
                nfx.FREESA(3);
            t.verifyEqual(text.treCount(), 2);
            [corners, ok] = text.FCRNSA(ID=1);
            t.verifyTrue(ok);
            t.verifyEqual(corners.ulcrn_lat, 40);
            [free, ok] = text.FREESA;
            t.verifyTrue(ok);
            t.verifyEqual(free.count, 3);
            t.verifyEqual(text.tre(2).id, 2);
        end

        function nestedWrappersHaveLocalEditableSnapshots(t)
            frame = nfx.CONTXA(context_type='FR', index_list='1-3') + ...
                fixtureRPC() + nfx.FREESA(2);
            outer = nfx.CONTXA(context_type='IS', index_list='2') + frame;
            file = nfx.File() + outer;
            [decoded, ok, status] = file.CONTXA;
            t.assertTrue(ok, status.message);
            [nested, ok, status] = decoded.getCONTXA;
            t.assertTrue(ok, status.message);
            t.verifyEqual(nested.RPC00B().payload(), fixtureRPC().payload());
            t.verifyEqual(nested.treCount(), 2);
            t.verifyEqual(decoded.treCount('RPC00B'), 0);
            nested = nested.removeTRE(1) + fixtureRPC();
            t.verifyEqual(nested.tre_ids, [2 3]);
            t.verifyEqual(file.CONTXA().payload(), outer.payload());
            t.verifyEqual(decoded.getCONTXA().tre_ids, [1 2]);
        end

        function wrapperAliasesAvoidTheirOwnConstructorNames(t)
            frame = nfx.FSYNWA() + fixtureRPC();
            nestedFrame = nfx.FSYNWA() + frame;
            [copy, ok] = nestedFrame.getFSYNWA;
            t.verifyTrue(ok);
            t.verifyEqual(copy.payload(), frame.payload());
            async = fixtureDecodableTRE('FASYWA');
            outer = nfx.CONTXA(context_type='IS', index_list='1') + async;
            [copy, ok] = outer.getFASYWA;
            t.verifyTrue(ok);
            t.verifyEqual(copy.payload(), async.payload());
            [copy, ok] = async.getFASYWA;
            t.verifyFalse(ok);
            t.verifyEqual(copy, nfx.FASYWA());
        end

        function nestedCorruptionReturnsStatusBeforeScopeInspection(t)
            outer = nfx.CONTXA(context_type='IS', index_list='1') + ...
                (nfx.FSYNWA() + fixtureCSEXRB());
            payload = outer.payload();
            for at = 1:numel(payload)
                damaged = payload;
                damaged(at) = 0;
                [copy, ok, status] = nfx.CONTXA.deserialize(damaged);
                t.verifyFalse(ok, sprintf('Accepted damaged byte %d', at));
                t.verifyNotEqual(status.code, 'OK');
                t.verifyEqual(copy, nfx.CONTXA());
            end
        end

        function sensorContinuationsAreOneLogicalAttachment(t)
            sensor = fixtureSensor();
            sensor.time_stamped_data = nfx.SENSRB.timeSeries( ...
                '06a', 0:4999, repmat(40, 1, 5000));
            sensor.uncertainty_data = nfx.SENSRB.uncertainty('12d1.1', .5);
            image = nfx.ImageSegment() + nfx.FREESA(1) + sensor + ...
                nfx.FREESA(2) + fixtureSensor();
            t.verifyEqual(image.treCount('SENSRB'), 2);
            t.verifyEqual(image.treCount(), 4);
            [decoded, ok, status] = image.SENSRB;
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.physicalRecords(), sensor.physicalRecords());
            t.verifyEqual([decoded.time_stamped_data.time_stamp_time], 0:4999);
            view = image.tre(2);
            t.verifyEqual(view.physical_count, 2);
            t.verifyEqual(view.id, 2);
            shown = evalc('disp(view)');
            t.verifySubstring(shown, 'time_stamped_data');
            t.verifyLessThan(numel(shown), 12000);
            image = image.removeTRE(2);
            t.verifyEqual(image.tre_ids, [1 3 4]);
            t.verifyEqual(image.SENSRB().physicalRecords(), ...
                fixtureSensor().physicalRecords());
        end

        function unknownAndMalformedViewsRemainBounded(t)
            raw = struct('tag', 'NEW123', 'payload', uint8(1:100), 'id', 7);
            view = nfx.TRERecord(raw); %#ok<NASGU>
            t.verifySubstring(evalc('disp(view)'), 'No concrete decoder');
            raw.tag = 'RPC00B';
            view = nfx.TRERecord(raw); %#ok<NASGU>
            t.verifySubstring(evalc('disp(view)'), 'Invalid');
            view = nfx.TRERecord(struct());
            t.verifyEmpty(view.records);
        end
    end
end

function owner = ownerFor(tag)
    %ownerFor - Choose a legal direct attachment scope for each fixture
    if any(strcmp(tag, {'MIMCSA', 'CAMSDA', 'MICIDA', 'MTIMFA', ...
            'TMINTA', 'CSDIDA'}))
        owner = nfx.File();
    else
        owner = nfx.ImageSegment();
    end
end
