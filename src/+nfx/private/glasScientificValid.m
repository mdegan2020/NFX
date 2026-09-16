function valid = glasScientificValid(values) %#codegen
    %glasScientificValid - Check scientific fields without retaining a payload
    valid = true;
    for k = 1:numel(values)
        [~,fits] = rsmNumber(values(k),false);
        if ~fits, valid = false; return; end
    end
end
