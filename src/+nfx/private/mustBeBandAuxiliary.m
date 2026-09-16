function mustBeBandAuxiliary(value,bandLevel) %#codegen
    %mustBeBandAuxiliary - Require concrete auxiliary fields and native types
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || numel(value) > 99
        error('nfx:BandAuxiliary','Supply at most 99 auxiliary parameter structs in a row.');
    end
    if bandLevel, fields = {'bapf','ubap','apn','apr','apa'};
    else, fields = {'capf','ucap','apn','apr','apa'};
    end
    if numel(fieldnames(value)) ~= 5 || ~all(isfield(value,fields))
        error('nfx:BandAuxiliary','Supply precisely the five mnemonic auxiliary fields.');
    end
    for k = 1:numel(value)
        if bandLevel, mustBeAscii(value(k).bapf,1); mustBeAscii(value(k).ubap,7);
        else, mustBeAscii(value(k).capf,1); mustBeAscii(value(k).ucap,7);
        end
        mustBeMetadataArray(value(k).apn,-999999999,9999999999,true);
        mustBeMetadataArray(value(k).apr,-1e38,1e38,false);
        text = metadataRows(value(k).apa,20,99999,false);
        if any(text(:) < ' ' | text(:) > '~')
            error('nfx:BandAuxiliary','Auxiliary character values must be printable ASCII.');
        end
    end
end
