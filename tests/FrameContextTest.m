classdef FrameContextTest < NfxTest
    methods (Test)
        function hypotheticalFileHeaderValidatesItsOwnAssociations(t)
            [base,image] = fixtureFile(); x = fixtureCSEXRB();
            wrapper = nfx.CONTXA(context_type='FH',index_list='1')+x;
            file = nfx.File(header=base.header)+image+wrapper;
            t.verifyTrue(file.validate().valid);
            [records,headerRecords] = file.effectiveTREs(1);
            t.verifyFalse(any(strcmp({records.tag},'CSEXRB')));
            t.verifyEqual(headerRecords(strcmp({headerRecords.tag},'CSEXRB')).payload,x.payload());
            x = fixtureCSEXRB('F'); wrapper = nfx.CONTXA(context_type='FH',index_list='1')+x;
            file = nfx.File(header=base.header)+image+wrapper; verifyIssue(t,file,'GLASMissingDES');
        end
        function wrappersDoNotRelocatePrimaryTimingOrAggregatePixelModels(t)
            [~,~,timing] = fixtureMotion();
            wrapper = nfx.FSYNWA()+timing; t.verifyFalse(wrapper.validate().valid);
            wrapper = nfx.CONTXA(context_type='FR',index_list='1-2',aggregation_mode='A')+fixtureCSEXRB('F');
            t.verifyFalse(wrapper.validate().valid);
            wrapper = nfx.CONTXA(context_type='FR',index_list='1-2',aggregation_mode='A')+fixtureCSEXRB();
            t.verifyTrue(wrapper.validate().valid);
        end
        function asynchronousInvalidTimingReturnsADiagnostic(t)
            [base,image,timing] = fixtureMotion(); image = image.removeTRE(image.tre_ids(1));
            timing.number_frames = 1; timing.dt = uint64([]);
            wrapper = nfx.FASYWA(start_timestamp='20260915120000.000000000',end_timestamp=repmat('-',1,24))+nfx.FREESA(1);
            file = nfx.File(header=base.header)+(image+timing+wrapper); verifyIssue(t,file,'AsynchronousTiming');
            timing.number_frames = 3; timing.dt = intmax('uint64'); timing.dt_multiplier = intmax('uint64');
            file = nfx.File(header=base.header)+(image+timing+wrapper); verifyIssue(t,file,'AsynchronousTiming');
        end
        function aNewWrappedEditionOverridesAnEarlierCompleteSet(t)
            [base,image] = fixtureMotion(); id = fixtureRSMIdentification(); polynomial = fixturePolynomial();
            image = image+id+polynomial; id.edition = 'REVISED'; polynomial.edition = 'REVISED';
            image = image+(nfx.FSYNWA()+id+polynomial);
            file = nfx.File(header=base.header)+image;
            t.verifyTrue(file.validate().valid); t.verifyEqual(payload(file,1,'RSMIDA'),id.payload());
            t.verifyEqual(payload(file,1,'RSMPCA'),polynomial.payload());
        end
        function synchronousAndIndexedRangesSelectSnapshots(t)
            [base,image] = fixtureMotion(); a = fixtureRPC(); b = a; b.line_off = 2;
            image = image+a+(nfx.FSYNWA(start_frame_number=2)+b);
            file = nfx.File(header=base.header)+image;
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(payload(file,1,'RPC00B'),a.payload());
            t.verifyEqual(payload(file,2,'RPC00B'),b.payload());
            t.verifyEqual(payload(file,3,'RPC00B'),b.payload());
            b.line_off = 7; t.verifyEqual(payload(file,2,'RPC00B'),image.tre_records(end).payload(30:end));
            selected = nfx.CONTXA(context_type='FR',index_list='1,3')+b;
            file = nfx.File(header=base.header)+(image+selected);
            t.verifyEqual(payload(file,1,'RPC00B'),b.payload());
            t.verifyEqual(payload(file,2,'RPC00B'),image.tre_records(end).payload(30:end));
            t.verifyEqual(payload(file,3,'RPC00B'),b.payload());
        end
        function fileImageScopeAndNestedFrameScope(t)
            [base,image] = fixtureMotion(); rpc = fixtureRPC();
            wrapper = nfx.CONTXA(context_type='IS',index_list='1')+ ...
                (nfx.CONTXA(context_type='FR',index_list='2-')+rpc);
            file = nfx.File(header=base.header)+image+wrapper;
            t.verifyTrue(file.validate().valid); t.verifyEmpty(payload(file,1,'RPC00B'));
            t.verifyEqual(payload(file,2,'RPC00B'),rpc.payload());
            t.verifyError(@() file.effectiveTREs(2,1),'nfx:ContextBounds');
            t.verifyError(@() file.effectiveTREs(1,4),'nfx:ContextBounds');
        end
        function boundsAndPhysicalStartOrderFailBeforeWriting(t)
            [base,image] = fixtureMotion(); rpc = fixtureRPC();
            wrappers = [nfx.FSYNWA(start_frame_number=4)+rpc nfx.FSYNWA(end_frame_number=4)+rpc];
            for k = 1:numel(wrappers)
                file = nfx.File(header=base.header)+(image+wrappers(k)); verifyIssue(t,file,'ContextBounds');
            end
            a = nfx.FSYNWA(start_frame_number=2)+rpc; b = nfx.FSYNWA(start_frame_number=1)+rpc;
            file = nfx.File(header=base.header)+(image+a+b); verifyIssue(t,file,'SynchronousOrder');
            path = fullfile(t.folder,'protected.ntf'); base.write(path); original = readBytes(path);
            t.verifyError(@() file.write(path,Overwrite=true),'nfx:Invalid'); t.verifyEqual(readBytes(path),original);
        end
        function fileOverflowOverridesLaterImageHeader(t)
            [base,image] = fixtureMotion(); a = fixtureRPC(); b = a; b.line_off = 4;
            wrapper = nfx.CONTXA(context_type='IS',index_list='1')+b;
            file = nfx.File(header=base.header)+nfx.FREESA(99974)+wrapper+(image+a);
            t.verifyTrue(file.validate().valid); t.verifyEqual(payload(file,1,'RPC00B'),b.payload());
            path = fullfile(t.folder,'precedence.ntf'); file.write(path); bytes = readBytes(path);
            x = strfind(char(bytes),char(a.bytes())); y = strfind(char(bytes),char(b.bytes()));
            t.verifyGreaterThan(y,x);
            records = file.effectiveTREs(1); model = records(strcmp({records.tag},'RPC00B'));
            t.verifyEqual(model.byte_offset,y-1); t.verifyEqual(model.file_index,0);
        end
        function userAreaPrecedesExtendedAreaForGLASPacking(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile();
            first = fixtureRPC(); second = first; second.line_off = 3;
            image = image+(nfx.FSYNWA()+x)+(nfx.FSYNWA()+first)+nfx.FREESA(97900)+(nfx.FSYNWA()+second);
            file = nfx.File(header=base.header)+image+a+e+s+c;
            path = fullfile(t.folder,'areas.ntf'); file.write(path); bytes = readBytes(path);
            firstOffset = strfind(char(bytes),char(first.bytes())); secondOffset = strfind(char(bytes),char(second.bytes()));
            t.verifyGreaterThan(firstOffset,secondOffset);
            t.verifyEqual(payload(file,1,'RPC00B'),first.payload());
        end
        function asynchronousExclusiveBoundsAndHeaderPrecedence(t)
            [base,image] = fixtureMotion();
            a = nfx.FASYWA(start_timestamp='20260915120000.040000000',end_timestamp='20260915120000.120000000')+nfx.FREESA(2);
            b = nfx.FASYWA(start_timestamp='20260915120000.080000000',end_timestamp='20260915120000.120000000')+nfx.FREESA(3);
            file = nfx.File(header=base.header)+b+(image+a);
            t.verifyTrue(file.validate().valid);
            t.verifyEqual(payload(file,1,'FREESA'),repmat(uint8(255),1,2));
            t.verifyEqual(payload(file,2,'FREESA'),repmat(uint8(255),1,3));
            t.verifyEmpty(payload(file,3,'FREESA'));
            synchronous = nfx.FSYNWA(start_frame_number=2,end_frame_number=2)+nfx.FREESA(4);
            file = nfx.File(header=base.header)+b+(image+a+synchronous);
            t.verifyEqual(payload(file,2,'FREESA'),repmat(uint8(255),1,4));
        end
        function asynchronousOpenEndAndInvalidOrder(t)
            [base,image] = fixtureMotion();
            a = nfx.FASYWA(start_timestamp='20260915120000.080000000',end_timestamp=repmat('-',1,24))+nfx.FREESA(2);
            file = nfx.File(header=base.header)+(image+a);
            t.verifyEmpty(payload(file,1,'FREESA')); t.verifyEqual(payload(file,3,'FREESA'),uint8([255 255]));
            b = nfx.FASYWA(start_timestamp='20260915120000.040000000',end_timestamp=repmat('-',1,24))+nfx.FREESA(1);
            file = nfx.File(header=base.header)+(image+a+b); verifyIssue(t,file,'AsynchronousOrder');
            [base,image] = fixtureFile(); file = nfx.File(header=base.header)+(image+a);
            t.verifyTrue(file.validate().valid);
            % IDATIM has only second precision; subsecond exclusion is unknown.
            t.verifyEqual(payload(file,1,'FREESA'),uint8([255 255]));
        end
        function wrappedRSMCompanionsValidateEachEffectiveSet(t)
            [base,image] = fixtureMotion(); id = fixtureRSMIdentification(); polynomial = fixturePolynomial();
            first = nfx.FSYNWA(end_frame_number=1)+id+polynomial;
            id.edition = 'SECOND'; polynomial.edition = 'SECOND';
            second = nfx.FSYNWA(start_frame_number=2)+id+polynomial;
            file = nfx.File(header=base.header)+(image+first+second); t.verifyTrue(file.validate().valid);
            t.verifyEqual(payload(file,2,'RSMIDA'),id.payload());
            incomplete = nfx.File(header=base.header)+(image+first+(nfx.FSYNWA(start_frame_number=2)+id));
            verifyIssue(t,incomplete,'RSMCompanions');
        end
        function wrappedGLASAssociationsResolvePerFrameGroup(t)
            [base,image,x,a,e,s,c] = fixtureGLASFile('F');
            image.data = repmat(image.data,1,1,1,3); image.header.icat = 'VIS.M';
            [~,~,timing] = fixtureMotion(image.data);
            x.time_stamp_loc = 1; x.base_timestamp = ''; x.number_frames = NaN;
            first = nfx.FSYNWA(end_frame_number=1)+x;
            x.image_uuid = '10000000-0000-4000-8000-000000000088';
            second = nfx.FSYNWA(start_frame_number=2)+x;
            file = nfx.File(header=base.header)+(image+timing+first+second)+a+e+s+c;
            t.verifyTrue(file.validate().valid);
            file.write(fullfile(t.folder,'motion-glas.ntf'));
            x.assoc_des_uuid = {'10000000-0000-4000-8000-000000000099'};
            file = nfx.File(header=base.header)+(image+timing+first+(nfx.FSYNWA(start_frame_number=2)+x))+a+e+s+c;
            verifyIssue(t,file,'GLASMissingDES');
        end
    end
end

function value = payload(file,frame,tag)
    %payload - Select the effective test leaf without parsing implementation data
    records = file.effectiveTREs(1,frame); selected = strcmp({records.tag},tag);
    value = [records(selected).payload];
end

function verifyIssue(t,file,id)
    %verifyIssue - Require the expected structured validation failure
    report = file.validate(); t.verifyFalse(report.valid); t.verifyTrue(any(strcmp({report.issues.id},id)),id);
end
