classdef (Sealed) CSEPHB < nfx.SensorDES
    %CSEPHB - Encode supplied ephemeris, velocity and acceleration samples
    %   OBJ = CSEPHB(Name=VALUE) holds chronological EPHEM_X/Y/Z double rows
    %   in meters. NUM_EPHEM derives from their common length. Optional
    %   VEL_X/Y/Z rows use meters/second; optional ACCEL_X/Y/Z rows use
    %   meters/second squared. Each group uses the same sample times and frame.
    %   Acceleration requires velocity. Flags, masks and lengths derive.
    %
    %   DATE_EPHEM and T0_EPHEM preserve exact UTC text; DT_EPHEM is seconds.
    %   ECI_ECF_EPHEM=0 selects ECI and =1 selects ECF. Only version-two ECI
    %   data contain EARTH_ORIENTATION. No orbital propagation or coordinate
    %   conversion is performed. Version-one ECI needs suitable consumers.
    %
    %   See also SensorDES, EarthOrientation, CSATTB, CSEXRB

    properties (Constant)
        desid = 'CSEPHB'
    end
    properties
        qual_flag_eph {mustBeMetadata(qual_flag_eph,0,1,1)} = NaN
        interp_type_eph {mustBeMetadata(interp_type_eph,0,2,1)} = NaN
        interp_order_eph {mustBeMetadata(interp_order_eph,3,7,1)} = NaN
        ephem_flag {mustBeMetadata(ephem_flag,0,2,1)} = NaN
        eci_ecf_ephem {mustBeMetadata(eci_ecf_ephem,0,1,1)} = NaN
        earth_orientation {mustBeGLASObjects(earth_orientation,'nfx.EarthOrientation')} = nfx.EarthOrientation.empty(1,0)
        dt_ephem {mustBeMetadata(dt_ephem,0.000000001,999.999999999,0)} = NaN
        date_ephem {mustBeAscii(date_ephem,8)} = ''
        t0_ephem {mustBeAscii(t0_ephem,16)} = ''
        ephem_x {mustBeGLASMatrix(ephem_x,1,99999,99999999.99)} = zeros(1,0)
        ephem_y {mustBeGLASMatrix(ephem_y,1,99999,99999999.99)} = zeros(1,0)
        ephem_z {mustBeGLASMatrix(ephem_z,1,99999,99999999.99)} = zeros(1,0)
        vel_x {mustBeGLASMatrix(vel_x,1,99999,99999999.99)} = zeros(1,0)
        vel_y {mustBeGLASMatrix(vel_y,1,99999,99999999.99)} = zeros(1,0)
        vel_z {mustBeGLASMatrix(vel_z,1,99999,99999999.99)} = zeros(1,0)
        accel_x {mustBeGLASMatrix(accel_x,1,99999,99999999.99)} = zeros(1,0)
        accel_y {mustBeGLASMatrix(accel_y,1,99999,99999999.99)} = zeros(1,0)
        accel_z {mustBeGLASMatrix(accel_z,1,99999,99999999.99)} = zeros(1,0)
    end
    properties (Dependent, SetAccess = private)
        num_ephem
        accel_provided
        reserved_len
    end
    methods
        function obj = CSEPHB(options) %#codegen
            %CSEPHB - Construct editable ephemeris and association metadata
            arguments
                options.?nfx.CSEPHB
            end
            if isfield(options,'uuid'), obj.uuid = options.uuid; end
            if isfield(options,'aisdlvl'), obj.aisdlvl = options.aisdlvl; end
            if isfield(options,'all_images'), obj.all_images = options.all_images; end
            if isfield(options,'assoc_elem_uuid'), obj.assoc_elem_uuid = options.assoc_elem_uuid; end
            if isfield(options,'desver'), obj.desver = options.desver; end
            if isfield(options,'desclas'), obj.desclas = options.desclas; end
            if isfield(options,'qual_flag_eph'), obj.qual_flag_eph = options.qual_flag_eph; end
            if isfield(options,'interp_type_eph'), obj.interp_type_eph = options.interp_type_eph; end
            if isfield(options,'interp_order_eph'), obj.interp_order_eph = options.interp_order_eph; end
            if isfield(options,'ephem_flag'), obj.ephem_flag = options.ephem_flag; end
            if isfield(options,'eci_ecf_ephem'), obj.eci_ecf_ephem = options.eci_ecf_ephem; end
            if isfield(options,'earth_orientation'), obj.earth_orientation = options.earth_orientation; end
            if isfield(options,'dt_ephem'), obj.dt_ephem = options.dt_ephem; end
            if isfield(options,'date_ephem'), obj.date_ephem = options.date_ephem; end
            if isfield(options,'t0_ephem'), obj.t0_ephem = options.t0_ephem; end
            if isfield(options,'ephem_x'), obj.ephem_x = options.ephem_x; end
            if isfield(options,'ephem_y'), obj.ephem_y = options.ephem_y; end
            if isfield(options,'ephem_z'), obj.ephem_z = options.ephem_z; end
            if isfield(options,'vel_x'), obj.vel_x = options.vel_x; end
            if isfield(options,'vel_y'), obj.vel_y = options.vel_y; end
            if isfield(options,'vel_z'), obj.vel_z = options.vel_z; end
            if isfield(options,'accel_x'), obj.accel_x = options.accel_x; end
            if isfield(options,'accel_y'), obj.accel_y = options.accel_y; end
            if isfield(options,'accel_z'), obj.accel_z = options.accel_z; end
        end
        function value = get.num_ephem(obj) %#codegen
            %get.num_ephem - Derive the chronological reference sample count
            value = numel(obj.ephem_x);
        end
        function value = get.accel_provided(obj) %#codegen
            %get.accel_provided - Derive acceleration presence from its samples
            value = 'N';
            if any([numel(obj.accel_x) numel(obj.accel_y) numel(obj.accel_z)] > 0), value = 'Y'; end
        end
        function value = get.reserved_len(obj) %#codegen
            %get.reserved_len - Derive the complete velocity/acceleration area
            value = 0;
            if any([numel(obj.vel_x) numel(obj.vel_y) numel(obj.vel_z)] > 0)
                value = 13+36*obj.num_ephem*(1+strcmp(obj.accel_provided,'Y'));
            end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check versions, timing and complete chronological groups
            report = headerReport(obj);
            reference = 'STDI-0002-2 Appendix M, Table M.6-6';
            report = addIssue(report,~any(obj.desver == [1 2]),'EphemerisVersion','desver', ...
                'CSEPHB supports definition versions one and two.',reference);
            report = addIssue(report,any(isnan([obj.qual_flag_eph obj.interp_type_eph obj.ephem_flag obj.eci_ecf_ephem obj.dt_ephem])), ...
                'Required','ephemeris flags/timing','Supply all ephemeris flags and the sample interval.',reference);
            orderValid = (obj.interp_type_eph == 2 && any(obj.interp_order_eph == [3 5 7])) || ...
                (any(obj.interp_type_eph == [0 1]) && isnan(obj.interp_order_eph));
            report = addIssue(report,~orderValid,'EphemerisInterpolation','interp_type_eph/interp_order_eph', ...
                'Lagrangian interpolation uses order 3/5/7; nearest and linear omit the order.',reference);
            needsEarth = obj.eci_ecf_ephem == 0 && obj.desver == 2;
            report = addIssue(report,numel(obj.earth_orientation) ~= double(needsEarth), ...
                'EarthOrientationPresence','earth_orientation','Only version-two ECI data contain one transformation block.',reference);
            for k = 1:numel(obj.earth_orientation)
                report = mergeReport(report,validate(obj.earth_orientation(k)),'earth_orientation');
            end
            report = addIssue(report,~validMieTimestamp([char(obj.date_ephem) char(obj.t0_ephem)]), ...
                'EphemerisTime','date_ephem/t0_ephem','Supply a valid UTC date and hhmmss.nnnnnnnnn time.',reference);
            count = obj.num_ephem;
            report = addIssue(report,count < 1 || count > 99999 || ...
                ~sampleGroup(obj.ephem_x,obj.ephem_y,obj.ephem_z,count),'EphemerisSamples','ephem_x/y/z', ...
                'Supply three equal-length known rows containing 1-99999 positions.',reference);
            velocity = any([numel(obj.vel_x) numel(obj.vel_y) numel(obj.vel_z)] > 0);
            acceleration = strcmp(obj.accel_provided,'Y');
            report = addIssue(report,velocity && ~sampleGroup(obj.vel_x,obj.vel_y,obj.vel_z,count), ...
                'VelocitySamples','vel_x/y/z','Velocity requires three known rows matching the ephemeris samples.',reference);
            report = addIssue(report,acceleration && (~velocity || ~sampleGroup(obj.accel_x,obj.accel_y,obj.accel_z,count)), ...
                'AccelerationSamples','accel_x/y/z','Acceleration requires velocity and three known rows matching the ephemeris samples.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode positions and the optional derivative-data area
            requireValid(validate(obj));
            value = [decimalField(obj.qual_flag_eph,1,0,false) decimalField(obj.interp_type_eph,1,0,false)];
            if obj.interp_type_eph == 2, value = [value decimalField(obj.interp_order_eph,1,0,false)]; end
            value = [value decimalField(obj.ephem_flag,1,0,false) decimalField(obj.eci_ecf_ephem,1,0,false)];
            if ~isempty(obj.earth_orientation), value = [value bytes(obj.earth_orientation)]; end
            value = [value decimalField(obj.dt_ephem,13,9,false) textField(obj.date_ephem,8) ...
                textField(obj.t0_ephem,16) decimalField(obj.num_ephem,5,0,false)];
            prefix = numel(value); value = [value zeros(1,36*obj.num_ephem,'uint8')];
            for k = 1:obj.num_ephem
                value(prefix+(k-1)*36+(1:36)) = vectorBytes(obj.ephem_x(k),obj.ephem_y(k),obj.ephem_z(k));
            end
            value = [value decimalField(obj.reserved_len,9,0,false)];
            if obj.reserved_len == 0, return; end
            acceleration = strcmp(obj.accel_provided,'Y'); stride = 36*(1+acceleration);
            value = [value uint8('011') decimalField(obj.reserved_len-12,9,0,false) uint8(obj.accel_provided)];
            prefix = numel(value); value = [value zeros(1,stride*obj.num_ephem,'uint8')];
            for k = 1:obj.num_ephem
                start = prefix+(k-1)*stride;
                value(start+(1:36)) = vectorBytes(obj.vel_x(k),obj.vel_y(k),obj.vel_z(k));
                if acceleration
                    value(start+(37:72)) = vectorBytes(obj.accel_x(k),obj.accel_y(k),obj.accel_z(k));
                end
            end
        end
    end
end

function valid = sampleGroup(x,y,z,count) %#codegen
    %sampleGroup - Check matched supplied Cartesian sample rows
    valid = numel(x) == count && numel(y) == count && numel(z) == count && ...
        all(isfinite(x)) && all(isfinite(y)) && all(isfinite(z));
end

function value = vectorBytes(x,y,z) %#codegen
    %vectorBytes - Encode a Cartesian vector without changing its frame
    value = [decimalField(x,12,2,true) decimalField(y,12,2,true) decimalField(z,12,2,true)];
end
