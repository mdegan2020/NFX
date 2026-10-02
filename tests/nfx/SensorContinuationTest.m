classdef SensorContinuationTest < NfxTest
    methods (Test)
        function boundaryUsesActualPairWidth(t)
            value = fixtureSensor(); times = 0:4332;
            value.time_stamped_data = nfx.SENSRB.timeSeries('06a',times,40+times*1e-7);
            records = value.physicalRecords(); t.verifyEqual(numel(records),1);
            t.verifyEqual(numel(records.payload),99975);
            value.time_stamped_data = nfx.SENSRB.timeSeries('06a',0:4333,40+(0:4333)*1e-7);
            records = value.physicalRecords(); t.verifyEqual(numel(records),2);
            first = inspectSENSRB(records(1).payload); second = inspectSENSRB(records(2).payload);
            t.verifyEqual(numel(records(1).payload),99975); t.verifyEqual(numel(records(2).payload),136);
            t.verifyEqual(first.series.time,0:4332); t.verifyEqual(second.series.time,4333);
            t.verifyEqual(second.flags,'NNNNYYNNNN');
            t.verifyEqual(second.fields,rmfield(first.fields,{}));
            t.verifyError(@() value.payload(),'nfx:MultipleTREs');
            t.verifyError(@() value.bytes(),'nfx:MultipleTREs');
            t.verifyError(@() lengthOf(value),'nfx:MultipleTREs');
        end
        function moreThanInnerCounterAndDuplicateTimesSurvive(t)
            value = fixtureSensor(); time = [0:5999 5000 6001:12999];
            values = mod(1:13000,2)+1;
            value.time_stamped_data = nfx.SENSRB.timeSeries('07a',time,values);
            records = value.physicalRecords(); t.verifyEqual(numel(records),2);
            allTime = []; allValue = [];
            for k = 1:numel(records)
                out = inspectSENSRB(records(k).payload);
                for j = 1:numel(out.series)
                    t.verifyLessThanOrEqual(numel(out.series(j).time),9999);
                    allTime = [allTime out.series(j).time]; %#ok<AGROW>
                    allValue = [allValue str2double(string(out.series(j).value)).']; %#ok<AGROW>
                end
            end
            t.verifyEqual(allTime,time); t.verifyEqual(allValue,values);
        end
        function moreThanOuterCounterSplitsAndKeepsGroupOrder(t)
            value = fixtureSensor(); group = nfx.SENSRB.timeSeries('10a',0,50);
            value.time_stamped_data = repmat(group,1,101);
            for k = 1:101, value.time_stamped_data(k).time_stamp_time = k; end
            records = value.physicalRecords(); t.verifyEqual(numel(records),2);
            first = inspectSENSRB(records(1).payload); second = inspectSENSRB(records(2).payload);
            t.verifyEqual(numel(first.series),99); t.verifyEqual(numel(second.series),2);
            t.verifyEqual([first.series.time second.series.time],1:101);
        end
        function firstInstanceCanContainOnlyStaticMetadata(t)
            value = fixtureSensor();
            % 309 + (32 + 999*99) + (32 + 1*711) = 99985.
            value.additional_parameter_data = [nfx.SENSRB.additionalParameter('BIG',repmat('A',99,999),999) ...
                nfx.SENSRB.additionalParameter('TAIL',repmat('B',1,711),711)];
            value.time_stamped_data = nfx.SENSRB.timeSeries('06a',0,40);
            records = value.physicalRecords(); t.verifyEqual(numel(records),2);
            t.verifyEqual(numel(records(1).payload),99985);
            first = inspectSENSRB(records(1).payload); second = inspectSENSRB(records(2).payload);
            t.verifyEmpty(first.series); t.verifyEmpty(second.additional);
            t.verifyEqual(second.series.time,0);
            value.additional_parameter_data(2) = nfx.SENSRB.additionalParameter('TAIL',repmat('B',1,712),712);
            t.verifyFalse(value.validate().valid); t.verifyError(@() value.physicalRecords(),'nfx:Invalid');
        end
        function uncertaintiesCannotReferToMovedSamples(t)
            value = fixtureSensor(); value.time_stamped_data = nfx.SENSRB.timeSeries('06a',0:4999,repmat(40,1,5000));
            value.uncertainty_data = nfx.SENSRB.uncertainty('12d1.1',0.5);
            t.verifyTrue(value.validate().valid);
            records = value.physicalRecords(); out = inspectSENSRB(records(1).payload);
            t.verifyEqual(strtrim(out.uncertainties.first),'12d1.1');
            value.uncertainty_data = nfx.SENSRB.uncertainty('12d1.5000',0.5);
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'ContinuationUncertainty')));
        end
        function snapshotsRemovalOverflowAndReaderRoundTrip(t)
            [base,image] = fixtureFile(uint16([1 1024;4095 65535]));
            value = fixtureSensor(); value.time_stamped_data = nfx.SENSRB.timeSeries('10a',0:9999,1:10000);
            image = image.removeTRE(1)+nfx.FREESA(1)+value+nfx.FREESA(2);
            t.verifyEqual(image.tre_ids,[2 3 4]); t.verifyEqual([image.tre_records.id],[2 3 3 3 4]);
            value.time_stamped_data(1).time_stamp_value.numeric(1) = 99;
            file = nfx.File(header=base.header)+image;
            path = fullfile(t.folder,'sensor-overflow.ntf'); file.write(path);
            out = inspectContainer(path); t.verifyEqual(numel(out.des),1);
            t.verifyEqual({out.images(1).allTRE.tag},{'FREESA','SENSRB','SENSRB','SENSRB','FREESA'});
            first = inspectSENSRB(out.images(1).allTRE(2).payload);
            t.verifyEqual(str2double(first.series.value(1,:)),1);
            t.verifyEqual(nitfread(path),image.data);
            reduced = image.removeTRE(3); t.verifyEqual(reduced.tre_tags,['FREESA';'FREESA']);
            t.verifyEqual(reduced.tre_ids,[2 4]);
            t.verifyError(@() base+value,'nfx:TREPlacement');
            t.verifyError(@() fixtureText()+value,'nfx:TREPlacement');
        end
        function wrappersRetainLogicalSnapshotAndRejectOversize(t)
            small = fixtureSensor(); wrapper = nfx.FSYNWA(start_frame=1,end_frame=1)+small;
            t.verifyTrue(wrapper.validate().valid);
            large = small; large.time_stamped_data = nfx.SENSRB.timeSeries('06a',0:4999,repmat(40,1,5000));
            wrapper = nfx.FSYNWA(start_frame=1,end_frame=1)+large;
            t.verifyEqual(wrapper.tre_ids,1); t.verifyEqual(numel(wrapper.tre_records),2);
            t.verifyFalse(wrapper.validate().valid);
            wrapper = wrapper.removeTRE(1); t.verifyEmpty(wrapper.tre_records);
        end
        function conflictingReferenceStateRepeatIsRejected(t)
            value = fixtureSensor();
            value.time_stamped_data = [nfx.SENSRB.timeSeries('06a',0,41) ...
                nfx.SENSRB.timeSeries('10a',0:5999,1:6000)];
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'ContinuationReferenceConflict')));
            value.time_stamped_data(1).time_stamp_value.numeric = 40;
            t.verifyTrue(value.validate().valid);
            value.time_stamped_data(1).time_stamp_time = 1;
            value.time_stamped_data(1).time_stamp_value.numeric = 41;
            t.verifyTrue(value.validate().valid);
        end
        function currentSeriesKeepsBaselineNominal(t)
            value = fixtureSensor(); value.time_stamped_data = nfx.SENSRB.timeSeries('06a',0:4999,repmat(41,1,5000));
            t.verifyTrue(value.validate().valid);
            value.time_stamped_data(1).time_stamp_time(1:3) = 0;
            value.time_stamped_data(1).time_stamp_value.numeric(1:3) = [42 43 40];
            value.time_stamped_data(2) = nfx.SENSRB.timeSeries('10a',0:5999,1:6000);
            t.verifyTrue(value.validate().valid);
        end
        function pixelReferenceHasPriorityAndDetectsConflicts(t)
            value = fixtureSensor(); value.reference_row = 1; value.reference_column = 2;
            value.pixel_referenced_data = nfx.SENSRB.pixelSeries('06a',1,2,41);
            value.time_stamped_data = nfx.SENSRB.timeSeries('10a',0:5999,1:6000);
            report = value.validate(); t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'ContinuationReferenceConflict')));
            value.reference_row = -1; value.pixel_referenced_data.pixel_reference_row = -1;
            t.verifyFalse(value.validate().valid);
            value.pixel_referenced_data.pixel_reference_value.numeric = 40;
            value.time_stamped_data(2) = nfx.SENSRB.timeSeries('06a',0,41);
            t.verifyTrue(value.validate().valid);
            value.pixel_referenced_data.pixel_reference_row = 3;
            value.pixel_referenced_data.pixel_reference_value.numeric = 42;
            t.verifyTrue(value.validate().valid);
        end
    end
end

function value = lengthOf(tre)
    value = tre.cel;
end
