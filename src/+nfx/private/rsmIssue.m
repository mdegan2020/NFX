function report = rsmIssue(report,failed,id,field,message) %#codegen
    %rsmIssue - Record an RSM serialization or relationship failure
    report = addIssue(report,failed,id,field,message, ...
        'STDI-0002-1 Appendix U (administrative update 2024-05), Set AB');
end
