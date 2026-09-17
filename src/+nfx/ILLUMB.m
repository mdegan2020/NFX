classdef (Sealed) ILLUMB < nfx.TRE
    %ILLUMB - Spectral, spatial and temporal illumination metadata
    %   OBJ = ILLUMB(Name=VALUE) supplies band bounds and illumination sets.
    %   DATETIME accepts 14-character UTC rows with trailing precision dashes.
    %   TARGET_LAT/LON and scalar geometry fields are 1-by-set double arrays.
    %
    %   Band illumination values/methods are band-by-set arrays. OTHER_ILLUM
    %   and OTHER_ILLUM_METHOD are other-by-band-by-set; OTHER_AZIMUTH/ELEV
    %   are other-by-set. Methods are character arrays of P or M. Empty
    %   conditional arrays omit a field; NaN encodes its specified unknown.
    %   The existence mask and every count derive from supplied fields.
    %
    %   COORDINATE_PRECISION is 6-by-set, with fractional digit counts for
    %   target latitude/longitude, sun glint latitude/longitude, and moon glint
    %   latitude/longitude. Empty uses six digits. No geometry is calculated.
    %   Datum codes and published ellipsoid pairings are checked; descriptive
    %   names and the provenance of supplied measurements remain caller data.
    %   Supply VERTICAL_DATUM_REF and VERTICAL_REF_CODE when any target
    %   height is known. Both remain blank when every target height is unknown.
    %
    %   See also FASYWA, BANDSB, CSCRNA

    properties (Constant)
        cetag = 'ILLUMB'
    end
    properties
        lbound {mustBeMetadataArray(lbound,0,9.9999999999E99,0)} = []
        ubound {mustBeMetadataArray(ubound,0,9.9999999999E99,0)} = []
        band_unit {mustBeECS(band_unit,40)} = [char(181) 'm']
        geo_datum {mustBeAscii(geo_datum,80)} = 'World Geodetic System 1984'
        geo_datum_code {mustBeAscii(geo_datum_code,4)} = 'WGE'
        ellipsoid_name {mustBeAscii(ellipsoid_name,80)} = 'World Geodetic System 1984'
        ellipsoid_code {mustBeAscii(ellipsoid_code,3)} = 'WE'
        vertical_datum_ref {mustBeAscii(vertical_datum_ref,80)} = ''
        vertical_ref_code {mustBeAscii(vertical_ref_code,4)} = ''
        rad_quantity {mustBeECS(rad_quantity,40)} = ''
        radq_unit {mustBeECS(radq_unit,40)} = ''
        target_lat {mustBeMetadataArray(target_lat,-90,90,0)} = []
        target_lon {mustBeMetadataArray(target_lon,-180,180,0)} = []
        target_hgt {mustBeMetadataArray(target_hgt,-12000,12000,0)} = []
        sun_azimuth {mustBeMetadataArray(sun_azimuth,0,359.9,0)} = []
        sun_elev {mustBeMetadataArray(sun_elev,-90,90,0)} = []
        moon_azimuth {mustBeMetadataArray(moon_azimuth,0,359.9,0)} = []
        moon_elev {mustBeMetadataArray(moon_elev,-90,90,0)} = []
        moon_phase_angle {mustBeMetadataArray(moon_phase_angle,-180,180,0)} = []
        moon_illum_percent {mustBeMetadataArray(moon_illum_percent,0,100,1)} = []
        other_azimuth {mustBeMetadataArray(other_azimuth,0,359.9,0)} = []
        other_elev {mustBeMetadataArray(other_elev,-90,90,0)} = []
        sensor_azimuth {mustBeMetadataArray(sensor_azimuth,0,359.9,0)} = []
        sensor_elev {mustBeMetadataArray(sensor_elev,-90,90,0)} = []
        cats_angle {mustBeMetadataArray(cats_angle,0,359.9,0)} = []
        sun_glint_lat {mustBeMetadataArray(sun_glint_lat,-90,90,0)} = []
        sun_glint_lon {mustBeMetadataArray(sun_glint_lon,-180,180,0)} = []
        catm_angle {mustBeMetadataArray(catm_angle,0,359.9,0)} = []
        moon_glint_lat {mustBeMetadataArray(moon_glint_lat,-90,90,0)} = []
        moon_glint_lon {mustBeMetadataArray(moon_glint_lon,-180,180,0)} = []
        sol_lun_dist_adjust {mustBeMetadataArray(sol_lun_dist_adjust,0.7,1.4,0)} = []
        sun_illum {mustBeMetadataArray(sun_illum,0,9.9999999999E99,0)} = []
        moon_illum {mustBeMetadataArray(moon_illum,0,9.9999999999E99,0)} = []
        tot_sunmoon_illum {mustBeMetadataArray(tot_sunmoon_illum,0,9.9999999999E99,0)} = []
        other_illum {mustBeMetadataArray(other_illum,0,9.9999999999E99,0)} = []
        art_illum_min {mustBeMetadataArray(art_illum_min,0,9.9999999999E99,0)} = []
        art_illum_max {mustBeMetadataArray(art_illum_max,0,9.9999999999E99,0)} = []
        sun_illum_method {mustBeMethods} = ''
        moon_illum_method {mustBeMethods} = ''
        other_illum_method {mustBeMethods} = ''
        art_illum_method {mustBeMethods} = ''
        coordinate_precision {mustBeMetadataArray(coordinate_precision,0,6,1)} = []
    end
    properties (Dependent)
        datetime
        other_name
        comment
    end
    properties (Dependent, SetAccess = private)
        num_bands
        num_others
        num_coms
        num_illum_sets
        existence_mask
    end
    properties (Access = private)
        timeRows = repmat(' ',0,14)
        otherRows = repmat(' ',0,40)
        commentRowsValue = repmat(' ',0,80)
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable ILLUMB value
            %   [OBJ, OK, STATUS] = nfx.ILLUMB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also ILLUMB, ILLUMB.payload
            arguments
                data
            end
            obj = nfx.ILLUMB();
            reader = nfx.internal.TREReader(data);
            [bands, reader] = reader.count(4, 32, 9999);
            [value, reader] = reader.text(40, true, true);
            if reader.ok
                obj.band_unit = value;
            end
            lower = zeros(1, bands);
            upper = zeros(1, bands);
            for b = 1:bands
                [lower(b), reader] = reader.number(16, 0, 9.9999999999E99);
                [upper(b), reader] = reader.number(16, 0, 9.9999999999E99);
            end
            [others, reader] = reader.count(2, 40, 99);
            [names, reader] = reader.textRows(40, others, true);
            [comments, reader] = reader.count(1, 80, 9);
            [commentText, reader] = reader.textRows(80, comments, true);
            if reader.ok
                obj.lbound = lower;
                obj.ubound = upper;
                obj.other_name = names;
                obj.comment = commentText;
            end
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.geo_datum = value;
            end
            [value, reader] = reader.text(4, true, false);
            if reader.ok
                obj.geo_datum_code = value;
            end
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.ellipsoid_name = value;
            end
            [value, reader] = reader.text(3, true, false);
            if reader.ok
                obj.ellipsoid_code = value;
            end
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.vertical_datum_ref = value;
            end
            [value, reader] = reader.text(4, true, false);
            if reader.ok
                obj.vertical_ref_code = value;
            end
            [mask, reader] = reader.unsigned(3);
            flags = false(1, 24);
            if reader.ok
                flags = bitget(uint32(mask), 1:24) ~= 0;
                if any(flags(1:8))
                    reader = reader.fail('InvalidField', 'Reserved mask bits are set.');
                end
            end
            if flags(24)
                [value, reader] = reader.text(40, true, true);
                if reader.ok
                    obj.rad_quantity = value;
                end
                [value, reader] = reader.text(40, true, true);
                if reader.ok
                    obj.radq_unit = value;
                end
            end
            [sets, reader] = reader.count(3, 49, 999);
            perSet = 49 + 10 * flags(23) + 10 * flags(22) + 6 * flags(21) + ...
                3 * flags(20) + 10 * others * flags(19) + 10 * flags(18) + ...
                5 * flags(17) + 21 * flags(16) + 5 * flags(15) + ...
                21 * flags(14) + 7 * flags(11);
            perBand = 17 * flags(13) + 17 * flags(12) + 16 * flags(11) + ...
                17 * others * flags(10) + 33 * flags(9);
            if reader.ok && sets * (perSet + bands * perBand) > ...
                    numel(data) - reader.position + 1
                reader = reader.fail('TruncatedPayload', ...
                    'Illumination arrays exceed the remaining payload.');
            end
            if ~reader.ok
                sets = 0;
            end
            times = repmat(' ', sets, 14);
            precisions = repmat(6, 6, sets);
            decoded.target_lat = zeros(1, sets);
            decoded.target_lon = zeros(1, sets);
            decoded.target_hgt = zeros(1, sets);
            decoded.sun_azimuth = [];
            if flags(23)
                decoded.sun_azimuth = zeros(1, sets);
            end
            decoded.sun_elev = [];
            if flags(23)
                decoded.sun_elev = zeros(1, sets);
            end
            decoded.moon_azimuth = [];
            if flags(22)
                decoded.moon_azimuth = zeros(1, sets);
            end
            decoded.moon_elev = [];
            if flags(22)
                decoded.moon_elev = zeros(1, sets);
            end
            decoded.moon_phase_angle = [];
            if flags(21)
                decoded.moon_phase_angle = zeros(1, sets);
            end
            decoded.moon_illum_percent = [];
            if flags(20)
                decoded.moon_illum_percent = zeros(1, sets);
            end
            decoded.other_azimuth = [];
            if flags(19)
                decoded.other_azimuth = zeros(others, sets);
            end
            decoded.other_elev = [];
            if flags(19)
                decoded.other_elev = zeros(others, sets);
            end
            decoded.sensor_azimuth = [];
            if flags(18)
                decoded.sensor_azimuth = zeros(1, sets);
            end
            decoded.sensor_elev = [];
            if flags(18)
                decoded.sensor_elev = zeros(1, sets);
            end
            decoded.cats_angle = [];
            if flags(17)
                decoded.cats_angle = zeros(1, sets);
            end
            decoded.sun_glint_lat = [];
            if flags(16)
                decoded.sun_glint_lat = zeros(1, sets);
            end
            decoded.sun_glint_lon = [];
            if flags(16)
                decoded.sun_glint_lon = zeros(1, sets);
            end
            decoded.catm_angle = [];
            if flags(15)
                decoded.catm_angle = zeros(1, sets);
            end
            decoded.moon_glint_lat = [];
            if flags(14)
                decoded.moon_glint_lat = zeros(1, sets);
            end
            decoded.moon_glint_lon = [];
            if flags(14)
                decoded.moon_glint_lon = zeros(1, sets);
            end
            decoded.sol_lun_dist_adjust = [];
            if flags(11)
                decoded.sol_lun_dist_adjust = zeros(1, sets);
            end
            decoded.sun_illum = [];
            if flags(13)
                decoded.sun_illum = zeros(bands, sets);
            end
            decoded.sun_illum_method = '';
            if flags(13)
                decoded.sun_illum_method = repmat('P', bands, sets);
            end
            decoded.moon_illum = [];
            if flags(12)
                decoded.moon_illum = zeros(bands, sets);
            end
            decoded.moon_illum_method = '';
            if flags(12)
                decoded.moon_illum_method = repmat('P', bands, sets);
            end
            decoded.tot_sunmoon_illum = [];
            if flags(11)
                decoded.tot_sunmoon_illum = zeros(bands, sets);
            end
            decoded.other_illum = [];
            if flags(10)
                decoded.other_illum = zeros(others, bands, sets);
            end
            decoded.other_illum_method = '';
            if flags(10)
                decoded.other_illum_method = repmat('P', others, bands, sets);
            end
            decoded.art_illum_min = [];
            if flags(9)
                decoded.art_illum_min = zeros(bands, sets);
            end
            decoded.art_illum_max = [];
            if flags(9)
                decoded.art_illum_max = zeros(bands, sets);
            end
            decoded.art_illum_method = '';
            if flags(9)
                decoded.art_illum_method = repmat('P', bands, sets);
            end
            for n = 1:sets
                [times(n, :), reader] = reader.text(14, false);
                [decoded.target_lat(n), precisions(1, n), reader] = ...
                    reader.coordinate(10, -90, 90);
                [decoded.target_lon(n), precisions(2, n), reader] = ...
                    reader.coordinate(11, -180, 180);
                [decoded.target_hgt(n), reader] = ...
                    reader.number(14, -12000, 12000, 0, true);
                if flags(23)
                    [decoded.sun_azimuth(n), reader] = ...
                        reader.dashed(5, 0, 359.9);
                    [decoded.sun_elev(n), reader] = ...
                        reader.dashed(5, -90, 90);
                end
                if flags(22)
                    [decoded.moon_azimuth(n), reader] = ...
                        reader.dashed(5, 0, 359.9);
                    [decoded.moon_elev(n), reader] = ...
                        reader.dashed(5, -90, 90);
                end
                if flags(21)
                    [decoded.moon_phase_angle(n), reader] = ...
                        reader.dashed(6, -180, 180);
                end
                if flags(20)
                    [decoded.moon_illum_percent(n), reader] = ...
                        reader.dashed(3, 0, 100, true);
                end
                if flags(19)
                    for j = 1:others
                        [decoded.other_azimuth(j, n), reader] = ...
                            reader.dashed(5, 0, 359.9);
                        [decoded.other_elev(j, n), reader] = ...
                            reader.dashed(5, -90, 90);
                    end
                end
                if flags(18)
                    [decoded.sensor_azimuth(n), reader] = ...
                        reader.dashed(5, 0, 359.9);
                    [decoded.sensor_elev(n), reader] = ...
                        reader.dashed(5, -90, 90);
                end
                if flags(17)
                    [decoded.cats_angle(n), reader] = ...
                        reader.dashed(5, 0, 359.9);
                end
                if flags(16)
                    [decoded.sun_glint_lat(n), precisions(3, n), reader] = ...
                        reader.coordinate(10, -90, 90);
                    [decoded.sun_glint_lon(n), precisions(4, n), reader] = ...
                        reader.coordinate(11, -180, 180);
                end
                if flags(15)
                    [decoded.catm_angle(n), reader] = ...
                        reader.dashed(5, 0, 359.9);
                end
                if flags(14)
                    [decoded.moon_glint_lat(n), precisions(5, n), reader] = ...
                        reader.coordinate(10, -90, 90);
                    [decoded.moon_glint_lon(n), precisions(6, n), reader] = ...
                        reader.coordinate(11, -180, 180);
                end
                if flags(11)
                    [decoded.sol_lun_dist_adjust(n), reader] = ...
                        reader.dashed(7, 0.7, 1.4);
                end
                for b = 1:bands
                    if flags(13)
                        [decoded.sun_illum_method(b, n), reader] = reader.choice('PM');
                        [decoded.sun_illum(b, n), reader] = ...
                            reader.number(16, 0, 9.9999999999E99, 0, true);
                    end
                    if flags(12)
                        [decoded.moon_illum_method(b, n), reader] = reader.choice('PM');
                        [decoded.moon_illum(b, n), reader] = ...
                            reader.number(16, 0, 9.9999999999E99, 0, true);
                    end
                    if flags(11)
                        [decoded.tot_sunmoon_illum(b, n), reader] = ...
                            reader.number(16, 0, 9.9999999999E99, 0, true);
                    end
                    if flags(10)
                        for j = 1:others
                            [decoded.other_illum_method(j, b, n), reader] = reader.choice('PM');
                            [decoded.other_illum(j, b, n), reader] = ...
                                reader.number(16, 0, 9.9999999999E99, 0, true);
                        end
                    end
                    if flags(9)
                        [decoded.art_illum_method(b, n), reader] = reader.choice('PM');
                        [decoded.art_illum_min(b, n), reader] = ...
                            reader.number(16, 0, 9.9999999999E99, 0, true);
                        [decoded.art_illum_max(b, n), reader] = ...
                            reader.number(16, 0, 9.9999999999E99, 0, true);
                    end
                end
                if ~reader.ok
                    break
                end
            end
            if reader.ok
                obj.datetime = times;
                obj.coordinate_precision = precisions;
                obj.target_lat = decoded.target_lat;
                obj.target_lon = decoded.target_lon;
                obj.target_hgt = decoded.target_hgt;
                obj.sun_azimuth = decoded.sun_azimuth;
                obj.sun_elev = decoded.sun_elev;
                obj.moon_azimuth = decoded.moon_azimuth;
                obj.moon_elev = decoded.moon_elev;
                obj.moon_phase_angle = decoded.moon_phase_angle;
                obj.moon_illum_percent = decoded.moon_illum_percent;
                obj.other_azimuth = decoded.other_azimuth;
                obj.other_elev = decoded.other_elev;
                obj.sensor_azimuth = decoded.sensor_azimuth;
                obj.sensor_elev = decoded.sensor_elev;
                obj.cats_angle = decoded.cats_angle;
                obj.sun_glint_lat = decoded.sun_glint_lat;
                obj.sun_glint_lon = decoded.sun_glint_lon;
                obj.catm_angle = decoded.catm_angle;
                obj.moon_glint_lat = decoded.moon_glint_lat;
                obj.moon_glint_lon = decoded.moon_glint_lon;
                obj.sol_lun_dist_adjust = decoded.sol_lun_dist_adjust;
                obj.sun_illum = decoded.sun_illum;
                obj.sun_illum_method = decoded.sun_illum_method;
                obj.moon_illum = decoded.moon_illum;
                obj.moon_illum_method = decoded.moon_illum_method;
                obj.tot_sunmoon_illum = decoded.tot_sunmoon_illum;
                obj.other_illum = decoded.other_illum;
                obj.other_illum_method = decoded.other_illum_method;
                obj.art_illum_min = decoded.art_illum_min;
                obj.art_illum_max = decoded.art_illum_max;
                obj.art_illum_method = decoded.art_illum_method;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.ILLUMB());
        end
    end
    methods
        function obj = ILLUMB(options) %#codegen
            %ILLUMB - Construct editable illumination metadata arrays
            arguments
                options.?nfx.ILLUMB
            end
            if isfield(options,'lbound'), obj.lbound = options.lbound; end
            if isfield(options,'ubound'), obj.ubound = options.ubound; end
            if isfield(options,'band_unit'), obj.band_unit = options.band_unit; end
            if isfield(options,'geo_datum'), obj.geo_datum = options.geo_datum; end
            if isfield(options,'geo_datum_code'), obj.geo_datum_code = options.geo_datum_code; end
            if isfield(options,'ellipsoid_name'), obj.ellipsoid_name = options.ellipsoid_name; end
            if isfield(options,'ellipsoid_code'), obj.ellipsoid_code = options.ellipsoid_code; end
            if isfield(options,'vertical_datum_ref'), obj.vertical_datum_ref = options.vertical_datum_ref; end
            if isfield(options,'vertical_ref_code'), obj.vertical_ref_code = options.vertical_ref_code; end
            if isfield(options,'rad_quantity'), obj.rad_quantity = options.rad_quantity; end
            if isfield(options,'radq_unit'), obj.radq_unit = options.radq_unit; end
            if isfield(options,'target_lat'), obj.target_lat = options.target_lat; end
            if isfield(options,'target_lon'), obj.target_lon = options.target_lon; end
            if isfield(options,'target_hgt'), obj.target_hgt = options.target_hgt; end
            if isfield(options,'sun_azimuth'), obj.sun_azimuth = options.sun_azimuth; end
            if isfield(options,'sun_elev'), obj.sun_elev = options.sun_elev; end
            if isfield(options,'moon_azimuth'), obj.moon_azimuth = options.moon_azimuth; end
            if isfield(options,'moon_elev'), obj.moon_elev = options.moon_elev; end
            if isfield(options,'moon_phase_angle'), obj.moon_phase_angle = options.moon_phase_angle; end
            if isfield(options,'moon_illum_percent'), obj.moon_illum_percent = options.moon_illum_percent; end
            if isfield(options,'other_azimuth'), obj.other_azimuth = options.other_azimuth; end
            if isfield(options,'other_elev'), obj.other_elev = options.other_elev; end
            if isfield(options,'sensor_azimuth'), obj.sensor_azimuth = options.sensor_azimuth; end
            if isfield(options,'sensor_elev'), obj.sensor_elev = options.sensor_elev; end
            if isfield(options,'cats_angle'), obj.cats_angle = options.cats_angle; end
            if isfield(options,'sun_glint_lat'), obj.sun_glint_lat = options.sun_glint_lat; end
            if isfield(options,'sun_glint_lon'), obj.sun_glint_lon = options.sun_glint_lon; end
            if isfield(options,'catm_angle'), obj.catm_angle = options.catm_angle; end
            if isfield(options,'moon_glint_lat'), obj.moon_glint_lat = options.moon_glint_lat; end
            if isfield(options,'moon_glint_lon'), obj.moon_glint_lon = options.moon_glint_lon; end
            if isfield(options,'sol_lun_dist_adjust'), obj.sol_lun_dist_adjust = options.sol_lun_dist_adjust; end
            if isfield(options,'sun_illum'), obj.sun_illum = options.sun_illum; end
            if isfield(options,'moon_illum'), obj.moon_illum = options.moon_illum; end
            if isfield(options,'tot_sunmoon_illum'), obj.tot_sunmoon_illum = options.tot_sunmoon_illum; end
            if isfield(options,'other_illum'), obj.other_illum = options.other_illum; end
            if isfield(options,'art_illum_min'), obj.art_illum_min = options.art_illum_min; end
            if isfield(options,'art_illum_max'), obj.art_illum_max = options.art_illum_max; end
            if isfield(options,'sun_illum_method'), obj.sun_illum_method = options.sun_illum_method; end
            if isfield(options,'moon_illum_method'), obj.moon_illum_method = options.moon_illum_method; end
            if isfield(options,'other_illum_method'), obj.other_illum_method = options.other_illum_method; end
            if isfield(options,'art_illum_method'), obj.art_illum_method = options.art_illum_method; end
            if isfield(options,'coordinate_precision'), obj.coordinate_precision = options.coordinate_precision; end
            if isfield(options,'datetime'), obj.datetime = options.datetime; end
            if isfield(options,'other_name'), obj.other_name = options.other_name; end
            if isfield(options,'comment'), obj.comment = options.comment; end
        end
        function value = get.datetime(obj) %#codegen
            %get.datetime - Return padded UTC timestamp rows
            value = obj.timeRows;
        end
        function obj = set.datetime(obj,value) %#codegen
            %set.datetime - Normalize exact timestamp text
            obj.timeRows = metadataRows(value,14,999,false);
        end
        function value = get.other_name(obj) %#codegen
            %get.other_name - Return other light-source names
            value = obj.otherRows;
        end
        function obj = set.other_name(obj,value) %#codegen
            %set.other_name - Normalize extended-character source names
            obj.otherRows = metadataRows(value,40,99,true);
        end
        function value = get.comment(obj) %#codegen
            %get.comment - Return ordered extended-character comments
            value = obj.commentRowsValue;
        end
        function obj = set.comment(obj,value) %#codegen
            %set.comment - Normalize up to nine extended-character comments
            obj.commentRowsValue = metadataRows(value,80,9,true);
        end
        function value = get.num_bands(obj) %#codegen
            %get.num_bands - Derive the number of spectral bands
            value = numel(obj.lbound);
        end
        function value = get.num_others(obj) %#codegen
            %get.num_others - Derive the number of other natural light sources
            value = size(obj.otherRows,1);
        end
        function value = get.num_coms(obj) %#codegen
            %get.num_coms - Derive the number of comment records
            value = size(obj.commentRowsValue,1);
        end
        function value = get.num_illum_sets(obj) %#codegen
            %get.num_illum_sets - Derive the number of timestamped sets
            value = size(obj.timeRows,1);
        end
        function value = get.existence_mask(obj) %#codegen
            %get.existence_mask - Derive the 24-bit conditional-field mask
            value = 0;
            if ~isempty(strtrim(char(obj.rad_quantity))) || ~isempty(strtrim(char(obj.radq_unit))), value = value+2^23; end
            if ~isempty(obj.sun_azimuth) || ~isempty(obj.sun_elev), value = value+2^22; end
            if ~isempty(obj.moon_azimuth) || ~isempty(obj.moon_elev), value = value+2^21; end
            if ~isempty(obj.moon_phase_angle), value = value+2^20; end
            if ~isempty(obj.moon_illum_percent), value = value+2^19; end
            if ~isempty(obj.other_azimuth) || ~isempty(obj.other_elev), value = value+2^18; end
            if ~isempty(obj.sensor_azimuth) || ~isempty(obj.sensor_elev), value = value+2^17; end
            if ~isempty(obj.cats_angle), value = value+2^16; end
            if ~isempty(obj.sun_glint_lat) || ~isempty(obj.sun_glint_lon), value = value+2^15; end
            if ~isempty(obj.catm_angle), value = value+2^14; end
            if ~isempty(obj.moon_glint_lat) || ~isempty(obj.moon_glint_lon), value = value+2^13; end
            if ~isempty(obj.sun_illum) || ~isempty(obj.sun_illum_method), value = value+2^12; end
            if ~isempty(obj.moon_illum) || ~isempty(obj.moon_illum_method), value = value+2^11; end
            if ~isempty(obj.sol_lun_dist_adjust) || ~isempty(obj.tot_sunmoon_illum), value = value+2^10; end
            if ~isempty(obj.other_illum) || ~isempty(obj.other_illum_method), value = value+2^9; end
            if ~isempty(obj.art_illum_min) || ~isempty(obj.art_illum_max) || ~isempty(obj.art_illum_method), value = value+2^8; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check field shapes, presence, datums, units and chronology
            report = newReport('STDI-0002 Appendix AL ILLUMB');
            reference = 'STDI-0002-1 Appendix AL, Tables AL.6-2/AL.6-3 and AL.9-1';
            bands = obj.num_bands; sets = obj.num_illum_sets; others = obj.num_others;
            flags = bitget(uint32(obj.existence_mask),1:24) ~= 0;
            report = addIssue(report,bands < 1 || bands > 9999 || sets < 1 || sets > 999, ...
                'IlluminationCount','lbound/datetime','Supply 1 to 9999 bands and 1 to 999 illumination sets.',reference);
            boundsValid = arrayShape(obj.lbound,1,bands,1,false) && arrayShape(obj.ubound,1,bands,1,false);
            report = addIssue(report,~boundsValid,'BandBoundsShape','lbound/ubound','Supply matching band-bound row vectors.',reference);
            if boundsValid
                report = addIssue(report,any(~isfinite(obj.lbound) | ~isfinite(obj.ubound) | ...
                    obj.lbound <= 0 | obj.ubound <= 0 | obj.lbound > obj.ubound), ...
                    'BandBounds','lbound/ubound','Bounds must be positive, known and ordered.',reference);
            end
            report = addIssue(report,~any(strcmp(obj.band_unit,{[char(181) 'm'],'1/cm','Hz'})), ...
                'BandUnit','band_unit','Use a published band unit: micro-meter, 1/cm, or Hz.',reference);
            for k = 1:others
                report = addIssue(report,~any(strcmp(strtrim(obj.otherRows(k,:)),{'VENUS','AURORA'})), ...
                    'OtherSource',sprintf('other_name(%d)',k),'Use a published other-source name.',reference);
            end
            report = addIssue(report,isempty(strtrim(char(obj.geo_datum))) || isempty(strtrim(char(obj.ellipsoid_name))) || ...
                ~illuminationDatum(obj.geo_datum_code,obj.ellipsoid_code), ...
                'Datum','geo_datum_code/ellipsoid_code','Supply registered datum/ellipsoid codes with their published pairing.', ...
                'STDI-0002-1 Appendix P, Tables P-16/P-17');
            verticalCode = strtrim(char(obj.vertical_ref_code));
            verticalName = strtrim(char(obj.vertical_datum_ref));
            report = addIssue(report,~any(strcmp(verticalCode,{'','GEOD','MSL'})) || ...
                (isempty(verticalCode) ~= isempty(verticalName)) || ...
                (any(isfinite(obj.target_hgt(:))) == isempty(verticalCode)), ...
                'VerticalReference','vertical_ref_code/vertical_datum_ref', ...
                'Supply a named GEOD or MSL reference exactly when at least one target height is known.',reference);
            report = addIssue(report,~any(flags(14:24)),'IlluminationPresence','existence_mask', ...
                'At least one bit from 13 to 23 must be set.',reference);
            radiometric = any(flags(9:13));
            report = addIssue(report,radiometric && ~flags(24),'RadiometricUnits','rad_quantity/radq_unit', ...
                'Quantitative illumination requires its radiometric quantity and units.',reference);
            if flags(24)
                report = addIssue(report,~radiometricUnit(obj.rad_quantity,obj.radq_unit), ...
                    'RadiometricUnits','rad_quantity/radq_unit','Use a published radiometric quantity/unit pair.',reference);
            end
            report = addIssue(report,(flags(19) || flags(10)) && others == 0, ...
                'OtherSourceCount','other_name','Other-source fields require named other sources.',reference);
            report = addIssue(report,~arrayShape(obj.target_lat,1,sets,1,false),'FieldShape','target_lat','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.target_lon,1,sets,1,false),'FieldShape','target_lon','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.target_hgt,1,sets,1,true),'FieldShape','target_hgt','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_azimuth,1,sets,1,true),'FieldShape','sun_azimuth','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_elev,1,sets,1,true),'FieldShape','sun_elev','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_azimuth,1,sets,1,true),'FieldShape','moon_azimuth','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_elev,1,sets,1,true),'FieldShape','moon_elev','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_phase_angle,1,sets,1,true),'FieldShape','moon_phase_angle','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_illum_percent,1,sets,1,true),'FieldShape','moon_illum_percent','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.other_azimuth,others,sets,1,true),'FieldShape','other_azimuth','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.other_elev,others,sets,1,true),'FieldShape','other_elev','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sensor_azimuth,1,sets,1,true),'FieldShape','sensor_azimuth','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sensor_elev,1,sets,1,true),'FieldShape','sensor_elev','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.cats_angle,1,sets,1,true),'FieldShape','cats_angle','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_glint_lat,1,sets,1,true),'FieldShape','sun_glint_lat','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_glint_lon,1,sets,1,true),'FieldShape','sun_glint_lon','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.catm_angle,1,sets,1,true),'FieldShape','catm_angle','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_glint_lat,1,sets,1,true),'FieldShape','moon_glint_lat','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_glint_lon,1,sets,1,true),'FieldShape','moon_glint_lon','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sol_lun_dist_adjust,1,sets,1,true),'FieldShape','sol_lun_dist_adjust','The array must match the illumination-set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_illum,bands,sets,1,true),'FieldShape','sun_illum','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.moon_illum,bands,sets,1,true),'FieldShape','moon_illum','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.tot_sunmoon_illum,bands,sets,1,true),'FieldShape','tot_sunmoon_illum','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.other_illum,others,bands,sets,true),'FieldShape','other_illum','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.art_illum_min,bands,sets,1,true),'FieldShape','art_illum_min','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.art_illum_max,bands,sets,1,true),'FieldShape','art_illum_max','The array must match the band/other/set dimensions.',reference);
            report = addIssue(report,~arrayShape(obj.sun_illum_method,bands,sets,1,true),'FieldShape','sun_illum_method','Method dimensions must match their illumination values.',reference);
            report = addIssue(report,~arrayShape(obj.moon_illum_method,bands,sets,1,true),'FieldShape','moon_illum_method','Method dimensions must match their illumination values.',reference);
            report = addIssue(report,~arrayShape(obj.other_illum_method,others,bands,sets,true),'FieldShape','other_illum_method','Method dimensions must match their illumination values.',reference);
            report = addIssue(report,~arrayShape(obj.art_illum_method,bands,sets,1,true),'FieldShape','art_illum_method','Method dimensions must match their illumination values.',reference);
            report = addIssue(report,~arrayShape(obj.coordinate_precision,6,sets,1,true) || ...
                any(~isfinite(obj.coordinate_precision(:))),'CoordinatePrecision','coordinate_precision', ...
                'Supply six finite fractional precision settings per set, or leave empty.',reference);
            report = addIssue(report,any(~isfinite(obj.target_lat(:))) || any(~isfinite(obj.target_lon(:))), ...
                'TargetLocation','target_lat/target_lon','Target coordinates must be known.',reference);
            report = addIssue(report,flags(16) && (isempty(obj.sun_glint_lat) || isempty(obj.sun_glint_lon) || ...
                any(~isfinite([obj.sun_glint_lat(:);obj.sun_glint_lon(:)]))), ...
                'GlintLocation','sun_glint_lat/sun_glint_lon','Included glint locations require both known coordinates.',reference);
            report = addIssue(report,flags(14) && (isempty(obj.moon_glint_lat) || isempty(obj.moon_glint_lon) || ...
                any(~isfinite([obj.moon_glint_lat(:);obj.moon_glint_lon(:)]))), ...
                'GlintLocation','moon_glint_lat/moon_glint_lon','Included glint locations require both known coordinates.',reference);
            report = addIssue(report,(flags(13) && isempty(obj.sun_illum_method)) || ...
                (flags(12) && isempty(obj.moon_illum_method)) || (flags(10) && isempty(obj.other_illum_method)) || ...
                (flags(9) && isempty(obj.art_illum_method)), ...
                'IlluminationMethod','illumination methods','Each included radiometric method must be explicitly P or M.',reference);
            if isequal(size(obj.art_illum_min),size(obj.art_illum_max))
                report = addIssue(report,any(obj.art_illum_min(:) > obj.art_illum_max(:)), ...
                    'ArtificialRange','art_illum_min/art_illum_max','Artificial minimum must not exceed maximum.',reference);
            end
            meaningful = any(isfinite(obj.sun_azimuth(:))) || ...
                any(isfinite(obj.sun_elev(:))) || ...
                any(isfinite(obj.moon_azimuth(:))) || ...
                any(isfinite(obj.moon_elev(:))) || ...
                any(isfinite(obj.moon_phase_angle(:))) || ...
                any(isfinite(obj.moon_illum_percent(:))) || ...
                any(isfinite(obj.other_azimuth(:))) || ...
                any(isfinite(obj.other_elev(:))) || ...
                any(isfinite(obj.sensor_azimuth(:))) || ...
                any(isfinite(obj.sensor_elev(:))) || ...
                any(isfinite(obj.cats_angle(:))) || ...
                any(isfinite(obj.sun_glint_lat(:))) || ...
                any(isfinite(obj.sun_glint_lon(:))) || ...
                any(isfinite(obj.catm_angle(:))) || ...
                any(isfinite(obj.moon_glint_lat(:))) || ...
                any(isfinite(obj.moon_glint_lon(:))) || any(isfinite(obj.sol_lun_dist_adjust(:))) || ...
                any(isfinite(obj.sun_illum(:))) || ...
                any(isfinite(obj.moon_illum(:))) || ...
                any(isfinite(obj.tot_sunmoon_illum(:))) || ...
                any(isfinite(obj.other_illum(:))) || ...
                any(isfinite(obj.art_illum_min(:))) || ...
                any(isfinite(obj.art_illum_max(:)));
            report = addIssue(report,~meaningful,'IlluminationValue','illumination fields', ...
                'Include at least one actual illumination or geometry value beyond target/date metadata.',reference);
            for k = 1:sets
                report = addIssue(report,~partialDate14(obj.timeRows(k,:)),'Timestamp',sprintf('datetime(%d)',k), ...
                    'Use a valid UTC numeric prefix followed only by precision dashes.',reference);
                if k > 1 && partialDate14(obj.timeRows(k,:)) && partialDate14(obj.timeRows(k-1,:))
                    report = addIssue(report,mieTimeEarlier(obj.timeRows(k,:),obj.timeRows(k-1,:)), ...
                        'TimeOrder',sprintf('datetime(%d)',k),'Illumination sets must be chronological.',reference);
                end
            end
            report = addIssue(report,payloadLength(obj) > 99985,'TRELength','illumination sets', ...
                'The complete ILLUMB payload must fit 99985 bytes.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize spectral bounds, datum metadata and masked sets
            requireValid(validate(obj));
            flags = bitget(uint32(obj.existence_mask),1:24) ~= 0;
            value = zeros(1,payloadLength(obj),'uint8');
            value(1:44) = [decimalField(obj.num_bands,4,0,false) textField(obj.band_unit,40)];
            at = 44;
            for b = 1:obj.num_bands
                value(at+1:at+32) = [illuminationNumber(obj.lbound(b),16) illuminationNumber(obj.ubound(b),16)]; at = at+32;
            end
            value(at+1:at+2) = decimalField(obj.num_others,2,0,false); at = at+2;
            names = reshape(uint8(obj.otherRows.'),1,[]);
            value(at+1:at+numel(names)) = names; at = at+numel(names);
            value(at+1) = decimalField(obj.num_coms,1,0,false); at = at+1;
            comments = reshape(uint8(obj.commentRowsValue.'),1,[]);
            value(at+1:at+numel(comments)) = comments; at = at+numel(comments);
            datum = [textField(obj.geo_datum,80) textField(obj.geo_datum_code,4) textField(obj.ellipsoid_name,80) ...
                textField(obj.ellipsoid_code,3) textField(obj.vertical_datum_ref,80) textField(obj.vertical_ref_code,4) ...
                unsignedBytes(uint64(obj.existence_mask),3)];
            value(at+1:at+numel(datum)) = datum; at = at+numel(datum);
            if flags(24)
                value(at+1:at+80) = [textField(obj.rad_quantity,40) textField(obj.radq_unit,40)]; at = at+80;
            end
            value(at+1:at+3) = decimalField(obj.num_illum_sets,3,0,false); at = at+3;
            for n = 1:obj.num_illum_sets
                precision = repmat(6,6,1);
                if ~isempty(obj.coordinate_precision), precision = obj.coordinate_precision(:,n); end
                value(at+1:at+49) = [uint8(obj.timeRows(n,:)) partialCoordinate(obj.target_lat(n),10,precision(1)) ...
                    partialCoordinate(obj.target_lon(n),11,precision(2)) illuminationNumber(arrayAt(obj.target_hgt,1,n,1),14)]; at = at+49;
                if flags(23)
                    value(at+1:at+10) = [angleAt(obj.sun_azimuth,1,n,5,1,false) angleAt(obj.sun_elev,1,n,5,1,true)]; at = at+10;
                end
                if flags(22)
                    value(at+1:at+10) = [angleAt(obj.moon_azimuth,1,n,5,1,false) angleAt(obj.moon_elev,1,n,5,1,true)]; at = at+10;
                end
                if flags(21), value(at+1:at+6) = angleAt(obj.moon_phase_angle,1,n,6,1,true); at = at+6; end
                if flags(20), value(at+1:at+3) = angleAt(obj.moon_illum_percent,1,n,3,0,false); at = at+3; end
                if flags(19)
                    for j = 1:obj.num_others
                        value(at+1:at+10) = [angleAt(obj.other_azimuth,j,n,5,1,false) angleAt(obj.other_elev,j,n,5,1,true)]; at = at+10;
                    end
                end
                if flags(18)
                    value(at+1:at+10) = [angleAt(obj.sensor_azimuth,1,n,5,1,false) angleAt(obj.sensor_elev,1,n,5,1,true)]; at = at+10;
                end
                if flags(17), value(at+1:at+5) = angleAt(obj.cats_angle,1,n,5,1,false); at = at+5; end
                if flags(16)
                    value(at+1:at+21) = [partialCoordinate(obj.sun_glint_lat(n),10,precision(3)) ...
                        partialCoordinate(obj.sun_glint_lon(n),11,precision(4))]; at = at+21;
                end
                if flags(15), value(at+1:at+5) = angleAt(obj.catm_angle,1,n,5,1,false); at = at+5; end
                if flags(14)
                    value(at+1:at+21) = [partialCoordinate(obj.moon_glint_lat(n),10,precision(5)) ...
                        partialCoordinate(obj.moon_glint_lon(n),11,precision(6))]; at = at+21;
                end
                if flags(11), value(at+1:at+7) = angleAt(obj.sol_lun_dist_adjust,1,n,7,5,false); at = at+7; end
                for b = 1:obj.num_bands
                    if flags(13)
                        value(at+1:at+17) = [uint8(obj.sun_illum_method(b,n)) illuminationNumber(arrayAt(obj.sun_illum,b,n,1),16)]; at = at+17;
                    end
                    if flags(12)
                        value(at+1:at+17) = [uint8(obj.moon_illum_method(b,n)) illuminationNumber(arrayAt(obj.moon_illum,b,n,1),16)]; at = at+17;
                    end
                    if flags(11)
                        value(at+1:at+16) = illuminationNumber(arrayAt(obj.tot_sunmoon_illum,b,n,1),16); at = at+16;
                    end
                    if flags(10)
                        for j = 1:obj.num_others
                            value(at+1:at+17) = [uint8(obj.other_illum_method(j,b,n)) illuminationNumber(arrayAt(obj.other_illum,j,b,n),16)]; at = at+17;
                        end
                    end
                    if flags(9)
                        value(at+1:at+33) = [uint8(obj.art_illum_method(b,n)) ...
                            illuminationNumber(arrayAt(obj.art_illum_min,b,n,1),16) illuminationNumber(arrayAt(obj.art_illum_max,b,n,1),16)]; at = at+33;
                    end
                end
            end
        end
    end
    methods (Access = private)
        function count = payloadLength(obj) %#codegen
            %payloadLength - Derive byte count from dimensions and mask groups
            f = bitget(uint32(obj.existence_mask),1:24) ~= 0;
            perSet = 49+10*f(23)+10*f(22)+6*f(21)+3*f(20)+10*obj.num_others*f(19)+ ...
                10*f(18)+5*f(17)+21*f(16)+5*f(15)+21*f(14)+7*f(11);
            perBand = 17*f(13)+17*f(12)+16*f(11)+17*obj.num_others*f(10)+33*f(9);
            count = 304+32*obj.num_bands+40*obj.num_others+80*obj.num_coms+80*f(24)+ ...
                obj.num_illum_sets*(perSet+obj.num_bands*perBand);
        end
    end
end

function valid = arrayShape(value,rows,columns,pages,allowEmpty) %#codegen
    %arrayShape - Check complete metadata dimensions without scalar expansion
    valid = (allowEmpty && isempty(value)) || (size(value,1) == rows && ...
        size(value,2) == columns && size(value,3) == pages && ndims(value) <= 3);
end

function mustBeMethods(value) %#codegen
    %mustBeMethods - Require a character array of predicted/measured indicators
    if ~ischar(value) || ndims(value) > 3 || any(value(:) ~= 'P' & value(:) ~= 'M')
        error('nfx:IlluminationMethod','Supply a character array containing only P or M.');
    end
end

function valid = radiometricUnit(quantity,unit) %#codegen
    %radiometricUnit - Match the published physical quantity and extended units
    quantity = char(quantity); unit = char(unit);
    switch quantity
        case {'EMITTANCE','IRRADIANCE'}, expected = 'W/(m m)';
        case 'RADIANCE', expected = 'W/(m m sr)';
        case 'SPECTRAL_RADIANCE', expected = ['W/(m m sr ' char(181) 'm)'];
        case 'SPECTRAL_EMITTANCE', expected = ['W/(m m ' char(181) 'm)'];
        case 'RADIANT_FLUX', expected = 'W';
        otherwise, valid = false; return
    end
    valid = strcmp(unit,expected);
end

function number = arrayAt(value,row,column,page) %#codegen
    %arrayAt - Map an omitted optional array to its unknown sentinel
    number = NaN;
    if ~isempty(value), number = value(row,column,page); end
end

function value = angleAt(array,row,column,width,places,signed) %#codegen
    %angleAt - Encode angular/adjustment fields with their all-dash sentinel
    number = arrayAt(array,row,column,1);
    if isnan(number), value = repmat(uint8('-'),1,width); ...
    else, value = decimalField(number,width,places,signed); end
end
