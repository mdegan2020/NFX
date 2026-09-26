function rgb = overviewPixels(data, limits, extent)
    %overviewPixels - Bilinearly sample an overview without a full-size copy
    rows = size(data, 1);
    columns = size(data, 2);
    x = min(columns, max(1, ...
        0.5 + ((1:extent(1)) - 0.5) * columns / extent(1)));
    y = min(rows, max(1, ...
        0.5 + ((1:extent(2)) - 0.5) * rows / extent(2)));
    left = floor(x);
    top = floor(y);
    right = min(columns, left + 1);
    bottom = min(rows, top + 1);
    wx = x - left;
    wy = (y - top).';
    rgb = zeros(extent(2), extent(1), 3, 'uint8');
    for band = 1:size(data, 3)
        pair = limits(band, :);
        % Interpolate display intensities. In particular, NaN*0 must not
        % erase a finite neighbor at an exact source-pixel position.
        upper = double(stretchChannel(data(top, left, band), pair)) .* ...
            (1 - wx) + double(stretchChannel( ...
            data(top, right, band), pair)) .* wx;
        lower = double(stretchChannel(data(bottom, left, band), pair)) .* ...
            (1 - wx) + double(stretchChannel( ...
            data(bottom, right, band), pair)) .* wx;
        rgb(:, :, band) = uint8(upper .* (1 - wy) + lower .* wy);
    end
    if size(data, 3) == 1
        rgb(:, :, 2) = rgb(:, :, 1);
        rgb(:, :, 3) = rgb(:, :, 1);
    end
end
