function [value,valid] = rsmPolynomial(coefficients) %#codegen
    %rsmPolynomial - Serialize one polynomial with X changing fastest
    powers = rsmPowers(coefficients);
    [data,valid] = rsmNumbers(coefficients,false);
    valid = valid && ~isempty(coefficients);
    value = [uint8(sprintf('%01.0f%01.0f%01.0f%03.0f',powers(1),powers(2),powers(3),numel(coefficients))) data];
end
