function [obj, ok, status] = finishDESDecode(obj, reader, header, unset) %#codegen
    %finishDESDecode - Grant typed reconstruction only after exact validation
    reader = reader.finish(); ok = reader.ok;
    status = decodeStatus(reader.code, reader.message, reader.position);
    if ok
        report = obj.validate();
        if ~report.valid
            ok = false; status = decodeStatus('InvalidMetadata', ...
                report.issues(1).message, reader.position);
        elseif ~isequal(obj.payload(), reader.data) || ~isequal(obj.subheader(), header)
            ok = false; status = decodeStatus('NoncanonicalPayload', ...
                'DES data is outside the supported NFX encoding.', reader.position);
        end
    end
    if ok, status = decodeStatus(); else, obj = unset; end
end
