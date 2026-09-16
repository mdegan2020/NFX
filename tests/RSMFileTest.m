classdef RSMFileTest < NfxTest
    methods (Test)
        function unequalImageParameterCountsAndExternalReferences(t)
            [first,a] = covariantImage('A',eye(2)); [second,b] = covariantImage('B',1);
            a.blocks(2) = nfx.RSMDCB.block('B',[0.5;0.25]);
            file = fileFor(first+a,second+b); t.verifyTrue(file.validate().valid);
            a.blocks(3) = nfx.RSMDCB.block('EXTERNAL',zeros(2,3));
            file = fileFor(first+a,second+b); t.verifyTrue(file.validate().valid);
        end
        function invalidJointCovarianceCanPassIndividualAndPairBounds(t)
            [first,a] = covariantImage('A',1); [second,b] = covariantImage('B',1); [third,c] = covariantImage('C',1);
            a.blocks(2) = nfx.RSMDCB.block('B',0.9); a.blocks(3) = nfx.RSMDCB.block('C',0.9);
            b.blocks(2) = nfx.RSMDCB.block('C',-0.9);
            t.verifyTrue(a.validate().valid); t.verifyTrue(b.validate().valid);
            file = fileFor(first+a,second+b,third+c); report = file.validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMJointCovariance')));
        end
        function singularJointCovarianceAndMissingZeroCrossBlocksAreValid(t)
            [first,a] = covariantImage('A',1); [second,b] = covariantImage('B',1); [third,c] = covariantImage('C',1);
            a.blocks(2) = nfx.RSMDCB.block('B',1);
            t.verifyTrue(fileFor(first+a,second+b,third+c).validate().valid);
            a.blocks(2).crscov = 0; t.verifyTrue(fileFor(first+a,second+b,third+c).validate().valid);
        end
        function oppositeBlocksMustAgreeAndEitherDirectionCanBeSupplied(t)
            [first,a] = covariantImage('A',eye(2)); [second,b] = covariantImage('B',1);
            b.blocks(2) = nfx.RSMDCB.block('A',[0.5 0.25]);
            t.verifyTrue(fileFor(first+a,second+b).validate().valid);
            a.blocks(2) = nfx.RSMDCB.block('B',[0.5;0.25]);
            t.verifyTrue(fileFor(first+a,second+b).validate().valid);
            a.blocks(2).crscov = [0.5;0.4]; report = fileFor(first+a,second+b).validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMCrossCovarianceTranspose')));
        end
        function referencedCovarianceDimensionsMustAgreeWithinAProcess(t)
            [first,a] = covariantImage('A',1); [second,b] = covariantImage('B',1);
            a.blocks(2) = nfx.RSMDCB.block('B',[0 0]);
            t.verifyFalse(fileFor(first+a,second+b).validate().valid);
            a.blocks(2) = nfx.RSMDCB.block('B',0); b.tid = 'OTHER';
            t.verifyTrue(fileFor(first+a,second+b).validate().valid);
            % An available different process does not resolve an external one.
            t.verifyTrue(fileFor(first+a,second).validate().valid);
            adjustment = nfx.RSMAPB(iid=b.iid,edition=b.edition,tid=a.tid,parameters=b.parameters,parval=0);
            t.verifyFalse(fileFor(first+a,second+adjustment).validate().valid);
        end
        function sharedOriginalImagesMustUseTheSameSet(t)
            [first,a] = covariantImage('A',1); image = first+a;
            t.verifyTrue(fileFor(image,image).validate().valid);
            [second,b] = covariantImage('A',2); t.verifyFalse(fileFor(image,second+b).validate().valid);
            % Attachment ordering does not alter the RSM set's meaning.
            [~,plain] = fixtureFile(); plain = plain.removeTRE(plain.tre_ids(1));
            id = fixtureRSMIdentification(); id.iid = 'A'; id.edition = a.edition;
            p = fixturePolynomial(); p.iid = 'A'; p.edition = a.edition;
            alternate = plain+a+p+id; t.verifyTrue(fileFor(image,alternate).validate().valid);
        end
        function distinctEditionsOfOneOriginalImageRemainSeparate(t)
            [first,a] = covariantImage('A',1);
            [second,b] = covariantImage('A',2,'A SECOND'); b.tid = 'SECOND PROCESS';
            file = fileFor(first+a,second+b); t.verifyTrue(file.validate().valid);
            name = fullfile(t.folder,'two-editions.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEqual(char(parsed.images(1).allTRE(1).payload(81:120)),pad('A EDITION',40));
            t.verifyEqual(char(parsed.images(2).allTRE(1).payload(81:120)),pad('A SECOND',40));
        end
        function differentOriginalImagesCannotReuseAnEdition(t)
            [first,a] = covariantImage('A',1,'REUSED'); [second,b] = covariantImage('B',1,'REUSED');
            report = fileFor(first+a,second+b).validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'RSMEditionIdentity')));
        end
        function covarianceLookupSelectsTheProcessAmongMultipleEditions(t)
            [first,a] = covariantImage('A',1);
            [old,b] = covariantImage('B',eye(2),'B OLD'); b.tid = 'OLD PROCESS';
            [current,c] = covariantImage('B',1,'B CURRENT');
            a.blocks(2) = nfx.RSMDCB.block('B',0.5);
            t.verifyTrue(fileFor(first+a,old+b,current+c).validate().valid);
            c.blocks(2) = nfx.RSMDCB.block('A',0.6);
            report = fileFor(first+a,old+b,current+c).validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'RSMCrossCovarianceTranspose')));
        end
        function remappedEditionsCanShareOneCovarianceProcess(t)
            [first,a] = covariantImage('A',1); [remapped,b] = covariantImage('A',1,'A REMAPPED');
            [second,c] = covariantImage('B',1); a.blocks(2) = nfx.RSMDCB.block('B',0.5); b.blocks = a.blocks;
            t.verifyTrue(fileFor(first+a,remapped+b,second+c).validate().valid);
            b.parameters.nsfx = 2; report = fileFor(first+a,remapped+b,second+c).validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMCovarianceParameterIdentity')));
        end
        function remappedEditionsUniteTheirSuppliedCovarianceBlocks(t)
            [first,a] = covariantImage('A',1); [remapped,b] = covariantImage('A',1,'A REMAPPED');
            [second,c] = covariantImage('B',1); a.blocks(2) = nfx.RSMDCB.block('B',0.5);
            t.verifyTrue(fileFor(first+a,remapped+b,second+c).validate().valid);
            t.verifyTrue(fileFor(remapped+b,first+a,second+c).validate().valid);
            % Repeated values must agree, including the associated auto block.
            b.blocks(2) = nfx.RSMDCB.block('B',0.6); report = fileFor(first+a,remapped+b,second+c).validate();
            t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},'RSMCovarianceBlockIdentity')));
            b.blocks = nfx.RSMDCB.block('A',2); t.verifyFalse(fileFor(first+a,remapped+b).validate().valid);
        end
        function availableSameProcessCovarianceResolvesAnAlternateEdition(t)
            [first,a] = covariantImage('A',1); [remapped,b] = covariantImage('A',1,'A REMAPPED');
            adjustment = nfx.RSMAPB(iid=b.iid,edition=b.edition,tid=b.tid,parameters=b.parameters,parval=0);
            t.verifyTrue(fileFor(first+a,remapped+adjustment).validate().valid);
            t.verifyTrue(fileFor(remapped+adjustment,first+a).validate().valid);
        end
        function distinctUnknownImagesAreNotMerged(t)
            [~,plain] = fixtureFile(); plain = plain.removeTRE(plain.tre_ids(1));
            id = fixtureRSMIdentification(); id.iid = ''; p = fixturePolynomial(); p.iid = '';
            first = plain+id+p; p.rnpcf = [1;2]; second = plain+id+p;
            t.verifyTrue(fileFor(first,second).validate().valid);
        end
        function wholePolynomialSectionsOverflowWithOriginalOrder(t)
            [~,image] = fixtureFile(); image = image.removeTRE(image.tre_ids(1)); id = fixtureRSMIdentification();
            directory = nfx.RSMPIA(iid=id.iid,edition=id.edition,rnis=1,cnis=6,rssiz=5,cssiz=7/6, ...
                r0=0,rx=0,ry=0,rz=0,rxx=0,rxy=0,rxz=0,ryy=0,ryz=0,rzz=0, ...
                c0=0,cx=0,cy=0,cz=0,cxx=0,cxy=0,cxz=0,cyy=0,cyz=0,czz=0);
            image = image+id+directory;
            p = fixturePolynomial(); p.rnpcf = ones(6,6,6); p.rdpcf = ones(6,6,6);
            p.cnpcf = ones(6,6,6); p.cdpcf = ones(6,6,6);
            for k = 1:6, p.csn = k; image = image+p; end
            file = fileFor(image); t.verifyTrue(file.validate().valid);
            name = fullfile(t.folder,'rsm-overflow.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEqual(numel(parsed.des),1); t.verifyEqual(numel(parsed.images(1).allTRE),8);
            t.verifyEqual({parsed.images(1).allTRE.tag},[{'RSMIDA','RSMPIA'} repmat({'RSMPCA'},1,6)]);
            t.verifyEqual(numel(parsed.images(1).tres),7); t.verifyEqual(parsed.des(1).fields.desitem,1);
            for k = 1:6
                payload = parsed.images(1).allTRE(k+2).payload;
                t.verifyEqual(str2double(char(payload(124:126))),k); t.verifyEqual(numel(payload),18546);
            end
            t.verifyEqual(nitfread(name),image.data);
        end
        function invalidSetNeverPublishesOverDestination(t)
            [first,a] = covariantImage('A',1); [second,b] = covariantImage('B',1);
            a.blocks(2) = nfx.RSMDCB.block('B',2); file = fileFor(first+a,second+b);
            name = fullfile(t.folder,'preserved.ntf'); putBytes(name,uint8('PRESERVE'));
            t.verifyError(@() file.write(name,Overwrite=true),'nfx:Invalid');
            t.verifyEqual(readBytes(name),uint8('PRESERVE'));
        end
        function publishedExampleWritesAnIndependentSyntheticFile(t)
            root = fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'examples')));
            file = rsmExample(); t.verifyTrue(file.validate().valid);
            name = fullfile(t.folder,'example.ntf'); file.write(name); parsed = inspectContainer(name);
            t.verifyEqual({parsed.images(1).allTRE.tag},{'RSMIDA','RSMPCA','RSMAPB','RSMDCB'});
            t.verifyEqual(nitfread(name),reshape(uint16(1:35),5,7));
        end
    end
end

function [image,direct] = covariantImage(identifier,covariance,edition)
    %covariantImage - Supply a complete original-image model and covariance
    [~,image] = fixtureFile(); image = image.removeTRE(image.tre_ids(1));
    if nargin < 3, edition = [identifier ' EDITION']; end
    id = fixtureRSMIdentification(); id.iid = identifier; id.edition = edition;
    p = fixturePolynomial(); p.iid = identifier; p.edition = edition; image = image+id+p;
    parameters = fixtureRSMParameters();
    if size(covariance,1) == 1
        parameters.xpwrc = []; parameters.ypwrc = []; parameters.zpwrc = [];
    end
    direct = nfx.RSMDCB(iid=identifier,edition=id.edition,tid='COMMON', ...
        parameters=parameters,blocks=nfx.RSMDCB.block(identifier,covariance));
end

function file = fileFor(varargin)
    %fileFor - Add supplied images to an otherwise empty synthetic file
    base = fixtureFile(); file = nfx.File(header=base.header);
    for k = 1:numel(varargin), file = file+varargin{k}; end
end
