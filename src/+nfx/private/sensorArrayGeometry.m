function [complete,consistent] = sensorArrayGeometry(metricRow,metricColumn,focal,fovRow,fovColumn,unit) %#codegen
    %sensorArrayGeometry - Check supplied detector geometry and quantization
    data = NaN(1,5);
    if ~isempty(metricRow), data(1) = metricRow; end
    if ~isempty(metricColumn), data(2) = metricColumn; end
    if ~isempty(focal), data(3) = focal; end
    if ~isempty(fovRow), data(4) = fovRow; end
    if ~isempty(fovColumn), data(5) = fovColumn; end
    known = isfinite(data) & data > 0;
    complete = all(known(4:5)) || (all(known(1:2)) && any(known(3:5))) || ...
        (known(3) && ((known(1) && known(5)) || (known(2) && known(4))));
    low = data; high = data;
    for k = 1:5
        if ~known(k), continue; end
        [encoded,valid,resolution] = sensNumber(data(k),8,'N');
        if ~valid, consistent = false; return; end
        rounded = str2double(char(encoded));
        low(k) = max(realmin,rounded-resolution/2); high(k) = rounded+resolution/2;
    end
    conversion = pi/180;
    if strcmp(unit,'RAD'), conversion = 1; elseif strcmp(unit,'SMC'), conversion = pi; end
    low(4:5) = low(4:5)*conversion; high(4:5) = high(4:5)*conversion;
    minimum = 0; maximum = Inf;
    if known(3), minimum = low(3); maximum = high(3); end
    for k = 1:2
        if ~known(k) || ~known(k+3), continue; end
        if data(k+3)*conversion >= pi, consistent = false; return; end
        angleLow = max(realmin,low(k+3)); angleHigh = min(pi-eps(pi),high(k+3));
        inferredLow = low(k)/(2*tan(angleHigh/2)); inferredHigh = high(k)/(2*tan(angleLow/2));
        % The standard says approximately consistent. Allow 0.01 percent
        % relative disagreement in addition to each field's quantization.
        inferredLow = inferredLow*(1-1e-4); inferredHigh = inferredHigh*(1+1e-4);
        minimum = max(minimum,inferredLow); maximum = min(maximum,inferredHigh);
    end
    consistent = minimum <= maximum;
end
