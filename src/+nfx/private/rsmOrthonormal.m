function valid = rsmOrthonormal(matrix,rightHanded) %#codegen
    %rsmOrthonormal - Check row orthonormality before and after serialization
    valid = ~isempty(matrix) && all(isfinite(matrix(:))) && all(abs(matrix(:)) <= 1);
    if ~valid, return; end
    residual = matrix*matrix'-eye(size(matrix,1));
    valid = max(abs(residual(:))) <= 1e-10;
    if rightHanded, valid = valid && det(matrix) > 0; end
end
