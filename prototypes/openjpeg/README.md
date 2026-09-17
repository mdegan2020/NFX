# OpenJPEG prototype

Experimental Windows-only, numerically lossless JPEG 2000 encoding for NFX.
The pinned encoder is OpenJPEG 2.5.4. MATLAB controls the codec executable;
Python, GDAL, NITRO and MATLAB Coder are not required.

## Try it

From the repository root, run `./tools/setupOpenJPEG.ps1` in PowerShell. It
downloads the official Windows x64 release, verifies the pinned SHA-256, and
extracts it under ignored `artifacts/openjpeg/`. The distribution includes its
license notices. The script prints the executable path. No codec is downloaded
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

For an existing valid still image with right-justified pixels and 1024-square
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

- Dense real `uint8` and `uint16` still images, including RGB and multispectral
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
- OpenJPEG CLI output has its TLMs rebuilt for the profile and its Rsiz set to
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

The final R2026a Update 4 run passed **1,056 tests**, including 43 optional
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

Lossy/visually lossless encoding, compressed motion, masks, arbitrary
codestream import, heterogeneous component precision and SNIP/MIE compressed
profile enforcement are outside this prototype. The existing SNIP validator
explicitly rejects C8; the existing MIE collection profile remains NC-only.
This optional encoding path is exempt from the MATLAB Coder goal. Execution has
been tested on MATLAB R2026a Update 4; compiled compatibility is not claimed.

The executable uses one encoding thread for repeatability. Raw input is staged
in row chunks. Native pixels and compressed bytes remain in MATLAB memory;
normalization temporarily holds both codestream copies. Reported temporary
bytes count the raw input plus encoder output, excluding the installed codec
and destination NITF. Timings exclude raw staging and executable version checks;
they are individual observations, not controlled performance benchmarks.

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
