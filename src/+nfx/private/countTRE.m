function [count, ok, status] = countTRE(records, tag) %#codegen
    %countTRE - Count logical direct attachments of an optional concrete tag
    count = 0;
    ok = false;
    status = decodeStatus('InvalidSelector', ...
        'Supply an ASCII TRE tag of at most six characters.');
    if ~(ischar(tag) && (isrow(tag) || isempty(tag))) && ...
            ~(isstring(tag) && isscalar(tag) && ~ismissing(tag))
        return
    end
    word = strtrim(char(tag));
    if numel(word) > 6 || any(word < ' ' | word > '~')
        return
    end
    if ~isempty(word)
        word = [word repmat(' ', 1, 6 - numel(word))];
        records = records(strcmp({records.tag}, word));
    end
    count = numel(unique([records.id]));
    ok = true;
    status = decodeStatus();
end
