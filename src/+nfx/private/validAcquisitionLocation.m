function valid = validAcquisitionLocation(value,kind) %#codegen
    %validAcquisitionLocation - Check the AIMIDB and ACFTB coordinate text forms
    value = char(value);
    valid = isempty(strtrim(value));
    if valid, return; end
    if strcmp(kind,'minute')
        if numel(value) ~= 11 || ~any(value(5) == 'NS') || ~any(value(11) == 'EW'), return; end
        numbers = value([1:4 6:10]);
        valid = all(numbers >= '0' & numbers <= '9') && str2double(value(1:2)) <= 89 && ...
            str2double(value(3:4)) <= 59 && str2double(value(6:8)) <= 179 && str2double(value(9:10)) <= 59;
    else
        if numel(value) ~= 25, return; end
        if any(value(1) == '+-')
            if ~any(value(13) == '+-') || value(4) ~= '.' || value(17) ~= '.', return; end
            numbers = value([2:3 5:12 14:16 18:25]);
            valid = all(numbers >= '0' & numbers <= '9') && ...
                abs(str2double(value(1:12))) <= 90 && abs(str2double(value(13:25))) <= 180;
        else
            if ~any(value(12) == 'NS') || ~any(value(25) == 'EW') || value(7) ~= '.' || value(20) ~= '.', return; end
            numbers = value([1:6 8:11 13:19 21:24]);
            valid = all(numbers >= '0' & numbers <= '9') && str2double(value(1:2)) <= 89 && ...
                str2double(value(3:4)) <= 59 && str2double(value(5:6)) <= 59 && ...
                str2double(value(13:15)) <= 179 && str2double(value(16:17)) <= 59 && str2double(value(18:19)) <= 59;
        end
    end
end
