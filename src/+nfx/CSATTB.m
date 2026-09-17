classdef (Sealed) CSATTB < nfx.SensorDES
    %CSATTB - Encode supplied GLAS/GFM attitude samples and timing
    %   OBJ = CSATTB(Name=VALUE) holds chronological Q1/Q2/Q3/Q4 double rows.
    %   Quaternions use the JPL convention: Q4 is scalar, and Q1-Q3 are the
    %   vector part. Samples must already be normalized; no fitting or
    %   renormalization is performed. NUM_ATT derives from their common length.
    %
    %   DATE_ATT and T0_ATT preserve exact UTC text. DT_ATT is double seconds.
    %   ECI_ECF_ATT=0 selects ECI and =1 selects ECF. Version two ECI data
    %   require one EARTH_ORIENTATION value; other variants omit it.
    %   Both versions are structurally supported. Version-one ECI and spherical
    %   interpolation require suitable consumer support for mensuration.
    %
    %   See also SensorDES, EarthOrientation, CSEPHB, CSEXRB

    properties (Constant)
        desid = 'CSATTB'
    end
    properties
        qual_flag_att {mustBeMetadata(qual_flag_att,0,1,1)} = NaN
        interp_type_att {mustBeMetadata(interp_type_att,0,3,1)} = NaN
        interp_order_att {mustBeMetadata(interp_order_att,1,7,1)} = NaN
        att_type {mustBeMetadata(att_type,0,2,1)} = NaN
        eci_ecf_att {mustBeMetadata(eci_ecf_att,0,1,1)} = NaN
        earth_orientation {mustBeGLASObjects(earth_orientation,'nfx.EarthOrientation')} = nfx.EarthOrientation.empty(1,0)
        dt_att {mustBeMetadata(dt_att,0.000000001,999.999999999,0)} = NaN
        date_att {mustBeAscii(date_att,8)} = ''
        t0_att {mustBeAscii(t0_att,16)} = ''
        q1 {mustBeGLASMatrix(q1,1,99999,1)} = zeros(1,0)
        q2 {mustBeGLASMatrix(q2,1,99999,1)} = zeros(1,0)
        q3 {mustBeGLASMatrix(q3,1,99999,1)} = zeros(1,0)
        q4 {mustBeGLASMatrix(q4,1,99999,1)} = zeros(1,0)
    end
    properties (Dependent, SetAccess = private)
        num_att
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data, header) %#codegen
            %deserialize - Restore an independent editable CSATTB descriptor
            %   [OBJ, OK, STATUS] = nfx.CSATTB.deserialize(DATA, HEADER)
            %   validates the DES payload and its nfx.DESHeader associations.
            %   Failure returns a default scalar OBJ and a diagnostic.
            %   No sensor model is fitted or transformed.
            %
            %   See also CSATTB, SensorDES.segment
            arguments
                data
                header
            end
            obj = nfx.CSATTB();
            [obj, reader] = nfx.SensorDES.readHeader(obj, header);
            if reader.ok && ~any(obj.desver == [1 2])
                reader = reader.fail('UnsupportedVersion', 'Unsupported CSATTB version.');
            end
            if ~reader.ok
                ok = false; status = decodeStatus(reader.code, reader.message, reader.position);
                obj = nfx.CSATTB(); return
            end
            reader = nfx.internal.TREReader(data, 999999998);
            [value, reader] = reader.number(1, 0, 1, true);
            if reader.ok, obj.qual_flag_att = value; end
            [value, reader] = reader.number(1, 0, 3, true);
            if reader.ok, obj.interp_type_att = value; end
            if reader.ok && any(obj.interp_type_att == [2 3])
                [value, reader] = reader.number(1, 1, 7, true);
                if reader.ok, obj.interp_order_att = value; end
            end
            [value, reader] = reader.number(1, 0, 2, true);
            if reader.ok, obj.att_type = value; end
            [value, reader] = reader.number(1, 0, 1, true);
            if reader.ok, obj.eci_ecf_att = value; end
            if reader.ok && obj.eci_ecf_att == 0 && obj.desver == 2
                [earth, reader] = readEarthOrientation(reader);
                if reader.ok, obj.earth_orientation = earth; end
            end
            [value, reader] = reader.number(13, 0.000000001, 999.999999999, false);
            if reader.ok, obj.dt_att = value; end
            [text, reader] = reader.text(8, false);
            if reader.ok, obj.date_att = text; end
            [text, reader] = reader.text(16, false);
            if reader.ok, obj.t0_att = text; end
            [count, reader] = reader.count(5, 72, 99999);
            [values, reader] = reader.numbers(count * 4, 18, -1, 1);
            if reader.ok
                obj.q1 = values(1:4:end);
                obj.q2 = values(2:4:end);
                obj.q3 = values(3:4:end);
                obj.q4 = values(4:4:end);
            end
            reader = reader.literal('000000000');
            [obj, ok, status] = finishDESDecode(obj, reader, header, nfx.CSATTB());
        end
    end
    methods
        function obj = CSATTB(options) %#codegen
            %CSATTB - Construct editable attitude and association metadata
            arguments
                options.?nfx.CSATTB
            end
            if isfield(options,'uuid'), obj.uuid = options.uuid; end
            if isfield(options,'aisdlvl'), obj.aisdlvl = options.aisdlvl; end
            if isfield(options,'all_images'), obj.all_images = options.all_images; end
            if isfield(options,'assoc_elem_uuid'), obj.assoc_elem_uuid = options.assoc_elem_uuid; end
            if isfield(options,'desver'), obj.desver = options.desver; end
            if isfield(options,'desclas'), obj.desclas = options.desclas; end
            if isfield(options,'qual_flag_att'), obj.qual_flag_att = options.qual_flag_att; end
            if isfield(options,'interp_type_att'), obj.interp_type_att = options.interp_type_att; end
            if isfield(options,'interp_order_att'), obj.interp_order_att = options.interp_order_att; end
            if isfield(options,'att_type'), obj.att_type = options.att_type; end
            if isfield(options,'eci_ecf_att'), obj.eci_ecf_att = options.eci_ecf_att; end
            if isfield(options,'earth_orientation'), obj.earth_orientation = options.earth_orientation; end
            if isfield(options,'dt_att'), obj.dt_att = options.dt_att; end
            if isfield(options,'date_att'), obj.date_att = options.date_att; end
            if isfield(options,'t0_att'), obj.t0_att = options.t0_att; end
            if isfield(options,'q1'), obj.q1 = options.q1; end
            if isfield(options,'q2'), obj.q2 = options.q2; end
            if isfield(options,'q3'), obj.q3 = options.q3; end
            if isfield(options,'q4'), obj.q4 = options.q4; end
        end
        function value = get.num_att(obj) %#codegen
            %get.num_att - Derive the number of chronological reference samples
            value = numel(obj.q1);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check definition version, conditional fields and samples
            report = headerReport(obj);
            reference = 'STDI-0002-2 Appendix M, Table M.6-4 and M.6.4';
            report = addIssue(report,~any(obj.desver == [1 2]),'AttitudeVersion','desver', ...
                'CSATTB supports definition versions one and two.',reference);
            report = addIssue(report,any(isnan([obj.qual_flag_att obj.interp_type_att obj.att_type obj.eci_ecf_att obj.dt_att])), ...
                'Required','attitude flags/timing','Supply all attitude flags and the sample interval.',reference);
            orderValid = (obj.interp_type_att == 2 && any(obj.interp_order_att == [3 5 7])) || ...
                (obj.interp_type_att == 3 && any(obj.interp_order_att == [1 3])) || ...
                (any(obj.interp_type_att == [0 1]) && isnan(obj.interp_order_att));
            report = addIssue(report,~orderValid,'AttitudeInterpolation','interp_type_att/interp_order_att', ...
                'Lagrangian interpolation uses order 3/5/7; spherical uses 1/3; nearest and linear omit the order.',reference);
            needsEarth = obj.eci_ecf_att == 0 && obj.desver == 2;
            report = addIssue(report,numel(obj.earth_orientation) ~= double(needsEarth), ...
                'EarthOrientationPresence','earth_orientation','Only version-two ECI data contain one transformation block.',reference);
            for k = 1:numel(obj.earth_orientation)
                report = mergeReport(report,validate(obj.earth_orientation(k)),'earth_orientation');
            end
            report = addIssue(report,~validMieTimestamp([char(obj.date_att) char(obj.t0_att)]), ...
                'AttitudeTime','date_att/t0_att','Supply a valid UTC date and hhmmss.nnnnnnnnn time.',reference);
            count = obj.num_att;
            shape = count >= 1 && count <= 99999 && ...
                numel(obj.q2) == count && numel(obj.q3) == count && numel(obj.q4) == count;
            report = addIssue(report,~shape,'AttitudeSamples','q1/q2/q3/q4', ...
                'Supply four equal-length rows containing 1-99999 quaternion samples.',reference);
            if shape
                q = [obj.q1;obj.q2;obj.q3;obj.q4];
                encoded = round(q*1e15)/1e15;
                report = addIssue(report,any(~isfinite(q),'all') || any(abs(sum(q.^2,1)-1) > 1e-12) || ...
                    any(abs(sum(encoded.^2,1)-1) > 1e-12),'AttitudeQuaternion','q1/q2/q3/q4', ...
                    'Every supplied and encoded JPL quaternion must have unit norm within 1e-12.',reference);
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode chronological JPL samples and reserved trailer
            requireValid(validate(obj));
            value = [decimalField(obj.qual_flag_att,1,0,false) decimalField(obj.interp_type_att,1,0,false)];
            if any(obj.interp_type_att == [2 3]), value = [value decimalField(obj.interp_order_att,1,0,false)]; end
            value = [value decimalField(obj.att_type,1,0,false) decimalField(obj.eci_ecf_att,1,0,false)];
            if ~isempty(obj.earth_orientation), value = [value bytes(obj.earth_orientation)]; end
            value = [value decimalField(obj.dt_att,13,9,false) textField(obj.date_att,8) ...
                textField(obj.t0_att,16) decimalField(obj.num_att,5,0,false)];
            prefix = numel(value); value = [value zeros(1,72*obj.num_att,'uint8') uint8('000000000')];
            for k = 1:obj.num_att
                start = prefix+(k-1)*72;
                value(start+(1:72)) = [decimalField(obj.q1(k),18,15,true) decimalField(obj.q2(k),18,15,true) ...
                    decimalField(obj.q3(k),18,15,true) decimalField(obj.q4(k),18,15,true)];
            end
        end
    end
end
