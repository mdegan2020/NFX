function valid = validLocation21(value, prefix, partial, blank) %#codegen
    %validLocation21 - Check the distinct BLOCKA and MSTGTA location forms
    value = char(value);
    valid = blank && isempty(strtrim(value));
    if valid || numel(value) ~= 21, return; end
    valid = false;
    if any(value(1) == '+-') && any(value(11) == '+-') && ...
            value(4) == '.' && value(15) == '.'
        positions = [2:3 5:10 12:14 16:21];
        digits = value(positions);
        if ~all((digits >= '0' & digits <= '9') | ...
                (partial & digits == '-')), return; end
        digits(digits == '-') = '0'; value(positions) = digits;
        valid = abs(str2double(value(1:10))) <= 90 && ...
            abs(str2double(value(11:21))) <= 180;
        return
    end
    if prefix
        hemispheres = [1 11]; dots = [8 19];
        positions = [2:7 9:10 12:18 20:21];
        groups = [2 3; 4 5; 6 7; 12 14; 15 16; 17 18];
    else
        hemispheres = [10 21]; dots = [7 18];
        positions = [1:6 8:9 11:17 19:20];
        groups = [1 2; 3 4; 5 6; 11 13; 14 15; 16 17];
    end
    north = value(hemispheres(1)); east = value(hemispheres(2));
    if ~(any(north == 'NS') || (partial && north == '-')) || ...
            ~(any(east == 'EW') || (partial && east == '-')) || ...
            any(value(dots) ~= '.')
        return
    end
    digits = value(positions);
    if ~all((digits >= '0' & digits <= '9') | ...
            (partial & digits == '-')), return; end
    digits(digits == '-') = '0'; value(positions) = digits;
    maximum = [89 59 59 179 59 59];
    for k = 1:6
        if str2double(value(groups(k,1):groups(k,2))) > maximum(k)
            return
        end
    end
    valid = true;
end
