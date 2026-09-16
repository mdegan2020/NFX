function report = mieIssue(report,condition,id,field,message) %#codegen
    %mieIssue - Attach a collection relationship diagnostic and reference
    report = addIssue(report,condition,id,field,message,'NGA.STND.0044 1.3.3, 6.2-6.13; STDI Appendix AF');
end
