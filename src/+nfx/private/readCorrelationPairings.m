function [items, reader] = readCorrelationPairings(reader) %#codegen
    %readCorrelationPairings - Restore conditional ordered sensor pairings
    items = nfx.CorrelationPairing.empty(1, 0);
    [flag, reader] = reader.number(1, 0, 1, true);
    if ~reader.ok || flag == 0, return, end
    [count, reader] = reader.count(2, 10, 99);
    for k = 1:count
        [id, reader] = reader.number(2, 1, 99, true);
        [sensorCount, reader] = reader.count(2, 6, 99);
        names = cell(1, sensorCount);
        for j = 1:sensorCount, [names{j}, reader] = reader.text(6); end
        if ~reader.ok, break, end
        items(end + 1) = nfx.CorrelationPairing(spdcf_id=id, sensor_id=names);
    end
end
