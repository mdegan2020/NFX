function [report,value,count] = bandAuxiliary(groups,numberBands,bandLevel,encode) %#codegen
    %bandAuxiliary - Validate and encode explicit spectral auxiliary groups
    report = newReport('STDI-0002 Appendix X auxiliary parameters');
    reference = 'STDI-0002-1 Appendix X, Table X.6-1; Appendix P, P.4.5';
    count = 0;
    value = zeros(1,0,'uint8');
    expected = 1;
    if bandLevel, expected = numberBands; end
    for k = 1:numel(groups)
        item = groups(k);
        if bandLevel, format = char(item.bapf); unit = char(item.ubap);
        else, format = char(item.capf); unit = char(item.ucap);
        end
        characters = metadataRows(item.apa,20,99999,false);
        width = 0;
        switch format
            case 'I'
                width = 10;
                legal = isrow(item.apn) && numel(item.apn) == expected && ...
                    ~any(isnan(item.apn)) && isempty(item.apr) && isempty(characters);
            case 'R'
                width = 4;
                legal = isrow(item.apr) && numel(item.apr) == expected && ...
                    ~any(isnan(item.apr) | (item.apr ~= 0 & abs(item.apr) < 1e-38)) && ...
                    isempty(item.apn) && isempty(characters);
            case 'A'
                width = 20;
                legal = size(characters,1) == expected && isempty(item.apn) && isempty(item.apr);
            otherwise
                legal = false;
        end
        report = addIssue(report,~legal,'AuxiliaryValues',sprintf('auxiliary(%d)',k), ...
            'Use I/R/A and supply only its matching value field, once per band or cube.',reference);
        report = addIssue(report,isempty(strtrim(unit)),'AuxiliaryUnit',sprintf('auxiliary(%d).unit',k), ...
            'Supply the published or applicable ISO unit code, within seven bytes.',reference);
        count = count+8+expected*width;
    end
    if ~encode || ~report.valid || count > 99985, return; end
    value = zeros(1,count,'uint8'); at = 0;
    for k = 1:numel(groups)
        item = groups(k);
        if bandLevel, format = char(item.bapf); unit = char(item.ubap);
        else, format = char(item.capf); unit = char(item.ucap);
        end
        value(at+1:at+8) = [uint8(format) textField(unit,7)]; at = at+8;
        switch format
            case 'I'
                for b = 1:expected
                    value(at+1:at+10) = decimalField(item.apn(b),10,0,false); at = at+10;
                end
            case 'R'
                part = float32Bytes(item.apr);
                value(at+1:at+numel(part)) = part; at = at+numel(part);
            case 'A'
                characters = metadataRows(item.apa,20,99999,false);
                part = reshape(uint8(characters.'),1,[]);
                value(at+1:at+numel(part)) = part; at = at+numel(part);
        end
    end
end
