function valid = rsmGroundCoordinates(xyz,form,optional) %#codegen
    %rsmGroundCoordinates - Check declared RSM ground-coordinate ranges
    valid = true;
    for k = 1:numel(xyz)
        [~,ok] = rsmNumber(xyz(k),optional); valid = valid && ok;
    end
    if form == 'G', valid = valid && ~any(xyz(1,:) < -pi | xyz(1,:) > pi);
    elseif form == 'H', valid = valid && ~any(xyz(1,:) < 0 | xyz(1,:) > 2*pi);
    elseif form ~= 'R', valid = false;
    end
    if form == 'G' || form == 'H', valid = valid && ~any(abs(xyz(2,:)) > pi/2); end
end
