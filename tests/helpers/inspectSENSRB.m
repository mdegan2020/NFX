function out = inspectSENSRB(bytes)
    %inspectSENSRB - Independent Appendix Z field and loop decoder for tests
    at = 1; out.fields = struct(); out.flags = repmat('N',1,10);
    out.flags(1) = text(1);
    if out.flags(1) == 'Y'
        names = {'sensor','sensor_uri','platform','platform_uri','operation_domain','content_level', ...
            'geodetic_system','geodetic_type','elevation_datum','length_unit','angular_unit', ...
            'start_date','start_time','end_date','end_time','generation_count','generation_date','generation_time'};
        widths = [25 32 25 32 10 1 5 1 3 2 3 8 14 8 14 2 8 10];
        for k = 1:numel(names), out.general.(names{k}) = text(widths(k)); end
    end
    layouts = {[],[20 8 8 8 8 8 8 8 1],[2 9 9 12 12 12 9 12 12 12 12 8], ...
        [15 3 8 8 8 8 10 10 8 8],[12 8 8],[11 12 11 8 8 8], ...
        [1 10 9 10 1 9 9 10],repmat(10,1,9),repmat(10,1,4),[9 9 9]};
    for module = 2:10
        if module == 5 || module == 6, out.flags(module) = 'Y';
        else, out.flags(module) = text(1);
        end
        if out.flags(module) == 'Y'
            widths = layouts{module};
            for k = 1:numel(widths), out.fields.(sprintf('i%02d%c',module,96+k)) = text(widths(k)); end
            if module == 4
                out.transform_count = number(1);
                for k = 1:out.transform_count, out.fields.(sprintf('i04%c',107+k)) = text(12); end
            end
        end
    end
    out.points = struct('type',{},'data',{});
    count = number(2);
    for k = 1:count
        type = text(25); n = number(3); data = NaN(6,n);
        widths = [8 8 10 11 6 8];
        for j = 1:n, for q = 1:6, data(q,j) = number(widths(q)); end, end
        out.points(k) = struct('type',type,'data',data);
    end
    out.series = struct('type',{},'time',{},'value',{}); count = number(2);
    for k = 1:count
        type = text(3); n = number(4); width = sampleWidth(type);
        times = zeros(1,n); values = repmat(' ',n,width);
        for j = 1:n, times(j) = number(12); values(j,:) = text(width); end
        out.series(k) = struct('type',type,'time',times,'value',values);
    end
    out.pixels = struct('type',{},'row',{},'column',{},'value',{}); count = number(2);
    for k = 1:count
        type = text(3); n = number(4); width = sampleWidth(type);
        rows = zeros(1,n); columns = rows; values = repmat(' ',n,width);
        for j = 1:n, rows(j) = number(8); columns(j) = number(8); values(j,:) = text(width); end
        out.pixels(k) = struct('type',type,'row',rows,'column',columns,'value',values);
    end
    out.uncertainties = struct('first',{},'second',{},'value',{},'literal',{}); count = number(3);
    for k = 1:count
        first = text(11); second = text(11); literal = text(10);
        out.uncertainties(k) = struct('first',first,'second',second,'value',str2double(literal),'literal',literal);
    end
    out.additional = struct('name',{},'width',{},'value',{}); count = number(3);
    for k = 1:count
        name = text(25); width = number(3); n = number(4); values = repmat(' ',n,width);
        for j = 1:n, values(j,:) = text(width); end
        out.additional(k) = struct('name',name,'width',width,'value',values);
    end
    assert(at == numel(bytes)+1,'oracle:SENSRB','Unexpected data after SENSRB modules.');
    function value = text(count)
        assert(at+count-1 <= numel(bytes),'oracle:SENSRB','Truncated SENSRB field.');
        value = char(bytes(at:at+count-1)); at = at+count;
        assert(all(value >= ' ' & value <= '~'),'oracle:SENSRB','Invalid SENSRB character.');
    end
    function value = number(count)
        word = text(count); value = str2double(word);
        assert(isfinite(value) || all(word == '-'),'oracle:SENSRB','Invalid numeric field.');
    end
    function width = sampleWidth(type)
        m = str2double(type(1:2)); j = double(type(3))-96;
        if m == 4 && j == 11, width = 1;
        elseif m == 4 && j > 11, width = 12;
        else, width = layouts{m}(j);
        end
    end
end
