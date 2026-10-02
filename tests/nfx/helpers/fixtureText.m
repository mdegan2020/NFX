function value = fixtureText(data)
    %fixtureText - Explicit synthetic standard text with fixed metadata
    arguments
        data = 'Synthetic text'
    end
    value = nfx.TextSegment(data, header=nfx.TextHeader(textid='TEXT001', ...
        txtdt='20260915120000', txtitl='Synthetic text', tsclas='U'));
end
