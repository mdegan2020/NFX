function value = glasImageInfo(data) %#codegen
    %glasImageInfo - Read association fields from a validated CSEXRB snapshot
    count = number(data,37,3);
    value = struct('uuid',char(data(1:36)),'des',repmat(' ',count,36), ...
        'sensor',' ','dimensions',[0 0],'frames',NaN,'timeLocation',NaN, ...
        'rolling',NaN,'target','','targetTime','');
    for k = 1:count, value.des(k,:) = char(data(40+36*(k-1):75+36*(k-1))); end
    at = 40+36*count; value.sensor = char(data(at+18)); at = at+55;
    if value.sensor == 'S'
        at = at+39;
    elseif value.sensor == 'F'
        value.timeLocation = number(data,at,1); at = at+1;
        if value.timeLocation == 0
            width = double(data(at+41)); value.frames = integer4(data(at+42:at+45));
            deltas = integer4(data(at+46:at+49)); at = at+50+width*deltas;
        end
    end
    at = at+94; value.dimensions = [number(data,at,7) number(data,at+7,5)]; at = at+66;
    if value.sensor == 'F', value.rolling = number(data,at,1); at = at+1; end
    reserved = number(data,at+1,5); at = at+6;
    if reserved == 0, return; end
    at = at+8+2; length = number(data,at,2); at = at+2;
    value.target = char(data(at:at+length-1)); at = at+length;
    for k = 1:2, length = number(data,at,2); at = at+2+length; end
    at = at+27; value.targetTime = char(data(at:at+13));
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end

function value = integer4(data) %#codegen
    %integer4 - Read a native four-byte count exactly into double
    value = 0;
    for k = 1:4, value = value*256+double(data(k)); end
end
