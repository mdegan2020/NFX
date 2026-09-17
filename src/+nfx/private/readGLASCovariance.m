function [value, reader] = readGLASCovariance(reader, count, pages) %#codegen
    %readGLASCovariance - Restore symmetric pages from row-major triangles
    value = zeros(0, 0);
    if ~reader.ok, return, end
    words = count * (count + 1) / 2 * pages;
    [terms, reader] = reader.numbers(words, 21, ...
        -9.99999999999999e99, 9.99999999999999e99);
    if ~reader.ok, return, end
    value = zeros(count, count, pages); at = 0;
    for page = 1:pages
        for row = 1:count
            for col = row:count
                at = at + 1;
                value(row, col, page) = terms(at);
                value(col, row, page) = terms(at);
            end
        end
    end
end
