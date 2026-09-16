function report = snipGLASTimeReport(exposure,header,des,linked) %#codegen
    %snipGLASTimeReport - Bound the collection event by supplied model samples
    report = newReport('SNIP GLAS temporal support');
    if ~knownDate(header.idatim,14)
        report = snipIssue(report,true,'SNIPGLASAcquisition','header.idatim', ...
            'Supply a known acquisition time for comparison with the sensor model.','6.6');
        return
    end
    at = 40+36*number(exposure,37,3); sensor = char(exposure(at+18)); at = at+55;
    if sensor == 'S'
        day = char(exposure(at:at+7)); time = number(exposure,at+8,15); duration = number(exposure,at+23,16);
        base = mieTimeValue([day '000000.000000000']);
        first = secondsFromDay(base,time+min(duration,0)); last = secondsFromDay(base,time+max(duration,0));
    elseif sensor == 'F' && exposure(at) == uint8('0')
        base = mieTimeValue(char(exposure(at+10:at+33))); multiplier = integer(exposure(at+34:at+41));
        width = double(exposure(at+42)); count = double(integer(exposure(at+47:at+50))); delta = uint64(0);
        if count > 0, delta = integer(exposure(at+51:at+50+width)); end
        [first,valid] = mieTimeAdd(base,delta,multiplier,1); last = first;
        report = snipIssue(report,~valid,'SNIPGLASTime','CSEXRB','The frame timestamp exceeds the supported calendar.','6.6');
    else
        report = snipIssue(report,true,'SNIPGLASTime','CSEXRB','Supply explicit still-frame or scanning acquisition timing.','6.6');
        return
    end
    report = snipIssue(report,mieTimeCompare(first,mieTimeValue([char(header.idatim) '.---------'])) ~= 0, ...
        'SNIPGLASAcquisition','CSEXRB/header.idatim','The acquisition start must agree at the image timestamp precision.','6.6');
    for k = linked
        type = des(k).header.desid;
        if ~any(strcmp(type,{'CSATTB','CSEPHB'})), continue; end
        info = glasDESInfo(des(k)); if info.eci, continue; end
        data = des(k).data; interpolation = number(data,2,1);
        at = 5+any(interpolation == [2 3]); spacing = number(data,at,13);
        start = mieTimeValue(char([data(at+13:at+20) data(at+21:at+36)]));
        samples = number(data,at+37,5);
        [finish,valid] = mieTimeAdd(start,uint64(round(spacing*1e9)),uint64(1),samples-1);
        report = snipIssue(report,~valid || mieTimeCompare(start,first) > 0 || mieTimeCompare(finish,last) < 0, ...
            'SNIPGLASTemporalCoverage',type,'Attitude and ephemeris samples must cover the complete acquisition event.','6.6');
    end
end

function value = secondsFromDay(base,seconds) %#codegen
    %secondsFromDay - Preserve subsecond timestamps across a day boundary
    days = floor(seconds/86400); nanos = uint64(round((seconds-days*86400)*1e9));
    value = base; value.day = value.day+days; value.nanos = nanos;
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end

function value = integer(data) %#codegen
    %integer - Preserve a big-endian native integer
    value = uint64(0);
    for k = 1:numel(data), value = bitshift(value,8)+uint64(data(k)); end
end
