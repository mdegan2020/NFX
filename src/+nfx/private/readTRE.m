function [obj, ok, status] = readTRE( ...
        records, unset, index, id) %#codegen
    %readTRE - Keep the decoder's output class fixed by its concrete prototype
    obj = unset;
    [selected, ok, status] = selectTRE(records, unset.cetag, index, id);
    if ~ok
        return
    end
    if isa(unset, 'nfx.SENSRB')
        [obj, ok, status] = nfx.SENSRB.deserializeRecords(selected);
    elseif numel(selected) ~= 1
        ok = false;
        status = decodeStatus('InvalidPayload', ...
            'This TRE type does not define continuation records.');
    else
        [obj, ok, status] = unset.deserialize(selected.payload);
    end
end
