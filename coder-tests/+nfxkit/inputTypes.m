function types = inputTypes(name)
    %inputTypes - Keep primitive types and variable dimensions explicit
    row4 = coder.typeof(0, [1 4], [false true]);
    raw = coder.typeof(uint8(0), [1 65536], [false true]);
    switch name
        case 'storage', types = {row4, row4};
        case 'rpc'
            types = {coder.typeof(uint8(0), [1 1041], [false true])};
        case 'timing'
            types = {coder.typeof(uint64(0), [1 4], [false true]), uint64(1)};
        case 'groups', types = {0};
        case 'engineering'
            types = {coder.typeof(uint16(0), [8 8], [true true]), 0};
        case {'native8', 'native16', 'file8', 'file16'}, types = {raw};
        case 'mixed'
            types = {coder.typeof(uint8(0), [4 5], [true true]), ...
                coder.typeof(uint16(0), [4 5], [true true])};
        otherwise, error('nfxkit:Probe', 'Unknown probe name.');
    end
end
