function [obj, reader] = readSensorErrorCore(reader) %#codegen
    %readSensorErrorCore - Decode bounded supplied sensor error metadata
    obj = nfx.SensorErrorCore();
    [value, reader] = reader.number(1, 1, 6, true);
    if reader.ok, obj.ref_frame_position = value; end
    [value, reader] = reader.number(1, 1, 6, true);
    if reader.ok, obj.ref_frame_attitude = value; end
    [count, reader] = reader.count(1, 28, 7);
    for k = 1:count
        [group, reader] = readSensorErrorGroup(reader);
        if ~reader.ok, break, end
        obj.groups(end + 1) = group;
    end
end
