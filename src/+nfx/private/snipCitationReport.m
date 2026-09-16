function report = snipCitationReport(texts,header,level) %#codegen
    %snipCitationReport - Check the standard citation and its text attachment
    report = newReport('SNIP citation'); indices = zeros(1,0);
    for k = 1:numel(texts)
        if strcmp(strtrim(char(texts(k).header.textid)),'SNIPSTD'), indices(end+1) = k; end
    end
    report = snipIssue(report,numel(indices) ~= 1,'SNIPCitationCount','texts', ...
        'Include exactly one SNIPSTD standard-citation text segment.','18');
    if numel(indices) ~= 1, return; end
    item = texts(indices); h = item.header; data = char(item.data);
    title = 'IMPLEMENTATION PROFILE, OTHER APPLICABLE STANDARDS AND DATASET DESCRIPTION DOCS';
    report = snipIssue(report,h.txtalvl ~= level || ~strcmp(char(h.txtdt),char(header.fdt)) || ...
        ~strcmp(strtrim(char(h.txtitl)),title) || ~isempty(item.tre_records), ...
        'SNIPCitationHeader','texts.SNIPSTD.header', ...
        'Use the prescribed title, file timestamp, first spectral display level and no text TREs.','Table 18-1');
    remainder = strrep(data,char([13 10]),'');
    report = snipIssue(report,~endsWith(data,char([13 10])) || any(ismember(remainder,char([10 12 13]))), ...
        'SNIPCitationLines','texts.SNIPSTD.data','Terminate every citation line with CR/LF.','18.1');
    lines = strsplit(data,char([13 10]));
    if isempty(lines{end}), lines(end) = []; end
    expected = strsplit(snipCitationData(),char([13 10]));
    report = snipIssue(report,isempty(lines) || ~strcmp(lines{1},expected{1}), ...
        'SNIPCitationTitle','texts.SNIPSTD.data','Use the standard TEXT_SEGMENT_TITLE opening line.','18.1');
    fields = {'DOC_TITLE','DOC_VERSION','DOC_DATE','DOC_ID','DOC_TYPE','DOC_URL','PRODUCT_CERT_DATE', ...
        'AUTHOR_NAME','AUTHOR_ORG','AUTHOR_PHONE','AUTHOR_EMAIL','AUTHOR_ADDRESS', ...
        'CUSTODIAN_ORG','CUSTODIAN_AGENCY','CUSTODIAN_NAME','CUSTODIAN_PHONE','CUSTODIAN_EMAIL','CUSTODIAN_ADDRESS','CUSTODIAN_URL'};
    citation = 0; previous = 0; seen = false(1,numel(fields)); first = cell(1,numel(fields));
    contributors = zeros(1,2); numbered = false(1,2);
    for k = 2:numel(lines)
        line = lines{k};
        if startsWith(line,'STANDARD CITATION ')
            if citation > 0, report = requiredFields(report,seen,citation); end
            citation = citation+1;
            report = snipIssue(report,~strcmp(line,sprintf('STANDARD CITATION %.0f',citation)), ...
                'SNIPCitationNumber','texts.SNIPSTD.data','Number citations consecutively from one.','18.1');
            previous = 0; seen(:) = false; contributors(:) = 0; numbered(:) = false; continue
        end
        match = 0; index = 0; delimiter = strfind(line,': ');
        if ~isempty(delimiter)
            label = line(1:delimiter(1)-1);
            for f = 1:numel(fields)
                if strcmp(label,fields{f}), match = f; break; end
                if any(f == [8 13]) && startsWith(label,[fields{f} '_'])
                    suffix = label(numel(fields{f})+2:end); index = str2double(suffix);
                    if ~isempty(suffix) && all(suffix >= '0' & suffix <= '9') && index >= 1 && isfinite(index)
                        match = f;
                    end
                    break
                end
            end
        end
        report = snipIssue(report,citation == 0 || match == 0,'SNIPCitationField','texts.SNIPSTD.data', ...
            'Use the named citation components after a numbered citation heading.','Table 18-2');
        if match == 0, continue; end
        value = line(delimiter(1)+2:end);
        if any(match == [8 13])
            group = 1+(match == 13);
            valid = (index == 0 && contributors(group) == 0) || ...
                (index == contributors(group)+1 && (contributors(group) == 0 || numbered(group)));
            report = snipIssue(report,~valid,'SNIPCitationContributors','texts.SNIPSTD.data', ...
                'Number multiple author names or custodian organizations consecutively from one.','18.1.2.11-18.1.2.12');
            contributors(group) = contributors(group)+1; numbered(group) = index > 0;
        end
        report = snipIssue(report,citation == 1 && match >= 8 && match <= 12,'SNIPCitationAuthors', ...
            'texts.SNIPSTD.data','The NTB prohibits an author citation for the SNIP standard.','18.1.2.11');
        % Author and custodian blocks can repeat in their documented order.
        restart = (match == 8 && previous >= 8 && previous <= 12) || (match == 13 && previous >= 13);
        report = snipIssue(report,isempty(strtrim(value)) || (match < previous && ~restart) || ...
            (match <= 7 && seen(match)),'SNIPCitationOrder','texts.SNIPSTD.data', ...
            'Supply nonblank citation components in the defined order.','Table 18-2');
        previous = match; seen(match) = true;
        if citation == 1, first{match} = value; end
        if match == 3 || match == 7
            valid = match == 7 && strcmp(value,'----------');
            if numel(value) == 10 && value(5) == '-' && value(8) == '-'
                valid = valid || knownDate([value(1:4) value(6:7) value(9:10)],8);
            end
            report = snipIssue(report,~valid,'SNIPCitationDate','texts.SNIPSTD.data', ...
                'Use a calendar date YYYY-MM-DD, or ---------- for unknown certification.','Table 18-2');
        end
    end
    report = snipIssue(report,citation == 0,'SNIPCitationNumber','texts.SNIPSTD.data', ...
        'Include the SNIP as citation one.','18.2');
    if citation > 0, report = requiredFields(report,seen,citation); end
    for k = 1:6
        prefix = [fields{k} ': ']; target = expected{k+2};
        report = snipIssue(report,~strcmp(first{k},target(numel(prefix)+1:end)), ...
            'SNIPCitationVersion','texts.SNIPSTD.data','Citation one must identify the pinned SNIP 1.2 CN1 standard.','Table 18-3');
    end
end

function report = requiredFields(report,seen,citation) %#codegen
    %requiredFields - Require the document identity and a custodian block
    complete = seen(1) && seen(13);
    if citation == 1, complete = complete && all(seen(1:7)); end
    report = snipIssue(report,~complete, ...
        'SNIPCitationRequired','texts.SNIPSTD.data','Supply the document fields and at least one custodian organization.','18.1');
end
