function [file, image, rpc] = fixtureFile(data, representation)
    %fixtureFile - Build an explicitly synthetic single-image test file
    arguments
        data = reshape(uint16(257:291), 5, 7)
        representation = 'MONO'
    end
    category = 'VIS';
    if strcmp(representation, 'MULTI'), category = 'MS'; end
    header = nfx.ImageHeader(iid1='SYNTHETIC', idatim='20260915120000', ...
        isclas='U', irep=representation, icat=category, nppbh=4, nppbv=3);
    rpc = fixtureRPC();
    image = nfx.ImageSegment(data, header=header) + rpc;
    header = nfx.FileHeader(ostaid='NFXTEST', fdt='20260915120100', ...
        fsclas='U', ftitle='Synthetic unit test', fbkgc=[1 128 255]);
    file = nfx.File(header=header) + image;
end
