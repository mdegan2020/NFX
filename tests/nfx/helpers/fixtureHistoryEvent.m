function event = fixtureHistoryEvent()
    %fixtureHistoryEvent - Supply a minimal synthetic processing event
    event = nfx.HistoryEvent(pdate='20260915120100',psite='NFXTEST',pas='NFX',ibpp=9,obpp=9);
end
