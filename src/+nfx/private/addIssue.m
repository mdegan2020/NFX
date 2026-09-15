function report = addIssue(report, failed, id, field, message, reference) %#codegen
    %addIssue - Append a failed validation rule to a report
    if failed
        report.valid = false;
        report.issues(end + 1) = struct('severity', 'error', 'id', id, ...
            'field', field, 'message', message, 'reference', reference);
    end
end
