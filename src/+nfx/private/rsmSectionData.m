function [value,report] = rsmSectionData(iid,edition,coefficients,rowCount,columnCount,rowSize,columnSize) %#codegen
    %rsmSectionData - Encode polynomial/grid section-identification layouts
    report = newReport('RSM section identification');
    report = rsmIssue(report,isempty(strtrim(char(edition))),'Required','edition','Supply the common RSM support-data edition.');
    total = rowCount*columnCount;
    report = rsmIssue(report,~isfinite(total) || total < 1 || total > 256,'SectionCount', ...
        'row_count/column_count','The product of section counts must be between 1 and 256.');
    [polynomial,valid] = rsmNumbers(coefficients,false);
    report = rsmIssue(report,~valid,'Coefficient','coefficients','All twenty quadratic coefficients must be known and representable.');
    [sizes,valid] = rsmNumbers([rowSize columnSize],false);
    report = rsmIssue(report,~valid || rowSize <= 0 || columnSize <= 0,'SectionSize', ...
        'row_size/column_size','Both section sizes must be positive and representable.');
    value = [textField(iid,80) textField(edition,40) polynomial ...
        uint8(sprintf('%03.0f%03.0f%03.0f',rowCount,columnCount,total)) sizes];
end
