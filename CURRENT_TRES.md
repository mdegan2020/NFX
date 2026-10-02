# Published TRE coverage

NFX provides concrete, editable classes for 94 TRE tags. This expansion adds
51 classes. Each has field validation, serialization, bounded deserialization,
snapshot attachment, typed retrieval, display, and file round-trip tests.
Repeated entries use homogeneous structures; wire counts derive from their
contents. Existing image-storage and product-profile limits still apply.

This is **not a claim of support for every current registered TRE**. The
inventory is pinned to the July 2025 STDI-0002 Fundamentals workbook and the
available individual appendices. The live registry could not be checked
through its human-verification challenge on October 2, 2026.

## Added classes

| Area | TREs |
| --- | --- |
| Comments, identification, release and country metadata | COMNTA, SYSIDA, RELCCA, CCINFA |
| Commercial and airborne imagery | CSEPHA, CSEXRA, CSPROA, CSSFAA, EXOPTA, EXPLTB, MENSRB, MTIRPB, PATCHB, SECTGA, STDIDC, STREOB, USE00A |
| Coordinates, accuracy and source descriptions | ACCPOB, ACCHZB, ACCVTB, BNDPLB, GEOLOB, GRDPSB, MAPLOB, PRJPSB, REGPTB, REGPTC, SNSPSB, SOURCB |
| Photographic interpretation | PIAEQA, PIAEVA, PIAIMC, PIAPEB, PIAPRD, PIATGB |
| Radar | ASTORA, ISACPA, ISASIA, ISATPA |
| Indexed RSM adjustment and covariance layouts | RSMAPA, RSMDCA, RSMECA |
| Attributes, conversion, compression and provenance | ATTPTA, BCHIPA, FACCBB, IOMAPA, J2KLRB, MITOCA, NBLOCA, PIXMTA, S2EVPA |

Most attach directly to images. PIAPRD and MITOCA attach to files.
ATTPTA, BNDPLB, MTIRPB, PIAIMC and PRJPSB support files and images.
CCINFA, COMNTA, RELCCA and SYSIDA support files, images and text.
PIAEQA, PIAEVA, PIAPEB and PIATGB support images and text. Owner and wrapper placement
checks run when attaching or validating metadata.

## Working with repeated fields

Use a class's entry factory to obtain the complete structure, then fill in
its mnemonic fields. Arrays retain insertion order. For example:

```matlab
point = nfx.REGPTC.pointsEntry();
point.pid = 'CONTROL1';
point.lon = -120;
point.lat = 35;
point.dix = 100;
point.diy = 200;
point.uniaah = 'M';
point.aah = 1.25;

registration = nfx.REGPTC(points=point);
image = image + registration;
[copy, found, status] = image.REGPTC();
```

`copy` is independent of the attachment. Use the established removal and
attachment API to replace a snapshot. Repeated physical instances remain
separate unless a class explicitly documents series assembly. All new typed
lookups accept an occurrence index or `ID=attachmentID`.

## Validation boundaries

For the unchecked RSM, BCHIPA, ATTPTA, NBLOCA, J2KLRB, CSEPHA and PIXMTA
relationships below, NFX emits `TREContextUnchecked` and sets
`report.complete` / `status.metadata_complete` false. CCINFA does the same
when it contains detail bytes. Valid payloads can still be read and written.

- Metadata encoders do not implement new image codecs or sensor-model
  calculations. IOMAPA and S2EVPA describe conversions; they do not apply
  them to pixels. BCHIPA formulas are retained as text and never executed.
  S2EVPA checks effective image band bounds, overlapping ranges, and
  conflicting BANDSB/PIXMTA transformations, including wrapped metadata.
- BCHIPA instances and ATTPTA associations are editable, but automatic
  BCHIPA splitting/assembly, whole-series coverage and external image
  association validation are not implemented.
- NBLOCA offsets are supplied metadata. NFX does not calculate or certify
  offsets into unsupported compressed frame streams. J2KLRB does not add
  JPEG 2000 encoders or verify its claims against an external codestream.
