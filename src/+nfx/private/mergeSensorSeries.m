function [merged, uncertainties, layout] = mergeSensorSeries(groups, uncertainties) %#codegen
    %mergeSensorSeries - Consolidate validated chunks into logical type groups
    merged = groups([]);
    layout = repmat(struct('type', '', 'first', 0, 'count', 0), ...
        1, numel(groups));
    sources = zeros(1, numel(groups));
    for k = 1:numel(groups)
        group = groups(k);
        at = find(strcmp({merged.time_stamp_type}, group.time_stamp_type), 1);
        first = 1;
        if isempty(at)
            merged(end + 1) = group;
            at = numel(merged);
        else
            first = numel(merged(at).time_stamp_time) + 1;
            merged(at).time_stamp_time = ...
                [merged(at).time_stamp_time group.time_stamp_time];
            merged(at).time_stamp_value.numeric = ...
                [merged(at).time_stamp_value.numeric group.time_stamp_value.numeric];
            merged(at).time_stamp_value.text = ...
                [merged(at).time_stamp_value.text; group.time_stamp_value.text];
        end
        sources(k) = at;
        layout(k) = struct('type', group.time_stamp_type, ...
            'first', first, 'count', numel(group.time_stamp_time));
    end
    if numel(merged) == numel(groups)
        layout = layout([]); return
    end
    for k = 1:numel(uncertainties)
        uncertainties(k).uncertainty_first_type = remapIndex( ...
            uncertainties(k).uncertainty_first_type, sources, layout);
        uncertainties(k).uncertainty_second_type = remapIndex( ...
            uncertainties(k).uncertainty_second_type, sources, layout);
    end
end

function word = remapIndex(word, sources, layout) %#codegen
    %remapIndex - Translate an already validated module-12 uncertainty target
    if numel(word) < 3 || ~any(strcmp(word(1:3), {'12c', '12d'}))
        return
    end
    dot = find(word == '.', 1);
    outer = str2double(word(4:dot - 1));
    inner = str2double(word(dot + 1:end));
    word = sprintf('%s%.0f.%.0f', word(1:3), ...
        sources(outer), inner + layout(outer).first - 1);
end
