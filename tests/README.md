# NFX test and compatibility notes

From the repository root, run `runTests()` or `runTests(Coverage=true)` in MATLAB. The runner errors on invalid test files, failed tests, or incomplete tests. Base MATLAB supplies `matlab.unittest` and statement coverage; Image Processing Toolbox supplies `nitfread`, `nitfinfo`, and `isnitf`. Tests require no local reference library, design documents, GDAL, or NITRO.

## What the suite checks

| Suite | Checks |
| --- | --- |
| `CoderKitTest` | All portable MATLAB reference probes, independent byte expectations, failure classification, source export, copied-folder execution, hashes and result archives without a Coder license |
| `TREDeserializeTest`, `TREInspectionTest` | Concrete byte round trips, malformed payloads and selectors, scalar missing results, stable IDs and order, nested wrappers, SENSRB continuations, independent copies, bounded display, and exact uint64 metadata |
| `ReaderIndexTest`, `NativePixelReaderTest` | Independent literal headers, source bounds, optional fields, B/F/T native samples, partial blocks and malformed layouts |
| `ReaderMetadataTest`, `FileReadTest` | Complete native file reads, raw snapshots, overflow ownership, continuation groups, independent edits, resource limits and I/O failures |
| `UnknownTRETest` | Opaque snapshots, owner/area preservation, wrappers, overflow, removal, incomplete semantic reports and independent DES invariants |
| `SensorDESReadTest` | Typed DES variants, header/payload agreement, raw-versus-verified trust, shared model associations and malformed support data |
| `JPEG2000ReadTest` | Native backend pixels, both profiles, untouched codestream preservation, missing/failing codecs and detected corruption warnings |
| `CollectionReadTest`, `CollectionManifestReadTest` | Complete collections and explicit lists, exact timing above flintmax, cross-file contexts, quick looks, missing/unavailable blocks, 650 members and FILE002 |
| `ReaderAcceptanceTest` | Supported RSM/ECF GLAS SNIP round trips, profile boundaries, preserving unrelated content during image edits and the public reading example |
| `RPC00BTest` | Exact field widths, signs, coefficient order, rounding, exponent limits, unset values, strict types, and nonzero normalization |
| `HeaderTest` | Required metadata, ASCII, dates, classification, representations, derived layout, and data replacement |
| `CompositionTest` | Value snapshots, native pixels, attachment IDs, removal/order, duplicates, TRE framing, and unsupported content |
| `WriterTest` | Independent header/length/TRE/pixel parsing, literal byte expectations, reader round trips, big-endian uint16, edge padding, and determinism |
| `LayoutTest` | Band and dimension boundaries, complexity levels, padded lengths, and limits checked without huge pixel allocations |
| `FileSystemTest` | Overwrite opt-in, validation/SNIP failures, short writes, open/close/position/publication failures, read-only targets, cleanup, and destination rechecks |
| `ABPPTest` | Every uint16 bit boundary, cached-statistics refresh, explicit precision, left justification, padding, and unchanged serialized samples |
| `ContainerTest` | Mixed images/text/DESs, text-only files, exact ordering and bytes, display references, corners/comments, snapshots, and later-segment failures |
| `OverflowTest` | Whole-record placement, all owner types, capacity boundaries, derived DES indices, order, determinism, and corrupted-reference detection |
| `SegmentCountTest` | Image/text/DES count limits and complexity transitions, including derived overflow in the DES limit |
| `SpectralTRETest`, `MATESATest` | Literal dataset/corner/chip bytes, relationship types, encodings, counts, identifiers, and placement |
| `BandMetadataTest` | BANDSB masks, floating-decimal precision, big-endian binary32, every defined band group, auxiliary I/R/A data, and payload boundaries |
| `HistoryTest`, `AirborneTRETest` | Processing-event conditions and chronology, aircraft/acquisition fields, registered codes, required comments, and fixed byte layouts |
| `IlluminationTest` | Every ILLUMB mask group, band/set/other-source ordering, scientific values, unknowns, partial coordinates/times, datum codes, and length limits |
| `MotionTRETest`, `FrameTimingTest` | Camera sets, intervals, mapping, native uint64 timing at all eight byte widths, temporal order, unavailable/unused blocks, and limits |
| `MICIDATest` | Ten published MIIS examples, independent permutation-table checks, all usage bytes, UUID formats, case and uniqueness, count/exact payload limits, repeated instances, file overflow and pixel readback |
| `WrapperTest` | Context grammar, nesting, effective owners, asynchronous/frame restrictions, child lengths, snapshot precedence, and removal |
| `SensorTest`, `SensorFieldTest`, `SensorContinuationTest` | All 15 SENSRB modules, every eligible dynamic field, numeric/text types, uncertainty indices, content prerequisites, exact continuation boundaries, loop limits, snapshots, overflow output, and reader round trips |
| `RSM*Test` | All eight current RSM records, coefficient/grid order, coordinate domains, adjustment and covariance definitions, PSD/PD checks, complete-set identities, chip mappings, alternate editions and covariance union, section overflow and reader round trips |
| `CSEXRBTest`, `ExploitationTest`, `RollingShutterTest`, `WarpingTest` | Current exploitation fields and reserved area, criteria/metric registries, exact timing integers, corner order, polynomial order and conditional sensor fields |
| `SensorDESHeaderTest`, `AttitudeTest`, `EphemerisTest`, `EarthOrientationTest` | Typed snapshot proof, UUID/header limits, version/coordinate variants, exact Julian epochs, JPL normalization, sample counts, optional derivatives and independent bytes |
| `FieldAlignmentTest`, `TelescopeOpticsTest` | Scanner pairs, framing grids, calibration/homography arrays, per-frame/time transforms, focal/time counts, ordering and conditional fields |
| `GLASCorrelationTest`, `SensorErrorGroupTest`, `CalibrationErrorTest`, `CovarianceDESTest` | All covariance allocations, correction posts, five time-sync layouts, upper triangles, unmodeled grids, SPDCF families/weights, internal references, direct adjustments and current reserved-area bytes |
| `GLASContainerTest`, `GLASFileTest`, `ImageBandFieldsTest` | Extended/user/overflow area order, preserved records, typed snapshots, forward/display/shared UUID associations, original/chipped geometry, band units/identities, warping, frame counts, target fields, generic partial models and reader round trips |
| `MotionStorageTest`, `MotionBlockTest` | B/F/T frame order, exact block bytes and padding, native types, motion complexity limits, uint64 products beyond native range, calendar rollover and block boundaries |
| `MIECollectionTest`, `MIEManifestTest`, `MIEQuicklookTest` | Runtime cameras/layers/intervals, deterministic file names, complete shared catalogs, FILE001/002 reconstruction, missing blocks, supplied quick looks, full preflight and partial-publication recovery diagnostics |
| `FrameContextTest`, `CollectionContextTest` | Physical byte precedence across inline/user/overflow areas, exact asynchronous times, image/frame/collection index bounds, wrapped RSM/GLAS models, foreign manifest metadata, snapshot integrity and ambiguous cross-file override rejection |
| `SNIPProfileTest` | Selected MSI profile, required records, citation bytes, symmetric/asymmetric bands, identity/time/lineage checks, mono/RGB quick looks, crop parents, RSM covariance, ECF frame/scanner GLAS timing, explicit unsupported paths and protected writing |

