# NFX — NITF File eXchange

A MATLAB toolbox for constructing and writing NITF files through a compact object-oriented API in the `nfx` namespace.

NFX writes NITF 2.1 files with multiple uncompressed blocked images, standard text segments, and data extension segments (DESs). Images support dense real `uint8` and `uint16` pixels, explicit unclassified metadata, and MONO, RGB, or MULTI representation. Blocks default to 1024 × 1024; partial edge blocks are zero padded. Concrete spectral, airborne, motion timing, and wrapper TREs complement RPC00B and FREESA. Oversized metadata areas use derived `TRE_OVERFLOW` DESs.

Targets MATLAB R2023b and newer; tested locally on R2026a. Writing requires base MATLAB. Reader round-trip tests also require Image Processing Toolbox. No GDAL or NITRO dependency.

An optional [OpenJPEG prototype](prototypes/openjpeg/README.md) adds Windows-only
lossless NPJE/EPJE JPEG 2000 still-image segments. It requires the pinned
OpenJPEG 2.5.4 executable for compression; writing captured segments needs no
codec. This experimental path is outside the MATLAB Coder goal and the existing
SNIP/MIE profile support. Run its tests with `runTests(OpenJPEG=encoder)`.

## Example

Run from the repository root. These pixels, dates, and RPC parameters are **synthetic demonstration data**, not a fitted camera model.

```matlab
addpath('src');
pixels = reshape(uint16(1001:1035), 5, 7);

rpc = nfx.RPC00B(line_off=2, samp_off=3, lat_off=0, long_off=0, ...
    height_off=0, line_scale=2, samp_scale=3, lat_scale=1, ...
    long_scale=1, height_scale=100, ...
    line_num_coeff=[0 0 1 zeros(1,17)], ...
    line_den_coeff=[1 zeros(1,19)], ...
    samp_num_coeff=[0 1 zeros(1,18)], ...
    samp_den_coeff=[1 zeros(1,19)]);

image = nfx.ImageSegment(pixels, header=nfx.ImageHeader( ...
    iid1='DEMO', idatim='20260915120000', isclas='U', ...
    irep='MONO', icat='VIS'));
image = image + rpc;
file = nfx.File(header=nfx.FileHeader(ostaid='NFXDEMO', ...
    fdt='20260915120100', fsclas='U', ftitle='Synthetic example')) + image;

report = file.validate();
assert(report.valid);
file.write('example.ntf');
```

## API behavior

- Header and TRE metadata use specification mnemonics in lowercase. Numeric metadata requires `double`; pixels retain their native class. Required caller metadata starts unset. RPC coefficient groups contain exactly 20 doubles each, in specification order.
- TREs are editable before attachment. `image + rpc` captures its validated bytes; later edits to `rpc` do not change the image. `file + image` also captures a value snapshot.
- Remove an attachment with `image = image.removeTRE(image.tre_ids(1))`. Files and text segments provide the same TRE API. Remaining IDs and insertion order survive removal; removed IDs are not reused. `tre_records` exposes physical snapshots for inspection. Repeated RPC attachments can be edited, but must be reduced to at most one per image before writing. Attachment checks each concrete TRE's legal owner.
- Set pixels through `image.data`, and block dimensions through `image.header.nppbh` / `nppbv`. Dimensions, bands, block counts, storage width, segment lengths, and file complexity update automatically.
- Automatic `abpp` is the number of bits needed for the largest right-justified sample across all bands and frames; all-zero data uses one bit. `nbpp` remains 8 or 16 according to native storage. Set `image.header.abpp` to declare a larger acquisition precision, or `NaN` to restore automatic behavior. A smaller precision must still fit every sample. With `pjust='L'`, automatic ABPP uses the full storage width; an explicit precision requires zero low-order padding bits. Samples are never shifted or converted. Statistics refresh on pixel replacement and indexed edits, using bounded temporary storage; header access does not rescan pixels.
- Append images, texts, DESs, and file-level TREs with `+`. Segment types serialize in NITF order: images, texts, then DESs. Automatic image display levels avoid explicitly assigned levels. Set `idlvl`, `ialvl`, and `iloc` for supplied display relationships; references, unique levels, and nonnegative absolute positions are validated. Supplied corners use `icords='D'` or `'G'` and a 60-character `igeolo`; `icom` accepts up to nine ASCII comment rows or strings.
- `validate()` returns `valid`, `scope`, and `issues`. Each issue includes an identifier, field location, message, and specification reference. `rpc.ascii()`, `rpc.payload()`, and `rpc.bytes()` expose the ASCII payload, payload bytes, and framed TRE bytes respectively.
- `write()` validates first and prepares a temporary file beside the destination. Replacing an existing file requires `Overwrite=true`. Failed preparation leaves the destination intact and cleans up temporary output. Concurrent writers to the same destination require caller coordination.

