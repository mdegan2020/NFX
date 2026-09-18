# Portable MATLAB Coder checks

The reader is usable independently of this kit. These probes measure Coder
compatibility; they do not promise that the whole toolbox compiles. Local
development has MATLAB R2026a without a MATLAB Coder license, so actual
compilation and generated execution remain pending on a licensed machine.

## Transfer and run

On the development machine:

```matlab
archive = exportCoderTests;
```

Copy the returned source ZIP to the other machine and extract it. Open the
extracted folder as MATLAB's current folder, then run:

```matlab
report = runCoderTests;
disp(report.archive)
```

Bring back the **result ZIP** named by `report.archive`. It contains the
diagnostics needed for a compatibility-fix pass. The source bundle needs
neither Git nor Codex, connectors, downloaded standards, or test data.
Synthetic inputs are generated locally. Normal MATLAB with its JVM is
required for source SHA-256 hashes.

Use MATLAB R2023b or later with MATLAB Coder installed and licensed. A
supported, selected C compiler is required for the default MEX checks.
The runner records both C and C++ compiler selections and never installs
products or changes their configuration. If needed, manually run
`mex -setup C` after installing a compiler supported by your MATLAB release.

These optional commands select additional checks:

```matlab
% Check the MATLAB references and archive machinery without compiling.
report = runCoderTests(ReferenceOnly=true);

% Also generate standalone C and C++ source (no library build).
report = runCoderTests(Standalone=true);

% Add separate source-generation checks with heap allocation disabled.
report = runCoderTests(Standalone=true, NoHeap=true);
```

`ReferenceOnly=true` overrides generation options. Default outputs go to
new directories under `artifacts/coder`, ignored by Git in NFX. An optional
`OutputFolder` changes that parent folder. Nothing overwrites an older run.
The runner returns failed results so that an archive can still be produced;
inspect `report.allRequestedPassed` for automation. A reference-only pass
does **not** mean compilation passed.

## What is exercised

Each row has one concrete entry point, or a separate entry point per pixel
type. The same generated MEX receives every fixture size for that row.
Outputs must match MATLAB and independent expected values or byte layouts.

| Probe | Entry point | Inputs and assertions |
|---|---|---|
| Storage | `nfxCoderStorage` | 0/1/9 comments, different counts across objects, 0–4 TRE records, payload lengths 1/251/99985, missing lookup |
| RPC | `nfxCoderRPC` | Concrete deserialize/serialize, malformed and empty payloads, status/default values, snapshot independence |
| Timing | `nfxCoderTiming` | Empty and varying delta vectors, exact `uint64` above `flintmax` and at its maximum, literal big-endian bytes |
| Groups | `nfxCoderGroups` | 0/1/10001 SENSRB module-12 samples, continuation groups, wrapper children, typed lookup, copy independence and removal |
| Native byte paths | `nfxCoderNative8`, `nfxCoderNative16` | Separate primitive types, text-only and multiple-image files, B/F/T blocking, multiple frames/bands, padding, independent pixel bytes and header metadata |
| File integration | `nfxCoderFile8`, `nfxCoderFile16` | Full in-memory reader, derived file headers, same native fixtures, malformed-file status |
| Mixed types | `nfxCoderMixed` | Different-size `uint8` and `uint16` images in one file object, with both types preserved |

The native probes call the actual `readPixels` and `pixelBlockBytes` code
used by NFX. The file-integration probes additionally exercise the complete
reader's object/type inference. Even single-type input files can expose
compiler inference limits in branches that support both pixel types. Such
failures remain visible; the harness never casts them to a common type.

Input bounds are explicit in `coder-tests/+nfxkit/inputTypes.m`: at most
four comment/record counts, 1041 RPC bytes, four timing deltas, 65536 bytes
per native input file, and small bounded mixed images. Bounds are test
configurations, not new toolbox limits. Internal variable-size arrays may
still be unbounded. No-heap failures are useful independent results.

## Generation settings and limits

The baseline enables variable sizing and dynamic memory allocation with a
65536-byte threshold. MEX generation disables automatic and explicit
extrinsic calls; success must exercise generated code. Each generation
attempt saves its actual configuration and input types. Standalone C/C++
checks use `codegen -c`: they generate source only, without building a
library or executing it. No-heap checks disable dynamic allocation and also
generate source only, avoiding large fixed-stack runtime experiments.
These settings follow the MathWorks documentation for
[MEX configuration](https://www.mathworks.com/help/coder/ref/coder.mexcodeconfig.html),
[dynamic allocation](https://www.mathworks.com/help/coder/ref/enabledynamicmemoryallocation.html),
and [codegen](https://www.mathworks.com/help/coder/ref/codegen.html).

Excluded from generated-code claims: JPEG2000 and MATLAB/Python/OpenJPEG
bridges, disk I/O and publication/manifest services, display dispatch,
arbitrary polymorphic object returns, and complete SNIP/GLAS/RSM/collection
coverage. Host-side fixture construction and reporting use ordinary MATLAB
features, including exceptions. Their availability is not evidence that
those features compile inside NFX.

## Reading the result archive

- `SUMMARY.md`: every probe and phase, with separate reference/MEX counts.
- `results.json`: phase outcomes, individual case diagnostics and test status.
- `test-results.mat`: standard `matlab.unittest` results with diagnostics.
- `session.json`: release, installed products, licenses, architecture,
  selected compilers, and requested phases.
- `source-hashes.json`: SHA-256 identity of every included source file.
- Per-probe folders: synthetic inputs, result JSON, and, when attempted,
  generation logs, actual configuration, generated sources and reports.

Outcomes distinguish `pass`, `reference_failure`, `compile_failure`,
`runtime_failure`, `unmet_prerequisites`, `not_requested`, and unexpected
`harness_failure`. Unavailable or unrequested phases are incomplete tests,
never passes. Only a passing **mex** phase proves generated execution for
its entry point and cases. A passing standalone/noheap phase proves source
generation only. Archives contain local paths and compiler locations as
well as synthetic data; review them before sharing outside your team.
