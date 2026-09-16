function report = glasIssue(report,failed,id,field,message) %#codegen
    %glasIssue - Attach the GLAS/GFM association reference to a failed rule
    report = addIssue(report,failed,id,field,message,'STDI-0002-2 Appendix M, M.5-M.7 and Tables M.6-1 through M.6-7');
end
