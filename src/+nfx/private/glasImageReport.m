function report = glasImageReport(records,header) %#codegen
    %glasImageReport - Check image-local model and exploitation relationships
    report = newReport('GLAS/GFM image associations'); names = {records.tag};
    exploitation = find(strcmp(names,'CSEXRB')); rolling = find(strcmp(names,'CSRLSB')); warping = find(strcmp(names,'CSWRPB'));
    report = glasIssue(report,numel(exploitation) > 1 || numel(rolling) > 1 || numel(warping) > 1, ...
        'GLASMultiplicity','tre_ids','Supply at most one unwrapped record of each GLAS/GFM TRE type per image context.');
    if numel(exploitation) ~= 1, return; end
    info = glasImageInfo(records(exploitation).payload);
    report = glasIssue(report,~isempty(info.target) && ~strcmp(info.target,char(textField(header.tgtid,17))), ...
        'GLASTarget','CSEXRB.exploitation.tgt_id','The supplied primary target ID must match the image subheader.');
    report = glasIssue(report,~isempty(strtrim(info.targetTime)) && ~strcmp(info.targetTime,char(header.idatim)), ...
        'GLASTargetTime','CSEXRB.exploitation.tgt_date_time','The supplied primary target time must match image IDATIM.');
    report = glasIssue(report,~isempty(rolling) && (info.sensor ~= 'F' || info.rolling ~= 1), ...
        'GLASRollingShutter','CSRLSB/CSEXRB','A rolling-shutter grid requires a framing sensor with ROLLING_SHUTTER_FLAG=1.');
    for k = warping
        report = glasIssue(report,char(records(k).payload(2)) ~= info.sensor,'GLASWarpingSensor','CSWRPB/CSEXRB', ...
            'Warping and exploitation metadata must identify the same sensor type.');
    end
    timing = find(strcmp(names,'MTIMSA'));
    if info.sensor == 'F' && info.timeLocation == 1
        report = glasIssue(report,numel(timing) ~= 1,'GLASFrameTiming','CSEXRB/MTIMSA', ...
            'TIME_STAMP_LOC=1 requires exactly one MTIMSA in the effective image context.');
    end
end
