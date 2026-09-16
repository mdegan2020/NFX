function [value,valid] = rsmNumber(number,optional) %#codegen
    %rsmNumber - Encode the 21-character RSM signed floating-point field
    value = repmat(uint8(' '),1,21);
    valid = optional && isnan(number);
    if valid, return; end
    valid = isfinite(number) && abs(number) <= 9.99999999999999e99 && ...
        (number == 0 || abs(number) >= 1e-113);
    if ~valid, return; end
    if number ~= 0 && abs(number) < 1e-99
        % Appendix U permits an unnormalized mantissa at exponent -99,
        % extending the positive field range down to 1e-113.
        word = [sprintf('%+.14f',number*1e99) 'E-99'];
    else
        word = sprintf('%+.14E',number);
    end
    rounded = str2double(word);
    valid = numel(word) == 21 && isfinite(rounded) && ...
        abs(rounded) <= 9.99999999999999e99 && (number == 0 || rounded ~= 0);
    if valid, value = uint8(word); end
end
