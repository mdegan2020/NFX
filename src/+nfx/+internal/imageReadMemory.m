function [retained, workspace, samples, encoded] = imageReadMemory(images, indices)
    %imageReadMemory - Estimate native arrays and payload buffers from headers
    retained = 0; workspace = 0; samples = 0; encoded = 0;
    for k = 1:numel(images)
        image = images(k);
        selected = any(indices == k);
        if ~image.pixelsLoaded && ~selected, continue; end
        h = image.header;
        count = h.nrows * h.ncols * image.number_bands * image.number_frames;
        samples = samples + count;
        retained = retained + count * h.nbpp / 8;
        if strcmp(h.ic, 'C8'), retained = retained + image.li; end
        if ~image.pixelsLoaded && selected
            encoded = encoded + image.li;
            % One segment is decoded at a time. Include its input buffer
            % and a native-size copy; codec workspace is implementation-specific.
            workspace = max(workspace, image.li + count * h.nbpp / 8);
        end
    end
end
