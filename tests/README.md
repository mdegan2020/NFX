# NFX test and compatibility notes

From the repository root, run `runTests()` or `runTests(Coverage=true)` in MATLAB. The runner errors on invalid test files, failed tests, or incomplete tests. Base MATLAB supplies `matlab.unittest` and statement coverage; Image Processing Toolbox supplies `nitfread`, `nitfinfo`, and `isnitf`. Tests require no local reference library, design documents, GDAL, or NITRO.

## What the suite checks

| Suite | Checks |
| --- | --- |
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

`helpers/inspectNITF.m` independently parses fixed specification offsets and reconstructs pixels without calling NFX serialization or layout helpers. Fixture RPC values are synthetic; these tests establish encoding behavior, not camera-model accuracy or general NITF/SNIP conformance.

`helpers/inspectContainer.m` walks segment tables and optional fields independently, checks byte lengths and ordering, follows overflow references, and verifies that every overflow DES has exactly one matching owner. Literal tests cover representative headers and both inline/overflow boundaries. Generic synthetic DES fixtures exercise container bytes without claiming a registered support-data model.

`helpers/inspectBANDSB.m` and `helpers/inspectILLUMB.m` independently walk all selected fields and require exact end-of-payload alignment. Other TRE suites compare literal field bytes, including mixed-record container output. Synthetic scientific fixtures establish encoding and validation behavior; they do not establish sensor-model accuracy or the truth of provider metadata.

`helpers/inspectSENSRB.m` independently walks the 15 modules and decodes typed time/pixel loops using the published field widths. Continuation tests reconstruct all original samples across records, including repeated times and more than 9,999 values or 99 groups. Separate assertions check literal minimum/maximum sizes, required inherited context, first-instance static data, atomic removal, and rejection of uncertainty indices that would refer to a moved sample. No interpolation or sensor fitting is claimed.

GLAS/GFM tests use literal field expectations, `inspectCSEXRB`, a separate full-covariance cursor oracle, and complete file reconstruction through `inspectContainer`. The latter walks both user-defined and extended areas and verifies each overflow owner. Tests include scanner/framer products and a standalone synthetic example. They do not evaluate GSET/PMA/DGA scientific conformance or geolocation accuracy. The optional current CSCSDB adjustment-correlation area is tested against its explicit byte-count markers; the contradictory packing/minimum-length statements remain documented and cannot establish profile conformance.

## Coverage review

Coverage reports include every implementation file under `src/`, including private helpers. Inspect `coverage/html/index.html` and `coverage/cobertura.xml` after a run. No coverage exclusions are applied.

Known defensive paths that are not exercised by the normal public file workflow:

- Attachment-ID exhaustion at `flintmax`: exercising it would require approximately nine quadrillion attachments/removals. IDs are private and are not weakened for testing.
- The private decimal formatter's width guard: public metadata validators constrain values to their encoded widths. It remains a last check against an internal regression.

The GLAS/GFM milestone's 921-test run measured 7,090 of 7,120 executable lines (99.58%). All new GLAS/GFM executable lines were covered. The 30 remaining uncovered lines predate the milestone and include defensive private-format guards, metadata getter/constructor alternatives, and a few invalid text/registry branches. MICIDA checks use all ten published MISB ST 1204.3 Appendix E examples and an independent Table 14 permutation oracle. Complete collection associations and profile enforcement are separate later milestones.

Review branches as well as line percentages: a one-line conditional can count as covered even when its body was skipped. Tests cover valid/invalid reports, native uint8/uint16 paths, block/representation choices, and the filesystem error paths above. Measured decision/condition coverage requires the separately licensed [MATLAB Test coverage metrics](https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin.forfolder.html), which are unavailable in the development installation. Platform crashes, power loss, and simultaneous publication by other processes are not simulated; publication is not claimed to be a crash-safe transaction.

## Memory observation

On Windows MATLAB:

```matlab
addpath('tests');
observations = measureMemory();
```

This creates an 8192 × 8192 uint16 image (128 MiB), observes process memory before/after attachment, metadata/TRE edits, file composition, validation, and writing, then removes its output. These observations can miss transient peaks and are not performance assertions. Pixel writes use block-sized native arrays and byte buffers; metadata operations do not intentionally copy or convert the whole image.

## Release and Coder review

The candidate was developed and tested with MATLAB R2026a Update 4 on Windows. R2023b is the target minimum but has not been executed. The test helper for open file handles uses `openedFiles` on R2024a+ and the earlier `fopen('all')` API on R2023b. No R2025a live-script format or newer argument syntax is required by implementation.

Every implementation function/method carries generation intent; there are no implementation imports or extrinsic fallbacks. Native pixel types, homogeneous serialized TRE records, typed segment arrays, fixed coefficient vectors, explicit byte assembly, and ordinary validation structs avoid unnecessary image conversion. ABPP reductions use native blocks of at most 65,536 samples and cache their scalar statistics.

Compilation and generated-byte parity remain unverified because MATLAB Coder is unavailable. Specific remaining work:

- `File.write` uses [`tempname`](https://www.mathworks.com/help/matlab/ref/tempname.html), which has no documented C/C++ generation support. Temporary creation needs a supported target implementation that preserves destination protection; replacing it with an unchecked fixed filename would weaken behavior.
- [`movefile` generation](https://www.mathworks.com/help/matlab/ref/movefile.html) has directory restrictions and platform-dependent behavior. Generated publication/overwrite/error semantics require verification on the actual target.
- Generated entry points must establish pixel class, text representation, and variable-size bounds for image arrays, metadata, issue collections, and ordered TRE records. Runtime-varying counts are intentional; no one-property-per-TRE layout or global fixed count is assumed.
- Object arrays, dependent properties, name-value/property validation, cleanup ownership, and variable-sized reports need actual compiler checks. Source annotations and a clean Code Analyzer run do not establish compiled support.
