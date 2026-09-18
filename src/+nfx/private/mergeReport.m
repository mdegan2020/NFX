function report = mergeReport(report, child, prefix) %#codegen
    %mergeReport - Append issues with their owning object location
    for k = 1:numel(child.issues)
        issue = child.issues(k);
        issue.field = [prefix issue.field];
        report.issues(end + 1) = issue;
    end
    report.valid = report.valid && child.valid;
    report.complete = report.complete && child.complete;
    errors = strcmp({report.issues.severity}, 'error');
    report.issues = [report.issues(errors) report.issues(~errors)];
end
