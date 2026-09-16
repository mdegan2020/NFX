function [valid,needsComment] = historyCompression(value,prior) %#codegen
    %historyCompression - Validate complete compression codes and operation flags
    value = char(value);
    valid = false;
    needsComment = false;
    width = 5; count = 2;
    if prior, width = 4; count = 3; end
    if numel(value) ~= width*count, return; end
    zeroSeen = false;
    for k = 1:count
        word = value((k-1)*width+1:k*width);
        if all(word == '0')
            if k == 1, return; end
            zeroSeen = true;
            continue
        end
        if zeroSeen, return; end
        code = word(1:4);
        known = any(strcmp(code,{'DP43','DC13','DC23','NJNL','NJQ0','NJQ1','NJQ2', ...
            'C11D','C12S','C12H','M11D','M12S','M12H','C207','C214','C223','C245', ...
            'C3Q0','C3Q1','C3Q2','C3Q3','C3Q4','C3Q5','M3Q0','M3Q1','M3Q2','M3Q3','M3Q4','M3Q5', ...
            'C4LO','M4LO','C5NL','M5NL','NC00','NM00','I1Q1','I1Q2','I1Q3','I1Q4','I1Q5', ...
            'WVLO','WVNL','JP20','J2NL','J2VL','J2LO','NONE','UNKC'}));
        other = any(strcmp(code,{'OTLO','OTNL'}));
        if ~(known || (~prior && other)), return; end
        needsComment = needsComment || other;
        if ~prior && (~any(word(5) == 'CE0') || (strcmp(code,'NONE') && word(5) ~= '0')), return; end
    end
    valid = true;
end
