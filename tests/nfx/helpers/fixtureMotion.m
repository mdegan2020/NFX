function [file,image,timing] = fixtureMotion(data,representation)
    %fixtureMotion - Create a synthetic native temporal block with exact timing
    if nargin < 1, data = reshape(uint16(1:210),5,7,2,3); end
    if nargin < 2
        representation = 'MULTI';
        if size(data,3) == 1, representation = 'MONO'; end
    end
    [base,image] = fixtureFile(data,representation); image = image.removeTRE(1);
    image.header.icat = [image.header.icat '.M'];
    timing = nfx.MTIMSA(image_seg_index=1,layer_id='VIS',camera_set_index=1, ...
        camera_id='10000000-0000-4000-8000-000000000001',time_interval_index=1, ...
        temp_block_index=1,nominal_frame_rate=25,reference_frame_num=1, ...
        base_timestamp='20260915120000.000000000',dt_multiplier=uint64(1000000), ...
        number_frames=size(data,4),dt=uint64(40));
    image = image+timing; file = nfx.File(header=base.header)+image;
end