## Text and support data

```matlab
text = nfx.TextSegment(sprintf('First line\nSecond line'), ...
    header=nfx.TextHeader(textid='TEXT001', txtdt='20260915120000', ...
    txtitl='Synthetic text', tsclas='U'));
file = file + text;
```

`TextSegment` accepts BCS standard text (`STA`): printable ASCII, line endings, and form feed. It normalizes line endings to CR/LF and derives the encoded byte count. Text-only files are supported. `txtalvl=0` associates text with the file; a nonzero value must identify an image's display level.

`DESSegment(DATA,header=nfx.DESHeader(...))` accepts supplied `uint8` payload bytes, with `desid`, `desver`, `desclas`, and optional `desshf` header bytes. Generic validation checks the container and byte limits; it does not establish the semantic validity of an arbitrary registered DES payload.

TRE attachment preserves complete records and order. NFX uses an inline capacity of 99,985 **framed bytes** for file and image extended areas, a conservative policy within the field limits. Text extended areas allow 9,713 framed bytes so the subheader fits its 9,998-byte limit. The remaining suffix moves intact into one overflow DES per owner. An individual TRE payload is limited to 99,985 bytes; its 11-byte envelope is additional. `file.des` includes supplied DESs followed by these derived overflow records. Callers cannot attach `TRE_OVERFLOW` directly.

For file/image owners containing GLAS/GFM TREs, packing uses the extended area first, then the user-defined area, then a whole-record overflow suffix, as required by Appendix M. Logical insertion order spans those areas even though the user-defined area occurs first in the physical header. A record too large for either inline area remains intact in overflow. Removing all GLAS/GFM TREs restores the ordinary extended-area policy.

## Spectral and motion metadata

| Records | Supplied metadata |
| --- | --- |
| `CSDIDA`, `ACFTB`, `AIMIDB` | Dataset, aircraft, and acquisition identifiers |
| `BANDSB`, `ILLUMB` | Spectral characterization and illumination |
| `HISTOA` with `HistoryEvent` | Chronological image processing history |
| `CSCRNA`, `FCRNSA`, `ICHIPB`, `MATESA` | Corners, chip mapping, and related products |
| `MIMCSA`, `CAMSDA`, `MICIDA`, `TMINTA`, `MTIMFA`, `MTIMSA` | Motion collection descriptions, camera sets/core identifiers, intervals, temporal blocks, and frame timing |
| `FSYNWA`, `FASYWA`, `CONTXA` | Frame, asynchronous time, and collection-context metadata wrappers |

These definitions encode caller-supplied metadata. They do not calculate radiometry, illumination, aircraft state, sensor identity, or processing history. The pinned definitions use the supplied STDI-0002 appendices through 2025. Additional registry values absent from those publications are not assumed valid.

`BANDSB` takes a row of `nfx.SpectralBand` values. It derives counts and masks, requires matching optional groups across bands, and supports all defined binary and auxiliary fields. Cube and per-band numeric metadata remain double until field encoding. `ILLUMB` uses band-by-set matrices, other-source-by-band-by-set arrays, and explicit `P`/`M` methods. Supply its vertical reference when any target height is known; leave both vertical reference fields blank when all heights are unknown. Unknown, omitted, and partially known values follow each record's own field rules.