`helpers/inspectNITF.m` independently parses fixed specification offsets and reconstructs pixels without calling NFX serialization or layout helpers. Fixture RPC values are synthetic; these tests establish encoding behavior, not camera-model accuracy or general NITF/SNIP conformance.

Actual Coder generation runs separately through `runCoderTests`, documented
in the [portable kit guide](../CODER_TESTS.md). The ordinary regression suite
checks its MATLAB references and harness only; it does not claim generated
execution. Missing Coder prerequisites remain incomplete in the portable
suite, with explicit outcomes and a result archive.

`helpers/inspectContainer.m` walks segment tables and optional fields independently, checks byte lengths and ordering, follows overflow references, and verifies that every overflow DES has exactly one matching owner. Literal tests cover representative headers and both inline/overflow boundaries. Generic synthetic DES fixtures exercise container bytes without claiming a registered support-data model.

`helpers/inspectBANDSB.m` and `helpers/inspectILLUMB.m` independently walk all selected fields and require exact end-of-payload alignment. Other TRE suites compare literal field bytes, including mixed-record container output. Synthetic scientific fixtures establish encoding and validation behavior; they do not establish sensor-model accuracy or the truth of provider metadata.

`helpers/inspectSENSRB.m` independently walks the 15 modules and decodes typed time/pixel loops using the published field widths. Continuation tests reconstruct all original samples across records, including repeated times and more than 9,999 values or 99 groups. Separate assertions check literal minimum/maximum sizes, required inherited context, first-instance static data, atomic removal, and rejection of uncertainty indices that would refer to a moved sample. No interpolation or sensor fitting is claimed.

