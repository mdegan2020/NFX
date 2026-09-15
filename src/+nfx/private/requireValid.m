function requireValid(report) %#codegen
    %requireValid - Reject serialization when validation fails
    if ~report.valid
        error('nfx:Invalid', '%s: %s', ...
            report.issues(1).field, report.issues(1).message);
    end
end