`MTIMSA` keeps `dt` and `dt_multiplier` as native `uint64`, including values above `flintmax`. Its derived `dt_size` supports one through eight bytes; an explicit width must fit every delta. Timestamps preserve their supplied decimal text and permitted unknown digits.

Wrappers support ordered `+` snapshots and `removeTRE`, like their file and image owners. NFX validates supported nesting, effective file/image context, and payload bounds. Frame and collection index membership, cross-file references, exact timing, and actual frame storage are implemented below. Profile validation covers the explicitly bounded SNIP and MIE cases described below.

`MICIDA` associates each supplied camera UUID with a MISB ST 1204.3 textual core identifier. It validates structure version 01, sensor/platform/window or minor-ID usage, UUID versions 1/4/5 and variant, and the two hexadecimal check digits. Counts and text lengths derive automatically. Each instance supports 1–999 cameras within 99,985 payload bytes; attach further instances as needed. Supplied letter case is preserved, while camera/core uniqueness checks ignore it.

```matlab
cameraID = '865efd9c-ef8a-41c3-8244-b885afcc40bf';
platformID = 'ed8a9ab8-72e2-4165-9979-7e5af54a5b9a';
coreID = nfx.MICIDA.coreIdentifier(120,{cameraID,platformID});
identifiers = nfx.MICIDA(cameras=nfx.MICIDA.camera(cameraID,coreID));
file = file + identifiers;
```

This example uses the published ST 1204.3 example IDs. Usage 120 (`0x78`) declares physical sensor and platform identifiers. The formatter takes canonical 8-4-4-4-12 UUIDs and emits MIIS's eight groups of four digits with its check value. It does not create identifiers or verify the source device, UUID generation method, or global uniqueness. Camera UUIDs need not equal a core identifier's sensor UUID. MIECollection checks collection-wide camera/core uniqueness and complete camera coverage.

## Sensor metadata and time series

`nfx.SENSRB` implements the 15 modules of Appendix Z 2.3. Supply general collection fields and the required reference/position fields, then add optional module fields and repeating groups:

```matlab
sensor = nfx.SENSRB(sensor='TEST SENSOR', platform='TEST PLATFORM', ...
    operation_domain='Airborne', start_date='20260915', end_date='20260915', ...
    start_time=43200, end_time=43201, reference_time=0, ...
    latitude_or_x=40, longitude_or_y=-105, altitude_or_z=1000);
sensor.time_stamped_data = nfx.SENSRB.timeSeries('06a', [0 1], [40 40.001]);
sensor.uncertainty_data = nfx.SENSRB.uncertainty('06a', 0.5);
image = image + sensor;
```

This example supplies synthetic measurements. Registered sensor/platform/detection labels and the scientific truth of metadata remain the provider's responsibility. `content_level` is an explicit declaration checked against its module prerequisites; NFX does not infer achievable geolocation accuracy. Levels 6–9 require optical geometry defining both detector dimensions. Redundant detector metrics, FOVs, and focal length must agree within their encoded quantization plus 0.01 percent relative tolerance. Coordinate and parameter units follow Appendix Z, including centimeters/inches for detector metrics and focal length, degrees for geographic coordinates, and meters/feet for their uncertainties.

`pointSet`, `pixelSeries`, and `additionalParameter` construct the other repeating groups. Numeric metadata uses double; text samples use character rows or strings. `transform_param` contains a supported 0-, 2-, 4-, 5-, 6-, or 8-coefficient transform. Module flags, counts, lengths, and continuation boundaries derive from the supplied data. Optional numeric `[]` means omitted; `NaN` means unknown only where the field permits it.

Module 12 splits automatically at the physical payload and loop-count limits. `sensor.physicalRecords()` returns ordered `tag`/`payload` structs. Each subsequent instance contains the minimum reference/position metadata and remaining time series. All non-module-12 data stays in the first instance and must fit there. Sample order, duplicate-time precedence, and the original `start_time` reference are preserved. `+` captures all instances under one attachment ID; `removeTRE` removes that whole group. `payload`, `bytes`, and `cel` reject a logical SENSRB that needs several instances.

