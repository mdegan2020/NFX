function value = mieTimeValue(text) %#codegen
    %mieTimeValue - Preserve a UTC day and nanoseconds without epoch rounding
    text = char(text); year = str2double(text(1:4)); month = str2double(text(5:6));
    day = str2double(text(7:8)); leap = mod(year,4) == 0 && (mod(year,100) ~= 0 || mod(year,400) == 0);
    months = [31 28+leap 31 30 31 30 31 31 30 31 30 31];
    ordinal = 365*year+floor((year+3)/4)-floor((year+99)/100)+floor((year+399)/400);
    ordinal = ordinal+sum(months(1:month-1))+day-1;
    seconds = str2double(text(9:10))*3600+str2double(text(11:12))*60+str2double(text(13:14));
    fraction = text(16:24); precision = sum(fraction ~= '-'); fraction(fraction == '-') = '0';
    nanos = uint64(seconds)*uint64(1000000000)+uint64(str2double(fraction));
    value = struct('day',ordinal,'nanos',nanos,'precision',precision);
end
