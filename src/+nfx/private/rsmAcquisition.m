function [value,valid] = rsmAcquisition(year,month,day,hour,minute,second) %#codegen
    %rsmAcquisition - Encode optional UTC components including leap seconds
    values = [year month day hour minute]; widths = [4 2 2 2 2];
    value = zeros(1,0,'uint8'); valid = true;
    for k = 1:5
        [field,ok] = rsmInteger(values(k),widths(k),true,false);
        valid = valid && ok; value = [value field]; %#ok<AGROW>
    end
    seconds = repmat(uint8(' '),1,9);
    if isfinite(second)
        word = sprintf('%09.6f',second);
        ok = numel(word) == 9 && str2double(word) <= 60.999999;
        valid = valid && ok;
        if ok, seconds = uint8(word); end
    end
    value = [value seconds];
    if isfinite(month) && isfinite(day)
        days = [31 29 31 30 31 30 31 31 30 31 30 31];
        if isfinite(year), days(2) = 28+(mod(year,4) == 0 && (mod(year,100) ~= 0 || mod(year,400) == 0)); end
        valid = valid && day <= days(month);
    end
end
