function valid = validQualityCondition(value) %#codegen
    %validQualityCondition - Apply the published case-sensitive token order
    spatial = {'Cluster_', 'Isolated_'};
    temporal = {'Static_', 'Dynamic_'};
    original = value;
    for k = 1:numel(spatial)
        if startsWith(value, spatial{k})
            value = value(numel(spatial{k}) + 1:end);
            break
        end
    end
    for k = 1:numel(temporal)
        if startsWith(value, temporal{k})
            value = value(numel(temporal{k}) + 1:end);
            break
        end
    end
    valid = any(strcmp(value, {'Bad', 'Saturated', 'Dead', 'Noisy', ...
        'Vignetted', 'Fill', 'Gap', 'Spurious-response', 'Missing', ...
        'Blinker', 'Failed', 'Repaired', 'Interpolated', 'Averaged', ...
        'Calibration-update'}));
    if ~valid && strcmp(original, value) && startsWith(value, 'FPA ')
        digits = value(5:end);
        valid = ~isempty(digits) && all(digits >= '0' & digits <= '9') && ...
            str2double(digits) >= 1;
    end
end
