function file = repeatImage(image, count)
    %repeatImage - Exercise the public collection limit without large pixels
    file = nfx.File();
    for k = 1:count, file = file+image; end
end
