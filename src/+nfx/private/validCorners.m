function valid = validCorners(code, corners) %#codegen
    %validCorners - Check decimal-degree or DMS corner text and unknown digits
    code = char(code);
    corners = char(corners);
    valid = strcmp(code, ' ') && isempty(corners);
    if ~(strcmp(code, 'D') || strcmp(code, 'G')) || numel(corners) ~= 60
        return
    end
    valid = true;
    for k = 0:3
        row = corners(15*k+1:15*k+15);
        if strcmp(code, 'D')
            valid = valid && coordinate(row(1:7), 90) && coordinate(row(8:15), 180);
        else
            valid = valid && dms(row(1:7), 90, 'NS') && dms(row(8:15), 180, 'EW');
        end
    end
end

function valid = coordinate(value, limit) %#codegen
    %coordinate - Validate signed degrees with trailing unknown precision
    point = numel(value)-3;
    digits = value(2:end);
    valid = any(value(1) == '+-') && value(point) == '.';
    digits(point-1) = '0';
    firstBlank = find(digits == ' ', 1);
    if ~isempty(firstBlank)
        valid = valid && firstBlank >= point && all(digits(firstBlank:end) == ' ');
        digits(firstBlank:end) = '0';
    end
    valid = valid && all(digits >= '0' & digits <= '9');
    value(value == ' ') = '0';
    valid = valid && abs(str2double(value)) <= limit;
end

function valid = dms(value, limit, hemispheres) %#codegen
    %dms - Check a latitude or longitude at its supplied precision
    degreeWidth = numel(value)-5;
    digits = value(1:end-1);
    valid = any(value(end) == hemispheres);
    firstBlank = find(digits == ' ', 1);
    if ~isempty(firstBlank)
        valid = valid && firstBlank > degreeWidth && all(digits(firstBlank:end) == ' ');
        digits(firstBlank:end) = '0';
    end
    valid = valid && all(digits >= '0' & digits <= '9');
    degrees = str2double(digits(1:degreeWidth));
    minutes = str2double(digits(degreeWidth+1:degreeWidth+2));
    seconds = str2double(digits(degreeWidth+3:end));
    valid = valid && minutes < 60 && seconds < 60 && ...
        degrees + minutes/60 + seconds/3600 <= limit;
end
