function [obj, reader] = readCollectionCriterion(reader) %#codegen
    %readCollectionCriterion - Decode bounded CollectionCriterion fields without exceptions
    obj = nfx.CollectionCriterion();
    [value, reader] = reader.sizedText(2, 25);
    if reader.ok
        obj.collect_criteria_name = value;
    end
    [unit, kind, lower, upper, exclusive, known] = ...
        exploitationDefinition(obj.collect_criteria_name, false);
    [width, reader] = reader.count(2, 1, 99);
    [rawUnit, reader] = reader.text(width, false, true);
    if reader.ok && (~known || ~strcmp(unit, rawUnit))
        reader = reader.fail('InvalidField', ...
            'Unknown exploitation name or mismatched units.');
    end
    [width, reader] = reader.count(2, 1, 21);
    if kind == 'T'
        [value, reader] = reader.text(width, false);
        if reader.ok
            obj.collect_criteria_value = value;
        end
    else
        [number, reader] = reader.number(width, lower, upper);
        if reader.ok && exclusive && number <= lower
            reader = reader.fail('InvalidNumber', ...
                'The exploitation value must exceed its lower bound.');
        end
        if reader.ok
            obj.collect_criteria_value = number;
        end
    end
end
