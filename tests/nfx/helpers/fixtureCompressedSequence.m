function source = fixtureCompressedSequence(encoder, shape, count)
    %fixtureCompressedSequence - Independent native frames with supplied UTCs
    source = fixtureCompressedCollection(encoder, 'NPJE', 'uint16', 'MONO');
    camera = source.camera_sets.camera_sets.cameras;
    camera.nrows = shape(1); camera.ncols = shape(2);
    source.camera_sets = nfx.CAMSDA(camera_sets=struct('cameras', camera));
    block = source.blocks(1); source.blocks = nfx.MotionBlock.empty(1, 0);
    for k = 1:count
        pixels = repmat(uint16(0:shape(2)-1), shape(1), 1);
        pixels(1, 1) = uint16(k);
        image = block.image; image.data = pixels;
        block.image = image.compress(encoder);
        block.start_timestamp = sprintf('20260915120000.%09d', (k - 1) * 40000000);
        block.end_timestamp = sprintf('20260915120000.%09d', k * 40000000);
        block.timing.base_timestamp = block.start_timestamp;
        source = source + block;
    end
end
