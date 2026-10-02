function collection = fixtureMIECollection()
    %fixtureMIECollection - Supply two layers, two camera sets and two intervals
    base = fixtureFile(); ids = cell(1,3);
    camera = struct('camera_id','','camera_desc','Synthetic camera','layer_id','VIS', ...
        'idlvl',1,'ialvl',0,'iloc',[0 0],'nrows',5,'ncols',7);
    cameras = repmat(camera,1,3); cores = repmat(nfx.MICIDA.camera('',''),1,3);
    for k = 1:3
        ids{k} = sprintf('10000000-0000-4000-8000-%012.0f',k);
        cameras(k).camera_id = ids{k}; cameras(k).idlvl = k;
        cores(k) = nfx.MICIDA.camera(ids{k},nfx.MICIDA.coreIdentifier(32,ids(k)));
    end
    cameras(2).layer_id = 'IR'; cameras(2).ialvl = 1; cameras(2).iloc = [0 7];
    cameras(3).ialvl = 1; cameras(3).iloc = [5 0];
    sets = [struct('cameras',cameras(1:2)) struct('cameras',cameras(3))];
    layers = [nfx.MIMCSA(layer_id='VIS',nominal_frame_rate=25,min_frame_rate=25,max_frame_rate=25, ...
        mi_req_decoder='NC',mi_req_profile='Not Applicable',mi_req_level='N/A') ...
        nfx.MIMCSA(layer_id='IR',nominal_frame_rate=20,min_frame_rate=20,max_frame_rate=20, ...
        mi_req_decoder='NC',mi_req_profile='Not Applicable',mi_req_level='N/A')];
    windows = [struct('time_interval_index',1,'start_timestamp','20260915120000.000000000','end_timestamp','20260915120001.000000000') ...
        struct('time_interval_index',2,'start_timestamp','20260915120001.000000000','end_timestamp','20260915120002.000000000')];
    collection = nfx.MIECollection(base_name='synthetic',header=base.header,layers=layers, ...
        camera_sets=nfx.CAMSDA(camera_sets=sets),camera_ids=nfx.MICIDA(cameras=cores),intervals=nfx.TMINTA(windows));
    for interval = 1:2
        for cameraIndex = 1:3
            count = 1+(interval == 1 && cameraIndex == 1);
            for blockIndex = 1:count
                bands = 2; type = 'uint16'; rate = 25;
                if cameraIndex == 2, bands = 1; type = 'uint8'; rate = 20; end
                data = reshape(cast(1:5*7*bands*3,type),5,7,bands,3);
                [~,image,timing] = fixtureMotion(data); image = image.removeTRE(image.tre_ids(1));
                timing.camera_id = ids{cameraIndex}; timing.time_interval_index = interval;
                timing.nominal_frame_rate = rate; timing.dt = uint64(1000/rate);
                start = sprintf('202609151200%02.0f.%09.0f',interval-1,(blockIndex-1)*500000000);
                finish = sprintf('202609151200%02.0f.%09.0f',interval-1,(blockIndex-1)*500000000+250000000);
                timing.base_timestamp = start;
                collection = collection+nfx.MotionBlock(image,timing=timing,start_timestamp=start,end_timestamp=finish);
            end
        end
    end
end
