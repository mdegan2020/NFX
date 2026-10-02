function valid = validLegacyCorrelation(correlation, distance) %#codegen
    valid = numel(correlation) >= 2 && numel(correlation) <= 9 && ...
        numel(correlation) == numel(distance) && ...
        all(isfinite(correlation)) && all(isfinite(distance));
    if ~valid, return; end
    obj = nfx.RSMCorrelation(corseg=correlation, tauseg=distance);
    valid = obj.validate().valid;
end
