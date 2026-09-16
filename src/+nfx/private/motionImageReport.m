function report = motionImageReport(records,header,frames) %#codegen
    %motionImageReport - Bind declared temporal block counts to native pixels
    report = newReport('MIE4NITF image storage');
    reference = 'NGA.STND.0044 1.3.3, 6.7, 6.9.2; STDI Appendix AF Table AF-8';
    timing = find(strcmp({records.tag},'MTIMSA'));
    report = addIssue(report,numel(timing) > 1 || (frames > 1 && numel(timing) ~= 1), ...
        'MotionTiming','MTIMSA','Supply exactly one MTIMSA for a multi-frame segment.',reference);
    report = addIssue(report,frames < 1 || frames > 4294967295,'MotionFrames', ...
        'data','Store between one and UINT32_MAX frames.',reference);
    report = addIssue(report,frames > 1 && ~endsWith(char(header.icat),'.M'), ...
        'MotionCategory','header.icat','Motion imagery ICAT must end in .M.',reference);
    for k = timing
        bytes = records(k).payload(145:148); count = 0;
        for j = 1:4, count = count*256+double(bytes(j)); end
        report = addIssue(report,count ~= frames,'MotionFrameCount','MTIMSA.number_frames', ...
            'Declared frame count must equal the fourth pixel dimension.',reference);
    end
end
