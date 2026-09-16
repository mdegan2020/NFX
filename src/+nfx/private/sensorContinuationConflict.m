function conflict = sensorContinuationConflict(records,firstPrefix,laterPrefix,reference,position,pixels,geo,angle) %#codegen
    %sensorContinuationConflict - Prevent conflicting reference-state repeats
    conflict = false;
    if numel(records) < 2, return; end
    pixelReference = ~all(reference(13:20) == uint8('-')) && ~all(reference(21:28) == uint8('-'));
    anchor = reference(1:12);
    if pixelReference, anchor = reference(13:28); end
    widths = [11 12 11 8 8 8]; at = 1;
    baseline = repmat({zeros(1,0,'uint8')},1,6);
    for k = 1:6, baseline{k} = position(at:at+widths(k)-1); at = at+widths(k); end
    latest = baseline; supplied = false(1,6);
    for k = 1:numel(records)
        offset = laterPrefix;
        if k == 1, offset = firstPrefix; end
        [mentioned,updated,seen] = scanReferences(records(k).payload(offset+1:end),12, ...
            anchor,~pixelReference,geo,angle);
        if k > 1
            for j = 1:6
                if supplied(j) && ~mentioned(j) && ~isequal(latest{j},baseline{j})
                    conflict = true; return
                end
            end
        end
        for j = 1:6
            if seen(j), latest{j} = updated{j}; supplied(j) = true; end
        end
        if k == 1 && pixelReference
            [~,updated,seen] = scanReferences(pixels,16,anchor,true,geo,angle);
            for j = 1:6
                if seen(j), latest{j} = updated{j}; supplied(j) = true; end
            end
        end
    end
end

function [mentioned,updated,seen] = scanReferences(bytes,referenceWidth,anchor,compare,geo,angle) %#codegen
    %scanReferences - Inspect already validated looping samples at one anchor
    mentioned = false(1,6); seen = false(1,6);
    updated = repmat({zeros(1,0,'uint8')},1,6);
    groups = str2double(char(bytes(1:2))); at = 3;
    for k = 1:groups
        type = char(bytes(at:at+2)); count = str2double(char(bytes(at+3:at+6)));
        info = sensFieldInfo(type,geo,angle); width = referenceWidth+info.width; at = at+7;
        if strcmp(type(1:2),'06') && any(type(3) == 'abcdef')
            field = double(type(3))-96; mentioned(field) = true;
            if compare
                samples = reshape(bytes(at:at+width*count-1),width,count);
                match = find(all(samples(1:referenceWidth,:) == anchor',1),1,'last');
                if ~isempty(match), updated{field} = samples(referenceWidth+1:end,match)'; seen(field) = true; end
            end
        end
        at = at+width*count;
    end
end
