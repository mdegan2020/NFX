function [frames, samples, ok, status] = imageShape(entry) %#codegen
    %imageShape - Validate image storage geometry without touching pixels
    h = entry.header; layout = entry.layout;
    status = nfx.internal.readStatus(); status.scope = 'image';
    status.offset = entry.location.dataOffset;
    frames = 1;
    if strcmp(layout.ic, 'NC')
        frameBytes = h.nppbh * h.nppbv * layout.nbpr * ...
            layout.nbpc * layout.bands * (layout.nbpp / 8);
        frames = entry.location.dataLength / frameBytes;
    end
    ok = isfinite(frames) && frames >= 1 && frames <= 4294967295 && ...
        fix(frames) == frames && ...
        ((strcmp(layout.imode, 'B') && frames == 1) || ...
        (strcmp(layout.imode, 'F') && frames > 1 && layout.bands == 1) || ...
        (strcmp(layout.imode, 'T') && frames > 1 && layout.bands > 1));
    samples = layout.nrows * layout.ncols * layout.bands * frames;
    ok = ok && samples <= flintmax;
    if ~ok
        status.code = 'MalformedFile';
        status.message = 'Stored image length disagrees with its block/frame layout.';
    end
end
