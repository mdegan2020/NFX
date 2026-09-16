function value = metadataRows(input,width,maxRows,extended) %#codegen
    %metadataRows - Normalize bounded text lists into fixed-width character rows
    if ischar(input) && ismatrix(input)
        count = size(input,1);
        if isempty(input), count = 0; end
        if count > maxRows || size(input,2) > width
            error('nfx:MetadataRows','Text rows exceed their field count or width.');
        end
        value = repmat(' ',count,width);
        value(:,1:size(input,2)) = input;
    elseif isstring(input) && (isvector(input) || isempty(input)) && ...
            numel(input) <= maxRows && ~any(ismissing(input))
        value = repmat(' ',numel(input),width);
        for k = 1:numel(input)
            row = char(input(k));
            if numel(row) > width, error('nfx:MetadataRows','Text exceeds its field width.'); end
            value(k,1:numel(row)) = row;
        end
    else
        error('nfx:MetadataRows','Supply a character matrix or a vector of text strings.');
    end
    for k = 1:size(value,1)
        if extended, mustBeECS(value(k,:),width); else, mustBeAscii(value(k,:),width); end
    end
end
