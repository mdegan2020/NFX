classdef FieldAlignmentTest < NfxTest
    methods (Test)
        function directGridUsesRowColumnClockwiseCornerOrder(t)
            value = fixtureFieldAlignmentGrid(); names = {'fa_x1','fa_y1','fa_x2','fa_y2','fa_x3','fa_y3','fa_x4','fa_y4'};
            for k = 1:8, value.(names{k}) = [1 2;3 4]+4*(k-1); end
            data = value.bytes(); t.verifyEqual(numel(data),63+4*88); t.verifyEqual(value.byte_length,numel(data));
            t.verifyEqual(char(data(35:37)),'002'); t.verifyEqual(char(data(61:63)),'002');
            numbers = reshape(str2double(cellstr(reshape(char(data(64:end)),11,[]).')),8,[]);
            t.verifyEqual(numbers,(1:4)+(0:4:28).');
            t.verifyEqual([value.num_fa_blocks_line value.num_fa_blocks_samp],[2 2]);
        end
        function directGridCompletenessAndShapes(t)
            t.verifyFalse(nfx.FieldAlignmentGrid().validate().valid);
            value = fixtureFieldAlignmentGrid(); value.fa_y4 = [1 2]; t.verifyFalse(value.validate().valid);
            value.fa_y4 = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.FieldAlignmentGrid(fa_x1=100),'nfx:GLASMatrix');
            t.verifyError(@() nfx.FieldAlignmentGrid(fa_x1=zeros(1000,1)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.FieldAlignmentGrid(delta_line=-1),'nfx:Metadata');
        end
        function lensParameterOrderAndScientificBounds(t)
            value = fixtureInteriorOrientation(); names = {'ppo_x0','ppo_y0','rld_k0','rld_k1','rld_k2','rld_k3','dcd_p1','dcd_p2','dcd_p3','ad_a1','ad_a2','radius_of_validity'};
            for k = 1:12, value.(names{k}) = k; end
            data = value.bytes(); t.verifyEqual(numel(data),263); t.verifyEqual(char(data(1:11)),'00.50000000');
            numbers = str2double(cellstr(reshape(char(data(12:end)),21,[]).')).'; t.verifyEqual(numbers,1:12);
            value.radius_of_validity = -1; t.verifyFalse(value.validate().valid); value.radius_of_validity = 1;
            value.rld_k3 = 1e-114; t.verifyFalse(value.validate().valid); value.rld_k3 = 1e-113;
            t.verifyTrue(value.validate().valid); value.rld_k3 = NaN; t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.InteriorOrientation().validate().valid);
        end
        function fiducialArraysUseRowColumnParameterOrder(t)
            value = fixtureFiducialTransform();
            for k = 0:7, value.(sprintf('ls_fid_trans_t%.0f',k)) = [1 2;3 4]+4*k; end
            data = value.bytes(); t.verifyEqual(char(data(1:6)),'002002');
            numbers = reshape(str2double(cellstr(reshape(char(data(7:end)),21,[]).')),8,[]);
            t.verifyEqual(numbers,(1:4)+(0:4:28).'); t.verifyEqual(value.byte_length,678);
            value.ls_fid_trans_t0 = []; t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.FiducialTransform().validate().valid);
        end
        function bandMetadataKeepsUnitsAndOptionalSpaces(t)
            value = nfx.SensorBand(band_index=2,irepband='R',isubcat=0.65);
            t.verifyEqual(char(value.bytes()),'00002R .65000'); value.isubcat = NaN;
            t.verifyEqual(char(value.bytes()),'00002R       '); value.isubcat = 1e-9;
            t.verifyFalse(value.validate().valid); value.isubcat = 1e-5; t.verifyTrue(value.validate().valid);
            t.verifyFalse(nfx.SensorBand().validate().valid);
            t.verifyError(@() nfx.SensorBand(isubcat='0.65'),'nfx:Metadata');
        end
        function scannerPayloadHasNoFramerTelescopeFlag(t)
            value = fixtureCSSFAB(); data = value.payload(); t.verifyEqual(numel(data),195);
            t.verifyEqual(value.byte_length,195); t.verifyEqual(value.num_fa_pairs,1); t.verifyEqual(value.num_fl_pts,1);
            t.verifyEqual(char(data(1:30)),'S 00.5500000000000001020260915');
            t.verifyEqual(char(data(117:142)),'+00000.0000000064.00000001');
            t.verifyEqual(char(data(143:186)),'-00.1000000+00.0000000+00.1000000+00.0000000');
            t.verifyEqual(char(data(end-8:end)),'000000000'); t.verifyEqual(value.telescope_optics_flag,0);
        end
        function bothFramingFormsEncodeTheirSelectedModel(t)
            value = fixtureCSSFAB('F',0); data = value.payload(); t.verifyEqual(numel(data),280);
            t.verifyEqual(char(data(117:119)),'100'); t.verifyEqual(data(120:270),fixtureFieldAlignmentGrid().bytes());
            t.verifyEqual(char(data(271:end)),'0000000000');
            value = fixtureCSSFAB('F',1); data = value.payload(); t.verifyEqual(numel(data),566);
            t.verifyEqual(char(data(117:119)),'110'); t.verifyEqual(data(120:293),fixtureFiducialTransform().bytes());
            t.verifyEqual(data(294:556),fixtureInteriorOrientation().bytes());
        end
        function bandCountsAndRepeatedFocalSamplesAreDerived(t)
            value = fixtureCSSFAB(); value.bands = [nfx.SensorBand(band_index=2,irepband='G',isubcat=0.55) nfx.SensorBand(band_index=1,irepband='R',isubcat=0.65)];
            value.foc_length_time = [1 2.123456789]; value.foc_length = [0.5 0.75]; data = value.payload();
            t.verifyEqual(value.n_bands,2); t.verifyEqual(value.num_fl_pts,2); t.verifyEqual(numel(data),247);
            t.verifyEqual(char(data(14:18)),'00002'); t.verifyEqual(data(19:44),[value.bands(1).bytes() value.bands(2).bytes()]);
            t.verifyEqual(char(data(45:47)),'002'); t.verifyEqual(char(data(57:82)),'00001.00000000000.50000000');
            value.bands(2).band_index = 2; t.verifyFalse(value.validate().valid);
            value.bands(2).band_index = NaN; t.verifyFalse(value.validate().valid);
        end
        function focalSamplesAndRequiredOffsetsAreValidated(t)
            value = fixtureCSSFAB(); value.foc_length_time = [1 2]; t.verifyFalse(value.validate().valid);
            value.foc_length = [0.5 0.6]; t.verifyTrue(value.validate().valid);
            value.foc_length_time = [2 1]; t.verifyFalse(value.validate().valid);
            value.foc_length_time = [1 1+1e-12]; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.foc_length_date = ''; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.angoff_z = NaN; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.foc_length = NaN; t.verifyFalse(value.validate().valid);
            t.verifyError(@() nfx.CSSFAB(foc_length=-1),'nfx:FocalSamples');
            t.verifyFalse(nfx.CSSFAB().validate().valid);
        end
        function publishedBandCategoriesDoNotSelectGeometry(t)
            value = fixtureCSSFAB();
            for band = {'',' ','M','R','G','B','N','S','I','L'}
                value.band_type = band{1}; t.verifyTrue(value.validate().valid);
            end
            value.band_type = 'X'; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.desver = 1; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.sensor_type = 'X'; t.verifyFalse(value.validate().valid);
        end
        function scannerAndFramingFieldsCannotBeSilentlyDiscarded(t)
            value = fixtureCSSFAB(); value.field_angle_type = 0; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.start_falign_x = [1 2]; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB(); value.smpl_num_first = NaN; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F'); value.smpl_num_first = 0; t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F'); value.iop = fixtureInteriorOrientation(); t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F',1); value.fa_grids = fixtureFieldAlignmentGrid(); t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F',1); value.fiducial_transform = nfx.FiducialTransform.empty(1,0); t.verifyFalse(value.validate().valid);
        end
        function framingSetAndTelescopeCountsApply(t)
            value = fixtureCSSFAB('F'); value.fa_grids = repmat(fixtureFieldAlignmentGrid(),1,9);
            t.verifyTrue(value.validate().valid); t.verifyEqual(value.num_sets_fa_data,9);
            value.fa_grids(10) = value.fa_grids(1); t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F',1); value.iop = repmat(fixtureInteriorOrientation(),1,9); t.verifyTrue(value.validate().valid);
            value.iop(10) = value.iop(1); t.verifyFalse(value.validate().valid);
            value = fixtureCSSFAB('F',1); value.telescope = fixtureTelescopeOptics();
            t.verifyEqual(value.telescope_optics_flag,1); data = value.payload();
            t.verifyEqual(numel(data),566+341); t.verifyEqual(data(558:end-9),value.telescope.bytes());
            value.telescope(2) = value.telescope(1); t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.telescope_optics_flag,'nfx:TelescopeCount');
        end
    end
end
