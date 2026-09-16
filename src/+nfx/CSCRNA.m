classdef (Sealed) CSCRNA < nfx.TRE
    %CSCRNA - Supplied WGS 84 corner coordinates
    %   OBJ = CSCRNA(Name=VALUE) sets PREDICT_CORNERS and the latitude,
    %   longitude, and ellipsoid height of the ULCRN, URCRN, LRCRN, and
    %   LLCRN corners. Coordinates are supplied by the caller.
    %
    %   See also TRE, ImageSegment, File

    properties (Constant)
        cetag = 'CSCRNA'
    end
    properties
        predict_corners {mustBeAscii(predict_corners, 1)} = '' % Prediction/intelligent-area flag
        ulcrn_lat {mustBeMetadata(ulcrn_lat, -90, 90, 0)} = NaN
        ulcrn_lon {mustBeMetadata(ulcrn_lon, -179.99999, 180, 0)} = NaN
        ulcrn_ht {mustBeMetadata(ulcrn_ht, -610, 10668, 0)} = NaN
        urcrn_lat {mustBeMetadata(urcrn_lat, -90, 90, 0)} = NaN
        urcrn_lon {mustBeMetadata(urcrn_lon, -179.99999, 180, 0)} = NaN
        urcrn_ht {mustBeMetadata(urcrn_ht, -610, 10668, 0)} = NaN
        lrcrn_lat {mustBeMetadata(lrcrn_lat, -90, 90, 0)} = NaN
        lrcrn_lon {mustBeMetadata(lrcrn_lon, -179.99999, 180, 0)} = NaN
        lrcrn_ht {mustBeMetadata(lrcrn_ht, -610, 10668, 0)} = NaN
        llcrn_lat {mustBeMetadata(llcrn_lat, -90, 90, 0)} = NaN
        llcrn_lon {mustBeMetadata(llcrn_lon, -179.99999, 180, 0)} = NaN
        llcrn_ht {mustBeMetadata(llcrn_ht, -610, 10668, 0)} = NaN
    end
    methods
        function obj = CSCRNA(options) %#codegen
            %CSCRNA - Construct editable corner metadata
            arguments
                options.?nfx.CSCRNA
            end
            if isfield(options, 'predict_corners'), obj.predict_corners = options.predict_corners; end
            if isfield(options, 'ulcrn_lat'), obj.ulcrn_lat = options.ulcrn_lat; end
            if isfield(options, 'ulcrn_lon'), obj.ulcrn_lon = options.ulcrn_lon; end
            if isfield(options, 'ulcrn_ht'), obj.ulcrn_ht = options.ulcrn_ht; end
            if isfield(options, 'urcrn_lat'), obj.urcrn_lat = options.urcrn_lat; end
            if isfield(options, 'urcrn_lon'), obj.urcrn_lon = options.urcrn_lon; end
            if isfield(options, 'urcrn_ht'), obj.urcrn_ht = options.urcrn_ht; end
            if isfield(options, 'lrcrn_lat'), obj.lrcrn_lat = options.lrcrn_lat; end
            if isfield(options, 'lrcrn_lon'), obj.lrcrn_lon = options.lrcrn_lon; end
            if isfield(options, 'lrcrn_ht'), obj.lrcrn_ht = options.lrcrn_ht; end
            if isfield(options, 'llcrn_lat'), obj.llcrn_lat = options.llcrn_lat; end
            if isfield(options, 'llcrn_lon'), obj.llcrn_lon = options.llcrn_lon; end
            if isfield(options, 'llcrn_ht'), obj.llcrn_ht = options.llcrn_ht; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check the complete supplied corner set
            report = newReport('STDI-0002 Appendix AW CSCRNA');
            reference = 'STDI-0002-1 Appendix AW, Tables AW.6-1 and AW.6-2';
            report = addIssue(report, ~any(strcmp(obj.predict_corners, cellstr('YN'.'))), ...
                'CornerFlag', 'predict_corners', 'Supply a permitted corner prediction flag.', reference);
            values = [obj.ulcrn_lat obj.ulcrn_lon obj.ulcrn_ht ...
                obj.urcrn_lat obj.urcrn_lon obj.urcrn_ht ...
                obj.lrcrn_lat obj.lrcrn_lon obj.lrcrn_ht ...
                obj.llcrn_lat obj.llcrn_lon obj.llcrn_ht];
            report = addIssue(report, any(isnan(values)), 'Required', 'corners', ...
                'Supply every latitude, longitude, and ellipsoid height.', reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the four corners in specification order
            requireValid(validate(obj));
            value = [textField(obj.predict_corners, 1) ...
                decimalField(obj.ulcrn_lat, 9, 5, true) ...
                decimalField(obj.ulcrn_lon, 10, 5, true) ...
                decimalField(obj.ulcrn_ht, 8, 1, true) ...
                decimalField(obj.urcrn_lat, 9, 5, true) ...
                decimalField(obj.urcrn_lon, 10, 5, true) ...
                decimalField(obj.urcrn_ht, 8, 1, true) ...
                decimalField(obj.lrcrn_lat, 9, 5, true) ...
                decimalField(obj.lrcrn_lon, 10, 5, true) ...
                decimalField(obj.lrcrn_ht, 8, 1, true) ...
                decimalField(obj.llcrn_lat, 9, 5, true) ...
                decimalField(obj.llcrn_lon, 10, 5, true) ...
                decimalField(obj.llcrn_ht, 8, 1, true)];
        end
    end
end