GLAS/GFM tests use literal field expectations, `inspectCSEXRB`, a separate full-covariance cursor oracle, and complete file reconstruction through `inspectContainer`. The latter walks both user-defined and extended areas and verifies each overflow owner. Tests include scanner/framer products and a standalone synthetic example. They do not evaluate GSET/PMA/DGA scientific conformance or geolocation accuracy. The optional current CSCSDB adjustment-correlation area is tested against its explicit byte-count markers; the contradictory packing/minimum-length statements remain documented and cannot establish profile conformance.

`helpers/decodeMotion.m` reconstructs native motion frames from literal NITF offsets and an independent block/frame/band loop. Motion tests use exact small byte strings and multiple native types; MATLAB reader round trips cover still and quick-look products because the legacy reader does not establish multi-frame MIE correctness. Timing expectations include separately calculated integer products above 2^53 and UINT64_MAX. The writer manifest test checks 420 filename entries; the reader integration test writes and reads 650 members across FILE001/FILE002. The latter takes several minutes on the development machine. A real read-only later destination exercises partial publication while preserving the prior manifest.

## Profile requirements and test mapping

The common format suites above test each record's conditional fields and byte order. Profile suites test relationships across those records. All fixtures are synthetic and self-contained; no test reads the ignored reference library.

| Pinned requirement | Implementation and regression evidence |
| --- | --- |
| JBP 2025.1 ABPP/PJUST; native sample preservation | `ABPPTest`, `WriterTest`: integer boundaries, explicit overrides, justification, padding and independent bytes |
| JBP segment tables, extension ownership and whole-TRE overflow | `ContainerTest`, `OverflowTest`, `SegmentCountTest`: mixed files, exact sizes/order, each owner and protected preflight |
| SNIP 1.2 CN1 Tables 6-5, 9-1, 10-5; sections 8-10 | `SNIPProfileTest`: required spectral metadata, first spectral IDLVL, supplied quick looks, source association, mono/RGB comments, multiple image identities and actual filename |
| SNIP Table 17-1, sections 17.1 and 10.7.4 | `BandMetadataTest`, `SNIPProfileTest`: CWAVE/FWHM, NOM_WAVE/bounds, wavenumber conversion, nanometer display fields, known spacing and wavelength order |
| SNIP sections 15, 17.6-17.7, 21.2.1.3 | `AirborneTRETest`, `HistoryTest`, `IlluminationTest`, `SNIPProfileTest`: catalog fields, dates, registered processing comments, datums and sensor angles; multiple illumination instances |
| SNIP section 18 and Table 18-3 | `SNIPProfileTest`: literal pinned citation, unknown certification, CR/LF termination, additional citations, ordering and attachment |
| SNIP section 20.1 | `SNIPProfileTest` and RSM/chip suites: integer crop mapping, processing event, PARENT FTITLE/ISORCE lineage and original-image domains |
| SNIP Table 7-2 and section 16.12 | `SNIPProfileTest`, `RSM*Test`: adjusted/nonadjusted companions, unique supplied model editions, complete polynomial/grid sets and supplemental models |
| SNIP sections 7.2.1 and 6.6; GLAS/GFM Appendix M | `SNIPProfileTest`, GLAS suites: ECF, UUID companions, scanner/frame acquisition timing, support-sample coverage and optional reserved-area rejection |
| SNIP section 7.2.3; SENSRB Appendix Z | `SensorContinuationTest` implements generic splitting; `SNIPProfileTest` explicitly rejects SENSRB as the sole SNIP path without the separately distributed mensuration profile |
| MIE4NITF 1.3.3 section 6, Tables 14-15; Appendix AF | `MotionStorageTest`, `MotionBlockTest`, `MIECollectionTest`: original-resolution NC, B/F/T layout, native data, complexity levels, runtime camera/layer/set/interval counts and exact timing |
| MIE sections 6.11-6.12; requirements 99, 103, 105, 109, 110, 116, 121 | `MIECollectionTest`, `MIEManifestTest`, `MIEQuicklookTest`: complete shared catalogs, canonical names, missing blocks, manifest mappings, FILE001/002 whole-entry splits and quick-look scopes |
| Appendix AF context/override semantics | `FrameContextTest`, `CollectionContextTest`: physical precedence, frame/time boundaries, nested scopes, cross-file targets and explicit ambiguous-override failure |
| MISB ST 1204.3 Appendix E and Table 14 | `MICIDATest`: all ten published MIIS examples and a separately implemented permutation oracle |

