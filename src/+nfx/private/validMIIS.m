function [valid,reason] = validMIIS(value) %#codegen
    %validMIIS - Validate structure-version-01 MIIS textual identifiers
    value = upper(char(value)); valid = false;
    reason = 'Use version-01 MIIS text with one to three UUIDs and a two-digit check value.';
    if ~any(numel(value) == [47 87 127]), return; end
    count = (numel(value)-7)/40;
    if value(5) ~= ':' || value(end-2) ~= ':', return; end
    prefix = value(1:4); checksum = value(end-1:end);
    if ~hexadecimal(prefix) || ~hexadecimal(checksum) || ~strcmp(prefix(1:2),'01'), return; end
    content = repmat(' ',1,4+32*count); content(1:4) = prefix;
    for k = 1:count
        offset = 5+40*(k-1); uuid = value(offset+(1:39));
        if any(uuid(5:5:35) ~= '-'), return; end
        digits = uuid(mod(1:39,5) ~= 0);
        if ~hexadecimal(digits), return; end
        if k < count && value(offset+40) ~= '/', return; end
        content(4+32*(k-1)+(1:32)) = digits;
        if ~any(digits(13) == '145') || ~any(digits(17) == '89AB') || ...
                (digits(13) == '1' && all(digits(21:32) == '0'))
            reason = 'MIIS component UUIDs require RFC variant 10 and version 1, 4 or 5; version 1 requires a nonnull node.';
            return
        end
    end
    usage = hex2dec(prefix(3:4));
    components = (mod(floor(usage/32),4) ~= 0)+(mod(floor(usage/8),4) ~= 0)+(bitand(usage,4) ~= 0);
    if bitand(usage,129) ~= 0 || (bitand(usage,2) ~= 0 && (usage ~= 2 || count ~= 1)) || ...
            (bitand(usage,2) == 0 && components ~= count)
        reason = 'The usage byte must match the present foundational components or a single minor identifier.';
        return
    end
    if ~strcmp(miisCheckValue(content),checksum)
        reason = 'The MIIS hexadecimal check value does not match the supplied identifier.';
        return
    end
    valid = true; reason = '';
end

function valid = hexadecimal(value) %#codegen
    %hexadecimal - Recognize uppercase hexadecimal digits without punctuation
    valid = all((value >= '0' & value <= '9') | (value >= 'A' & value <= 'F'));
end
