function data = associatedLevels(levels, allImages) %#codegen
    data = uint8('ALL');
    if allImages, return; end
    data = decimalField(numel(levels), 3, 0, false);
    for k = 1:numel(levels)
        data = [data decimalField(levels(k), 3, 0, false)]; %#ok<AGROW>
    end
end
