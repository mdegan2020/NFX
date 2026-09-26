function limits = displayLimits(data, stretch, supplied)
    %displayLimits - Estimate fixed per-channel limits with bounded sampling
    bands = size(data, 3);
    if ~isempty(supplied)
        if ~isnumeric(supplied) || ~isreal(supplied) || ...
                ~ismatrix(supplied) || size(supplied, 2) ~= 2 || ...
                ~ismember(size(supplied, 1), [1 bands]) || ...
                any(~isfinite(supplied), 'all') || ...
                any(supplied(:, 2) <= supplied(:, 1))
            error('twd:InvalidLimits', ...
                'Limits must be finite increasing pairs, one or per channel.');
        end
        limits = repmat(double(supplied), bands / size(supplied, 1), 1);
        return;
    end
    limits = zeros(bands, 2);
    count = size(data, 1) * size(data, 2);
    % Spread samples over the full array, without a full double conversion.
    indices = unique(round(linspace(1, count, min(count, 100000))));
    for band = 1:bands
        if strcmp(stretch, 'minmax')
            low = Inf;
            high = -Inf;
            for first = 1:100000:count
                values = double(data((first:min(first + 99999, count)) ...
                    + (band - 1) * count));
                values = values(isfinite(values));
                if ~isempty(values)
                    low = min(low, min(values));
                    high = max(high, max(values));
                end
            end
        else
            values = double(data(indices + (band - 1) * count));
            values = sort(values(isfinite(values)));
            values = values(:).';
            if isempty(values)
                low = Inf;
                high = -Inf;
            else
                % Linear interpolation between ordered samples.
                ranks = 1 + (numel(values) - 1) * [0.02 0.98];
                lower = floor(ranks);
                upper = ceil(ranks);
                fraction = ranks - lower;
                pair = values(lower) .* (1 - fraction) + ...
                    values(upper) .* fraction;
                low = pair(1);
                high = pair(2);
                if low == high
                    low = values(1);
                    high = values(end);
                end
            end
        end
        if ~isfinite(low)
            limits(band, :) = [0 1];
        else
            % A constant finite channel displays as mid-gray.
            limits(band, :) = [low high];
        end
    end
end
