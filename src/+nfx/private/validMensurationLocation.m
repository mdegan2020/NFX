function valid = validMensurationLocation(value) %#codegen
    %validMensurationLocation - Check coordinates with omitted fine precision
    text = char(value);
    valid = false;
    if numel(text) ~= 25
        return
    end
    if any(text(1) == '+-')
        fractions = [5:12 18:25];
    else
        fractions = [8:11 21:24];
    end
    % Unspecified fractional digits retain their positions as spaces.
    for k = fractions
        if text(k) == ' '
            text(k) = '0';
        end
    end
    valid = validAcquisitionLocation(text, 'precise');
end
