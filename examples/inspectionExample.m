function [image, original, edited] = inspectionExample()
    %inspectionExample - Inspect and edit independent TRE snapshots
    %   [IMAGE, ORIGINAL, EDITED] = inspectionExample constructs synthetic
    %   RPC metadata, attaches it, and displays its encoded snapshot. An
    %   edited copy replaces that attachment without changing ORIGINAL.
    %   The example also selects repeated TREs and handles an absent type.
    %
    %   See also nfx.ImageSegment.RPC00B, nfx.TRERecord, nfx.FSYNWA

    rpc = nfx.RPC00B(line_off=2, samp_off=3, lat_off=0, long_off=0, ...
        height_off=0, line_scale=2, samp_scale=3, lat_scale=1, ...
        long_scale=1, height_scale=100, ...
        line_num_coeff=[0 0 1 zeros(1, 17)], ...
        line_den_coeff=[1 zeros(1, 19)], ...
        samp_num_coeff=[0 1 zeros(1, 18)], ...
        samp_den_coeff=[1 zeros(1, 19)]);
    image = nfx.ImageSegment(reshape(uint16(1001:1035), 5, 7), ...
        header=nfx.ImageHeader(iid1='INSPECT', ...
            idatim='20260917120000', isclas='U', ...
            irep='MONO', icat='VIS'));
    image = image + rpc + nfx.FREESA(8) + nfx.FREESA(16);
    attachmentID = image.tre_ids(1);

    % Display chooses the decoder using the serialized tag.
    disp(image.tre(1));
    [original, found] = image.RPC00B(ID=attachmentID);
    assert(found);

    % A concrete value is independent and can be edited normally.
    edited = original;
    edited.err_bias = 0.25;
    image = image.removeTRE(attachmentID) + edited;

    % Occurrences count matching logical attachments in insertion order.
    for index = 1:image.treCount('FREESA')
        freeSpace = image.FREESA(index);
        fprintf('Free-space record %d contains %d bytes.\n', ...
            index, freeSpace.count);
    end

    % An absent type returns a default scalar and explicit status.
    [sensor, found, status] = image.SENSRB;
    if ~found
        fprintf('SENSRB: %s\n', status.message);
    end
    assert(isscalar(sensor));

    % Wrapper children are inspected through the decoded wrapper.
    wrapper = nfx.FSYNWA() + edited;
    recovered = nfx.FSYNWA.deserialize(wrapper.payload());
    assert(isequal(recovered.RPC00B().payload(), edited.payload()));
end