Reference decisions:

- The local SNIP PDF filename contains 2025-01, but its actual identity is **1.2 CN1, 29 February 2024**. The generated citation follows the document identity.
- Appendix X's band field definitions and sections X.6.3/X.7.4, plus SNIP Table 17-1 and its explicit symmetric mask 293601280, require CWAVE with FWHM. Appendix X Table X9 requirement 4 contradicts those definitions by calling bit 23 asymmetric. Encoding and tests follow the consistent field definitions and the explicit SNIP mask.
- MIE section 6.12 prose says FLSTnnn; normative requirement 116 says FILEnnn. Output uses FILE001, FILE002, etc.
- The current Appendix M explicit CSCSDB adjustment-correlation fields conflict with older zero-reserved packing/minimum-length statements. Generic bytes follow the counted field definitions. That optional area fails the sole GLAS SNIP path until the conflict is resolved.
- CSDIDA Appendix AS identifies 9I as airborne/WAMI and AU as Aurora. The selected airborne profile uses 9I; other airborne registrations require a verified catalog update.

`MIECollection.validate` checks the complete NFX-MIE-NC1 collection, including generated imagery and manifest distinctions. `File.validate` alone checks an individual generic NITF file; it cannot establish a complete external collection. An individually imported NFX MIE member exposes stored content with `context_complete=false` and requires `MIECollection.read` before full context/model validation or writing. Profile checks do not prove scientific calibration/geolocation, truthful provider declarations, actual image-center targeting, inherited parent metadata or external certification. SENSRB-only SNIP mensuration remains blocked by the unavailable NGA profile; independent RSM/ECF GLAS cases are implemented.

## Coverage review

Optional Windows codec tests run with `runTests(OpenJPEG=encoder)` or a supplied
`NFX_OPENJPEG` environment variable. They use the pinned OpenJPEG 2.5.4 binary,
an independent codestream marker oracle and MATLAB decoder round trips. The
default runner explicitly excludes these tests when no encoder is configured.
See [the prototype notes](../prototypes/openjpeg/README.md) for setup and scope.
`observeOpenJPEG(encoder)` in `examples/` records synthetic timings, temporary
byte counts and pre/post MATLAB memory; it does not measure transient peaks or
encoder-process memory. These are observations, not portable resource bounds.

Coverage reports include every implementation file under `src/`, including private helpers. Inspect `coverage/html/index.html` and `coverage/cobertura.xml` after a run. No coverage exclusions are applied.

Known defensive paths that are not exercised by the normal public file workflow:

- Attachment-ID exhaustion at `flintmax`: exercising it would require approximately nine quadrillion attachments/removals. IDs are private and are not weakened for testing.
- The private decimal formatter's width guard: public metadata validators constrain values to their encoded widths. It remains a last check against an internal regression.

The final profile milestone's 1,013-test run measured 8,544 of 8,584 executable lines (99.53%). The 40 uncovered lines include defensive private-format/attachment guards, metadata constructor alternatives, invalid-template/manifest-limit branches, missing asynchronous timing, and SNIP early exits for unsupported timing. Focused tests cover exact bytes, calendar and native-integer boundaries, wrapper scope/precedence, complete collection references, selected SNIP relationships, missing blocks, and protected publication; a high line percentage does not establish every combination of those conditions. MICIDA checks retain all ten published MISB ST 1204.3 Appendix E examples and an independent Table 14 permutation oracle. The fresh profile reviewer independently verified 142 focused tests after resolving five profile findings, including comment inheritance, citation grammar, quick-look wavelengths and sorted complete-image identifiers.

