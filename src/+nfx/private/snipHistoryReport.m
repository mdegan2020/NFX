function [report,cropped] = snipHistoryReport(data,header,fileHeader) %#codegen
    %snipHistoryReport - Check lineage schema and the recorded output type
    report = newReport('SNIP HISTOA'); cropped = false;
    report = snipIssue(report,~strcmp(char(data(38:39)),'00'),'SNIPHistoryMapping','HISTOA.lutid', ...
        'Spectral history uses LUTID 00.','17.6.3.2');
    report = snipIssue(report,any(strcmp(char(data(33:36)),{'GEOR','ORTH'})), ...
        'SNIPRectification','HISTOA.pe','Rectified products are outside the selected profile.','6.4 and 17.6');
    count = number(data,40,2); at = 42; inheritedAlgorithm = false;
    prefixes = {'PROCEV_','ALGO_','NAME_','PHONE_','EMAIL_'};
    lastName = ''; lastPhone = ''; inheritedEvent = '';
    for event = 1:count
        eventTime = char(data(at:at+13)); site = strtrim(char(data(at+14:at+23)));
        software = strtrim(char(data(at+24:at+33))); comments = number(data,at+34,1); at = at+35;
        report = snipIssue(report,isempty(site) || isempty(software),'SNIPHistorySoftware','HISTOA.event', ...
            'Identify the processing site and application.','17.6.3.3-17.6.3.4');
        report = snipIssue(report,event == 1 && comments == 0,'SNIPHistoryComments','HISTOA.event.ipcom', ...
            'Record the processing event and its algorithm.','17.6.3.5');
        lastKind = 0; eventName = '';
        for c = 1:comments
            comment = strtrim(char(data(at:at+79))); at = at+80; kind = 0;
            for p = 1:numel(prefixes), if startsWith(comment,prefixes{p}), kind = p; break; end, end
            report = snipIssue(report,(event == 1 && c == 1 && kind ~= 1) || (kind > 0 && kind < lastKind), ...
                'SNIPHistoryCommentOrder','HISTOA.event.ipcom','Use PROCEV first and preserve the defined prefix order.','Table 17-3');
            if kind == 0, continue; end
            report = snipIssue(report,numel(comment) <= numel(prefixes{kind}), ...
                'SNIPHistoryCommentValue','HISTOA.event.ipcom','A comment prefix requires its supplied value.','17.6.3.5');
            lastKind = kind;
            if kind == 1
                eventName = [eventName ' ' strtrim(comment(8:end))]; %#ok<AGROW>
                cropped = cropped || strcmp(comment,'PROCEV_Spatially Chipped: Cropped');
                outside = startsWith(comment,'PROCEV_Band Chipped') || ...
                    startsWith(comment,'PROCEV_Geo-rectification') || startsWith(comment,'PROCEV_Ortho-rectification') || ...
                    startsWith(comment,'PROCEV_Spatially Chipped: Resampled');
                report = snipIssue(report,outside,'SNIPProcessingScope','HISTOA.event.ipcom', ...
                    'Spectral chipping, rectification and resampled spatial chips are outside this profile.','17.6 and 20.1');
            elseif kind == 2, inheritedAlgorithm = true;
            elseif kind == 3, lastName = strtrim(comment(6:end));
            elseif kind == 4, lastPhone = strtrim(comment(7:end));
            end
        end
        if ~isempty(eventName), inheritedEvent = strtrim(eventName); end
        report = snipIssue(report,~registeredEvent(inheritedEvent),'SNIPHistoryEvent', ...
            'HISTOA.event.ipcom','Use a processing event defined in SNIP Table 17-4.','Table 17-4');
        report = snipIssue(report,~inheritedAlgorithm,'SNIPHistoryAlgorithm','HISTOA.event.ipcom', ...
            'Supply ALGO before relying on unchanged inherited algorithm information.','17.6.3.5');
        % Skip the validated event's conditional image-processing fields.
        at = at+16; rotate = number(data,at,1); at = at+1+8*(rotate == 1);
        asymmetric = number(data,at,1); at = at+1+14*(asymmetric == 1);
        projected = number(data,at,1); sharpen = number(data,at+1,1); at = at+2+4*(sharpen == 1);
        magnify = number(data,at,1); at = at+1+7*(magnify == 1);
        dynamic = number(data,at,1); at = at+1+12*(dynamic == 1);
        tonal = number(data,at,1); at = at+1+4*(tonal == 1);
        report = snipIssue(report,projected == 1,'SNIPRectification','HISTOA.event.proj_flag', ...
            'Projected processing is outside the nonrectified profile.','6.4 and 17.6');
        if event == count
            report = snipIssue(report,number(data,at+1,2) ~= header.abpp || ...
                ~strcmp(strtrim(char(data(at+3:at+5))),header.pvtype),'SNIPHistoryOutput','HISTOA.event.obpp/opvtype', ...
                'The final event must describe the stored significant-bit representation.','17.6.3.6');
            report = snipIssue(report,mieTimeEarlier(fileHeader.fdt,eventTime),'SNIPHistoryTime','HISTOA.event.pdate', ...
                'The last processing event cannot follow file creation.','17.6');
        end
        at = at+16;
    end
    report = snipIssue(report,~isempty(lastName) && ~strcmp(lastName,strtrim(char(fileHeader.oname))), ...
        'SNIPHistoryOriginator','HISTOA.NAME/ONAME','The last supplied NAME must match the file originator.','17.6.3.5.3.3');
    report = snipIssue(report,~isempty(lastPhone) && ~contains(lastPhone,strtrim(char(fileHeader.ophone))), ...
        'SNIPHistoryPhone','HISTOA.PHONE/OPHONE','The last supplied PHONE must include the file contact number.','17.6.3.5.3.4');
end

function valid = registeredEvent(value) %#codegen
    %registeredEvent - Recognize the pinned processing vocabulary and templates
    valid = any(strcmp(value,{'Bad Pixel Repair','Band-to-Band Registration', ...
        'Band-to-Band Relative Calibration','Band Chipped: Cropped','Band Chipped: Resampled', ...
        'Geo-rectification','Illumination Normalization','Radiometric Calibration', ...
        'Spatially Chipped: Cropped','Spatially Chipped: Resampled'}));
    valid = valid || (startsWith(value,'Format Conversion from ') && contains(value,' to ') && ~endsWith(value,' to')) || ...
        (startsWith(value,'Atmospheric Compensation to ') && contains(value,' Weather Source ')) || ...
        startsWith(value,'Ortho-rectification with Elevation Source ') || startsWith(value,'Band Chipped ');
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end
