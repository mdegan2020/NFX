classdef (Sealed) BNDPLC < nfx.TRE
    %BNDPLC - Complex bounding polygon rings in an associated coordinate system
    %   OBJ = BNDPLC(RINGS) accepts a row of structs with double row fields
    %   lon, lat and height. Omit heights with an empty double row for 2-D
    %   rings. Every ring must use the same dimensionality. Supply vertices
    %   in order without repeating the first point at the end.
    %
    %   File validation resolves GEOPSB, checks coordinate units, and checks
    %   ring topology. Clockwise rings add coverage; counterclockwise rings
    %   remove it. Geographic topology uses unwrapped longitude/latitude
    %   coordinates and supports rings narrower than 180 degrees.
    %   Decoding accepts the variable decimal and exponent coordinate
    %   formats defined by Table P-9a. Attached records retain their bytes;
    %   serializing a decoded object uses NFX coordinate formatting.
    %
    %   See also GEOPSB, TRE, File, ImageSegment

    properties (Constant)
        cetag = 'BNDPLC'
    end
    properties
        rings {mustBePolygonRings} = struct('lon', {}, 'lat', {}, 'height', {})
    end
    properties (Dependent, SetAccess = private)
        num_rings
        dimensions
        num_pts
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode independent polygon coordinate arrays
            %   [OBJ, OK, STATUS] = nfx.BNDPLC.deserialize(PAYLOAD)
            %   checks the encoded structure; GEOPSB resolves in the file.
            %
            %   See also BNDPLC, BNDPLC.payload
            arguments
                data
            end
            obj = nfx.BNDPLC();
            reader = nfx.internal.TREReader(data);
            [count, reader] = polygonCount(reader, 3, 94, 999);
            [dimension, reader] = reader.choice('23');
            dims = 2;
            if reader.ok, dims = double(dimension) - double('0'); end
            ring = struct('lon', zeros(1, 0), 'lat', zeros(1, 0), ...
                'height', zeros(1, 0));
            rings = repmat(ring, 1, count);
            for k = 1:count
                [n, reader] = polygonCount(reader, 4, 15 * dims, 3332);
                if ~reader.ok, break; end
                rings(k).lon = zeros(1, n);
                rings(k).lat = zeros(1, n);
                if dims == 3, rings(k).height = zeros(1, n); end
                for j = 1:n
                    [rings(k).lon(j), reader] = polygonNumber( ...
                        reader, -99999999999999, 999999999999999);
                    [rings(k).lat(j), reader] = polygonNumber( ...
                        reader, -99999999999999, 999999999999999);
                    if dims == 3
                        [rings(k).height(j), reader] = polygonNumber( ...
                            reader, -999999999999.9, 999999999999.9);
                    end
                end
            end
            if reader.ok, obj.rings = rings; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.BNDPLC(), false);
        end
    end
    methods
        function obj = BNDPLC(rings) %#codegen
            %BNDPLC - Construct an ordered set of homogeneous rings
            arguments
                rings = struct('lon', {}, 'lat', {}, 'height', {})
            end
            obj.rings = rings;
        end
        function value = get.num_rings(obj) %#codegen
            %get.num_rings - Derive the polygon ring count
            value = numel(obj.rings);
        end
        function value = get.dimensions(obj) %#codegen
            %get.dimensions - Derive two or three coordinate dimensions
            value = 2;
            for k = 1:obj.num_rings
                if ~isempty(obj.rings(k).height), value = 3; end
            end
        end
        function value = get.num_pts(obj) %#codegen
            %get.num_pts - Derive vertex counts in ring order
            value = zeros(1, obj.num_rings);
            for k = 1:obj.num_rings, value(k) = numel(obj.rings(k).lon); end
        end
        function report = validate(obj) %#codegen
            %validate - Check finite coordinate arrays and payload limits
            reference = 'STDI-0002-1 Appendix P, Table P-9a';
            report = newReport(reference);
            report = addIssue(report, obj.num_rings < 1, ...
                'PolygonRings', 'rings', 'Supply at least one ring.', reference);
            count = 4;
            for k = 1:obj.num_rings
                ring = obj.rings(k);
                n = numel(ring.lon);
                valid = n >= 3 && numel(ring.lat) == n && ...
                    ((obj.dimensions == 2 && isempty(ring.height)) || ...
                    (obj.dimensions == 3 && numel(ring.height) == n));
                report = addIssue(report, ~valid, 'PolygonDimensions', ...
                    'rings', 'Use matching arrays with at least three points.', ...
                    reference);
                if valid
                    report = addIssue(report, ...
                        ring.lon(1) == ring.lon(end) && ...
                        ring.lat(1) == ring.lat(end), ...
                        'RepeatedVertex', 'rings', ...
                        'Do not repeat the first vertex to close a ring.', ...
                        reference);
                end
                count = count + 4 + 15 * obj.dimensions * n;
            end
            report = addIssue(report, count > 99985, 'TRELength', ...
                'rings', 'Polygon payloads cannot exceed 99985 bytes.', reference);
        end
        function value = payload(obj) %#codegen
            %payload - Encode counts and fifteen-byte coordinates
            requireValid(obj.validate());
            value = [decimalField(obj.num_rings, 3, 0, false) ...
                decimalField(obj.dimensions, 1, 0, false)];
            for k = 1:obj.num_rings
                ring = obj.rings(k);
                value = [value ...
                    decimalField(numel(ring.lon), 4, 0, false)]; %#ok<AGROW>
                for j = 1:numel(ring.lon)
                    value = [value polygonCoordinate(ring.lon(j)) ...
                        polygonCoordinate(ring.lat(j))]; %#ok<AGROW>
                    if obj.dimensions == 3
                        value = [value polygonCoordinate(ring.height(j))]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

function [count, reader] = polygonCount( ...
        reader, width, minimum, maximum) %#codegen
    %polygonCount - Require decimal digits in structural BCS-N counts
    first = reader.position;
    [count, reader] = reader.count(width, minimum, maximum);
    if reader.ok
        raw = reader.data(first:first + width - 1);
        if any(raw < '0' | raw > '9')
            reader = reader.fail('InvalidNumber', ...
                'Polygon counts must contain only decimal digits.');
            count = 0;
        end
    end
end

function [value, reader] = polygonNumber(reader, lower, upper) %#codegen
    %polygonNumber - Check signed limits and reject exponent underflow
    first = reader.position;
    [value, reader] = reader.number(15, lower, upper);
    if ~reader.ok, return; end
    raw = reader.data(first:first + 14);
    firstDigit = find(raw ~= ' ', 1);
    if raw(firstDigit) == '+' && value > -lower
        reader = reader.fail('InvalidNumber', ...
            'A signed coordinate exceeds its specified range.');
    elseif value == 0
        exponent = find(raw == 'E' | raw == 'e', 1);
        if ~isempty(exponent) && ...
                any(raw(1:exponent - 1) >= '1' & ...
                    raw(1:exponent - 1) <= '9')
            reader = reader.fail('InvalidNumber', ...
                'A nonzero coordinate underflows double precision.');
        end
    end
end
