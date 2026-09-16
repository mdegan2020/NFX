function value = sensValues(input,width) %#codegen
    %sensValues - Store numeric or text samples in a uniform value structure
    value = struct('numeric',zeros(1,0),'text',repmat(' ',0,width));
    if isa(input,'double')
        mustBeMetadataArray(input,-Inf,Inf,false);
        if ~(isrow(input) || isequal(size(input),[0 0]))
            error('nfx:SensorValues','Numeric SENSRB samples must be a double row.');
        end
        value.numeric = input;
    else
        value.text = metadataRows(input,width,Inf,false);
    end
end
