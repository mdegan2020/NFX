function valid = rsmCovariance(matrix,strict) %#codegen
    %rsmCovariance - Check supplied symmetric positive semidefinite matrices
    if nargin < 2, strict = false; end
    valid = ismatrix(matrix) && ~isempty(matrix) && size(matrix,1) == size(matrix,2) && ...
        all(isfinite(matrix(:))) && all(diag(matrix) >= 0);
    if ~valid, return; end
    variance = diag(matrix); positive = variance > 0;
    zeroRows = matrix(~positive,:); zeroColumns = matrix(:,~positive);
    valid = all(zeroRows(:) == 0) && all(zeroColumns(:) == 0) && (~strict || all(positive));
    if ~valid || ~any(positive), return; end
    scale = sqrt(variance(positive));
    correlation = matrix(positive,positive)./(scale*scale');
    residual = correlation-correlation';
    valid = all(isfinite(correlation(:))) && max(abs(residual(:))) <= 1e-10 && ...
        max(abs(correlation(:))) <= 1+1e-10;
    if ~valid, return; end
    if strict
        [~,failure] = chol((correlation+correlation')/2);
        valid = failure == 0;
    else
        eigenvalues = eig((correlation+correlation')/2);
        valid = all(eigenvalues >= -1e-10);
    end
end
