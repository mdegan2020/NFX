function [report,found,geometry] = snipIlluminationReport(data,header) %#codegen
    %snipIlluminationReport - Check the acquisition set and WGS 84 declarations
    report = newReport('SNIP ILLUMB'); bands = number(data,1,4); at = 45+32*bands;
    others = number(data,at,2); at = at+2+40*others;
    comments = number(data,at,1); at = at+1+80*comments;
    fields = {char(data(at:at+79)),char(data(at+80:at+83)),char(data(at+84:at+163)), ...
        char(data(at+164:at+166)),char(data(at+167:at+246)),char(data(at+247:at+250))};
    expected = {'World Geodetic System 1984','WGE','World Geodetic System 1984','WE','Geodetic','GEOD'};
    for k = 1:6
        report = snipIssue(report,~strcmp(strtrim(fields{k}),expected{k}), ...
            'SNIPIlluminationDatum','ILLUMB.datum','Use the specified WGS 84 and geodetic datum names and codes.','17.7');
    end
    mask = uint32(0); for k = at+251:at+253, mask = bitshift(mask,8)+uint32(data(k)); end
    f = bitget(mask,1:24) ~= 0; at = at+254+80*f(24);
    count = number(data,at,3); at = at+3;
    stride = 49+10*f(23)+10*f(22)+6*f(21)+3*f(20)+10*others*f(19)+ ...
        10*f(18)+5*f(17)+21*f(16)+5*f(15)+21*f(14)+7*f(11)+ ...
        bands*(17*f(13)+17*f(12)+16*f(11)+17*others*f(10)+33*f(9));
    found = false; geometry = false;
    for k = 1:count
        if strcmp(char(data(at:at+13)),char(header.idatim))
            found = true;
            position = at+49+10*f(23)+10*f(22)+6*f(21)+3*f(20)+10*others*f(19);
            if f(18)
                geometry = geometry || all(isfinite([number(data,position,5) number(data,position+5,5)]));
            end
        end
        at = at+stride;
    end
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end
