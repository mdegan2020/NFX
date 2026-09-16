function mustBeECS(value, width) %#codegen
    %mustBeECS - Validate one-byte ECS-A text without encoding substitutions
    if ~(ischar(value) && (isrow(value) || isempty(value))) && ...
            ~(isstring(value) && isscalar(value) && ~ismissing(value))
        error('nfx:ECSText', 'Expected a character row or a nonmissing string scalar.');
    end
    characters = char(value);
    if numel(characters) > width || any(characters < 32 | ...
            (characters > 126 & characters < 160) | characters > 255)
        error('nfx:ECSText', 'Expected at most %d ECS-A characters (32-126 or 160-255).', width);
    end
end
