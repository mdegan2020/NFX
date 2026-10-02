function valid = validUpperCovariance(values, count) %#codegen
    valid = isscalar(count) && isfinite(count) && count >= 1 && ...
        count <= 98 && fix(count) == count && ...
        numel(values) == count * (count + 1) / 2;
    if ~valid, return; end
    matrix = zeros(count);
    at = 1;
    for row = 1:count
        for column = row:count
            matrix(row, column) = values(at);
            matrix(column, row) = values(at);
            at = at + 1;
        end
    end
    valid = rsmCovariance(matrix);
    if valid
        [~, ok, rounded] = rsmNumbers(values, false);
        for row = 1:count
            start = (row - 1) * (2 * count - row + 2) / 2 + 1;
            for column = row:count
                matrix(row, column) = rounded(start + column - row);
                matrix(column, row) = matrix(row, column);
            end
        end
        valid = ok && rsmCovariance(matrix);
    end
end
