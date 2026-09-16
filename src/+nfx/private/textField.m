function bytes = textField(value, width) %#codegen
    %textField - Pad a validated one-byte character field on the right
    text = char(value);
    bytes = repmat(uint8(32), 1, width);
    bytes(1:numel(text)) = uint8(text);
end