- CSEPHA supports individual payloads. Checking a complete multi-instance
  ephemeris series and product-specific sample requirements is external.
- RSMAPA, RSMDCA and RSMECA validate their own parameter indexing, coordinate
  frames and covariance matrices. Full relationships with other model
  records and images are not checked for these older layouts.
- GeoSDE fields do not add coordinate transformations or complete GeoSDE
  product validation. BNDPLC retains its existing topology checks.
- CCINFA preserves XML or GZIP detail bytes. External XML schemas and GZIP
  content validation remain outside its field decoder.
- Fixed-format decoders retain the existing canonical-encoding boundary:
  an otherwise numeric field using a different spelling may return
  `NoncanonicalPayload`. Imported bytes remain available in the TRE record.
- CSSFAA's current table prints seven-byte offsets but range examples that
  need more bytes. Its `oppoff_x/y/z` values are validated seven-character
  signed decimal strings, preserving precision without guessing a format.
  NUM_BANDS uses one byte, consistent with its published payload formula
  and the earlier NCDRD table.
- PRJPSB uses an 80-byte PRN, consistent with its base payload length and
  published product examples; the local appendix's three-byte entry is
  inconsistent with both. PIAPEB DOB preserves the printed eight-digit
  `CCMMDDYY` field without reinterpreting it as `YYYYMMDD`.

## Remaining definitions

The following remain opaque, preserved TRE records. They can be retained or
removed without a concrete deserializer; NFX reports incomplete metadata
validation. Opaque preservation is not counted as concrete support.

| Group | Tags | Missing prerequisite |
| --- | --- | --- |
| DPPDB | IMASDA, IMCBDA, IMRFCA, MSDIRA, PPRSDA, PRADAA, PRADRA, PSUPDA, PTPRAA, RGRDRA, SEGSPA, SISDDA, SSDPDA | An authorized current MIL-PRF-89034 definition; the current revision is controlled distribution C |
| Native XML | FRMSGA, ILLUMA, SODDXA, SORBXA | Complete imported ISM/IC-ID/IC-ARH schema bundles and a schema-aware editable XML implementation; the local top-level XSDs alone do not establish full validation |

FIRELA still has no available authoritative definition. RSMIDC remains
unknown, with no alias or inferred layout. Draft vector extensions are not
counted as current implementations. MTIMFA remains supported through its
existing motion-imagery path, although it is absent from this catalog table.

## Verification and compatibility

`PublishedTRETest` uses independent expected bytes for every new class,
malformed inputs and damaged-field probes, typed lookups, snapshot removal,
display, wrappers, and complete file read/write round trips.
`PublishedTREBoundaryTest` adds nested conditional fields, binary byte order,
large offsets, lookup tables, Unicode lengths and covariance checks.

On October 2, 2026, all 2,895 MATLAB tests passed on R2026a Update 4,
including 576 tests for this expansion and 43 OpenJPEG tests. A fresh
GPT-6 Astra Extra High review identified five correctness issues; all were
fixed and covered by regression tests before this final run.

Toolbox implementation uses static dispatch and applicable `%#codegen`
annotations. Generated development scripts and reference material are not
runtime dependencies. MATLAB Coder compilation remains unverified because
no local license is available. Tests run locally on R2026a; R2023b execution
is not claimed.

## Reference notes

The [NGA technical-board page](https://gwg.nga.mil/gwg/focus-groups/NITFS_Technical_Board_(NTB).html)
links the current standards registry. The
[DLA specification listing](https://quicksearch.dla.mil/qsDocDetails.aspx?ident_number=206235)
identifies the controlled current DPPDB revision. CSSFAA's field widths are
also recorded in Table 3.7-1 of the
[2010 NCDRD](https://csda-maxar-pdfs.s3.amazonaws.com/NCDRD_18February2010.pdf).
The PRJPSB width is corroborated by Table 7-3 of the
[ASNARO-2 Product Guide](https://jeoss.co.jp/asnaro2/images/ASNARO-2-Product-Guide_icon_202110_EN.pdf).
