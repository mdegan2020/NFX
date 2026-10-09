# OpenJPEG prototype

Experimental Windows-only, numerically lossless JPEG 2000 encoding for NFX.
The pinned codec is OpenJPEG 2.5.4. MATLAB can use an executable or an optional
in-memory MEX backend;
Python, GDAL, NITRO and MATLAB Coder are not required.

## Try it

From the repository root, run `./tools/setupOpenJPEG.ps1` in PowerShell. It
downloads the official Windows x64 release, verifies the pinned SHA-256, and
extracts it under ignored `artifacts/openjpeg/`. OpenJPEG's license is reproduced
in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md). The script prints the
executable path. No codec is downloaded
automatically during ordinary toolbox use or testing.

```matlab
addpath('src', 'examples');
encoder = fullfile(pwd, 'artifacts', 'openjpeg', '2.5.4', ...
    'openjpeg-v2.5.4-windows-x64', 'bin', 'opj_compress.exe');
[file, metrics] = openjpegExample(encoder);
file.write(fullfile('artifacts', 'openjpeg', 'example.ntf'), ...
    Overwrite=true);
disp(metrics)
```

For an existing valid single frame with right-justified pixels and 1024-square
blocks:

```matlab
image = image.compress(encoder, Profile='EPJE');  % Or 'NPJE' (default)
file = nfx.File(header=fileHeader) + image;
file.write('compressed.ntf');
```

`image.compression` exposes the immutable codestream, derived J2KLRA payload,
structural inspection and timings. Native pixels stay in `image.data`.
Compression is eager: validation and writing never run the codec again.
`image.uncompress()` drops the encoding and restores the existing uncompressed
behavior. Replacing or editing pixels also drops the encoding and its derived
TRE. Metadata edits retain it; incompatible block dimensions or justification
fail validation. Attached files retain their value snapshots.

The generated J2KLRA appears last in `tre_records`, with reserved ID zero. It is
derived metadata, excluded from `tre_ids`/`tre_tags`, and cannot be independently
removed. User TRE attachments retain their IDs, order and removal behavior.

## Implemented configuration

- Dense real `uint8` and `uint16` single frames, including RGB and multispectral
  arrays. Both dimensions must be at least 32. Partial edge tiles are supported.
- Native component precision (8 or 16), no component/color transform, no sample
  subsampling, reversible 5–3 wavelet, two guard bits, 64-square codeblocks,
  maximal precincts, zero offsets, and 1024-square tiles.
- Five decompositions/six resolutions and 20 quality layers. The first 19
  targets follow BPJ2K01.20 Table D-17; the final layer retains all coding passes.
  Targets may be unattainable on small or highly compressible imagery. J2KLRA
  records the requested targets and the achieved final codestream bitrate.
- NPJE uses LRCP, one tile-part per tile and one TLM with implicit tile indices.
  This prototype limits NPJE to 16,382 tiles, following Table D-13's single-TLM
  form conservatively despite broader multiple-TLM language elsewhere.
- EPJE uses RLCP, one tile-part per resolution per tile, then physically orders
  all lowest-resolution tiles before all next-resolution tiles. TLM entries use
  explicit two-byte tile indices and four-byte lengths. Up to 65,535 tiles are
  admitted; very large images have not been exercised.
- EPJE admits at most 3,276 bands: each part has 20 packets per band, and one
  PLT can hold at most 65,532 packet-length bytes. Variable-length entries can
  impose a stricter data-dependent limit. The encoder output is rejected if
  its packet lengths need multiple PLTs. The NPJE component bound is 16,384.
- OpenJPEG output from either backend has its TLMs rebuilt and its Rsiz set to
  Profile-1 only after the bounded coding configuration is checked. Whole
  tile-parts are copied; entropy-coded bytes are not recompressed.
- Each NITF image stores one raw codestream with `IC=C8`, derived `LI`, `COMRAT`
  and original-encoding J2KLRA (`ORIG=0` or `2`). JPEG 2000 requires
  `ABPP=NBPP=codestream precision`; uncompressed images retain value-based ABPP.
  Mixed compressed/uncompressed image segments and text segments are supported.

## Validation and limits

```matlab
results = runTests(OpenJPEG=encoder, Coverage=true);
```

Without `OpenJPEG=...` or `NFX_OPENJPEG`, `runTests` explicitly excludes the
optional codec tests. Existing uncompressed tests need no external encoder.
Codec tests include an independent file-based marker parser, corrupted marker
rejection, exact MATLAB `imread`/`nitfread` round trips, multiband and edge cases,
reduced-resolution NPJE/EPJE comparisons, snapshot behavior and mixed segments.

