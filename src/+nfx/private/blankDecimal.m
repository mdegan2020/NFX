function value = blankDecimal(number,width,places,signed) %#codegen
    %blankDecimal - Encode an optional numeric field with a blank NaN sentinel
    if isnan(number)
        value = repmat(uint8(' '),1,width);
    else
        value = decimalField(number,width,places,signed);
    end
end
