function mustBePixels(value) %#codegen
    %mustBePixels - Validate pixels without copying or converting samples
    if ~(isa(value, 'uint8') || isa(value, 'uint16')) || ...
            ~isreal(value) || issparse(value) || ndims(value) > 4
        error('nfx:Pixels', 'Expected a full real uint8 or uint16 rows-by-columns-by-bands-by-frames array.');
    end
end