Uncertainty indices are checked against known numeric fields and loop samples. An uncertainty targeting a time-series sample moved to a later instance is explicitly rejected: the standard's first-instance uncertainty placement does not provide an unambiguous cross-instance sample index. Direct parameter uncertainties remain supported with large series. Wrappers retain their own payload limit; automatic SENSRB splitting does not make a single oversized wrapper valid.

Splitting also rejects a continuation that would re-emit a required reference position conflicting with an earlier sample at that same reference, when the continuation no longer indexes that position parameter as dynamic. This safeguards later-record precedence without inventing a new position or time. Both time-only and explicit pixel references are checked; an explicit pixel reference has the standard's priority.

## Replacement sensor models

Run `addpath('src','examples'); file = rsmExample();` for a complete synthetic adjusted-model example, then call `file.write(...)` with a destination path.

NFX writes supplied RSM Set AB models using `RSMIDA`, `RSMPCA`, `RSMPIA`, `RSMGGA`, `RSMGIA`, `RSMAPB`, `RSMECB`, and `RSMDCB`. These records attach to an image with the same snapshot/removal behavior as other TREs. A writable set requires one identification record, polynomial sections or grid sections (or both), consistent original-image identifiers and editions, and complete section coverage. Section directories are required for multiple sections. Their sizes divide the inclusive RSM image domain; sections may have fractional sizes. Separate editions of one original image may occupy different segments. Segments sharing both a known original-image ID and edition must carry identical sets; different known original images require different editions.

- `RSMPCA` coefficient arrays are **X-by-Y-by-Z**, at most 6 elements along each axis. Powers and counts derive from the array shape; coefficients serialize with X changing fastest. A 2-by-1 coefficient array defines a linear X term; a 1-by-2 array defines a linear Y term. Normalization scales may be signed but must be nonzero.
- `RSMGGA.plane(rcoord,ccoord,ixo=...,iyo=...)` accepts **X-by-Y** matrices of nonnegative pixel offsets from `refrow` and `refcol`. Grid points serialize with Y changing fastest. Use NaN for unavailable coordinates. `fnumrd` and `fnumcd` choose 1–3 fractional digits; digit widths derive after rounding. Plane offsets reference the first plane, whose offsets are zero. Grid sections remain indivisible and must fit 99,985 bytes.
- `RSMParameters` defines the ordered image-space power triples or ground-space identifiers used by adjustment and covariance records. It validates normalization, Local coordinate frames, and optional orthonormal basis mappings. `RSMAPB.parval` follows the active parameter order. Its published payload limit of 28,411 bytes also applies when individual parameter-count limits would permit a larger combination.
- `RSMDCB.block(iidi,crscov)` supplies a full direct covariance block. Row counts refer to the associated image; column counts refer to `iidi` and may differ. Multiple instances in one set must collectively include one auto-covariance block and parameter definitions, without duplicate image pairs. Applicable adjustment definitions must agree, and all adjustment/covariance records in an edition share the most recent process ID. Covariance references resolve by image ID and process ID. Supplied blocks from alternate editions sharing that pair are combined for validation; conflicting definitions or conflicting copies of a block fail. Available matching versions are checked jointly; unavailable versions are preserved without claiming their covariance has been checked.
- `RSMECB.subgroup(errcvg,tcdf,correlation)` supplies an independent original-parameter subgroup. Original covariances are positive definite; direct and unmodeled covariances may be positive semidefinite. `RSMCorrelation` accepts convex piecewise-linear breakpoints or the four CSM parameters. Covariance, basis, and correlation checks also examine the encoded numeric values. No model fitting, geolocation, uncertainty propagation, or scientific accuracy claim is made.

Without an `ICHIPB` mapping, stored pixels are treated as the original full image; known original dimensions must agree. With a mapping, known full-image dimensions must agree across the companion records, and mapping quadrilaterals must be nondegenerate. Output corners follow their declared upper/lower and left/right ordering and fit the stored raster's CCS position. File validation resolves attached-image positions through their parent chain. The RSM validity domain may be a subset of the original image. Wrapped RSM records are validated in each effective frame context before writing. Generic structural RSM validity does not establish SNIP mensuration conformance.

