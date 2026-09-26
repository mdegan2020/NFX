function rect = viewRectangle(center, extent, bounds, snap)
    %viewRectangle - Clamp a fixed-size view without changing its scale
    center = double(center(:).');
    low = bounds(1:2) + extent / 2;
    high = bounds(1:2) + bounds(3:4) - extent / 2;
    center = min(high, max(low, center));
    oversized = extent >= bounds(3:4);
    midpoint = bounds(1:2) + bounds(3:4) / 2;
    center(oversized) = midpoint(oversized);
    origin = center - extent / 2;
    if snap
        % Put main-view pixel edges on display-pixel edges at 1:1.
        origin = floor(origin) + 0.5;
    end
    rect = [origin extent];
end
