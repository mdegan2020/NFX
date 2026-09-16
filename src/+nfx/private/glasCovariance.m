function [valid,value] = glasCovariance(matrix,encode) %#codegen
    %glasCovariance - Check PSD and encode the upper triangle in row order
    value = zeros(1,0,'uint8'); valid = rsmCovariance(matrix);
    if ~valid, return; end
    n = size(matrix,1); rounded = zeros(n); at = 0;
    if encode, value = zeros(1,21*n*(n+1)/2,'uint8'); end
    for row = 1:n
        for col = row:n
            [word,fits] = rsmNumber(matrix(row,col),false);
            if ~fits, valid = false; return; end
            rounded(row,col) = str2double(char(word)); rounded(col,row) = rounded(row,col);
            if encode, value(at+(1:21)) = word; at = at+21; end
        end
    end
    valid = rsmCovariance(rounded);
end
