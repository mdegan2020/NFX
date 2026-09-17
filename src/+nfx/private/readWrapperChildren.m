function [records, reader] = readWrapperChildren(tag, payload) %#codegen
    %readWrapperChildren - Check nested prefixes before scope inspection
    reader = nfx.internal.TREReader(payload);
    switch tag
        case 'FSYNWA'
            [first, reader] = reader.number(9, 1, 999999999, true);
            [last, reader] = reader.number(9, 0, 999999999, true);
            if reader.ok
                encoded = [decimalField(first, 9, 0, false) ...
                    decimalField(last, 9, 0, false)];
                valid = (last == 0 || last >= first) && ...
                    isequal(encoded, payload(1:18));
                if ~valid
                    reader = reader.fail('InvalidField', ...
                        'Invalid nested frame range.');
                end
            end
        case 'FASYWA'
            [first, reader] = reader.text(24, false);
            [last, reader] = reader.text(24, false);
            if reader.ok
                open = all(last == '-');
                valid = validMieTimestamp(first) && ...
                    (validMieTimestamp(last) || open);
                if valid && ~open
                    valid = ~mieTimeEarlier(last, first);
                end
                if ~valid
                    reader = reader.fail('InvalidField', ...
                        'Invalid nested timestamp interval.');
                end
            end
        case 'CONTXA'
            [context, reader] = reader.text(2, false);
            [mode, reader] = reader.choice('IA');
            [width, reader] = reader.count(4, 1, 9999);
            [indices, reader] = reader.text(width, false);
            if reader.ok
                [valid, ~] = contextIndices(indices, context);
                valid = valid && any(strcmp(context, ...
                    {'IS', 'FR', 'FH', 'CS', 'CM', 'TI', 'TB'})) && ...
                    (~strcmp(context, 'IS') || strcmp(mode, 'I'));
                valid = valid && isequal(payload(4:7), ...
                    decimalField(width, 4, 0, false));
                if ~valid
                    reader = reader.fail('InvalidField', ...
                        'Invalid nested context definition.');
                end
            end
        otherwise
            reader = reader.fail('UnsupportedTRE', 'Unknown wrapper type.');
    end
    [records, reader] = readWrappedRecords(reader);
    if reader.ok && isempty(records)
        reader = reader.fail('InvalidPayload', ...
            'A wrapper must contain at least one TRE.');
    end
    maximum = 99956;
    if strcmp(tag, 'FASYWA')
        maximum = 99926;
    end
    for k = 1:numel(records)
        if numel(records(k).payload) > maximum
            reader = reader.fail('InvalidPayload', ...
                'A nested child exceeds its wrapper field limit.');
        end
    end
end
