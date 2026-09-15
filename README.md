# NFX — NITF File eXchange

A MATLAB toolbox for constructing and writing NITF files through a compact object-oriented API in the `nfx` namespace.

NFX writes NITF 2.1 files with multiple uncompressed blocked images, standard text segments, and data extension segments (DESs). Images support dense real `uint8` and `uint16` pixels, explicit unclassified metadata, and MONO, RGB, or MULTI representation. Blocks default to 1024 × 1024; partial edge blocks are zero padded. RPC00B and FREESA are supported TRE definitions; oversized metadata areas use derived `TRE_OVERFLOW` DESs.

Targets MATLAB R2023b and newer; tested locally on R2026a. Writing requires base MATLAB. Reader round-trip tests also require Image Processing Toolbox. No GDAL or NITRO dependency.

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
- `RPC00B` is editable before attachment. `image + rpc` captures its validated bytes; later edits to `rpc` do not change the image. `file + image` also captures a value snapshot.
- Remove an attachment with `image = image.removeTRE(image.tre_ids(1))`. Files and text segments provide the same TRE API. Remaining IDs and insertion order survive removal; removed IDs are not reused. `tre_records` exposes physical snapshots for inspection. Repeated RPC attachments can be edited, but must be reduced to at most one per image before writing. Attachment checks each concrete TRE's legal owner.
- Set pixels through `image.data`, and block dimensions through `image.header.nppbh` / `nppbv`. Dimensions, bands, block counts, storage width, segment lengths, and file complexity update automatically.
- Automatic `abpp` is the number of bits needed for the largest right-justified sample across all bands; all-zero data uses one bit. `nbpp` remains 8 or 16 according to native storage. Set `image.header.abpp` to declare a larger acquisition precision, or `NaN` to restore automatic behavior. A smaller precision must still fit every sample. With `pjust='L'`, automatic ABPP uses the full storage width; an explicit precision requires zero low-order padding bits. Samples are never shifted or converted. Statistics refresh on pixel replacement and indexed edits, using bounded temporary storage; header access does not rescan pixels.
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

## Tests and limits

```matlab
results = runTests(Coverage=true);
```

The suite includes independent byte checks, MATLAB reader round trips, metadata and layout boundaries, snapshot/removal behavior, and injected filesystem failures. Reports go under ignored `coverage/`; generated files use temporary fixtures. See [test and compatibility notes](tests/README.md).

Classified products, LUTs, compression, and geographic coordinate representations other than D/G are not supported. `SNIP_COMPLIANT=true` explicitly fails validation and writing until profile enforcement is implemented. RPC fitting and evaluation are outside scope.

MATLAB Coder remains a design priority: implementation uses qualified names, applicable `%#codegen` annotations, and native pixel storage. No Coder license is available, and compiled compatibility is **not verified**. Temporary-file creation and publication still need a supported, tested generated-code path. R2023b execution is also unverified.
