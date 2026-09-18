function [valid, supported] = polygonTopology(rings, geographic) %#codegen
    %polygonTopology - Check simple nested rings in a local coordinate plane
    %   Geographic rings use continuous longitudes and must span less than
    %   180 degrees. Intersections, touching rings and reversed nesting fail.
    valid = false;
    supported = true;
    if isempty(rings), return; end
    work = rings;
    center = 0;
    for k = 1:numel(work)
        x = work(k).lon;
        if geographic
            for j = 2:numel(x)
                delta = x(j) - x(j - 1);
                if delta >= 180 || delta < -180
                    x(j) = x(j) - 360 * floor((delta + 180) / 360);
                end
            end
            if max(x) - min(x) >= 180
                supported = false;
                return
            end
            if k == 1, center = mean(x); end
            x = x + 360 * round((center - mean(x)) / 360);
        end
        work(k).lon = x;
    end
    areas = zeros(1, numel(work));
    for k = 1:numel(work)
        % A separate local scale prevents large rings from erasing small
        % rings. Keep shared coordinates for intersections and nesting.
        x = work(k).lon - work(k).lon(1);
        y = work(k).lat - work(k).lat(1);
        scale = max([abs(x) abs(y)]);
        if scale == 0, return; end
        x = x / scale; y = y / scale;
        n = numel(x); next = [2:n 1]; previous = [n 1:n-1];
        dx = x(next) - x; dy = y(next) - y;
        if any(dx == 0 & dy == 0), return; end
        [terms, errors] = determinant(x, y, x(next), y(next));
        areas(k) = sum(terms);
        if abs(areas(k)) <= sum(errors), return; end
        px = x(previous) - x; py = y(previous) - y;
        [turn, errors] = determinant(px, py, dx, dy);
        if any(abs(turn) <= errors & px .* dx + py .* dy > 0)
            return
        end
        for j = 1:n
            candidates = j+2:n;
            if j == 1, candidates(candidates == n) = []; end
            if crosses(x(j), y(j), x(next(j)), y(next(j)), ...
                    x(candidates), y(candidates), ...
                    x(next(candidates)), y(next(candidates)))
                return
            end
        end
    end
    for k = 1:numel(work)
        a = work(k); an = [2:numel(a.lon) 1];
        nesting = 0;
        for j = 1:numel(work)
            if j == k, continue; end
            b = work(j); bn = [2:numel(b.lon) 1];
            if j > k
                for p = 1:numel(a.lon)
                    if crosses(a.lon(p), a.lat(p), ...
                            a.lon(an(p)), a.lat(an(p)), ...
                            b.lon, b.lat, b.lon(bn), b.lat(bn))
                        return
                    end
                end
            end
            selected = (b.lat > a.lat(1)) ~= (b.lat(bn) > a.lat(1));
            x = b.lon(selected); y = b.lat(selected);
            xn = b.lon(bn(selected)); yn = b.lat(bn(selected));
            hits = a.lon(1) < x + (a.lat(1) - y) .* (xn - x) ./ (yn - y);
            nesting = nesting + mod(nnz(hits), 2);
        end
        if (areas(k) < 0) ~= (mod(nesting, 2) == 0), return; end
    end
    valid = true;
end

function hit = crosses(ax, ay, bx, by, cx, cy, dx, dy) %#codegen
    %crosses - Include boundary contacts and collinear segment overlaps
    [one, e1] = determinant(bx - ax, by - ay, cx - ax, cy - ay);
    [two, e2] = determinant(bx - ax, by - ay, dx - ax, dy - ay);
    [three, e3] = determinant(dx - cx, dy - cy, ax - cx, ay - cy);
    [four, e4] = determinant(dx - cx, dy - cy, bx - cx, by - cy);
    separated = min(ax, bx) > max(cx, dx) | ...
        max(ax, bx) < min(cx, dx) | min(ay, by) > max(cy, dy) | ...
        max(ay, by) < min(cy, dy);
    first = (one <= e1 & two >= -e2) | (two <= e2 & one >= -e1);
    second = (three <= e3 & four >= -e4) | (four <= e4 & three >= -e3);
    hit = any(~separated & first & second);
end

function [value, tolerance] = determinant(ax, ay, bx, by) %#codegen
    %determinant - Scale the roundoff guard to the actual products
    positive = ax .* by; negative = ay .* bx;
    value = positive - negative;
    tolerance = 64 * eps * (abs(positive) + abs(negative));
end
