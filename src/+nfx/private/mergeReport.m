function report = mergeReport(report, child, prefix) %#codegen
    %mergeReport - Append issues with their owning object location
    for k = 1:numel(child.issues)
        issue = child.issues(k);
        issue.field = [prefix issue.field];
        report.issues(end + 1) = issue;
    end
    report.valid = report.valid && child.valid;
end
