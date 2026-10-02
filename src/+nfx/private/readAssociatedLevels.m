function [levels, allImages, reader] = readAssociatedLevels(reader) %#codegen
    levels = zeros(1, 0); allImages = false;
    [word, reader] = reader.text(3, false);
    if ~reader.ok, return; end
    if strcmp(word, 'ALL')
        allImages = true;
    elseif all(word >= '0' & word <= '9') && str2double(word) <= 998
        [levels, reader] = reader.numbers(str2double(word), 3, 1, 999, true);
    else
        reader = reader.fail('InvalidField', 'NUMAIS must be ALL or 000..998.');
    end
end
