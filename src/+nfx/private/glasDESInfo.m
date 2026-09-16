function value = glasDESInfo(segment) %#codegen
    %glasDESInfo - Read associations only from an unchanged typed DES snapshot
    value = struct('verified',segment.verifiedSensor(),'uuid',repmat(' ',1,36), ...
        'all',false,'levels',zeros(1,0),'sensor',' ','bandIndex',zeros(1,0), ...
        'bandLabels',repmat(' ',0,2),'wavelengths',zeros(1,0), ...
        'fieldAngle',NaN,'fiducialSize',[0 0],'telescope',0,'frames',NaN,'eci',false);
    if ~value.verified, return; end
    h = segment.header.desshf; data = segment.data; value.uuid = char(h(1:36));
    value.all = strcmp(char(h(37:39)),'ALL');
    if ~value.all
        n = number(h,37,3); value.levels = zeros(1,n);
        for k = 1:n, value.levels(k) = number(h,40+3*(k-1),3); end
    end
    if any(strcmp(segment.header.desid,{'CSATTB','CSEPHB'}))
        interp = number(data,2,1); at = 3+any(interp == [2 3]);
        value.eci = data(at+1) == uint8('0'); return
    end
    if ~strcmp(segment.header.desid,'CSSFAB'), return; end
    value.sensor = char(data(1)); count = number(data,14,5); at = 19;
    value.bandIndex = zeros(1,count); value.bandLabels = repmat(' ',count,2); value.wavelengths = NaN(1,count);
    for k = 1:count
        value.bandIndex(k) = number(data,at,5); value.bandLabels(k,:) = char(data(at+5:at+6));
        value.wavelengths(k) = number(data,at+7,6); at = at+13;
    end
    points = number(data,at,3); at = at+12+26*points+60;
    if value.sensor ~= 'F', return; end
    sets = number(data,at,1); value.fieldAngle = number(data,at+1,1); at = at+3;
    if value.fieldAngle == 0
        for k = 1:sets
            rows = number(data,at+34,3); cols = number(data,at+60,3); at = at+63+88*rows*cols;
        end
    else
        rows = number(data,at,3); cols = number(data,at+3,3); value.fiducialSize = [rows cols];
        at = at+6+168*rows*cols+263*sets;
    end
    value.telescope = number(data,at,1);
    if value.telescope == 1
        value.frames = 0;
        for k = 1:4, value.frames = value.frames*256+double(data(at+1+k)); end
    end
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end
