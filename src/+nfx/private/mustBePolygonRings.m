function mustBePolygonRings(value) %#codegen
    %mustBePolygonRings - Enforce homogeneous finite coordinate row storage
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            numel(value) > 999 || numel(fieldnames(value)) ~= 3 || ...
            ~all(isfield(value, {'lon', 'lat', 'height'}))
        error('nfx:PolygonRings', 'Supply a row of lon/lat/height structs.');
    end
    for k = 1:numel(value)
        check(value(k).lon, -99999999999999, 999999999999999);
        check(value(k).lat, -99999999999999, 999999999999999);
        check(value(k).height, -999999999999.9, 999999999999.9);
    end
end

function check(value, lower, upper) %#codegen
    mustBeMetadataArray(value, lower, upper, false);
    if ~(isrow(value) || isequal(size(value), [0 0])) || ...
            numel(value) > 3332 || any(isnan(value))
        error('nfx:PolygonCoordinates', ...
            'Supply finite double rows with at most 3332 coordinates.');
    end
end