The initial prototype qualification on R2026a Update 4 passed **1,056 tests**,
including 43 optional
OpenJPEG tests, with no failures or incomplete tests. Implementation line
coverage was **8,803 / 8,853 (99.44%)**. Uncovered prototype lines include
external-codec/version failure and defensive format/size branches; the large
tile/band limits and every malformed codestream combination are not exercised.
An independent fresh GPT-6 Astra Extra High review found one early bounds-check
issue, which was fixed and regression-tested, and no unresolved findings.

`nfx.JPEG2000.inspect(bytes,profile)` checks only this prototype's bounded
configuration. It walks marker lengths and tile-part boundaries, checks TLM
indices/lengths, PLT packet coverage/counts and physical ordering. It is not a
general JPEG 2000 validator, does not decode entropy data or prove requested
rate-control targets, and is not a conformance certification.

Single motion frames may carry `.M` categories and MTIMSA timing. Collections
can assemble these captured C8 snapshots without invoking the encoder during
planning or writing; see [compressed collections](../../README.md#compressed-motion-frames).
`MemoryWarningBytes` on `compress` or `nfx.JPEG2000` defaults to 4 GiB and warns
without blocking when the estimated buffers exceed that threshold. The estimate
includes two native-size buffers and, for MEX, its int32 component arrays.
Additional tile/packet workspace and compressed output can increase memory;
this is not a peak-memory guarantee. `Inf` silences the warning.

Lossy/visually lossless encoding, multi-frame compressed segments (CB/MB),
IMODE X, masks, arbitrary codestream import, heterogeneous component precision
and compressed SNIP enforcement remain outside this prototype. The SNIP
validator explicitly rejects C8. Collection support covers original-resolution
NC and the documented single-frame NPJE/EPJE C8 configuration.
This optional encoding path is exempt from the MATLAB Coder goal. Execution has
been tested on MATLAB R2026a Update 4; compiled compatibility is not claimed.

Both encoders default to one thread; `Threads=N` selects a positive integer
thread count. Executable raw input is staged
in row chunks. Native pixels and compressed bytes remain in MATLAB memory;
normalization temporarily holds both codestream copies. Reported temporary
bytes count the raw input plus encoder output, excluding the installed codec
and destination NITF. Timings exclude raw staging and executable version checks;
they are individual observations, not controlled performance benchmarks.

## In-memory MEX backend

The MEX accepts and returns MATLAB arrays directly. It stages no raw pixels
or codestream files and launches no external encoder/decoder processes.
It uses the same profile settings, structural validation, normalization,
J2KLRA derivation, and compression snapshots as the executable backend.

### Build once

On 64-bit Windows, install Microsoft Visual C++ 2022 Build Tools with its
C++ workload and CMake tools, then select it using `mex -setup C++`. From the
NFX root in MATLAB:

```matlab
binary = buildOpenJPEGMex;
```

The build downloads SHA-256-verified OpenJPEG 2.5.4 source, builds a Release
static library using CMake, and creates
`src/+nfx/+internal/openjpegMex.mexw64`. A separate CMake installation can be
selected with `buildOpenJPEGMex(CMake='C:/path/to/cmake.exe')`.
The build makes no persistent MATLAB path changes. As with ordinary NFX use,
add only `src` to the MATLAB path using the Set Path GUI if desired.
Generated source/build files and the MEX binary remain ignored by Git.

OpenJPEG is statically linked: the built MEX needs no OpenJPEG executable or
DLL at runtime. A compatible Microsoft Visual C++ runtime is still required.
For redistribution, include [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).
The build targets MATLAB R2023b+ and has been exercised on R2026a Update 4 with
MSVC 2022. Other MATLAB releases/compiler combinations have not been tested.
This host codec path is outside the MATLAB Coder compatibility goal.

### Encode and decode

```matlab
image = image.compress(Backend='mex', Profile='EPJE', Threads=4);

packed = nfx.JPEG2000(pixels, Backend='mex', Profile='NPJE', Threads=4);
restored = nfx.JPEG2000.decode(packed.codestream, Backend='mex', Threads=4);

[file, ok, status] = nfx.File.read('capture.ntf', readAll=true, ...
    JPEG2000Backend='mex', JPEG2000Threads=4);
```

For encoding, `Backend='auto'` preserves an explicitly supplied executable
path; without a path it selects MEX. Thus `image.compress(encoder)` retains
its original meaning, while `image.compress()` uses the optional MEX.
Explicit `Backend='mex'` requires omitting the executable path.

For decoding, `Backend='auto'` (or `JPEG2000Backend` on readers) selects MEX
when installed and MATLAB otherwise. Force `'matlab'` to use the original
decoder. MEX decoding defaults to four threads; encoding defaults to one.
Explicit `'mex'` reports a missing dependency when the binary is
absent. A broken binary or failed MEX decode is reported without silently
retrying another backend. Standalone `decode` validates the supported NPJE
or EPJE structure and automatically identifies its progression order.

No source pixels are modified. Thread counts may affect performance differently
by image and machine. Four threads are an example, not a required setting.
MEX `metrics.temporary_bytes` is zero; it measures disk staging, not RAM.

### Tests and timing

```matlab
results = runTests(OpenJPEGMex=true, OpenJPEG=encoder);
timings = benchmarkOpenJPEGMex(pixels, encoder, Profile='EPJE', Threads=4);
```

The benchmark is in `examples`. It uses warmed `timeit` measurements of full
public encode/decode calls, verifies exact pixels, and compares the executable
and MATLAB decoder against MEX with one and multiple threads. There are no
timing assertions in the unit suite. `OpenJPEGMex=true` alone runs MEX tests
without the executable cross-checks.

On 2026-10-04, R2026a Update 4 / MSVC 2022 validation passed the 2,963-test
ordinary NFX suite. After the final native allocation hardening, all 175
affected checks passed, including exact 5000-by-15000 uint16 round trips in
both profiles and explicit collection backend selection. An additional run
with the MEX removed passed all 109 executable/reader/collection checks.
A fresh independent code review had no unresolved findings. Large-data tests
remain opt-in; the multi-GB, 20-frame stress test was not run in this iteration.

Final warmed `timeit` observations for a 1024-by-1024 uint16 noise image:

| Profile | CLI encode, 1 thread | MEX encode, 1 thread | MEX encode, 4 threads | MATLAB decode | MEX decode, 4 threads |
| --- | ---: | ---: | ---: | ---: | ---: |
| NPJE | 1.006 s | 0.424 s | 0.166 s | 0.186 s | 0.144 s |
| EPJE | 0.991 s | 0.413 s | 0.159 s | 0.189 s | 0.134 s |

This case showed about 2.4x faster encoding with one MEX thread, 6.1–6.2x
with four threads, and 1.3–1.4x faster decoding with four threads. Single-thread
MEX decoding was slower (0.406/0.402 s), motivating the four-thread decoder
default. These synthetic timings depend on image content, size, thread count,
and machine; benchmark operational imagery before choosing a configuration.
The MEX used zero temporary-file bytes, versus about 4.34 MB for CLI encoding.

Source archive SHA-256:
`1048d084b89ac1587e3b0dca00b863a757fed2bc1804c6355eb4bce9090356b7`.

### Initial local observations

`addpath('src', 'examples'); observations = observeOpenJPEG(encoder);` reproduces
these synthetic cases. This run used R2026a Update 4 and one codec thread:

| Synthetic input | Raw size | Profile | Codestream bytes | Encode seconds | Total seconds |
| --- | ---: | --- | ---: | ---: | ---: |
| 2048×2048 mono uint16 ramp | 8 MiB | NPJE | 5,266 | 0.214 | 0.881 |
| Same | 8 MiB | EPJE | 5,774 | 0.209 | 0.863 |
| 1024×1024×5 uint16 random noise | 10 MiB | NPJE | 11,195,660 | 1.403 | 2.092 |
| Same | 10 MiB | EPJE | 11,195,787 | 1.396 | 2.071 |
| 1024×1024 RGB uint8 ramp | 3 MiB | NPJE | 5,802 | 0.124 | 0.765 |
| Same | 3 MiB | EPJE | 5,929 | 0.126 | 0.775 |

Normalization took 0.001–0.013 seconds. The noise case used about 20.68 MiB of
temporary files and showed a 10.68 MiB pre/post MATLAB memory increase. Other
cases showed 0–7.63 MiB increases, affected by allocation reuse. These memory
observations exclude the encoder process and transient peaks. Lossless encoding
can expand noise. Ramps compress unusually well; these numbers do not predict
performance or ratios for operational imagery. Total time includes raw staging,
version checking, encoding, normalization, inspection and temporary cleanup.

## References

- Local BPJ2K01.20, 27 October 2023, Table 8-2/8-3 and Appendices D/E.
- STDI-0002 Volume 1 Appendix Y, administrative update 2 July 2024.
- [OpenJPEG 2.5.4 release](https://github.com/uclouvain/openjpeg/releases/tag/v2.5.4).
- [Pinned encoder source and options](https://github.com/uclouvain/openjpeg/blob/v2.5.4/src/bin/jp2/opj_compress.c).

Release archive SHA-256:
`655f6111449da83f5424f76d74873116bc01ce50cc10361d2b0b4667c3e5e8c3`.
