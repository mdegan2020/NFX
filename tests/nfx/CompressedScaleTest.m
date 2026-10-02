classdef (TestTags = {'OpenJPEG', 'LargeData'}) CompressedScaleTest < NfxTest
    methods (Test)
        function singleFullResolutionFrame(t)
            source = fixtureCompressedSequence(getenv('NFX_OPENJPEG'), [5000 15000], 1);
            planned = source.plan();
            t.verifyEqual(planned(2).file.header.clevel, 6);
            paths = source.write(t.folder);
            t.verifyEqual(nitfread(paths{1}), source.blocks.image.data);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.blocks.image.data, source.blocks.image.data);
            t.verifyEqual(copy.blocks.image.compression.codestream, ...
                source.blocks.image.compression.codestream);
        end

        function twentyFullResolutionFrames(t)
            % This opt-in fixture uses 3 GB of native source pixels alone.
            encoder = getenv('NFX_OPENJPEG');
            source = fixtureCompressedSequence(encoder, [5000 15000], 20);
            planned = source.plan();
            t.verifyEqual(planned(2).file.header.clevel, 6);
            paths = source.write(t.folder);
            [copy, ok, status] = nfx.MIECollection.read(paths{end});
            t.assertTrue(ok, status.message); t.verifyNumElements(copy.blocks, 20);
            for k = 1:20
                t.verifyEqual(copy.blocks(k).image.data, source.blocks(k).image.data);
                t.verifyEqual(copy.blocks(k).image.compression.codestream, ...
                    source.blocks(k).image.compression.codestream);
            end
        end
    end
end
