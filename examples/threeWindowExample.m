function viewer = threeWindowExample()
    %threeWindowExample - Explore a synthetic RGB image in three linked views
    %   VIEWER = threeWindowExample opens a synthetic scene containing fine
    %   stripes, circular boundaries, and color gradients. Drag the red box
    %   in the overview to pan. Drag the main-view box to inspect fine detail.
    %
    %   Add the repository's src and examples folders through MATLAB's Set
    %   Path dialog before running this example.
    %
    %   See also twd.show, twd.Display
    [x, y] = meshgrid(single(1:1800), single(1:1200));
    radius = hypot(x - 900, y - 600);
    stripes = mod(floor(x / 3) + floor(y / 3), 2);
    rings = mod(floor(radius / 35), 2);
    red = 1000 + 2500 * x / 1800 + 450 * stripes;
    green = 800 + 2500 * y / 1200 + 600 * rings;
    blue = 500 + 2200 * (1 - x / 1800) + 900 * stripes;
    pixels = uint16(cat(3, red, green, blue));

    viewer = twd.show(pixels, Title='TWD synthetic scene');
    viewer.zoomTo([970 620]);
end
