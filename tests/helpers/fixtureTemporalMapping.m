function value = fixtureTemporalMapping()
    %fixtureTemporalMapping - Supply one camera and one temporal block
    block = struct('start_timestamp','20260915120000.000000001', ...
        'end_timestamp','20260915120001.000000001','image_seg_index',1);
    camera = struct('camera_id','01234567-89ab-4def-8123-456789abcdef','temporal_blocks',block);
    value = nfx.MTIMFA(layer_id='LAYER',camera_set_index=1,time_interval_index=7,cameras=camera);
end
