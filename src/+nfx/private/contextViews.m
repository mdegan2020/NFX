function views = contextViews(contexts,images) %#codegen
    %contextViews - Present effective snapshots to existing model validators
    record = struct('tag','      ','payload',zeros(1,0,'uint8'),'byte_offset',0,'file_index',0);
    item = struct('header',nfx.ImageHeader(),'tre_records',repmat(record,1,0),'number_frames',1);
    views = repmat(item,1,numel(contexts));
    for k = 1:numel(contexts)
        image = images(contexts(k).image);
        views(k).header = image.header; views(k).tre_records = contexts(k).records;
        views(k).number_frames = image.number_frames;
    end
end
