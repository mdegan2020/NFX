function [obj, ok, status] = finishTREDecode(obj, reader, unset) %#codegen
    %finishTREDecode - Validate a complete concrete value before exposing it
    reader = reader.finish();
    ok = reader.ok;
    status = decodeStatus(reader.code, reader.message, reader.position);
    if ok
        report = obj.validate();
        if ~report.valid
            ok = false;
            status = decodeStatus('InvalidMetadata', ...
                report.issues(1).message, reader.position);
        elseif ~isequal(obj.payload(), reader.data)
            ok = false;
            status = decodeStatus('NoncanonicalPayload', ...
                'The payload is outside the supported NFX encoding.', ...
                reader.position);
        end
    end
    if ok
        status = decodeStatus();
    else
        obj = unset;
    end
end