## GLAS/GFM metadata

Run `addpath('src','examples'); file = glasExample();` for a complete synthetic scanner example. `CSEXRB`, `CSRLSB`, and `CSWRPB` attach as TRE snapshots. The typed `CSATTB`, `CSEPHB`, `CSSFAB`, and `CSCSDB` descriptors attach directly with `file = file + descriptor`; `descriptor.segment()` also returns a verified `DESSegment` snapshot. Editing that snapshot's raw bytes or header invalidates its typed proof. Edit the descriptor and capture it again instead.

The implementation follows the current May 2025 Volume 2 Appendix M definitions. It supports supplied scanner and framing metadata, partial Level 0 metadata, shared supporting DESs, spatial segmentation and `ICHIPB` mappings. It checks actual forward UUID references, current display levels, sensor types, band identities, frame counts and applicable warping/rolling-shutter relationships. Optional reverse element UUIDs can remain external or refer to removed images after chipping. Complete image-plane UUIDs and DES UUIDs are caller-supplied; no identifiers, sensor science or coordinate conversions are invented.

- `CSATTB` and `CSEPHB` support definition versions 1/2 and ECF/ECI. Version-two ECI includes an `EarthOrientation` value. Attitude uses normalized JPL quaternions with **Q4 scalar**; ephemeris uses supplied XYZ rows and optional velocity/acceleration. Dates and reference times retain exact text. Sample intervals are double seconds. Julian transformation epochs retain eleven fractional digits as text.
- `CSSFAB` writes version two. Scanner field-alignment pairs, framer corner grids, fiducial transforms, interior orientation and optional telescope optics use their named value descriptors. Counts derive from homogeneous arrays. `SensorBand.isubcat` is in micrometers; `ImageHeader.isubcat` is a double row in **nanometers**, with NaN for blank. `ImageHeader.irepband` accepts a cell row of supported display labels or empty for defaults. Supplied band indices are primary; uniquely matching supplemental identities also support reordered bands. Unresolvable or ambiguous mappings fail validation. Arbitrary text subcategories and LUT bands are outside this candidate.
- `CSCSDB` writes version one. `SensorErrorCore` / `SensorErrorGroup` describe fundamental errors and correction posts; `CalibrationErrorGroup`, `TimeSyncError`, and `UnmodeledErrorGrid` describe the other allocations. `SPDCF` combines weighted `GLASCorrelation` components. References resolve within their containing DES. Covariance matrices must remain positive semidefinite after encoding; correlation weights must still sum to one at their encoded precision. Optional `adj` / `errcov_c4` cover all supplied adjustable parameters and preserve the original error model.
- `CSEXRB.exploitation` accepts `ExploitationInfo` with collection criteria, imaging operations and quality metrics. Supplied target ID and time must match image-header `tgtid` and `idatim`. `CSRLSB` stores a row-by-column grid of four corner time offsets. `CSWRPB` stores supplied warping polynomials; framing warps require CSSFAB calibration with a 1-by-1 fiducial array. NFX does not warp pixels.

CSCSDB's optional `spdcf_id_adj` uses the defined reserved area in current Table M.6-5. Its field-count markers conflict with the table's stated minimum lengths, and older packing criteria still say its reserved length must be zero. NFX follows the explicitly counted fields for generic encoding and does not claim profile conformance for that optional combination pending clarification.

These checks establish supported encoding and associations, not scientific sensor-model accuracy, covariance propagation, CSM execution or Level 2 conformance. Incomplete generic metadata is permitted. Wrapped models resolve against their effective image/frame contexts, including shared DESs for different groups of motion frames.

## Selected SNIP profile

`File.validate(SNIP_COMPLIANT=true)` checks supplied metadata against the **SNIP 1.2 CN1 airborne nonrectified MSI** case. Generic NITF validation remains the default. Profile failures carry stable issue identifiers, field locations and specification references. Writing with the same option performs these checks before touching the destination and requires the filename prefix to equal FTITLE, with a `.ntf` extension.

