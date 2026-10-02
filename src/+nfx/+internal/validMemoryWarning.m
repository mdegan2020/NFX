function valid = validMemoryWarning(value)
    %validMemoryWarning - Accept a nonnegative byte threshold or Inf
    valid = isa(value, 'double') && isscalar(value) && isreal(value) && ...
        ~isnan(value) && value >= 0;
end
