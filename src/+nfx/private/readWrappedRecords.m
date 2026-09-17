function [records, reader] = readWrappedRecords(reader) %#codegen
    %readWrappedRecords - Restore envelope boundaries and local identities
    records = repmat(struct('tag', '      ', ...
        'payload', zeros(1, 0, 'uint8'), 'id', 0), 1, 0);
    identity = 0;
    while reader.ok && reader.position <= numel(reader.data)
        [tag, reader] = reader.text(6, false);
        lengthAt = reader.position;
        [count, reader] = reader.count(5, 1, 99985);
        if reader.ok && ~isequal(reader.data(lengthAt:lengthAt + 4), ...
                decimalField(count, 5, 0, false))
            reader = reader.fail('NoncanonicalPayload', ...
                'A wrapped TRE length must contain exactly five digits.');
        end
        if reader.ok && count == 0
            reader = reader.fail('InvalidPayload', ...
                'A wrapped TRE must have a nonempty payload.');
        end
        [payload, reader] = reader.take(count);
        if ~reader.ok
            return
        end
        continuation = strcmp(tag, 'SENSRB') && payload(1) == 'N';
        if continuation
            if isempty(records) || ~strcmp(records(end).tag, 'SENSRB')
                reader = reader.fail('InvalidContinuation', ...
                    'A SENSRB continuation must follow its first instance.');
                return
            end
        else
            identity = identity + 1;
        end
        records(end + 1) = struct('tag', tag, ...
            'payload', payload, 'id', identity);
    end
end
