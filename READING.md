# Reading NFX files

NFX reads the NITF 2.1 layouts that its writer supports. It returns the same
value classes used to construct files, with native `uint8` or `uint16`
pixels and editable metadata. This is a bounded reader, not a promise to
accept every valid NITF file from another producer.

## A single file

```matlab
addpath('src');
[file, ok, status] = nfx.File.read('source.ntf');
if ~ok
    fprintf('%s: %s\n', status.code, status.message);
    return
end

pixels = file.images(1).data;
comments = file.images(1).header.icom;
[rpc, found] = file.images(1).RPC00B;
if found
    disp(rpc.line_num_coeff);
end

for index = 1:file.images(1).treCount('FREESA')
    record = file.images(1).FREESA(index);
    fprintf('Free-space payload: %d bytes\n', record.count);
end
```

Use `numel(file.images)` before selecting an image in a file that might
contain only text or support data. Typed TRE methods return a new concrete
value; editing it does not change the attachment. Raw payloads remain in
`tre_records`. Imported attachment IDs are new local identities, since IDs
are not stored in NITF. Encoded metadata precision is preserved; original
pre-serialization precision cannot be recovered.

For an ordinary file with complete context, editing `file.header` and
calling `file.write('copy.ntf')` preserves the attached segments. To update an
image snapshot, use `file = file.replaceImage(index, image)`; other images,
text, support data and file-level TREs retain their places. Existing
destinations require `Overwrite=true`. Validation runs again before writing.

## Supported content

| Content | Reading behavior |
| --- | --- |
| Uncompressed imagery | Blocked B/F/T layouts, native unsigned samples, bands, frames, edge padding, multiple images |
| Image metadata | Comments, band fields, corners, stored ABPP/PJUST and display relationships |
| TREs | Supported concrete types, repeated records, SENSRB continuation groups, wrappers and overflow ownership |
| Text | Supported STA text and subheaders, including text-only files |
| Generic DESs | Exact payload and supported subheader bytes; no semantic claim about arbitrary registered data |
| GLAS/GFM DESs | Typed CSATTB, CSEPHB, CSSFAB and CSCSDB layouts already supported by the writer |
| JPEG2000 | Existing lossless NPJE/EPJE C8 still-image output |
| Collections | Original-resolution uncompressed MIE collections, explicit members, manifests, quick looks and unavailable blocks |

Lengths, counts, conditional headers and source bounds are checked before
content is reconstructed. Supplied structural values must agree with the
decoded data. Supported TRE encodings and metadata packing follow the NFX
writer's canonical rules. Unknown TREs, unsupported layouts and conflicting
fields produce a diagnostic instead of silently dropping or repairing data.

TRE payloads, generic DES payloads and untouched compressed codestreams are
preserved. Native significant pixels, exact `uint64` timing, and metadata at
encoded precision survive a semantic write/read/write round trip. Whole-file
byte identity is tested in many cases but is not the public guarantee.

A recognized sensor DES name alone does not establish typed validity. Its
complete payload and association header must decode and validate before NFX
restores sensor verification. Otherwise it remains generic raw support data;
a model that requires that unverified descriptor fails full validation.

## JPEG2000

`File.read` uses MATLAB's `imread` JPEG2000 backend through a temporary raw
codestream file. Missing codec support and detected corruption return a
diagnostic. Decoder corruption warnings count as failure; caller warning
settings are restored. Reading is eager and needs space for decoded samples.

No OpenJPEG encoder is needed to read or rewrite an unchanged compressed
image. Its compression snapshot retains the original codestream, J2KLRA and
COMRAT; imported encoding metrics are empty because they are not on wire.
Replacing or editing `image.data` discards that snapshot. Compression after
a pixel edit is an explicit operation using the existing OpenJPEG prototype.
This host codec path is outside the Coder scope.

## A complete MIE collection

