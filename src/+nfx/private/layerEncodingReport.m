function report = layerEncodingReport(image, records) %#codegen
    %layerEncodingReport - Compare present layer declarations with image storage
    report = newReport('MIE layer decoder consistency');
    [timing, found] = image.MTIMSA();
    if ~found, return; end
    for k = 1:numel(records)
        if ~strcmp(records(k).tag, 'MIMCSA'), continue; end
        [layer, valid] = nfx.MIMCSA.deserialize(records(k).payload);
        if ~valid || ~strcmp(strtrim(layer.layer_id), strtrim(timing.layer_id)), continue; end
        report = mieIssue(report, ~strcmp(layer.mi_req_decoder, image.header.ic), ...
            'LayerEncoding', 'header.ic', ...
            'Every image in a layer must match its MIMCSA decoder declaration.');
        if strcmp(image.header.ic, 'C8') && strcmp(layer.mi_req_decoder, 'C8')
            report = mieIssue(report, ~strcmp(layer.mi_req_profile, 'ISO/IEC 15444-1') || ...
                ~strcmp(layer.mi_req_level, 'class2'), 'LayerDecoderProfile', 'MIMCSA', ...
                'This C8 snapshot requires ISO/IEC 15444-1, class2 in MIMCSA.');
        end
    end
end
