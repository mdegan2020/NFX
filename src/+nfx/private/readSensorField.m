function [number, word, reader] = readSensorField( ...
        reader, index, geo, angle, dynamic) %#codegen
    %readSensorField - Decode the explicit numeric/text field union
    number = NaN;
    word = '';
    info = sensFieldInfo(index, geo, angle);
    if ~reader.ok
        return
    end
    if ~info.valid
        reader = reader.fail('InvalidField', 'Unknown sensor field index.');
        return
    end
    first = reader.position;
    if any(info.format == 'AD')
        [word, reader] = reader.text(info.width);
        if ~isempty(word) && all(word == '-')
            word = '';
        end
        if reader.ok
            [encoded, valid] = sensField( ...
                [], word, index, geo, angle, dynamic);
        end
    else
        [number, reader] = reader.dashed( ...
            info.width, info.lower, info.upper);
        if reader.ok
            [encoded, valid] = sensField( ...
                number, '', index, geo, angle, dynamic);
        end
    end
    if reader.ok && (~valid || ~isequal(encoded, ...
            reader.data(first:reader.position - 1)))
        reader = reader.fail('InvalidField', ...
            'The sensor field has invalid syntax, range or encoding.');
    end
end
