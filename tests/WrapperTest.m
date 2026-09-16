classdef WrapperTest < NfxTest
    properties (TestParameter)
        invalidList = {'','0','01','1,,','1 2',' 1','2-1','1-,3','1--','1000','1-0'}
        validList = {'1','2,4-15','3-15,18,25-30','5-','1,2,  ','1-3,5-, '}
    end
    methods (Test)
        function synchronousRangeHasLiteralBytesAndSnapshotOrder(t)
            value = nfx.FSYNWA(start_frame_number=2,end_frame_number=7)+nfx.FREESA(1)+nfx.FREESA(2);
            t.verifyEqual(value.cel,43);
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:29)),'000000002000000007FREESA00001');
            t.verifyEqual(encoded(30),uint8(255));
            t.verifyEqual(char(encoded(31:41)),'FREESA00002');
            removed = value.removeTRE(value.tre_ids(1));
            t.verifyEqual(removed.tre_ids,2);
            t.verifyEqual(removed.cel,31);
            t.verifyEqual(value.tre_ids,[1 2]);
            t.verifyError(@() value.removeTRE(3),'nfx:UnknownAttachment');
        end
        function synchronousRangeRejectsMissingAndReversedLimits(t)
            value = nfx.FSYNWA(start_frame_number=9,end_frame_number=8)+nfx.FREESA(1);
            t.verifyFalse(value.validate().valid);
            value.end_frame_number = 0;
            t.verifyTrue(value.validate().valid);
            value.start_frame_number = NaN;
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.FSYNWA().validate().valid);
            t.verifyError(@() nfx.FSYNWA(start_frame_number=uint16(1)),'nfx:Metadata');
        end
        function synchronousWrapperHonorsExactPayloadLimit(t)
            value = nfx.FSYNWA()+nfx.FREESA(99956);
            t.verifyEqual(value.cel,99985);
            value = nfx.FSYNWA()+nfx.FREESA(99957);
            t.verifyFalse(value.validate().valid);
            value = nfx.FSYNWA()+nfx.FREESA(99956)+nfx.FREESA(1);
            t.verifyFalse(value.validate().valid);
        end
        function asynchronousTimestampsAndOpenEnd(t)
            value = nfx.FASYWA(start_timestamp='20260915120000.000000001', ...
                end_timestamp='20260915120001.123------')+nfx.FREESA(1);
            t.verifyEqual(value.cel,60);
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:59)), ...
                '20260915120000.00000000120260915120001.123------FREESA00001');
            t.verifyTrue(value.allowsPlacement('file'));
            t.verifyTrue(value.allowsPlacement('image'));
            value.end_timestamp = repmat('-',1,24);
            t.verifyFalse(value.allowsPlacement('file'));
            t.verifyTrue(value.allowsPlacement('image'));
            value.end_timestamp = '20260915120000.000000000';
            t.verifyFalse(value.validate().valid);
            value.start_timestamp = '';
            t.verifyFalse(value.validate().valid);
        end
        function asynchronousWrapperHonorsLengthAndMetadataKinds(t)
            value = nfx.FASYWA(start_timestamp='20260915120000.000000000', ...
                end_timestamp='20260915120001.000000000');
            largest = value+nfx.FREESA(99926);
            t.verifyEqual(largest.cel,99985);
            over = value+nfx.FREESA(99927);
            t.verifyFalse(over.validate().valid);
            tied = value+fixtureRPC();
            t.verifyFalse(tied.validate().valid);
        end
        function contextPreservesIndexTextAndDerivedLength(t)
            value = nfx.CONTXA(context_type="FR",aggregation_mode="I",index_list="2,4-7,10-,  ")+nfx.FREESA(1);
            t.verifyEqual(value.index_list_length,12);
            t.verifyEqual(value.cel,31);
            encoded = value.payload();
            t.verifyEqual(char(encoded(1:30)),'FRI00122,4-7,10-,  FREESA00001');
            value.context_type = 'IS';
            value.aggregation_mode = 'A';
            t.verifyFalse(value.validate().valid);
            value.aggregation_mode = 'X';
            t.verifyFalse(value.validate().valid);
            value.context_type = 'XX';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.CONTXA().validate().valid);
        end
        function contextRejectsInvalidGrammar(t,invalidList)
            value = nfx.CONTXA(context_type='IS',index_list=invalidList)+nfx.FREESA(1);
            t.verifyFalse(value.validate().valid);
        end
        function contextAcceptsDefinedGrammar(t,validList)
            value = nfx.CONTXA(context_type='IS',index_list=validList)+nfx.FREESA(1);
            t.verifyTrue(value.validate().valid);
        end
        function contextBoundsFollowReferencedIndexType(t)
            value = nfx.CONTXA(context_type='FR',index_list='4294967295')+nfx.FREESA(1);
            t.verifyTrue(value.validate().valid);
            value.index_list = '4294967296';
            t.verifyFalse(value.validate().valid);
            value.context_type = 'TI'; value.index_list = '999999';
            t.verifyTrue(value.validate().valid);
            value.index_list = '1000000';
            t.verifyFalse(value.validate().valid);
        end
        function contextAppliesChildLimitAndAggregateRestrictions(t)
            value = nfx.CONTXA(context_type='FH',index_list='1')+nfx.FREESA(99956);
            t.verifyEqual(value.cel,99975);
            value = nfx.CONTXA(context_type='FH',index_list='1')+nfx.FREESA(99957);
            t.verifyFalse(value.validate().valid);
            model = nfx.CONTXA(context_type='FR',aggregation_mode='A',index_list='1-2')+fixtureRPC();
            t.verifyFalse(model.validate().valid);
            footprint = nfx.CONTXA(context_type='FR',aggregation_mode='A',index_list='1-2')+fixtureCorners('FCRNSA');
            t.verifyTrue(footprint.validate().valid);
            model.index_list = '1';
            t.verifyTrue(model.validate().valid);
        end
        function nestedContextChecksScopesWithoutChangingChildIndices(t)
            frames = nfx.CONTXA(context_type='FR',index_list='3-5')+fixtureRPC();
            segments = nfx.CONTXA(context_type='IS',index_list='1-2')+frames;
            t.verifyTrue(segments.validate().valid);
            t.verifyTrue(segments.allowsPlacement('file'));
            t.verifyFalse(segments.allowsPlacement('image'));
            encoded = segments.payload();
            t.verifyEqual(char(encoded(1:31)),'ISI00031-2CONTXA01062FRI00033-5');
            file = fixtureFile()+segments;
            name = fullfile(t.folder,'contexts.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.allTRE(1).payload,encoded);
            [~,image] = fixtureFile();
            t.verifyError(@() plus(image,segments),'nfx:TREPlacement');
            t.verifyError(@() plus(file,frames),'nfx:TREPlacement');
        end
        function cameraAndIntervalHierarchyNarrowsScope(t)
            blocks = nfx.CONTXA(context_type='TB',index_list='1')+fixtureCorners('FCRNSA');
            cameras = nfx.CONTXA(context_type='CM',index_list='1-2')+blocks;
            intervals = nfx.CONTXA(context_type='TI',index_list='3')+cameras;
            sets = nfx.CONTXA(context_type='CS',index_list='4')+intervals;
            t.verifyTrue(sets.validate().valid);
            alternate = nfx.CONTXA(context_type='TI',index_list='3')+ ...
                (nfx.CONTXA(context_type='CS',index_list='4')+cameras);
            t.verifyTrue(alternate.validate().valid);
            ambiguous = nfx.CONTXA(context_type='CM',index_list='1')+ ...
                (nfx.CONTXA(context_type='CS',index_list='4')+nfx.FREESA(1));
            t.verifyFalse(ambiguous.validate().valid);
        end
        function snapshotAndOwnerChecksApplyToWrappedContents(t)
            child = fixtureRPC();
            value = nfx.FSYNWA()+child;
            original = value.payload();
            child.line_off = 5;
            t.verifyEqual(value.payload(),original);
            [file,image] = fixtureFile();
            t.verifyError(@() plus(file,value),'nfx:TREPlacement');
            image = image+value;
            t.verifyEqual(image.tre_tags(end,:),'FSYNWA');
            invalid = nfx.FSYNWA()+nfx.TMINTA(struct('time_interval_index',1,'start_timestamp','','end_timestamp',''));
            t.verifyFalse(invalid.validate().valid);
        end
    end
end
