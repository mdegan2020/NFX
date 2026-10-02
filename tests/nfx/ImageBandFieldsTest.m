classdef ImageBandFieldsTest < NfxTest
    methods (Test)
        function defaultsAndResetFollowRepresentation(t)
            [~,image] = fixtureFile(); t.verifyEqual(image.header.irepband,{'M'}); t.verifyTrue(isnan(image.header.isubcat));
            [~,image] = fixtureFile(ones(2,3,3,'uint8'),'RGB'); t.verifyEqual(image.header.irepband,{'R','G','B'});
            image.header.irepband = {'B','R','G'}; t.verifyEqual(image.header.irepband,{'B','R','G'});
            image.header.irepband = {}; t.verifyEqual(image.header.irepband,{'R','G','B'});
            [~,image] = fixtureFile(ones(2,3,4,'uint8'),'MULTI'); t.verifyEqual(image.header.irepband,{'','','',''});
            t.verifyTrue(all(isnan(image.header.isubcat)));
        end
        function suppliedLabelsWavelengthsAndTargetHaveIndependentBytes(t)
            [base,image] = fixtureFile(ones(2,3,3,'uint8'),'MULTI');
            header = image.header; header.irepband = {'R','G','B'}; header.isubcat = [650 550 450];
            header.tgtid = 'OBJ123456789012US'; image.header = header;
            file = nfx.File(header=base.header)+image; name = fullfile(t.folder,'bands.ntf'); file.write(name);
            parsed = inspectContainer(name); data = parsed.images.header;
            t.verifyEqual(char(data(27:43)),'OBJ123456789012US');
            t.verifyEqual(char(data(377:415)),'R 650.00N   0G 550.00N   0B 450.00N   0');
            t.verifyEqual(nitfread(name),image.data);
        end
        function labelsAndCountsCannotContradictRepresentation(t)
            [~,image] = fixtureFile(ones(2,3,3,'uint8'),'MULTI'); image.header.irepband = {'R','R','B'};
            t.verifyFalse(image.validate().valid); image.header.irepband = {'R','G'}; t.verifyFalse(image.validate().valid);
            image.header.irepband = {'M','N',''}; t.verifyTrue(image.validate().valid);
            image.header.isubcat = [1 2]; t.verifyFalse(image.validate().valid);
            image.header.isubcat = [NaN 0 1e-5]; t.verifyTrue(image.validate().valid);
            image.header.isubcat = [NaN 0 1e-6]; t.verifyFalse(image.validate().valid);
            [~,image] = fixtureFile(); image.header.irepband = {'R'}; t.verifyFalse(image.validate().valid);
            image.header.irepband = {''}; t.verifyTrue(image.validate().valid);
            image.header.irepband = {'LU'}; t.verifyFalse(image.validate().valid);
        end
        function strictMetadataTypesAndWavelengthReset(t)
            t.verifyError(@() nfx.ImageHeader(irepband='R'),'nfx:BandRepresentations');
            t.verifyError(@() nfx.ImageHeader(isubcat=single(550)),'nfx:GLASMatrix');
            t.verifyError(@() nfx.ImageHeader(isubcat=-1),'nfx:BandWavelengths');
            [~,image] = fixtureFile(); image.header.isubcat = 550; image.header.isubcat = [];
            t.verifyTrue(isnan(image.header.isubcat));
        end
    end
end