Review branches as well as line percentages: a one-line conditional can count as covered even when its body was skipped. Tests cover valid/invalid reports, native uint8/uint16 paths, block/representation choices, and the filesystem error paths above. Measured decision/condition coverage requires the separately licensed [MATLAB Test coverage metrics](https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin.forfolder.html), which are unavailable in the development installation. Platform crashes, power loss, and simultaneous publication by other processes are not simulated; publication is not claimed to be a crash-safe transaction.

The bounded-reader acceptance run passed all 1,924 tests, including the
OpenJPEG cases and the separately completed 650-member collection case.
The remaining suite was rerun with coverage: 15,328 of 15,640 executable
implementation lines (98.005%). The large split-list case is retained in the
normal `runTests` suite; its earlier passing result was reused for this
acceptance run because the later change only added image replacement.
Reader tests include native and compressed products, canonical payload
preservation, supported RSM/ECF GLAS SNIP products, complete collection
contexts, explicit pending local contexts, source budgets and malformed data.

`UnknownTRETest` checks opaque binary snapshots on file/image/text owners,
known wrapper children, repeated identities and removal, manual tag probes,
user/extended-area preservation, overflow up to 99,999 payload bytes, MIE
collection round trips, incomplete semantic reports and strict SNIP refusal.
Malformed framing and malformed known payloads remain hard read failures.

The unknown-TRE milestone passed a fresh full run of **1,960 tests** on
R2026a Update 4, including OpenJPEG and the 650-member collection case.
All changed MATLAB files passed Code Analyzer. The coverage percentages
above describe earlier milestones; coverage was not remeasured for this run.

## Memory observation

On Windows MATLAB:

```matlab
addpath('tests');
observations = measureMemory();
```

This creates an 8192 × 8192 uint16 image (128 MiB), observes process memory before/after attachment, metadata/TRE edits, file composition, validation, and writing, then removes its output. These observations can miss transient peaks and are not performance assertions. Pixel writes use block-sized native arrays and byte buffers; metadata operations do not intentionally copy or convert the whole image.

The final R2026a Update 4 observation allocated 134,217,728 image bytes and observed the same 128 MiB process-memory increase. Subsequent attachment, metadata edits, composition, validation and writing showed no additional retained process-memory increase in that run. The output was 134,219,626 bytes. These are pre/post observations from a warmed session, not peak-allocation bounds or performance guarantees.

## Release and Coder review

The candidate was developed and tested with MATLAB R2026a Update 4 on Windows. R2023b is the target minimum but has not been executed. The test helper for open file handles uses `openedFiles` on R2024a+ and the earlier `fopen('all')` API on R2023b. No R2025a live-script format or newer argument syntax is required by implementation.

Implementation retains generation intent, with no imports or extrinsic fallbacks. The host-only `publishCollection` helper isolates try/catch for precise partial-publication diagnostics; metadata, planning, validation and pixel/byte paths retain applicable annotations. Native pixel types, homogeneous serialized TRE records, typed segment arrays, fixed coefficient vectors, explicit byte assembly, and ordinary validation structs avoid unnecessary image conversion. ABPP reductions use native blocks of at most 65,536 samples and cache their scalar statistics.

Compilation and generated-byte parity remain unverified because MATLAB Coder is unavailable. Specific remaining work:

- `File.write` uses [`tempname`](https://www.mathworks.com/help/matlab/ref/tempname.html), which has no documented C/C++ generation support. Temporary creation needs a supported target implementation that preserves destination protection; replacing it with an unchecked fixed filename would weaken behavior.
- [`movefile` generation](https://www.mathworks.com/help/matlab/ref/movefile.html) has directory restrictions and platform-dependent behavior. Generated publication/overwrite/error semantics require verification on the actual target.
- Generated entry points must establish pixel class, text representation, and variable-size bounds for image arrays, metadata, issue collections, and ordered TRE records. Runtime-varying counts are intentional; no one-property-per-TRE layout or global fixed count is assumed.
- Object arrays, dependent properties, name-value/property validation, cleanup ownership, and variable-sized reports need actual compiler checks. Source annotations and a clean Code Analyzer run do not establish compiled support.
