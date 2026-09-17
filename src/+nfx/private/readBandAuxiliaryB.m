function [groups, reader] = readBandAuxiliaryB( ...
        reader, count, bands) %#codegen
    %readBandAuxiliaryB - Decode typed auxiliary values
    item = struct('bapf', '', 'ubap', '', ...
        'apn', [], 'apr', [], 'apa', '');
    groups = repmat(item, 1, count);
    for k = 1:count
        [format, reader] = reader.choice('IRA');
        [groups(k).ubap, reader] = reader.text(7);
        groups(k).bapf = format;
        switch format
            case 'I'
                [groups(k).apn, reader] = reader.numbers( ...
                    bands, 10, -999999999, 9999999999, true);
            case 'R'
                [groups(k).apr, reader] = reader.float32(bands, -1e38, 1e38);
            case 'A'
                [groups(k).apa, reader] = reader.textRows(20, bands, false);
        end
    end
end
