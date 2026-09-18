function value = emptyEngineeringEntries() %#codegen
    %emptyEngineeringEntries - Homogeneous descriptors with raw byte rows
    prototype = struct('englbl', '', 'engmtxc', 1, 'engmtxr', 1, ...
        'engtyp', 'B', 'engdts', 1, 'engdatu', 'UD', ...
        'engdata', zeros(1, 0, 'uint8'));
    value = repmat(prototype, 1, 0);
end
