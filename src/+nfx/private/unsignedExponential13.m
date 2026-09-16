function value = unsignedExponential13(number) %#codegen
    %unsignedExponential13 - Encode MIE UE/13, including its unknown sentinel
    if isnan(number)
        value = textField('NaN', 13);
    else
        value = uint8(sprintf('%.7E', number));
        if numel(value) ~= 13
            error('nfx:Width', 'The value requires more than two exponent digits.');
        end
    end
end
