function collection = fixtureCompressedCollection(encoder, profile, pixelType, representation, shape)
    %fixtureCompressedCollection - Two supplied frames in one original layer
    if nargin < 5, shape = [33 35]; end
    collection = fixtureMIECollection();
    collection.layers = collection.layers(1);
    collection.layers.mi_req_decoder = 'C8';
    collection.layers.mi_req_profile = 'ISO/IEC 15444-1';
    collection.layers.mi_req_level = 'class2';
    camera = collection.camera_sets.camera_sets(1).cameras(1);
    camera.nrows = shape(1); camera.ncols = shape(2);
    collection.camera_sets = nfx.CAMSDA(camera_sets=struct('cameras', camera));
    collection.camera_ids.cameras = collection.camera_ids.cameras(1);
    collection.intervals.intervals = collection.intervals.intervals(1);
    collection.blocks = collection.blocks(1:2);
    bands = 1;
    if strcmp(representation, 'RGB'), bands = 3; end
    if strcmp(representation, 'MULTI'), bands = 5; end
    for k = 1:2
        pixels = reshape(cast(mod((0:prod(shape)*bands-1)*251 + k, ...
            double(intmax(pixelType)) + 1), pixelType), [shape bands]);
        [~, image] = fixtureMotion(pixels, representation);
        image = image.removeTRE(image.tre_ids(1));
        image.header.nppbh = 1024; image.header.nppbv = 1024;
        collection.blocks(k).image = image.compress(encoder, Profile=profile);
        collection.blocks(k).timing.dt = zeros(1, 0, 'uint64');
    end
end
