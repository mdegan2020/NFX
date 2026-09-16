function report = glasHeaderContextReport(records,des) %#codegen
    %glasHeaderContextReport - Validate exploitation in a hypothetical file header
    report = newReport('GLAS/GFM file-header context');
    selected = find(strcmp({records.tag},'CSEXRB'));
    report = glasIssue(report,numel(selected) > 1,'GLASMultiplicity','CSEXRB', ...
        'Each effective file-header context permits at most one CSEXRB.');
    for k = selected
        plane = glasImageInfo(records(k).payload);
        for d = 1:size(plane.des,1)
            matches = 0;
            for j = 1:numel(des)
                info = glasDESInfo(des(j));
                matches = matches+(info.verified && strcmpi(info.uuid,plane.des(d,:)));
            end
            report = glasIssue(report,matches ~= 1,'GLASMissingDES','CSEXRB.assoc_des_uuid', ...
                'Each effective file-header forward UUID must resolve to one unchanged typed DES.');
        end
    end
end
