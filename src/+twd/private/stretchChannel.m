function bytes = stretchChannel(data, pair)
    %stretchChannel - Map one channel to bytes with nonfinite samples black
    values = double(data);
    if pair(1) == pair(2)
        mapped = repmat(0.5, size(values));
    else
        % Normalize first to avoid overflow for wide floating ranges.
        magnitude = max(abs(pair));
        mapped = (values / magnitude - pair(1) / magnitude) / ...
            (pair(2) / magnitude - pair(1) / magnitude);
    end
    mapped(~isfinite(values)) = 0;
    bytes = uint8(255 * min(1, max(0, mapped)));
end
