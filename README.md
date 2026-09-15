# NFX — NITF File eXchange

A MATLAB toolbox for constructing and writing NITF files through a compact object-oriented API in the `nfx` namespace.

The first candidate writes NITF 2.1 files with one uncompressed, blocked image and an optional RPC00B TRE. It supports dense real `uint8` and `uint16` pixels, explicit unclassified metadata, and MONO, RGB, or MULTI representation. Blocks default to 1024 × 1024; partial edge blocks are zero padded.

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

- `FileHeader` and `ImageHeader` expose specification mnemonics in lowercase. Numeric metadata requires `double`; pixels retain their native class. Required caller metadata starts unset. RPC coefficient groups contain exactly 20 doubles each, in specification order.
- `RPC00B` is editable before attachment. `image + rpc` captures its validated bytes; later edits to `rpc` do not change the image. `file + image` also captures a value snapshot.
- Remove an attachment with `image = image.removeTRE(image.tre_ids(1))`. Remaining IDs and insertion order survive removal; removed IDs are not reused. Repeated RPC attachments can be edited, but must be reduced to at most one before writing.
- Set pixels through `image.data`, and block dimensions through `image.header.nppbh` / `nppbv`. Dimensions, bands, block counts, storage width, segment lengths, and file complexity update automatically.
- `validate()` returns `valid`, `scope`, and `issues`. Each issue includes an identifier, field location, message, and specification reference. `rpc.ascii()`, `rpc.payload()`, and `rpc.bytes()` expose the ASCII payload, payload bytes, and framed TRE bytes respectively.
- `write()` validates first and prepares a temporary file beside the destination. Replacing an existing file requires `Overwrite=true`. Failed preparation leaves the destination intact and cleans up temporary output. Concurrent writers to the same destination require caller coordination.

## Tests and limits

```matlab
results = runTests(Coverage=true);
```

The suite includes independent byte checks, MATLAB reader round trips, metadata and layout boundaries, snapshot/removal behavior, and injected filesystem failures. Reports go under ignored `coverage/`; generated files use temporary fixtures. See [test and compatibility notes](tests/README.md).

This candidate supports full-width unsigned samples and inline RPC00B only. It does not write classified products, geographic corners, LUTs, image comments, multiple images, text segments, TRE overflow, or compressed imagery. `SNIP_COMPLIANT=true` explicitly fails validation and writing because SNIP enforcement is not implemented. RPC fitting and evaluation are outside scope.

MATLAB Coder remains a design priority: implementation uses qualified names, applicable `%#codegen` annotations, and native pixel storage. No Coder license is available, and compiled compatibility is **not verified**. Temporary-file creation and publication still need a supported, tested generated-code path. R2023b execution is also unverified.
