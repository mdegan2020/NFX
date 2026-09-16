function [value,valid,rounded] = rsmNumbers(numbers,optional) %#codegen
    %rsmNumbers - Serialize fixed-width RSM values in supplied linear order
    value = zeros(21,numel(numbers),'uint8'); valid = true;
    rounded = NaN(size(numbers));
    for k = 1:numel(numbers)
        [field,ok] = rsmNumber(numbers(k),optional);
        value(:,k) = field'; valid = valid && ok;
        if ok, rounded(k) = str2double(char(field)); end
    end
    value = reshape(value,1,[]);
end
