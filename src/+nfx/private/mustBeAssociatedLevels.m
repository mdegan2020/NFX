function mustBeAssociatedLevels(value) %#codegen
    mustBeMetadataArray(value, 1, 999, true);
    if ~(isrow(value) || isequal(size(value), [0 0])) || ...
            numel(value) > 998 || any(~isfinite(value))
        error('nfx:AssociatedLevels', ...
            'Supply at most 998 finite display levels from 1 through 999.');
    end
end
