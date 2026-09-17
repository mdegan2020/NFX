function records = emptyTRERecords() %#codegen
    %emptyTRERecords - Create the common variable-length snapshot array
    %   Record count and payload length vary independently. Each physical
    %   payload is a uint8 row of at most 99985 bytes; no maximum-sized
    %   payload buffer is allocated for an empty record.
    template = struct('tag', '      ', ...
        'payload', zeros(1, 0, 'uint8'), 'id', 0);
    coder.varsize('template.payload', [1 99985], [false true]);
    records = repmat(template, 1, 0);
    coder.varsize('records', [1 Inf], [false true]);
end