```matlab
[collection, ok, status] = nfx.MIECollection.read( ...
    'capture.c0i0.ntf');
if ~ok
    fprintf('%s: %s\n', status.code, status.message);
    return
end

files = collection.plan();
records = files(2).file.effectiveTREs(1, 1);
collection.blocks(1).image.header.icom = 'Reviewed acquisition';
collection.write('existing-output-folder');
```

The manifest's `FILE001`, `FILE002`, and subsequent text lists name the
members. Flat names are resolved relative to the manifest directory. NFX
does not scan a directory or guess missing members. Without a manifest,
supply an explicit cell or string vector of paths; order does not matter:

```matlab
members = {'capture.i2.ntf', 'capture.i1.ntf'};
[collection, ok, status] = nfx.MIECollection.read(members);
```

A scalar text path means a manifest; use `{filename}` for a one-member
explicit list. Supplied lists must agree with an included manifest. Files
must follow the writer's original-resolution naming scheme and have matching
collection definitions. A missing required file is different from a declared
`available=false` block: the former fails, while the latter is reconstructed.

Collection reading restores local templates, camera/layer/interval/block
relationships and timing. It binds all files before checking inherited
metadata and model relationships, then checks the reconstructed plan.
Edit the collection and replan to refresh inherited metadata. Changing a
bound `File` directly invalidates its captured collection context.

### Inspecting one collection member

`File.read` can inspect each individual collection file without its peers.
All locally stored content is available, and local container structure is
checked. `file.context_complete` and `status.context_complete` are false:
cross-file model and context checks still need the complete collection.
`validate` reports `CollectionContextRequired`; writing and `effectiveTREs`
require collection binding. Use `MIECollection.read` to obtain the complete
semantic view. A successful local read does not invent absent inherited TREs.

## Limits and diagnostics

Both readers accept `MaxBytes` and `MaxPixels`; defaults are `2^30` source
bytes and `2^28` decoded samples. A sample includes each band and frame.
Collection limits apply to the sum across members; `MaxFiles` defaults to
10,000. Supply positive finite integer `double` limits to change them.
These are input budgets, not guarantees of available process memory.

```matlab
[file, ok, status] = nfx.File.read('source.ntf', ...
    MaxBytes=2^29, MaxPixels=2^26);
```

Expected failure returns a fresh default scalar, `ok=false`, and `status`.
No partially recovered file is presented as a successful result.

| Status code | Meaning |
| --- | --- |
| `OK` | Stored content was reconstructed; check context completeness for a standalone MIE member |
| `InvalidInput` | Invalid path argument or limit |
| `MalformedFile` | Invalid lengths, bytes, relationships or detected codec corruption |
| `UnsupportedFeature` | Outside the supported encoding or organization |
| `ResourceLimit` | A configured source, sample or file-count budget was exceeded |
| `IOError` | Host file access, reading or codec staging failed |
| `MissingDependency` | The required host decoder is unavailable |
| `MissingFile` | A required collection member is absent |

`status.message` supplies detail. `path` identifies a source where available;
`scope` and `index` identify the affected owner or member. `offset` is a
zero-based source-byte offset, or `NaN` when unavailable. This differs from
the one-based payload cursor used by concrete TRE/DES deserialization.

## Validation boundaries

Generic read validity does not establish SNIP compliance or scientific
sensor-model accuracy. Request the supported profile checks separately:

```matlab
report = file.validate(SNIP_COMPLIANT=true);
```

Core code targets R2023b and later; local execution uses R2026a. Ordinary
native reading does not require GDAL or NITRO. The regression suite also
uses MathWorks `nitfread` as an independent still-image oracle and therefore
requires Image Processing Toolbox. JPEG2000 backend behavior is tested on
the local MATLAB installation.

Class structure, homogeneous TRE storage and explicit parse status preserve
the Coder design intent. Varying array dimensions and varying primitive
pixel classes are separate compilation questions. No local Coder license
is available; MATLAB execution and source review do not prove compiled
compatibility. Host filesystem, codec and publication services are excluded
from core generated-code claims.
