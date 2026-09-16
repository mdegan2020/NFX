function report = snipChipReport(data,records,header,fileHeader,cropped) %#codegen
    %snipChipReport - Check a declared spatial crop and its parent identity
    report = newReport('SNIP spatial crop');
    output = zeros(2,4); original = zeros(2,4);
    for k = 1:8
        output(k) = number(data,17+12*(k-1),12); original(k) = number(data,113+12*(k-1),12);
    end
    shifts = original-output;
    valid = number(data,1,2) == 0 && number(data,3,10) == 1 && ...
        all(all(abs(shifts-shifts(:,1)) < 1e-9)) && all(abs(shifts(:,1)-round(shifts(:,1))) < 1e-9);
    report = snipIssue(report,~valid,'SNIPChipTransform','ICHIPB', ...
        'This profile supports integer spatial crops with an available original-image mapping.','20.1');
    report = snipIssue(report,~cropped,'SNIPChipHistory','HISTOA', ...
        'Record the spatial crop in HISTOA.','20.1.3.2');
    parent = false;
    for k = find(strcmp({records.tag},'MATESA'))
        value = records(k).payload; length = number(value,59,4); at = 63+length;
        identity = strcmp(strtrim(char(value(43:58))),'FTITLE') && ...
            strcmp(strtrim(char(value(63:at-1))),strtrim(char(fileHeader.ftitle))) && ...
            strcmp(strtrim(char(value(1:42))),strtrim(char(header.isorce)));
        groups = number(value,at,4); at = at+4;
        for g = 1:groups
            relationship = strtrim(char(value(at:at+23))); count = number(value,at+24,4); at = at+28;
            for m = 1:count
                source = strtrim(char(value(at:at+41))); type = strtrim(char(value(at+42:at+57)));
                length = number(value,at+58,4); mate = strtrim(char(value(at+62:at+61+length))); at = at+62+length;
                parent = parent || (identity && strcmp(relationship,'PARENT') && strcmp(type,'FTITLE') && ...
                    ~isempty(source) && ~isempty(mate) && ~strcmp(mate,strtrim(char(fileHeader.ftitle))));
            end
        end
    end
    report = snipIssue(report,~parent,'SNIPChipParent','MATESA', ...
        'Identify this file and its parent FTITLE and sensor source with a PARENT relationship.','20.1.3.1');
end

function value = number(data,at,width) %#codegen
    %number - Read a previously validated ASCII numeric field
    value = str2double(char(data(at:at+width-1)));
end
