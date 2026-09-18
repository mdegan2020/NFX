function report = addIssue(report, failed, id, field, message, reference) %#codegen
    %addIssue - Append a failed validation rule to a report
    if failed
        hasWarnings = ~isempty(report.issues) && ...
            strcmp(report.issues(end).severity, 'warning');
        report.valid = false;
        report.issues(end + 1) = struct('severity', 'error', 'id', id, ...
            'field', field, 'message', message, 'reference', reference);
        if hasWarnings
            errors = strcmp({report.issues.severity}, 'error');
            report.issues = [report.issues(errors) report.issues(~errors)];
        end
    end
end
