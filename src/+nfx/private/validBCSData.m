function valid = validBCSData(value) %#codegen
    %validBCSData - Accept printable BCS plus LF, FF and CR controls
    valid = all((value(:) >= 32 & value(:) <= 126) | ...
        value(:) == 10 | value(:) == 12 | value(:) == 13);
end
