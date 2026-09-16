function [value,valid,rounded] = rsmCoordinates(xyz,form,optional) %#codegen
    %rsmCoordinates - Encode geographic boundaries without rounding outside
    valid = rsmGroundCoordinates(xyz,form,optional);
    [value,representable,rounded] = rsmNumbers(xyz,optional);
    valid = valid && representable;
    if ~valid || form == 'R', return; end
    lower = [-pi;-pi/2;-Inf]; upper = [pi;pi/2;Inf];
    if form == 'H', lower(1) = 0; upper(1) = 2*pi; end
    for k = 1:size(xyz,2)
        for j = 1:2
            direction = double(rounded(j,k) < lower(j))-double(rounded(j,k) > upper(j));
            if direction == 0, continue; end
            [field,ok] = rsmNumber(rounded(j,k)+direction*1e-14,false);
            rounded(j,k) = str2double(char(field));
            valid = valid && ok && rounded(j,k) >= lower(j) && rounded(j,k) <= upper(j);
            first = 21*((k-1)*3+j-1)+1;
            value(first:first+20) = field;
        end
    end
end
