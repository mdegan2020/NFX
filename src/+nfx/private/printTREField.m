function printTREField(name, value) %#codegen
    %printTREField - Show bounded values without retaining a decoded graph
    fprintf('    %-28s ', name);
    if ischar(value) && (isrow(value) || isempty(value))
        count = min(numel(value), 80);
        fprintf('''%s''', value(1:count));
        if numel(value) > count
            fprintf(' ... (%.0f characters)', numel(value));
        end
    elseif isnumeric(value) || islogical(value)
        count = min(numel(value), 8);
        fprintf('[');
        for k = 1:count
            if k > 1
                fprintf(' ');
            end
            if isa(value, 'uint64')
                fprintf('%u', value(k));
            else
                fprintf('%.15g', double(value(k)));
            end
        end
        if numel(value) > count
            fprintf(' ...');
        end
        fprintf(']');
        if ~isvector(value) || numel(value) > count
            printShape(size(value), class(value));
        end
    else
        printShape(size(value), class(value));
    end
    fprintf('\n');
end

function printShape(shape, type) %#codegen
    %printShape - Summarize nested or large values by dimensions and type
    fprintf(' (');
    for k = 1:numel(shape)
        if k > 1
            fprintf('x');
        end
        fprintf('%.0f', shape(k));
    end
    fprintf(' %s)', type);
end
