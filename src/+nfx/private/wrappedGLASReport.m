function report = wrappedGLASReport(records) %#codegen
    %wrappedGLASReport - Guard model wrappers until effective contexts resolve
    report = newReport('GLAS/GFM wrapper associations');
    for k = 1:numel(records)
        prefix = wrapperLength(records(k).tag,records(k).payload,1);
        if prefix == 0, continue; end
        data = records(k).payload; at = prefix+1;
        while at <= numel(data)
            tag = char(data(at:at+5)); length = str2double(char(data(at+6:at+10))); first = at+11;
            if any(strcmp(tag,{'CSEXRB','CSRLSB','CSWRPB'}))
                report = glasIssue(report,true,'GLASContextPending','wrappers', ...
                    'Wrapped GLAS/GFM metadata require effective frame/context resolution, which is not yet available.');
                return
            end
            prefix = wrapperLength(tag,data,first);
            if prefix > 0, at = first+prefix; else, at = first+length; end
        end
    end
end

function value = wrapperLength(tag,data,first) %#codegen
    %wrapperLength - Read the prefix of an internally validated wrapper
    value = 0;
    if strcmp(tag,'FSYNWA'), value = 18;
    elseif strcmp(tag,'FASYWA'), value = 48;
    elseif strcmp(tag,'CONTXA'), value = 7+str2double(char(data(first+3:first+6)));
    end
end
