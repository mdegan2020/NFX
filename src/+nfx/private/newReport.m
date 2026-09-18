function report = newReport(scope) %#codegen
    %newReport - Create a validation report with homogeneous issue records
    issue = struct('severity', 'error', 'id', '', 'field', '', ...
        'message', '', 'reference', '');
    report = struct('valid', true, 'complete', true, 'scope', scope, 'issues', repmat(issue, 1, 0));
end
