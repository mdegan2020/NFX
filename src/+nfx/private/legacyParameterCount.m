function count = legacyParameterCount(groups) %#codegen
    count = 0;
    for k = 1:numel(groups)
        count = count + (sqrt(1 + 8 * numel(groups(k).errcvg)) - 1) / 2;
    end
end
