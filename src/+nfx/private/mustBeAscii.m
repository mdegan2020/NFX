function mustBeAscii(value, width) %#codegen
    %mustBeAscii - Validate printable ASCII text without converting numbers
    if ~(ischar(value) && (isrow(value) || isempty(value))) && ...
            ~(isstring(value) && isscalar(value) && ~ismissing(value))
        error('nfx:Text', 'Expected a character row or a nonmissing string scalar.');
    end
    text = char(value);
    if numel(text) > width || any(text < ' ' | text > '~')
        error('nfx:Text', 'Expected at most %d printable ASCII characters.', width);
    end
end
