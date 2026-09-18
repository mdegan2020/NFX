classdef TREDeserializeTest < NfxTest
    properties (TestParameter)
        treType = {'RPC00B', 'ACFTB', 'AIMIDB', 'CSCRNA', 'FCRNSA', ...
            'ICHIPB', 'FREESA', 'MIMCSA', 'CAMSDA', 'MICIDA', ...
            'MTIMSA', 'MTIMFA', 'TMINTA', 'MATESA', 'CSRLSB', ...
            'RSMIDA', 'RSMPCA', 'RSMGGA', 'RSMAPB', 'RSMDCB', 'RSMECB', ...
            'BANDSB', 'ILLUMB', 'HISTOA', 'CSEXRB', 'CSWRPB', 'SENSRB', ...
            'CSDIDA', 'RSMPIA', 'RSMGIA', 'FSYNWA', 'FASYWA', 'CONTXA', ...
            'J2KLRA','GEOPSB','BNDPLC','XMLDCA','SECURA','PIXQLA', ...
            'CSCCGA','MSTGTA','BLOCKA','ENGRDA'}
        badInput = {[], uint8([]), 'bytes', "bytes", uint16(1), ...
            uint8([1; 2]), zeros(2, 2, 'uint8'), zeros(1, 100000, 'uint8')}
    end

    methods (Test)
        function concretePayloadRoundTrip(t, treType)
            original = fixtureDecodableTRE(treType);
            payload = original.payload();
            [decoded, ok, status] = original.deserialize(payload);
            t.assertTrue(ok, status.message);
            t.verifyClass(decoded, class(original));
            t.verifySize(decoded, [1 1]);
            t.verifyEqual(decoded.payload(), payload);
            t.verifyEqual(status.code, 'OK');
        end

        function invalidInputReturnsDefault(t, treType, badInput)
            original = fixtureDecodableTRE(treType);
            [decoded, ok, status] = original.deserialize(badInput);
            t.verifyFalse(ok);
            t.verifyClass(decoded, class(original));
            t.verifySize(decoded, [1 1]);
            t.verifyEqual(status.code, 'InvalidPayload');
        end

        function truncatedAndDamagedPayloadsUseStatus(t, treType)
            original = fixtureDecodableTRE(treType);
            payload = original.payload();
            cuts = unique([0 1 floor(numel(payload) / 2) numel(payload)-1]);
            if ~strcmp(treType, 'FREESA')
                for count = cuts
                    [decoded, ok, status] = ...
                        original.deserialize(payload(1:count));
                    t.verifyFalse(ok, sprintf('Accepted %d bytes', count));
                    t.verifyClass(decoded, class(original));
                    t.verifyNotEqual(status.code, 'OK');
                end
            end
            for at = unique(round(linspace(1, numel(payload), 11)))
                damaged = payload;
                damaged(at) = 0;
                [decoded, ok, status] = original.deserialize(damaged);
                if ~ok
                    t.verifySize(decoded, [1 1]);
                    t.verifyNotEqual(status.code, 'OK');
                end
            end
        end

        function rpcHasIndependentEncodedFieldValues(t)
            original = fixtureRPC();
            payload = original.payload();
            [decoded, ok] = nfx.RPC00B.deserialize(payload);
            t.assertTrue(ok);
            t.verifyEqual(decoded.line_off, 123);
            t.verifyEqual(decoded.samp_off, 45);
            t.verifyEqual(decoded.lat_off, 12.3456);
            t.verifyEqual(decoded.long_off, -98.7654);
            decoded.line_off = 999;
            t.verifyEqual(original.line_off, 123);
            t.verifyEqual(original.payload(), payload);
        end

        function timingPreservesEveryUnsignedBitAndExplicitWidth(t)
            original = fixtureTiming();
            original.dt_multiplier = intmax('uint64');
            original.dt = intmax('uint64') - uint64(7);
            original.dt_size = 8;
            [decoded, ok, status] = nfx.MTIMSA.deserialize(original.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.dt, original.dt);
            t.verifyEqual(decoded.dt_multiplier, original.dt_multiplier);
            t.verifyEqual(decoded.dt_size, 8);
            original.dt = uint64(1);
            original.dt_size = 7;
            [decoded, ok] = nfx.MTIMSA.deserialize(original.payload());
            t.assertTrue(ok);
            t.verifyEqual(decoded.dt_size, 7);
        end

        function typedMissingLookupReturnsDefaultAndStatus(t)
            image = nfx.ImageSegment() + fixtureRPC();
            [rpc, ok, status] = image.RPC00B(2);
            t.verifyFalse(ok);
            t.verifyEqual(status.code, 'NotFound');
            t.verifyEqual(rpc, nfx.RPC00B());
            [rpc, ok] = image.RPC00B;
            t.verifyTrue(ok);
            t.verifyEqual(rpc.payload(), fixtureRPC().payload());
        end
    end
end
