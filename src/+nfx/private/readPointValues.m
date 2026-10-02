function [values, reader] = readPointValues(reader, definitions) %#codegen
    values = struct('value', {});
    for k = 1:numel(definitions)
        [word, reader] = reader.text(definitions(k).att_len, false);
        if ~reader.ok, return; end
        values(end + 1) = struct('value', word);
    end
end
