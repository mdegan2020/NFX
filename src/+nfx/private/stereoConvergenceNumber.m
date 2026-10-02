function [bytes, valid] = stereoConvergenceNumber(value) %#codegen
    %stereoConvergenceNumber - Encode the two specified angle precisions
    [bytes, valid] = treNumber(value, 5, 2 - (value >= 100), ...
        false, true, false);
end
