function result = nfxCoderGroups(count) %#codegen
    %nfxCoderGroups - Probe continuation groups, wrappers and value snapshots
    assert(count >= 0 && count <= 10001 && fix(count) == count);
    sensor = nfx.SENSRB(sensor='SYNTHETIC', platform='TEST', ...
        operation_domain='Airborne', start_date='20260917', end_date='20260917', ...
        start_time=43200, end_time=43201, reference_time=0, ...
        latitude_or_x=40, longitude_or_y=-105, altitude_or_z=1000);
    if count > 0
        sensor.time_stamped_data = nfx.SENSRB.timeSeries('06a', 0:count - 1, ...
            repmat(40, 1, count));
    end
    image = nfx.ImageSegment(uint8(1)) + sensor;
    [copy, ok] = image.SENSRB();
    values = zeros(1, count); times = zeros(1, count); at = 1;
    for k = 1:numel(copy.time_stamped_data)
        number = numel(copy.time_stamped_data(k).time_stamp_time);
        values(at:at + number - 1) = copy.time_stamped_data(k).time_stamp_value.numeric;
        times(at:at + number - 1) = copy.time_stamped_data(k).time_stamp_time;
        at = at + number;
    end
    assert(at == count + 1);
    wrapper = nfx.FSYNWA() + nfx.FREESA(251);
    [decoded, wrapped] = nfx.FSYNWA.deserialize(wrapper.payload());
    free = decoded.FREESA(); free.count = 1;
    reduced = image.removeTRE(image.tre_ids(1));
    result = struct('ok', ok && wrapped, 'values', values, 'times', times, ...
        'split', numel(image.tre_records) > 1, ...
        'wrapperCount', decoded.FREESA().count, ...
        'independent', free.count ~= decoded.FREESA().count, ...
        'removed', reduced.treCount('SENSRB') == 0);
end
