function [chunks, origins] = restoreSensorSeries(groups, layout) %#codegen
    %restoreSensorSeries - Reuse imported chunk order while its shape matches
    chunks = groups;
    origins = repmat(struct('source', 0, 'first', 1), 1, numel(groups));
    for k = 1:numel(groups), origins(k).source = k; end
    if isempty(layout), return; end

    % A changed type, count, or repeated logical type requires fresh packing.
    sources = zeros(1, numel(layout));
    counts = zeros(1, numel(groups));
    next = 1;
    for k = 1:numel(layout)
        at = find(strcmp({groups.type}, layout(k).type));
        if ~isscalar(at), return; end
        if counts(at) == 0
            if at ~= next, return; end
            next = next + 1;
        end
        if layout(k).first ~= counts(at) + 1 || ...
                layout(k).count > size(groups(at).data, 2) - counts(at)
            return
        end
        sources(k) = at;
        counts(at) = counts(at) + layout(k).count;
    end
    for k = 1:numel(groups)
        if counts(k) ~= size(groups(k).data, 2), return; end
    end
    chunks = repmat(struct('type', '   ', 'data', zeros(0, 0, 'uint8')), ...
        1, numel(layout));
    origins = repmat(struct('source', 0, 'first', 1), 1, numel(layout));
    for k = 1:numel(layout)
        at = sources(k);
        samples = layout(k).first + (0:layout(k).count - 1);
        chunks(k) = struct('type', groups(at).type, ...
            'data', groups(at).data(:, samples));
        origins(k) = struct('source', at, 'first', layout(k).first);
    end
end
