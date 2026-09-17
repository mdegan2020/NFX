function [obj, reader] = readRSMParameters(reader) %#codegen
    %readRSMParameters - Decode a bounded conditional parameter definition
    obj = nfx.RSMParameters();
    [active, reader] = reader.number(2, 1, 36, true);
    [aptyp, reader] = reader.choice('IG');
    [loctyp, reader] = reader.choice('RN');
    if reader.ok
        obj.aptyp = aptyp;
        obj.loctyp = loctyp;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.nsfx = value;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.nsfy = value;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.nsfz = value;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.noffx = value;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.noffy = value;
    end
    [value, reader] = reader.number( ...
        21, -9.99999999999999e99, 9.99999999999999e99, false, true);
    if reader.ok
        obj.noffz = value;
    end
    if strcmp(loctyp, 'R')
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.xuol = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.yuol = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.zuol = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.xuxl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.xuyl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.xuzl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.yuxl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.yuyl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.yuzl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.zuxl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.zuyl = value;
        end
        [value, reader] = reader.number( ...
            21, -9.99999999999999e99, 9.99999999999999e99, false, true);
        if reader.ok
            obj.zuzl = value;
        end
    end
    [basis, reader] = reader.choice('YN');
    if strcmp(aptyp, 'I')
        [total, reader] = reader.number(2, 1, 99, true);
        [rows, reader] = reader.count(2, 3, 99);
        [rp, reader] = reader.numbers(rows * 3, 1, 0, 5, true);
        [columns, reader] = reader.count(2, 3, 99);
        [cp, reader] = reader.numbers(columns * 3, 1, 0, 5, true);
        if reader.ok && total ~= rows + columns
            reader = reader.fail('InvalidCount', ...
                'Image parameter counts disagree.');
        end
        if reader.ok
            obj.xpwrr = rp(1:3:end);
            obj.ypwrr = rp(2:3:end);
            obj.zpwrr = rp(3:3:end);
            obj.xpwrc = cp(1:3:end);
            obj.ypwrc = cp(2:3:end);
            obj.zpwrc = cp(3:3:end);
        end
    else
        [total, reader] = reader.count(2, 4, 16);
        identifiers = cell(1, total);
        allowed = {'OFFX', 'OFFY', 'OFFZ', 'ROTX', 'ROTY', 'ROTZ', ...
            'SCAL', 'XRTX', 'XRTY', 'XRTZ', 'YRTX', 'YRTY', 'YRTZ', ...
            'ZRTX', 'ZRTY', 'ZRTZ'};
        for k = 1:total
            [identifiers{k}, reader] = reader.text(4, false);
            if reader.ok && ~any(strcmp(identifiers{k}, allowed))
                reader = reader.fail('InvalidField', ...
                    'Unknown ground parameter identifier.');
            end
        end
        if reader.ok
            obj.gsapid = identifiers;
        end
    end
    if strcmp(basis, 'Y')
        [columns, reader] = reader.number(2, 1, 99, true);
        if reader.ok && (columns ~= total || active * columns > 1296)
            reader = reader.fail('InvalidCount', ...
                'Basis dimensions exceed the supported parameter layout.');
        end
        [values, reader] = reader.numbers(active * columns, 21, ...
            -9.99999999999999e99, 9.99999999999999e99);
        if reader.ok
            obj.ael = reshape(values, columns, active).';
        end
    end
    if reader.ok && obj.npar ~= active
        reader = reader.fail('InvalidCount', ...
            'Active parameter count disagrees with its definition.');
    end
    if reader.ok
        report = obj.validate();
        if ~report.valid
            reader = reader.fail('InvalidMetadata', report.issues(1).message);
        end
    end
end
