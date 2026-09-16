function mustBeMIEObjects(value,type) %#codegen
    %mustBeMIEObjects - Require a typed object row without silent reshaping
    if ~isa(value,type) || ~(isrow(value) || isequal(size(value),[0 0]))
        error('nfx:MIEObjects','Expected a row of %s values.',type);
    end
end
