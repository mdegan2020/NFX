function [bytes, valid] = rpcCoefficient(value) %#codegen
    %rpcCoefficient - Encode six decimals with a one-digit signed exponent
    bytes = zeros(1, 12, 'uint8');
    valid = isfinite(value) && abs(value) <= 9.999999e9;
    if ~valid
        return
    end
    text = sprintf('%+.6E', value + 0);
    % Normalization and rounding happen before checking the exponent.
    valid = numel(text) == 13 && text(12) == '0';
    if valid
        bytes = uint8(text([1:11 13]));
    end
end
