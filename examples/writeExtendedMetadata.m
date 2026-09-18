function file = writeExtendedMetadata(folder)
    %writeExtendedMetadata - Write synthetic polygons and engineering data
    %   FILE = writeExtendedMetadata(FOLDER) creates extended_metadata.ntf
    %   in an existing output folder. The coordinates and sensor
    %   values are synthetic demonstrations, not measured metadata.
    %
    %   See also nfx.GEOPSB, nfx.BNDPLC, nfx.ENGRDA, nfx.XMLDCA
    arguments
        folder {mustBeTextScalar, mustBeNonempty}
    end
    pixels = reshape(uint16(1:35), 5, 7);
    header = nfx.ImageHeader( ...
        iid1='EXTENDED', idatim='20260918120000', isclas='U', ...
        irep='MONO', icat='VIS');
    image = nfx.ImageSegment(pixels, header=header);

    % Clockwise exterior; the first vertex is not repeated at the end.
    ring = struct('lon', [-105 -105 -104.9 -104.9], ...
                  'lat', [40 40.1 40.1 40], 'height', []);
    image = image + nfx.BNDPLC(ring);

    entries = nfx.ENGRDA.entry('Detector temperatures', ...
                               single([20.5 21; 20.75 21.25]), 'K');
    entries(2) = nfx.ENGRDA.entry('Detector status', uint8([1 0]));
    image = image + nfx.ENGRDA(resrc='Synthetic sensor', redata=entries);

    document = nfx.XMLDCA(tredata=uint8('<example synthetic="true"/>'));
    document = document.updateCRC();
    image = image + document;

    file = nfx.File(header=nfx.FileHeader( ...
        ostaid='NFXDEMO', fdt='20260918120000', fsclas='U', ...
        ftitle='Synthetic extended metadata'));
    file = file + nfx.GEOPSB() + image;
    file.write(fullfile(folder, 'extended_metadata.ntf'));

    % A typed lookup creates an independently editable concrete TRE.
    [engineering, found] = file.images(1).ENGRDA;
    if found
        [temperatures, decoded] = nfx.ENGRDA.values( ...
            engineering.redata(1), single(0));
        if decoded, disp(temperatures); end
    end
    disp(file.images(1).tre(1));
end
