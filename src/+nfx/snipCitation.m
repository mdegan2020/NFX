function value = snipCitation(header,imageLevel) %#codegen
%snipCitation - Create the pinned SNIP standard-citation text segment
%   VALUE = nfx.snipCitation(HEADER,IMAGELEVEL) returns SNIPSTD with the
%   file creation timestamp and first spectral image's display level.
%   The citation identifies SNIP 1.2 CN1 and declares certification unknown.
%   It does not certify the supplied imagery or its supporting metadata.
%
%   See also nfx.TextSegment, nfx.File
    arguments
        header (1,1) nfx.FileHeader
        imageLevel {mustBeMetadata(imageLevel,1,999,1),mustBeFinite} = 1
    end
    textHeader = nfx.TextHeader(textid='SNIPSTD',txtalvl=imageLevel,txtdt=header.fdt,tsclas=header.fsclas, ...
        txtitl='IMPLEMENTATION PROFILE, OTHER APPLICABLE STANDARDS AND DATASET DESCRIPTION DOCS');
    value = nfx.TextSegment(snipCitationData(),header=textHeader);
end
