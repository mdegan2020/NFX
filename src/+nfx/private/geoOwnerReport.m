function report = geoOwnerReport(records, inherited) %#codegen
    %geoOwnerReport - Resolve a polygon's coordinate reference and topology
    report = newReport('STDI-0002-1 Appendix P, Tables P-2 and P-9a');
    tags = {records.tag}; parentTags = {inherited.tag};
    local = find(strcmp(tags, 'GEOPSB'));
    parent = find(strcmp(parentTags, 'GEOPSB'));
    bounds = find(strcmp(tags, 'BNDPLC'));
    report = issue(report, numel(local) > 1 || numel(parent) > 1 || ...
        (~isempty(local) && ~isempty(parent)), 'CoordinateReference', ...
        'A coordinate context must resolve to one file or image GEOPSB.');
    report = issue(report, numel(bounds) > 1, 'BoundingPolygon', ...
        'Use one bounding polygon in each effective metadata context.');
    tre = nfx.GEOPSB(); present = false;
    if isscalar(local)
        tre = nfx.GEOPSB.deserialize(records(local).payload); present = true;
    elseif isscalar(parent)
        tre = nfx.GEOPSB.deserialize(inherited(parent).payload); present = true;
    end
    coverage = unknownTREReport(records);
    inheritedCoverage = unknownTREReport(inherited);
    complete = coverage.complete && inheritedCoverage.complete;
    report = issue(report, ~isempty(bounds) && ~present && complete, ...
        'MissingGEOPSB', 'A bounding polygon requires its GEOPSB coordinate reference.');
    if ~present, return; end
    report = issue(report, strcmp(tre.uni, 'M') && ...
        ~any(strcmp([tags parentTags], 'PRJPSB')) && complete, ...
        'MissingProjection', 'Meter coordinates require PRJPSB projection metadata.');
    for k = bounds
        polygon = nfx.BNDPLC.deserialize(records(k).payload);
        rings = polygon.rings;
        geographic = ~strcmp(tre.uni, 'M');
        if geographic
            factor = 1;
            if strcmp(tre.uni, 'SEC'), factor = 3600; end
            valid = true;
            for j = 1:numel(rings)
                rings(j).lon = rings(j).lon / factor;
                rings(j).lat = rings(j).lat / factor;
                valid = valid && all(abs(rings(j).lon) <= 180) && ...
                    all(abs(rings(j).lat) <= 90);
            end
            report = issue(report, ~valid, 'PolygonCoordinateRange', ...
                'Geographic coordinates must fit longitude/latitude limits in GEOPSB units.');
            if ~valid, continue; end
        else
            report = issue(report, polygon.dimensions ~= 2, ...
                'PolygonDimensions', 'Meter coordinate polygons must be two-dimensional.');
        end
        [valid, supported] = polygonTopology(rings, geographic);
        report = issue(report, ~supported, 'PolygonExtentUnsupported', ...
            'Geographic ring validation currently requires longitude spans below 180 degrees.');
        report = issue(report, supported && ~valid, 'PolygonTopology', ...
            'Use simple non-touching rings with clockwise exteriors and alternating nested holes.');
    end
end

function report = issue(report, condition, id, message) %#codegen
    report = addIssue(report, condition, id, 'tre_records', message, report.scope);
end