```matlab
addpath('src','examples');
file = snipExample();               % Synthetic two-band RSM example
report = file.validate(SNIP_COMPLIANT=true);
assert(report.valid);
file.write([file.header.ftitle '.ntf'],SNIP_COMPLIANT=true);
```

The supported case uses unclassified, unsigned 8/16-bit still images with supplied D/G geographic corners. Spectral images require CSDIDA at file level and BANDSB, CSCRNA, HISTOA, ILLUMB, ACFTB and AIMIDB at image level. Checks cover placement/counts, known spatial response, band IDs and wavelength order, nanometer ISUBCAT values, acquisition/processing times, registered processing comments, illumination datums and supplied sensor angles. Symmetric bands use CWAVE/FWHM; asymmetric bands use NOM_WAVE/LBOUND/UBOUND. Each image uses one complete BANDSB instance.

Multiple complete images may use sorted `MSI:000001` identifiers or uppercase base-26 suffixes; segmented-image identifier forms remain outside this case. Later HISTOA events inherit unchanged processing comments. Additional standard citations support numbered author and custodian blocks; the SNIP citation itself must omit authors and include its certification status.

- At least one complete mensuration metadata path is required: RSM with the appropriate nonadjusted/adjusted covariance companions, or ECF GLAS/GFM with associated attitude, ephemeris, field alignment and covariance DESs. GLAS attitude/ephemeris samples must cover the supplied acquisition event. Supplemental generic metadata may accompany a complete path. RPC00B alone cannot satisfy this check.
- Supplied mono/RGB quick looks precede spectral images, use one unpadded block, preserve source identity/corners/aspect ratio, and describe their displayed source bands and wavelengths in ICOM1. NFX does not generate quick-look pixels.
- Integer spatial crops require ICHIPB original-image mapping, a HISTOA crop event and file-level MATESA parent lineage. Resampled/spectral chips, rectified imagery, HSI, geolocation grids, cloud masks and pixel-metric products are outside this selected case.
- `nfx.snipCitation(file.header,1)` supplies the required SNIPSTD text segment with the pinned standard identity and `PRODUCT_CERT_DATE: ----------`. This explicitly records unknown certification. Additional ordered citations are supported.

The pinned CSDIDA catalog identifies airborne/WAMI with platform code **9I**; the selected validator accepts that code. **AU is the Aurora satellite**, not a generic airborne code. Additional airborne registrations need an authoritative catalog update before they can be accepted. The SENSRB-only SNIP mensuration path fails with `SNIPSENSRBProfileUnavailable`: the separate NGA SENSRB image-to-ground profile is not present in the supplied library. SENSRB serialization, continuation splitting and supplemental use are implemented. The conflicting optional CSCSDB adjustment-correlation area likewise cannot establish the sole GLAS SNIP path.

