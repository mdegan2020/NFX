function [value,valid] = rsmInteger(number,width,optional,signed) %#codegen
    %rsmInteger - Encode exact integer fields or the optional blank indicator
    value = repmat(uint8(' '),1,width);
    valid = optional && isnan(number);
    if valid, return; end
    valid = isfinite(number) && fix(number) == number && (signed || number >= 0);
    if ~valid, return; end
    if signed, word = sprintf('%+0*.0f',width,number);
    else, word = sprintf('%0*.0f',width,number);
    end
    valid = numel(word) == width;
    if valid, value = uint8(word); end
end
