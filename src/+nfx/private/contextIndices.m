function [valid,ranges] = contextIndices(text,context) %#codegen
    %contextIndices - Parse bounded index ranges without expanding their members
    text = char(text);
    valid = false;
    ranges = zeros(0,2);
    switch char(context)
        case 'FR', maximum = 4294967295;
        case 'TI', maximum = 999999;
        otherwise, maximum = 999;
    end
    count = numel(text);
    while count > 0 && text(count) == ' ', count = count-1; end
    if count == 0, return; end
    if text(count) == ',', count = count-1; end
    if count == 0, return; end
    ranges = zeros(1+sum(text(1:count) == ','),2);
    at = 1; item = 0;
    while at <= count
        [first,at,ok] = indexAt(text,at,count,maximum);
        if ~ok, return; end
        last = first;
        if at <= count && text(at) == '-'
            at = at+1;
            if at > count
                last = Inf;
            else
                [last,at,ok] = indexAt(text,at,count,maximum);
                if ~ok || last < first, return; end
            end
        end
        item = item+1;
        ranges(item,:) = [first last];
        if at <= count
            if text(at) ~= ',' || at == count, return; end
            at = at+1;
        end
    end
    valid = item == size(ranges,1);
end

function [value,at,valid] = indexAt(text,at,count,maximum) %#codegen
    %indexAt - Read a positive bounded decimal integer with no leading zero
    value = 0;
    valid = false;
    if at > count || text(at) < '1' || text(at) > '9', return; end
    while at <= count && text(at) >= '0' && text(at) <= '9'
        value = value*10+double(text(at))-48;
        at = at+1;
        if value > maximum, return; end
    end
    valid = true;
end
