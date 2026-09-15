function value = commentRows(input) %#codegen
    %commentRows - Normalize up to nine printable image comments
    if ischar(input) && ismatrix(input)
        count = size(input, 1);
        if isempty(input), count = 0; end
        if count > 9 || size(input, 2) > 80 || any(input(:) < ' ' | input(:) > '~')
            error('nfx:Comments', 'Supply up to nine ASCII comments of at most 80 characters.');
        end
        value = repmat(' ', count, 80);
        value(:, 1:size(input, 2)) = input;
    elseif isstring(input) && (isvector(input) || isempty(input)) && ...
            numel(input) <= 9 && ~any(ismissing(input))
        value = repmat(' ', numel(input), 80);
        for k = 1:numel(input)
            row = char(input(k));
            mustBeAscii(row, 80);
            value(k, 1:numel(row)) = row;
        end
    else
        error('nfx:Comments', 'Supply a character matrix or a vector of strings.');
    end
end
