function value = partialCoordinate(number,width,places) %#codegen
    %partialCoordinate - Encode geographic precision with trailing hyphens
    if places == 0
        prefix = [decimalField(number,width-7,0,true) uint8('.')];
    else
        prefix = decimalField(number,width-6+places,places,true);
    end
    value = [prefix repmat(uint8('-'),1,6-places)];
end
