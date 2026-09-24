function count = sourceLength(data) %#codegen
    %sourceLength - Return the physical length of a byte source
    if isstruct(data)
        count = data.length;
    else
        count = numel(data);
    end
end
