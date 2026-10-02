function collection = fixtureCompressedMetadata(encoder)
    %fixtureCompressedMetadata - Preserve supplied models through TRE overflow
    collection = fixtureCompressedCollection(encoder, 'NPJE', 'uint16', 'MONO');
    collection.manifest_template = nfx.File(header=collection.header) + nfx.GEOPSB();
    collection.file_templates = struct('camera_set_index', 1, ...
        'time_interval_index', 1, 'file', collection.manifest_template);
    points = struct('lon', {-105, -105, -104, -104, -105}, ...
        'lat', {40, 41, 41, 40, 40});
    polygon = nfx.BNDPLB(points=points);
    for k = 1:numel(collection.blocks)
        image = collection.blocks(k).image;
        id = fixtureRSMIdentification();
        id.iid = sprintf('SUPPLIED FRAME %d', k);
        id.edition = sprintf('SUPPLIED EDITION %d', k);
        id.fullr = 33; id.fullc = 35;
        id.maxr = 32; id.maxc = 34;
        directory = nfx.RSMPIA(iid=id.iid, edition=id.edition, ...
            rnis=1, cnis=6, rssiz=33, cssiz=35/6, ...
            r0=0, rx=0, ry=0, rz=0, rxx=0, rxy=0, rxz=0, ryy=0, ryz=0, rzz=0, ...
            c0=0, cx=0, cy=0, cz=0, cxx=0, cxy=0, cxz=0, cyy=0, cyz=0, czz=0);
        chip = nfx.ICHIPB(scale_factor=1, fi_row=33, fi_col=35, ...
            op_row_11=0.5, op_col_11=0.5, op_row_12=0.5, op_col_12=34.5, ...
            op_row_21=32.5, op_col_21=0.5, op_row_22=32.5, op_col_22=34.5, ...
            fi_row_11=0.5, fi_col_11=0.5, fi_row_12=0.5, fi_col_12=34.5, ...
            fi_row_21=32.5, fi_col_21=0.5, fi_row_22=32.5, fi_col_22=34.5);
        image = image + chip + polygon + id + directory;
        polynomial = fixturePolynomial();
        polynomial.iid = id.iid; polynomial.edition = id.edition;
        polynomial.rnpcf = ones(6, 6, 6); polynomial.rdpcf = ones(6, 6, 6);
        polynomial.cnpcf = ones(6, 6, 6); polynomial.cdpcf = ones(6, 6, 6);
        for section = 1:6
            polynomial.csn = section;
            image = image + polynomial;
        end
        collection.blocks(k).image = image;
    end
end
