function [records, outputs] = compareCases(callable, cases, reference)
    %compareCases - Run all sizes through one callable and check independent data
    if nargin < 3, reference = {}; end
    item = struct('name', '', 'passed', false, 'diagnostic', '');
    records = repmat(item, 1, numel(cases)); outputs = cell(1, numel(cases));
    for k = 1:numel(cases)
        records(k).name = cases(k).name;
        try
            actual = callable(cases(k).args{:}); outputs{k} = actual;
            fields = fieldnames(cases(k).expected);
            for j = 1:numel(fields)
                field = fields{j};
                assert(isequaln(actual.(field), cases(k).expected.(field)), ...
                    'nfxkit:Expected', 'Independent expectation differs: %s.', field);
            end
            if ~isempty(reference)
                assert(isequaln(actual, reference{k}), 'nfxkit:Parity', ...
                    'Generated output differs from MATLAB reference.');
            end
            records(k).passed = true;
        catch exception
            records(k).diagnostic = getReport(exception, 'extended', 'hyperlinks', 'off');
        end
    end
end
