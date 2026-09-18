function valid = validCloudSensor(value, multiple, displayLevel) %#codegen
    %validCloudSensor - Check Appendix AV sensor codes and local references
    value = strtrim(char(value));
    if displayLevel && numel(value) == 3 && ...
            all(value >= '0' & value <= '9')
        valid = str2double(value) >= 1 && str2double(value) <= 999;
        return
    end
    valid = ~isempty(value);
    if ~valid, return; end
    cuts = [0 find(value == ',') numel(value) + 1];
    if ~multiple && numel(cuts) ~= 2
        valid = false;
        return
    end
    codes = {'CAVIS', 'EO', 'EOVIS', 'HS', 'IR', 'LWIR', 'MS', ...
        'MWIR', 'NIR', 'PAN', 'SWIR', 'VNIR'};
    for k = 1:numel(cuts) - 1
        token = strtrim(value(cuts(k) + 1:cuts(k + 1) - 1));
        if numel(token) > 2 && strcmp(token(end - 1:end), '.M')
            token = token(1:end - 2);
        end
        valid = valid && any(strcmp(token, codes));
    end
end
