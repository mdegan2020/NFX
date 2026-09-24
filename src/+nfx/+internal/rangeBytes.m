function [value, ok] = rangeBytes(bytes, ranges, offset, count) %#codegen
    %rangeBytes - Resolve a physical range in retained metadata bytes
    value = zeros(1, 0, 'uint8'); ok = false;
    if count == 0, ok = true; return; end
    at = offset;
    if ~isempty(ranges)
        selected = find(offset >= ranges(:, 1) & ...
            offset + count <= ranges(:, 1) + ranges(:, 2), 1);
        if isempty(selected), return; end
        at = ranges(selected, 3) + offset - ranges(selected, 1);
    end
    if at < 0 || count < 0 || at + count > numel(bytes), return; end
    value = bytes(at + (1:count)); ok = true;
end
