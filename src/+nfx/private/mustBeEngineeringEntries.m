function mustBeEngineeringEntries(value) %#codegen
    %mustBeEngineeringEntries - Require one uniform descriptor schema
    fields = {'englbl', 'engmtxc', 'engmtxr', 'engtyp', 'engdts', ...
        'engdatu', 'engdata'};
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            numel(value) > 999 || numel(fieldnames(value)) ~= 7 || ...
            ~all(isfield(value, fields))
        error('nfx:EngineeringEntries', ...
            'Supply a row of at most 999 engineering descriptor structs.');
    end
    for k = 1:numel(value)
        e = value(k);
        mustBeAscii(e.englbl, 99);
        mustBeMetadata(e.engmtxc, 1, 9999, true);
        mustBeMetadata(e.engmtxr, 1, 9999, true);
        mustBeMetadata(e.engdts, 1, 9, true);
        mustBeAscii(e.engtyp, 1);
        mustBeAscii(e.engdatu, 2);
        mustBeByteRow(e.engdata);
        if any(isnan([e.engmtxc e.engmtxr e.engdts])) || ...
                numel(char(e.engtyp)) ~= 1 || ...
                ~any(char(e.engtyp) == 'BISRCA')
            error('nfx:EngineeringEntries', ...
                'Supply finite dimensions, byte width, and a known type.');
        end
    end
end
