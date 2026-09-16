function last = rsmParameterEnd(data,first) %#codegen
    %rsmParameterEnd - Locate the end of a validated parameter definition
    count = str2double(char(data(first:first+1)));
    kind = char(data(first+2)); local = char(data(first+3));
    at = first+130+252*(local == 'R');
    basis = char(data(at)); at = at+1;
    if kind == 'I'
        rows = str2double(char(data(at+2:at+3))); at = at+4+3*rows;
        columns = str2double(char(data(at:at+1))); at = at+2+3*columns;
    else
        ground = str2double(char(data(at:at+1))); at = at+2+4*ground;
    end
    if basis == 'Y'
        basisCount = str2double(char(data(at:at+1))); at = at+2+21*count*basisCount;
    end
    last = at-1;
end
