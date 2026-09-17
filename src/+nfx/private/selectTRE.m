function [selected, ok, status] = selectTRE( ...
        records, tag, index, id) %#codegen
    %selectTRE - Select one logical attachment by occurrence or stable ID
    selected = records([]);
    ok = false;
    status = decodeStatus('InvalidSelector', ...
        'Use a positive occurrence index or one nonnegative attachment ID.');
    if ~validIndex(index, 1) || ...
            ~(isa(id, 'double') && isreal(id) && isempty(id)) && ...
            ~validIndex(id, 0)
        return
    end
    if ~isempty(id) && index ~= 1
        status.message = 'Specify an occurrence index or ID, not both.';
        return
    end
    if isempty(tag)
        matching = records;
    else
        matching = records(strcmp({records.tag}, tag));
    end
    if isempty(id)
        ids = unique([matching.id], 'stable');
        if index <= numel(ids)
            selected = matching([matching.id] == ids(index));
        end
    else
        selected = matching([matching.id] == id);
    end
    ok = ~isempty(selected);
    if ok
        status = decodeStatus();
    else
        status = decodeStatus('NotFound', ...
            'No matching logical TRE attachment exists.');
    end
end

function valid = validIndex(value, lower) %#codegen
    %validIndex - Reject coercion, non-scalars and inexact identities
    valid = isa(value, 'double') && isscalar(value) && ...
        isreal(value) && ~issparse(value) && isfinite(value) && ...
        value >= lower && value < flintmax && fix(value) == value;
end
