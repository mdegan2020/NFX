function [original, edited] = readingExample(folder)
    %readingExample - Read, inspect and edit synthetic multi-image content
    %   [ORIGINAL, EDITED] = readingExample(FOLDER) writes three files in
    %   an existing folder. The original, copied and edited files retain
    %   native pixels, a second image, text and unrelated TRE snapshots.
    %   Add src and examples to the MATLAB path before running this demo.
    %
    %   See also nfx.File.read, nfx.File.replaceImage, inspectionExample
    arguments
        folder {mustBeTextScalar, mustBeNonzeroLengthText}
    end

    image = inspectionExample();
    second = nfx.ImageSegment(uint8([1 2; 3 4]), ...
        header=nfx.ImageHeader(iid1='SECOND', ...
            idatim='20260917120000', isclas='U', ...
            irep='MONO', icat='VIS'));
    text = nfx.TextSegment('Synthetic reader demonstration.', ...
        header=nfx.TextHeader(textid='NOTE', ...
            txtdt='20260917120000', txtitl='Reader example', tsclas='U'));
    source = nfx.File(header=nfx.FileHeader(ostaid='NFXDEMO', ...
        fdt='20260917120100', fsclas='U', ...
        ftitle='Synthetic reader example')) + image + second + text;
    source.write(fullfile(folder, 'reader-source.ntf'));

    [original, ok, status] = nfx.File.read( ...
        fullfile(folder, 'reader-source.ntf'));
    assert(ok, status.message);
    original.write(fullfile(folder, 'reader-copy.ntf'));

    % A decoded TRE is independent until its edited snapshot is attached.
    image = original.images(1);
    [rpc, found] = image.RPC00B;
    assert(found);
    rpc.err_bias = 1.5;
    records = image.tre_records;
    id = records(strcmp({records.tag}, 'RPC00B')).id;
    image = image.removeTRE(id) + rpc;
    image.header.icom = 'Reviewed metadata; native pixels preserved.';

    for index = 1:image.treCount('FREESA')
        record = image.FREESA(index);
        fprintf('Free-space record %d: %d payload bytes\n', ...
            index, record.count);
    end

    % Replace one image slot while retaining all other file content.
    edited = original.replaceImage(1, image);
    edited.write(fullfile(folder, 'reader-edited.ntf'));
    assert(isequal(edited.images(2).data, original.images(2).data));
    assert(original.images(1).RPC00B().err_bias ~= rpc.err_bias);
end
