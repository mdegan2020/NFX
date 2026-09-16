classdef (Sealed) InteriorOrientation
    %InteriorOrientation - Supply one lens calibration for CSSFAB
    %   OBJ = InteriorOrientation(Name=VALUE) holds a focal length and twelve
    %   double calibration values in Appendix M's field order. Distortion
    %   units are those of the specification; offsets and radius use mm.
    %   NFX encodes the supplied model without fitting or applying corrections.
    %
    %   CSSFAB uses these values for its regular lens calibration sets.
    %   TelescopeOptics uses the same values for the corresponding _TELE
    %   fields; FL_CAL_IOP becomes FL_CAL_IOP_TELE in that context.
    %
    %   See also CSSFAB, TelescopeOptics, FieldAlignmentGrid

    properties
        fl_cal_iop {mustBeMetadata(fl_cal_iop,0,99.99999999,0)} = NaN
        ppo_x0 {mustBeRSMNumber} = NaN
        ppo_y0 {mustBeRSMNumber} = NaN
        rld_k0 {mustBeRSMNumber} = NaN
        rld_k1 {mustBeRSMNumber} = NaN
        rld_k2 {mustBeRSMNumber} = NaN
        rld_k3 {mustBeRSMNumber} = NaN
        dcd_p1 {mustBeRSMNumber} = NaN
        dcd_p2 {mustBeRSMNumber} = NaN
        dcd_p3 {mustBeRSMNumber} = NaN
        ad_a1 {mustBeRSMNumber} = NaN
        ad_a2 {mustBeRSMNumber} = NaN
        radius_of_validity {mustBeRSMNumber} = NaN
    end
    methods
        function obj = InteriorOrientation(options) %#codegen
            %InteriorOrientation - Construct editable supplied lens parameters
            arguments
                options.?nfx.InteriorOrientation
            end
            if isfield(options,'fl_cal_iop'), obj.fl_cal_iop = options.fl_cal_iop; end
            if isfield(options,'ppo_x0'), obj.ppo_x0 = options.ppo_x0; end
            if isfield(options,'ppo_y0'), obj.ppo_y0 = options.ppo_y0; end
            if isfield(options,'rld_k0'), obj.rld_k0 = options.rld_k0; end
            if isfield(options,'rld_k1'), obj.rld_k1 = options.rld_k1; end
            if isfield(options,'rld_k2'), obj.rld_k2 = options.rld_k2; end
            if isfield(options,'rld_k3'), obj.rld_k3 = options.rld_k3; end
            if isfield(options,'dcd_p1'), obj.dcd_p1 = options.dcd_p1; end
            if isfield(options,'dcd_p2'), obj.dcd_p2 = options.dcd_p2; end
            if isfield(options,'dcd_p3'), obj.dcd_p3 = options.dcd_p3; end
            if isfield(options,'ad_a1'), obj.ad_a1 = options.ad_a1; end
            if isfield(options,'ad_a2'), obj.ad_a2 = options.ad_a2; end
            if isfield(options,'radius_of_validity'), obj.radius_of_validity = options.radius_of_validity; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check complete encodable parameters and a valid radius
            report = newReport('CSSFAB InteriorOrientation');
            reference = 'STDI-0002-2 Appendix M, Table M.6-7';
            report = addIssue(report,isnan(obj.fl_cal_iop),'Required','fl_cal_iop','Supply the calibration focal length.',reference);
            values = [obj.ppo_x0 ...
                obj.ppo_y0 ...
                obj.rld_k0 ...
                obj.rld_k1 ...
                obj.rld_k2 ...
                obj.rld_k3 ...
                obj.dcd_p1 ...
                obj.dcd_p2 ...
                obj.dcd_p3 ...
                obj.ad_a1 ...
                obj.ad_a2 ...
                obj.radius_of_validity];
            valid = true;
            for k = 1:12, [~,fits] = rsmNumber(values(k),false); valid = valid && fits; end
            report = addIssue(report,~valid,'CalibrationPrecision','interior orientation', ...
                'Supply all twelve known parameters within the signed 21-byte scientific format.',reference);
            report = addIssue(report,obj.radius_of_validity < 0,'CalibrationRadius','radius_of_validity', ...
                'The radius of validity must be nonnegative.',reference);
        end
        function value = bytes(obj) %#codegen
            %BYTES - Encode the focal length followed by twelve coefficients
            requireValid(validate(obj));
            values = [obj.ppo_x0 ...
                obj.ppo_y0 ...
                obj.rld_k0 ...
                obj.rld_k1 ...
                obj.rld_k2 ...
                obj.rld_k3 ...
                obj.dcd_p1 ...
                obj.dcd_p2 ...
                obj.dcd_p3 ...
                obj.ad_a1 ...
                obj.ad_a2 ...
                obj.radius_of_validity];
            value = zeros(1,263,'uint8'); value(1:11) = decimalField(obj.fl_cal_iop,11,8,false);
            for k = 1:12, value(11+(k-1)*21+(1:21)) = rsmNumber(values(k),false); end
        end
    end
end
