classdef SensorDESHeaderTest < NfxTest
    methods (Test)
        function commonHeaderBytesAndAssociationOrder(t)
            value = fixtureCSATTB(); value.aisdlvl = [3 1 2];
            value.assoc_elem_uuid = {'10000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000001'};
            header = value.subheader(); expected = uint8(['20000000-0000-4000-8000-000000000001003003001002002' ...
                '10000000-0000-4000-8000-00000000000310000000-0000-4000-8000-0000000000010000']);
            t.verifyEqual(header.desshf,expected); t.verifyEqual(header.desid,'CSATTB');
            t.verifyEqual(header.desver,2); t.verifyEqual(header.desshl,127); t.verifyEqual(header.ldsh,327);
            value.aisdlvl = []; value.all_images = true; value.assoc_elem_uuid = {};
            header = value.subheader(); t.verifyEqual(char(header.desshf), ...
                '20000000-0000-4000-8000-000000000001ALL0000000');
            t.verifyEqual(header.desshl,46); t.verifyEqual(header.ldsh,246);
        end
        function explicitAndAllImageAssociationsAreExclusive(t)
            value = fixtureCSATTB(); value.all_images = true; t.verifyFalse(value.validate().valid);
            value.aisdlvl = []; t.verifyTrue(value.validate().valid); value.all_images = false;
            t.verifyFalse(value.validate().valid); value.aisdlvl = 1:998; t.verifyTrue(value.validate().valid);
            value.aisdlvl = 1:999; t.verifyFalse(value.validate().valid);
            value.aisdlvl = [1 1]; t.verifyFalse(value.validate().valid);
        end
        function uuidClassificationVersionAndAssociationSyntax(t)
            value = fixtureCSATTB(); value.uuid = 'bad'; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.desclas = 'S'; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.desver = NaN; t.verifyFalse(value.validate().valid);
            value = fixtureCSATTB(); value.assoc_elem_uuid = {'bad'}; t.verifyFalse(value.validate().valid);
            id = 'a0000000-0000-4000-8000-000000000001'; value.assoc_elem_uuid = {id,upper(id)};
            t.verifyFalse(value.validate().valid);
            value.assoc_elem_uuid = repmat({id},1,277); t.verifyFalse(value.validate().valid);
        end
        function aggregateSubheaderLimitAppliesBeforeFieldCounts(t)
            value = fixtureCSATTB(); value.aisdlvl = 1:10; ids = cell(1,270);
            for k = 1:270, ids{k} = sprintf('10000000-0000-4000-8000-%012.0f',k); end
            value.assoc_elem_uuid = ids; t.verifyEqual(value.subheader().ldsh,9996);
            value.aisdlvl = 1:11; t.verifyFalse(value.validate().valid);
            value.aisdlvl = []; value.all_images = true;
            value.assoc_elem_uuid{271} = '10000000-0000-4000-8000-000000000271';
            t.verifyFalse(value.validate().valid);
        end
        function commonPropertiesRejectConversionsAndWrongShapes(t)
            t.verifyError(@() nfx.CSATTB(aisdlvl=uint16(1)),'nfx:SensorLevels');
            t.verifyError(@() nfx.CSATTB(aisdlvl=[1;2]),'nfx:SensorLevels');
            t.verifyError(@() nfx.CSATTB(aisdlvl=NaN),'nfx:SensorLevels');
            t.verifyError(@() nfx.CSATTB(aisdlvl=0),'nfx:SensorLevels');
            t.verifyError(@() nfx.CSATTB(all_images=1),'nfx:LogicalScalar');
            t.verifyError(@() nfx.CSATTB(assoc_elem_uuid='uuid'),'nfx:SensorUUIDs');
        end
    end
end
