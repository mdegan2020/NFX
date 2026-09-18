function result = nfxCoderMixed(first, second) %#codegen
    %nfxCoderMixed - Report mixed primitive storage as a separate probe
    file = nfx.File() + nfx.ImageSegment(first) + nfx.ImageSegment(second);
    result = struct('first', file.images(1).data, 'second', file.images(2).data, ...
        'native', isa(file.images(1).data, 'uint8') && isa(file.images(2).data, 'uint16'));
end
