function value = extensionBytes(data, overflow, capacity) %#codegen
    %extensionBytes - Frame an extended area and its overflow pointer
    if numel(data) > capacity
        error('nfx:TREOverflow', 'Inline TRE bytes exceed this area''s capacity.');
    end
    if isempty(data) && overflow == 0
        value = uint8('00000');
    else
        value = [decimalField(numel(data)+3, 5, 0, false) ...
            decimalField(overflow, 3, 0, false) data];
    end
end
