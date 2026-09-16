function value = referenceMIISCheck(text)
    %referenceMIISCheck - Independent check using published Table 14 rows
    p = ['0123456789ABCDEF';'02468ACE9BDF1357';'048C9D15BF3726AE'; ...
         '0891B32AF76E4CD5';'09B2F64D7EC5813A';'0BF47C83E51A926D'; ...
         '0F78E1965A2DB4C3';'07E952BCAD43F816';'0E5BA4F1D386792C'; ...
         '05AFD872369CEB41';'0AD739E46CB15F82';'0D3E6B58C1F2A794'; ...
         '0365CFA91274DEB8';'06CA17DB24E835F9';'0C1D2E3F48596A7B'];
    q = flipud(p([2:end 1],:));
    text = upper(text); text = text(isstrprop(text,'xdigit'));
    accumulated = [0 0];
    for k = 1:numel(text)
        index = hex2dec(text(k))+1; row = mod(k,15)+1;
        accumulated = bitxor(accumulated,[hex2dec(p(row,index)) hex2dec(q(row,index))]);
    end
    value = sprintf('%X%X',accumulated);
end
