function value = rsmPowers(coefficients) %#codegen
    %rsmPowers - Derive polynomial powers from X-by-Y-by-Z array dimensions
    value = NaN(1,3);
    if ~isempty(coefficients)
        value = [size(coefficients,1) size(coefficients,2) size(coefficients,3)]-1;
    end
end
