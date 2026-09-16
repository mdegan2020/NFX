function value = fixtureAircraft()
    %fixtureAircraft - Synthetic metadata using a published MSI sensor mode
    value = nfx.ACFTB(sensor_id_type='MMFR',sensor_id='AG3607',mplan=24,pdate='20260915');
end
