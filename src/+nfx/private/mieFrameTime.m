function [value,valid] = mieFrameTime(timing,index) %#codegen
    %mieFrameTime - Apply Appendix AF equation 1 using exact delta products
    value = mieTimeValue(timing.base_timestamp); valid = true;
    if isempty(timing.dt), return; end
    if isscalar(timing.dt)
        [value,valid] = mieTimeAdd(value,timing.dt(1),timing.dt_multiplier,index);
    else
        for k = 1:index
            [value,valid] = mieTimeAdd(value,timing.dt(k),timing.dt_multiplier,1);
            if ~valid, return; end
        end
    end
end
