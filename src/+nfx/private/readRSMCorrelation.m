function [obj, reader] = readRSMCorrelation(reader, form) %#codegen
    %readRSMCorrelation - Decode either published correlation layout
    obj = nfx.RSMCorrelation();
    if isempty(form)
        [form, reader] = reader.choice('YN');
    end
    if strcmp(form, 'Y')
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.ac = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.alpc = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.betc = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.tc = value;
        end
    else
        [count, reader] = reader.count(1, 42, 9);
        values = zeros(2, count);
        for k = 1:count
            [values(1, k), reader] = reader.number(21, 0, 1);
            [values(2, k), reader] = ...
                reader.number(21, 0, 9.99999999999999e99);
        end
        if reader.ok
            obj.corseg = values(1, :);
            obj.tauseg = values(2, :);
        end
    end
    if reader.ok
        report = obj.validate();
        if ~report.valid
            reader = reader.fail('InvalidMetadata', report.issues(1).message);
        end
    end
end
