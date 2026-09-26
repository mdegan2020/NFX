function rgb = stretchPixels(data, limits)
    %stretchPixels - Convert only the requested pixels to display RGB bytes
    rgb = zeros(size(data, 1), size(data, 2), 3, 'uint8');
    for band = 1:size(data, 3)
        rgb(:, :, band) = stretchChannel(data(:, :, band), limits(band, :));
    end
    if size(data, 3) == 1
        rgb(:, :, 2) = rgb(:, :, 1);
        rgb(:, :, 3) = rgb(:, :, 1);
    end
end
