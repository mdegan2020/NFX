function report = snipIssue(report,condition,id,field,message,section) %#codegen
    %snipIssue - Identify a requirement in the pinned spectral profile
    report = addIssue(report,condition,id,field,message,['SNIP 1.2 CN1, ' section]);
end
