function value = fixtureCSSFAB(type,form)
    %fixtureCSSFAB - Supply complete scanner, direct-grid or calibration data
    if nargin == 0, type = 'S'; end
    if nargin < 2, form = 0; end
    value = nfx.CSSFAB(uuid='20000000-0000-4000-8000-000000000003',aisdlvl=1, ...
        sensor_type=type,band_wavelength=0.55,fl_interp=0,foc_length_date='20260915', ...
        foc_length_time=0,foc_length=0.5,ppoff_x=0,ppoff_y=0,ppoff_z=0,angoff_x=0,angoff_y=0,angoff_z=0);
    if strcmp(type,'S')
        value.smpl_num_first = 0; value.delta_smpl_pairs = 64;
        value.start_falign_x = -0.1; value.start_falign_y = 0;
        value.end_falign_x = 0.1; value.end_falign_y = 0;
    else
        value.field_angle_type = form; value.fa_interp = 0;
        if form == 0
            value.fa_grids = fixtureFieldAlignmentGrid();
        else
            value.fiducial_transform = fixtureFiducialTransform(); value.iop = fixtureInteriorOrientation();
        end
    end
end
