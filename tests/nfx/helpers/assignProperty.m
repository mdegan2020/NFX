function obj = assignProperty(obj, name, value)
    %assignProperty - Exercise assignment validators inside verifyError callbacks
    obj.(name) = value;
end
