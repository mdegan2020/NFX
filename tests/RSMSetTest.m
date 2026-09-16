classdef RSMSetTest < NfxTest
    methods (Test)
        function polynomialAndGridSetsWriteAndRoundTripPixels(t)
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial();
            file = wrapFile(image); name = fullfile(t.folder,'polynomial.ntf'); file.write(name);
            parsed = inspectContainer(name); t.verifyEqual({parsed.images.allTRE.tag},{'RSMIDA','RSMPCA'});
            t.verifyEqual(nitfread(name),image.data);
            image = baseImage()+fixtureRSMIdentification()+fixtureRSMGrid();
            name = fullfile(t.folder,'grid.ntf'); wrapFile(image).write(name);
            parsed = inspectContainer(name); t.verifyEqual({parsed.images.allTRE.tag},{'RSMIDA','RSMGGA'});
            t.verifyEqual(nitfread(name),image.data);
        end
        function simultaneousPolynomialAndCorrectionGridAreLegal(t)
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+fixtureRSMGrid();
            t.verifyTrue(image.validate().valid);
        end
        function twoByTwoSectionGridHasEveryPairAndFractionalSizes(t)
            image = baseImage()+fixtureRSMIdentification()+sectionID(false,2,2);
            for row = 1:2
                for col = 1:2
                    polynomial = fixturePolynomial(); polynomial.rsn = row; polynomial.csn = col; image = image+polynomial;
                end
            end
            t.verifyTrue(image.validate().valid);
            image = image.removeTRE(image.tre_ids(end)); t.verifyFalse(image.validate().valid);
            polynomial = fixturePolynomial(); image = image+polynomial; t.verifyFalse(image.validate().valid);
        end
        function gridAndPolynomialSectionLayoutsAreIndependent(t)
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+sectionID(true,1,2);
            grid = fixtureRSMGrid(); image = image+grid; grid.ggcsn = 2; image = image+grid;
            t.verifyTrue(image.validate().valid);
            grid.ggcsn = 3; image = image.removeTRE(image.tre_ids(end))+grid; t.verifyFalse(image.validate().valid);
        end
        function missingDuplicateAndOrphanCompanionsFail(t)
            t.verifyFalse(validImage(baseImage()+fixturePolynomial()));
            t.verifyFalse(validImage(baseImage()+fixtureRSMIdentification()));
            t.verifyFalse(validImage(baseImage()+fixtureRSMIdentification()+fixtureRSMIdentification()+fixturePolynomial()));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+fixturePolynomial(); t.verifyFalse(image.validate().valid);
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+sectionID(true,1,1); t.verifyFalse(image.validate().valid);
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+sectionID(false,1,1)+sectionID(false,1,1);
            t.verifyFalse(image.validate().valid);
        end
        function allIdentityFieldsAndSizesMustAgree(t)
            polynomial = fixturePolynomial(); polynomial.edition = 'DIFFERENT';
            t.verifyFalse(validImage(baseImage()+fixtureRSMIdentification()+polynomial));
            polynomial = fixturePolynomial(); polynomial.iid = 'DIFFERENT';
            t.verifyFalse(validImage(baseImage()+fixtureRSMIdentification()+polynomial));
            id = sectionID(false,1,1); id.rssiz = 4;
            t.verifyFalse(validImage(baseImage()+fixtureRSMIdentification()+fixturePolynomial()+id));
        end
        function originalDimensionsRequireMappingForAChip(t)
            identification = fixtureRSMIdentification(); identification.fullr = 20; identification.fullc = 30;
            image = baseImage()+identification+fixturePolynomial(); t.verifyFalse(image.validate().valid);
            [~,chipImage] = fixtureFile(zeros(2,3,'uint8')); chipImage = chipImage.removeTRE(chipImage.tre_ids(1));
            chipImage = chipImage+identification+fixturePolynomial()+fixtureChip(); t.verifyTrue(chipImage.validate().valid);
            identification.fullr = 21; image = chipImage.removeTRE(chipImage.tre_ids(1))+identification;
            t.verifyFalse(image.validate().valid);
        end
        function domainMayBeASubsetOfTheOriginalImage(t)
            identification = fixtureRSMIdentification(); identification.minr = 1; identification.maxr = 3;
            identification.minc = 2; identification.maxc = 4;
            image = baseImage()+identification+fixturePolynomial(); t.verifyTrue(image.validate().valid);
            identification.fullr = NaN; identification.fullc = NaN; identification.maxr = 6;
            image = baseImage()+identification+fixturePolynomial(); t.verifyFalse(image.validate().valid);
        end
        function unknownOriginalDimensionsCanUseChipDimensions(t)
            identification = fixtureRSMIdentification(); identification.fullr = NaN; identification.fullc = NaN;
            image = baseImage()+identification+fixturePolynomial()+fixtureChip(); t.verifyTrue(image.validate().valid);
            identification.maxr = 20; image = baseImage()+identification+fixturePolynomial()+fixtureChip();
            t.verifyFalse(image.validate().valid);
        end
        function invalidOrUnavailableChipMappingCannotPass(t)
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+nfx.ICHIPB(xfrm_flag=1);
            t.verifyFalse(image.validate().valid);
            identification = fixtureRSMIdentification(); identification.fullr = 20; identification.fullc = 30;
            chip = fixtureChip(); chip.op_row_21 = 0.5; chip.op_row_22 = 0.5;
            image = baseImage()+identification+fixturePolynomial()+chip; t.verifyFalse(image.validate().valid);
            image = baseImage()+identification+fixturePolynomial()+fixtureChip()+fixtureChip(); t.verifyFalse(image.validate().valid);
        end
        function outputChipCornersMustFitTheStoredRasterAndLabels(t)
            id = fixtureRSMIdentification(); id.fullr = 20; id.fullc = 30;
            chip = fixtureChip(); chip.op_row_11 = 100.5; chip.op_row_12 = 100.5;
            chip.op_row_21 = 101.5; chip.op_row_22 = 101.5;
            image = baseImage()+id+fixturePolynomial()+chip; report = image.validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMChipOutputExtent')));
            chip = fixtureChip(); chip.op_row_11 = 1.5; chip.op_row_12 = 1.5;
            chip.op_row_21 = 0.5; chip.op_row_22 = 0.5;
            image = baseImage()+id+fixturePolynomial()+chip; report = image.validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMChipCornerOrder')));
            chip = fixtureChip(); chip.op_col_12 = 7.5; chip.op_col_22 = 7.5;
            image = baseImage()+id+fixturePolynomial()+chip; t.verifyFalse(image.validate().valid);
        end
        function chipExtentUsesTheResolvedCommonCoordinatePosition(t)
            id = fixtureRSMIdentification(); id.fullr = 20; id.fullc = 30;
            chip = fixtureChip(); fields = {'11','12','21','22'};
            for k = 1:4
                chip.(['op_row_' fields{k}]) = chip.(['op_row_' fields{k}])+100;
                chip.(['op_col_' fields{k}]) = chip.(['op_col_' fields{k}])+200;
            end
            image = baseImage()+id+fixturePolynomial()+chip; image.header.iloc = [100 200];
            t.verifyTrue(image.validate().valid); t.verifyTrue(wrapFile(image).validate().valid);
            parent = baseImage(); parent.header.idlvl = 1; parent.header.iloc = [90 180];
            image.header.idlvl = 2; image.header.ialvl = 1; image.header.iloc = [10 20];
            file = wrapFile(parent)+image; t.verifyTrue(file.validate().valid);
            image.header.iloc = [11 20]; file = wrapFile(parent)+image; report = file.validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMChipOutputExtent')));
        end
        function gridInitialCoordinatesRespectTheDeclaredGroundSystem(t)
            grid = fixtureRSMGrid(); grid.xipln1 = 4;
            image = baseImage()+fixtureRSMIdentification()+grid; t.verifyFalse(image.validate().valid);
            identification = fixtureRSMIdentification(); identification.grndd = 'H';
            image = baseImage()+identification+grid; t.verifyTrue(image.validate().valid);
            grid.yipln1 = 2; image = baseImage()+identification+grid; t.verifyFalse(image.validate().valid);
        end
        function adjustmentAndDirectCovarianceDefinitionsMustAgree(t)
            [adjustment,direct] = adjustedRecords();
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct;
            t.verifyTrue(image.validate().valid);
            direct.parameters.nsfx = 2;
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct; t.verifyFalse(image.validate().valid);
            [adjustment,direct] = adjustedRecords(); direct.tid = 'OTHER';
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct; t.verifyFalse(image.validate().valid);
        end
        function directCovarianceRequiresAutoAndParameterDefinitions(t)
            [~,direct] = adjustedRecords(); direct.parameters = nfx.RSMParameters.empty(1,0);
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct; t.verifyFalse(image.validate().valid);
            [~,direct] = adjustedRecords(); direct.blocks = nfx.RSMDCB.block('OTHER',eye(2));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct; t.verifyFalse(image.validate().valid);
        end
        function directInstancesShareDefinitionsAndCannotRepeatBlocks(t)
            [~,direct] = adjustedRecords(); second = nfx.RSMDCB(iid=direct.iid,edition=direct.edition,tid=direct.tid, ...
                blocks=nfx.RSMDCB.block('OTHER',zeros(2,1)));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct+second; t.verifyTrue(image.validate().valid);
            second.parameters = direct.parameters; image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct+second;
            t.verifyTrue(image.validate().valid);
            second.parameters.nsfx = 2; image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct+second;
            t.verifyFalse(image.validate().valid);
            second.parameters = direct.parameters; second.blocks = direct.blocks;
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+direct+second; t.verifyFalse(image.validate().valid);
        end
        function parameterDefinitionParserHandlesRectangularBasis(t)
            p = fixtureRSMParameters(); p.loctyp = 'R';
            p.xuol = 0; p.yuol = 0; p.zuol = 0;
            p.xuxl = 1; p.xuyl = 0; p.xuzl = 0; p.yuxl = 0; p.yuyl = 1; p.yuzl = 0; p.zuxl = 0; p.zuyl = 0; p.zuzl = 1;
            p.ael = [0.6 0.8];
            [adjustment,direct] = adjustedRecords(); adjustment.parameters = p; adjustment.parval = 1;
            direct.parameters = p; direct.blocks = nfx.RSMDCB.block(direct.iid,1);
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct;
            t.verifyTrue(image.validate().valid);
        end
        function snapshotRemovalAndWrongOwners(t)
            polynomial = fixturePolynomial(); original = polynomial.payload(); image = baseImage()+fixtureRSMIdentification()+polynomial;
            polynomial.rnpcf = 123; t.verifyEqual(image.tre_records(2).payload,original);
            image = image.removeTRE(image.tre_ids(2)); t.verifyFalse(image.validate().valid);
            t.verifyError(@() nfx.File()+fixtureRSMIdentification(),'nfx:TREPlacement');
            t.verifyError(@() fixtureText()+fixtureRSMGrid(),'nfx:TREPlacement');
        end
        function indirectCovarianceAndAdjustmentShareTheirActiveDefinitions(t)
            [adjustment,~] = adjustedRecords();
            correlation = nfx.RSMCorrelation(ac=1,alpc=0,betc=2,tc=5);
            indirect = nfx.RSMECB(iid=adjustment.iid,edition=adjustment.edition,tid=adjustment.tid, ...
                parameters=adjustment.parameters,subgroups=nfx.RSMECB.subgroup(eye(2),0,correlation),map=eye(2));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+indirect;
            t.verifyTrue(image.validate().valid);
            image = image+adjustment; t.verifyTrue(image.validate().valid);
            indirect.parameters.nsfx = 2;
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+indirect+adjustment;
            t.verifyFalse(image.validate().valid);
        end
        function directCovarianceCanCoexistWithPriorIndirectDefinitions(t)
            [adjustment,direct] = adjustedRecords(); p = adjustment.parameters; p.nsfx = 2;
            c = nfx.RSMCorrelation(ac=1,alpc=0,betc=2,tc=5);
            indirect = nfx.RSMECB(iid=adjustment.iid,edition=adjustment.edition,tid=adjustment.tid, ...
                parameters=p,subgroups=nfx.RSMECB.subgroup(eye(2),0,c),map=eye(2));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+indirect+adjustment+direct;
            t.verifyTrue(image.validate().valid);
            indirect.parameters = nfx.RSMParameters.empty(1,0);
            indirect.subgroups = struct('errcvg',{},'tcdf',{},'correlation',{}); indirect.map = [];
            indirect.urr = 1; indirect.urc = 0; indirect.ucc = 1;
            indirect.row_correlation = c; indirect.column_correlation = c;
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+indirect+adjustment+direct;
            t.verifyTrue(image.validate().valid);
        end
        function allCovarianceAndAdjustmentProcessIDsMustAgree(t)
            [adjustment,direct] = adjustedRecords();
            c = nfx.RSMCorrelation(ac=1,alpc=0,betc=2,tc=5);
            indirect = nfx.RSMECB(iid=adjustment.iid,edition=adjustment.edition,tid='OTHER', ...
                parameters=adjustment.parameters,subgroups=nfx.RSMECB.subgroup(eye(2),0,c),map=eye(2));
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial();
            assembled = image+adjustment+indirect; report = assembled.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'RSMProcessIdentity')));
            assembled = image+direct+indirect; t.verifyFalse(assembled.validate().valid);
            indirect.parameters = nfx.RSMParameters.empty(1,0);
            indirect.subgroups = struct('errcvg',{},'tcdf',{},'correlation',{}); indirect.map = [];
            indirect.urr = 1; indirect.urc = 0; indirect.ucc = 1;
            indirect.row_correlation = c; indirect.column_correlation = c;
            assembled = image+direct+indirect; t.verifyFalse(assembled.validate().valid);
        end
        function groundParameterDefinitionsParseAcrossCompanions(t)
            p = nfx.RSMParameters(aptyp='G',loctyp='R',gsapid={'OFFX','ZRTY'}, ...
                nsfx=1,nsfy=1,nsfz=1,noffx=0,noffy=0,noffz=0, ...
                xuol=0,yuol=0,zuol=0,xuxl=1,xuyl=0,xuzl=0,yuxl=0,yuyl=1,yuzl=0,zuxl=0,zuyl=0,zuzl=1);
            [adjustment,direct] = adjustedRecords(); adjustment.parameters = p; direct.parameters = p;
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct;
            t.verifyTrue(image.validate().valid);
            p.ael = [0.6 0.8]; adjustment.parameters = p; adjustment.parval = 1;
            direct.parameters = p; direct.blocks = nfx.RSMDCB.block(direct.iid,1);
            image = baseImage()+fixtureRSMIdentification()+fixturePolynomial()+adjustment+direct;
            t.verifyTrue(image.validate().valid);
        end
        function wrappedModelsRequireEffectiveContextResolution(t)
            wrapper = nfx.FSYNWA()+fixtureRSMIdentification()+fixturePolynomial();
            image = baseImage()+wrapper; t.verifyFalse(image.validate().valid);
            wrapper = nfx.CONTXA(context_type='IS',index_list='1')+fixtureRSMIdentification()+fixturePolynomial();
            file = wrapFile(baseImage())+wrapper; t.verifyFalse(file.validate().valid);
        end
    end
