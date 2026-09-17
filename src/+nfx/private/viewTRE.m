function [record, ok, status] = viewTRE(records, index, id) %#codegen
    %viewTRE - Select an independent homogeneous record view
    record = nfx.TRERecord();
    [selected, ok, status] = selectTRE(records, '', index, id);
    if ok
        record = nfx.TRERecord(selected);
    end
end
