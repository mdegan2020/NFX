classdef HistoryTest < NfxTest
    properties (TestParameter)
        invalidPC = {'NONE','000000000000','NONE0000DC13','XXXX00000000','OTLO00000000'}
        invalidBWC = {'NONE      ','NONEC00000','0000000000','DC13X00000','DC13E0000X'}
        precisionIndex = {1,2,3,4,5}
    end
    methods (Test)
        function roundingCannotCrossAnyProcessingFieldMaximum(t,precisionIndex)
            event = fullHistoryEvent();
            t.verifyTrue(event.validate().valid);
            event.decimal_places(precisionIndex) = 1;
            t.verifyFalse(event.validate().valid);
            t.verifyError(@() event.bytes(),'nfx:Invalid');
        end
        function minimalEventAndHeaderHaveLiteralBytes(t)
            event = fixtureHistoryEvent();
            expected = '20260915120100NFXTEST   NFX       009INTNONE000000 0 00000009INTNONE000000';
            t.verifyEqual(event.byte_count,74);
            t.verifyEqual(event.bytes(),uint8(expected));
            value = nfx.HISTOA(systype='TBD',pc='NONE00000000',pe='NONE',event=event);
            t.verifyEqual(value.cel,115);
            t.verifyEqual(value.payload(),uint8(['TBD' repmat(' ',1,17) 'NONE00000000NONE 0001' expected]));
        end
        function fullEventHasAllConditionalFieldsInOrder(t)
            event = fullHistoryEvent();
            encoded = event.bytes();
            t.verifyEqual(event.nipcom,9);
            t.verifyEqual(event.byte_count,843);
            t.verifyEqual(encoded(36:755),repmat(uint8('X'),1,720));
            t.verifyEqual(char(encoded(771:843)), ...
                '31359.9999199.999999.9999119999199.99991999.999-999919999109INTNONE000000');
            history = nfx.HISTOA(systype='TBD',event=repmat(event,1,99));
            t.verifyEqual(history.nevents,99);
            t.verifyEqual(history.cel,83498);
            history.event(100) = event;
            t.verifyFalse(history.validate().valid);
        end
        function conditionalParametersCannotBeSilentlyDiscarded(t)
            event = fixtureHistoryEvent();
            event.rot_flag = 1;
            t.verifyFalse(event.validate().valid);
            event.rot_angle = 15;
            t.verifyTrue(event.validate().valid);
            event.rot_flag = 0;
            t.verifyFalse(event.validate().valid);
            event.rot_angle = NaN;
            event.dra_flag = 2;
            t.verifyTrue(event.validate().valid);
            t.verifyEqual(numel(event.bytes()),74);
            event.dra_sub = 0;
            t.verifyFalse(event.validate().valid);
        end
        function declaredDecimalPrecisionControlsTheField(t)
            event = fixtureHistoryEvent();
            event.rot_flag = 1; event.rot_angle = 15.4;
            event.decimal_places = [2 4 4 4 3];
            encoded = event.bytes();
            t.verifyEqual(char(encoded(53:60)),'00015.40');
            event.decimal_places = [6 4 4 4 3];
            t.verifyFalse(event.validate().valid);
            t.verifyError(@() nfx.HistoryEvent(decimal_places=single([2 4 4 4 3])),'nfx:DecimalPrecision');
        end
        function projectionAndCustomProcessingRequireAnExplanation(t)
            event = fixtureHistoryEvent();
            event.proj_flag = 1;
            t.verifyFalse(event.validate().valid);
            event.ipcom = ' ';
            t.verifyFalse(event.validate().valid);
            event.ipcom = "Supplied projection method";
            t.verifyTrue(event.validate().valid);
            event.proj_flag = 0; event.ipcom = '';
            event.sharp_flag = 1; event.sharpfam = -1; event.sharpmem = -1;
            t.verifyFalse(event.validate().valid);
            event.ipcom = 'Custom supplied kernel';
            t.verifyTrue(event.validate().valid);
            encoded = event.bytes();
            t.verifyEqual(char(encoded(136:139)),'-1-1');
        end
        function unknownCompressionRequiresComments(t)
            event = fixtureHistoryEvent();
            event.inbwc = 'OTLOC00000';
            t.verifyFalse(event.validate().valid);
            event.ipcom = 'Supplied unknown lossy compression history';
            t.verifyTrue(event.validate().valid);
            event.outbwc = 'J2NLCJ2NLE';
            t.verifyTrue(event.validate().valid);
        end
        function historyRejectsInvalidCompressionGrammar(t,invalidPC)
            value = nfx.HISTOA(systype='TBD',pc=invalidPC,event=fixtureHistoryEvent());
            t.verifyFalse(value.validate().valid);
        end
        function eventRejectsInvalidCompressionGrammar(t,invalidBWC)
            event = fixtureHistoryEvent(); event.inbwc = invalidBWC;
            t.verifyFalse(event.validate().valid);
        end
        function historyMaintainsOrderAndPixelRepresentationContinuity(t)
            first = fixtureHistoryEvent(); second = first;
            second.pdate = '20260915120101';
            value = nfx.HISTOA(systype='TBD',event=[first second]);
            t.verifyTrue(value.validate().valid);
            value.event = [second first];
            t.verifyFalse(value.validate().valid);
            value.event = [first second];
            value.event(2).ibpp = 10;
            t.verifyFalse(value.validate().valid);
            value.event(1).obpp = 10;
            t.verifyTrue(value.validate().valid);
        end
        function pixelTypeLimitsAndHistoryCodeValidation(t)
            event = fixtureHistoryEvent();
            event.ibpp = 17;
            t.verifyFalse(event.validate().valid);
            event.ipvtype = 'R'; event.ibpp = 32;
            t.verifyTrue(event.validate().valid);
            value = nfx.HISTOA(systype='WV03GA',event=event);
            t.verifyTrue(value.validate().valid);
            value.lutid = 9;
            t.verifyFalse(value.validate().valid);
            value.lutid = 11; value.pe = 'XXXX';
            t.verifyFalse(value.validate().valid);
            value.pe = 'ORTH'; value.systype = 'BOGUS';
            t.verifyFalse(value.validate().valid);
            t.verifyFalse(nfx.HISTOA().validate().valid);
            t.verifyFalse(nfx.HistoryEvent().validate().valid);
            t.verifyError(@() nfx.HISTOA(event=struct()),'nfx:HistoryEvents');
            t.verifyError(@() nfx.HistoryEvent(ipcom=repmat('X',10,80)),'nfx:Comments');
        end
        function fileRetainsHistorySnapshot(t)
            [file,image] = fixtureFile();
            value = nfx.HISTOA(systype='TBD',event=fixtureHistoryEvent());
            image = image+value;
            original = value.payload();
            value.event.ipcom = 'Later change';
            file = nfx.File(header=file.header)+image;
            name = fullfile(t.folder,'history.ntf'); file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.images(1).allTRE(2).tag,'HISTOA');
            t.verifyEqual(parsed.images(1).allTRE(2).payload,original);
            t.verifyError(@() plus(file,value),'nfx:TREPlacement');
        end
    end
end