A passing report establishes the implemented structural and supplied-metadata checks. It does not establish the truth of sensor calibration, model accuracy, illumination target being the actual image center, correct parent-data inheritance, or external product certification. Those require provider evidence and scientific evaluation. See the [requirements-to-test mapping and reference decisions](tests/README.md#profile-requirements-and-test-mapping).

## Motion collections and manifests

Run `addpath('src','examples'); collection = mieExample();` for a self-contained synthetic collection with two layers, three cameras, two camera sets, two intervals, and a supplied quick look.

```matlab
files = collection.plan();      % Manifest first, then interval/set order
assert(collection.validate().valid);
paths = collection.write(pwd);  % Publishes imagery first, manifest last
```

`MIECollection` implements the original-resolution uncompressed **NFX-MIE-NC1** writing scope. Supply arrays of `MIMCSA` layer summaries, `CAMSDA` camera sets, `MICIDA` core identities, and `TMINTA` interval definitions. Append `MotionBlock` values containing an image, editable `MTIMSA` timing, and exact start/end timestamps. Counts vary at runtime. Supply camera UUID and interval index in each block; image index, camera-set/layer references, temporal-block index, and frame count derive from the collection. Do not also attach MTIMSA to the block image.

- Pixels are rows-by-columns-by-bands-by-frames, with a constant native class and shape within each segment. A single frame uses IMODE B; multiple monochrome frames use F and multiple multiband frames use T. Bytes run through spatial blocks, frames, bands, rows, then columns. Edge padding, ABPP, LI, and motion complexity levels 51/54/57 derive automatically.
- Camera dimensions and CCS placement, layer rate bounds, consecutive chronological intervals, nonoverlapping camera blocks, and exact frame timestamps are checked before output. One constant `dt` applies to **every** frame, including the first offset from `base_timestamp`. Integer arithmetic preserves products beyond uint64 without double rounding. Unknown fractional timestamp digits retain their precision; comparisons use the precision common to both operands. Motion block ends are exclusive; a supplied still may have equal start/end times.
- One imagery file is generated per available camera-set/interval group, with canonical `.cNiN.ntf` or single-set `.iN.ntf` names. Each contains the full common collection definitions, its MTIMFA mappings, and derived per-image MTIMSA. A mapping must fit its specified single-record limit; NFX does not split MTIMFA in ways the standard does not permit.
- The manifest is enabled by default. Its FILE001, FILE002, etc. text segments contain the complete CR/LF-separated filename list, split only between entries. `manifest_mtimfa=true` includes the complete mapping set. `available=false` blocks preserve supplied missing-imagery times; groups with no available imagery require these mappings in the manifest.
- `quicklooks` accepts supplied single-frame images with selection comments and MTIMSA scope/time metadata. Associations must identify existing collection entities. NFX writes these images into the manifest without generating or resampling their pixels.
- `file_templates` supplies optional headers, TREs, text and DESs for a particular set/interval; `manifest_template` supplies manifest metadata. The planner owns imagery and collection-definition TREs. Edit the collection and replan to update these snapshots.

`FSYNWA`, `FASYWA`, and `CONTXA` select effective metadata before model validation. Physical byte offsets determine within-file override precedence, including user-defined areas and TRE-overflow DESs. FASYWA uses exact frame times and exclusive end limits; synchronous metadata takes precedence over overlapping asynchronous metadata. RSM sections retain their section identities, and augment/partial-override records such as SENSRB retain their ordered parts. MTIMSA itself stays unwrapped as the primary temporal-block timing record.

CONTXA resolves image/frame indices and collection camera-set, camera, interval and temporal-block hierarchies. Metadata in a manifest or another imagery file can describe a target image. Planned File values capture the relevant collection catalog and foreign snapshots; editing such a bound File requires replanning from the collection. Conflicting cross-file overrides fail explicitly because independent files have no common byte-offset order. Identical repeats are coalesced for validation; original output bytes remain intact.

`[records,fileRecords] = file.effectiveTREs(imageIndex,frameIndex)` exposes effective image and file-header snapshots. `byte_offset` is zero based; `file_index=0` identifies the current file, and positive indices identify source files in the captured collection plan. These diagnostic offsets are separate from logical `tre_ids` used for removal.

Collection writing validates every planned file and every destination before publishing. Each file keeps the ordinary temporary-write/replace protection. A later filesystem failure reports the failed path and all paths already published, and leaves the old manifest untouched until the final publication step. This is **not a collection-wide transaction**. Retry/recovery and concurrent writers require caller coordination. `Overwrite=true` explicitly allows per-file replacement.

## Tests and limits

```matlab
results = runTests(Coverage=true);
```

The suite includes independent byte checks, MATLAB reader round trips, metadata and layout boundaries, snapshot/removal behavior, and injected filesystem failures. Reports go under ignored `coverage/`; generated files use temporary fixtures. See [test and compatibility notes](tests/README.md).

Classified products, LUTs, compression, and geographic coordinate representations other than D/G are not supported. SNIP validation is restricted to the selected case above; MIE validation is restricted to NFX-MIE-NC1. RPC fitting and evaluation are outside scope.

MATLAB Coder remains a design priority: implementation uses qualified names, applicable `%#codegen` annotations, and native pixel storage. No Coder license is available, and compiled compatibility is **not verified**. Temporary-file creation and publication still need a supported, tested generated-code path. The small `publishCollection` host helper isolates try/catch needed to report partial publication; its callers and metadata/byte paths retain generation intent. R2023b execution is also unverified.
