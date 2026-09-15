# NFX test and compatibility notes

From the repository root, run `runTests()` or `runTests(Coverage=true)` in MATLAB. The runner errors on failed or incomplete tests. Base MATLAB supplies `matlab.unittest` and statement coverage; Image Processing Toolbox supplies `nitfread`, `nitfinfo`, and `isnitf`. Tests require no local reference library, design documents, GDAL, or NITRO.

## What the suite checks

| Suite | Checks |
| --- | --- |
| `RPC00BTest` | Exact field widths, signs, coefficient order, rounding, exponent limits, unset values, strict types, and nonzero normalization |
| `HeaderTest` | Required metadata, ASCII, dates, classification, representations, derived layout, and data replacement |
| `CompositionTest` | Value snapshots, native pixels, attachment IDs, removal/order, duplicates, TRE framing, and unsupported content |
| `WriterTest` | Independent header/length/TRE/pixel parsing, literal byte expectations, reader round trips, big-endian uint16, edge padding, and determinism |
| `LayoutTest` | Band and dimension boundaries, complexity levels, padded lengths, and limits checked without huge pixel allocations |
| `FileSystemTest` | Overwrite opt-in, validation/SNIP failures, short writes, open/close/position/publication failures, read-only targets, cleanup, and destination rechecks |

`helpers/inspectNITF.m` independently parses fixed specification offsets and reconstructs pixels without calling NFX serialization or layout helpers. Fixture RPC values are synthetic; these tests establish encoding behavior, not camera-model accuracy or general NITF/SNIP conformance.

## Coverage review

Coverage reports include every implementation file under `src/`, including private helpers. Inspect `coverage/html/index.html` and `coverage/cobertura.xml` after a run. No coverage exclusions are applied.

Known defensive paths that are not exercised by the normal public file workflow:

- The image-header serializer's raw extension-size guard: the supported RPC has a fixed payload size, and segment validation rejects overflow before serialization.
- Attachment-ID exhaustion at `flintmax`: exercising it would require approximately nine quadrillion attachments/removals. IDs are private and are not weakened for testing.
- The private decimal formatter's width guard: public metadata validators constrain values to their encoded widths. It remains a last check against an internal regression.

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

Every implementation function/method carries generation intent; there are no implementation imports or extrinsic fallbacks. Class-valued properties are initialized in constructors. Native pixel types, homogeneous serialized TRE records, fixed coefficient vectors, explicit byte assembly, and ordinary validation structs avoid unnecessary dynamic dispatch or image conversion.

Compilation and generated-byte parity remain unverified because MATLAB Coder is unavailable. Specific remaining work:

- `File.write` uses [`tempname`](https://www.mathworks.com/help/matlab/ref/tempname.html), which has no documented C/C++ generation support. Temporary creation needs a supported target implementation that preserves destination protection; replacing it with an unchecked fixed filename would weaken behavior.
- [`movefile` generation](https://www.mathworks.com/help/matlab/ref/movefile.html) has directory restrictions and platform-dependent behavior. Generated publication/overwrite/error semantics require verification on the actual target.
- Generated entry points must establish pixel class, text representation, and variable-size bounds for image arrays, metadata, issue collections, and ordered TRE records. Runtime-varying counts are intentional; no one-property-per-TRE layout or global fixed count is assumed.
- Object arrays, dependent properties, name-value/property validation, cleanup ownership, and variable-sized reports need actual compiler checks. Source annotations and a clean Code Analyzer run do not establish compiled support.
