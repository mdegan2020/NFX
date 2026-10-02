function [value, reader] = readUTF8Field(reader, countWidth) %#codegen
    [count, reader] = reader.count(countWidth, 1, 10^countWidth - 1);
    [raw, reader] = reader.take(count);
    [value, valid] = decodeUTF8(raw);
    if reader.ok && ~valid
        reader = reader.fail('InvalidText', 'Invalid UTF-8 field.');
    end
end