end

function value = baseImage()
    %baseImage - Supply standalone synthetic pixels without a competing model
    [~,value] = fixtureFile(); value = value.removeTRE(value.tre_ids(1));
end

function value = validImage(image)
    %validImage - Query a composed value without expression-indexing syntax
    value = image.validate().valid;
end

function value = wrapFile(image)
    %wrapFile - Provide complete file metadata around the tested image
    base = fixtureFile(); value = nfx.File(header=base.header)+image;
end

function value = sectionID(grid,rows,columns)
    %sectionID - Supply a synthetic section directory with exact domain sizes
    p = fixturePolynomial();
    if grid, value = nfx.RSMGIA(iid=p.iid,edition=p.edition,grnis=rows,gcnis=columns,grssiz=5/rows,gcssiz=7/columns); prefix = 'g';
    else, value = nfx.RSMPIA(iid=p.iid,edition=p.edition,rnis=rows,cnis=columns,rssiz=5/rows,cssiz=7/columns); prefix = ''; end
    fields = {'r0','rx','ry','rz','rxx','rxy','rxz','ryy','ryz','rzz','c0','cx','cy','cz','cxx','cxy','cxz','cyy','cyz','czz'};
    for k = 1:numel(fields), value.([prefix fields{k}]) = 0; end
end

function [adjustment,direct] = adjustedRecords()
    %adjustedRecords - Pair known translations with direct error covariance
    id = fixtureRSMIdentification(); p = fixtureRSMParameters();
    adjustment = nfx.RSMAPB(iid=id.iid,edition=id.edition,tid='ADJUSTED',parameters=p,parval=[1 2]);
    direct = nfx.RSMDCB(iid=id.iid,edition=id.edition,tid='ADJUSTED',parameters=p,blocks=nfx.RSMDCB.block(id.iid,eye(2)));
end
