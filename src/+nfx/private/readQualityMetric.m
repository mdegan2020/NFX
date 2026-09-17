function [obj, reader] = readQualityMetric(reader) %#codegen
    %readQualityMetric - Decode bounded QualityMetric fields without exceptions
    obj = nfx.QualityMetric();
    [value, reader] = reader.sizedText(2, 25);
    if reader.ok
        obj.quality_metric_name = value;
    end
    [unit, kind, lower, upper, exclusive, known] = ...
        exploitationDefinition(obj.quality_metric_name, true);
    [width, reader] = reader.count(2, 1, 99);
    [rawUnit, reader] = reader.text(width, false, true);
    if reader.ok && (~known || ~strcmp(unit, rawUnit))
        reader = reader.fail('InvalidField', ...
            'Unknown exploitation name or mismatched units.');
    end
    [value, reader] = reader.text(1, true, false);
    if reader.ok
        obj.quality_metric_type = value;
    end
    [width, reader] = reader.count(2, 1, 21);
    if kind == 'T'
        [value, reader] = reader.text(width, false);
        if reader.ok
            obj.quality_metric_value = value;
        end
    else
        [number, reader] = reader.number(width, lower, upper);
        if reader.ok && exclusive && number <= lower
            reader = reader.fail('InvalidNumber', ...
                'The exploitation value must exceed its lower bound.');
        end
        if reader.ok
            obj.quality_metric_value = number;
        end
    end
end
