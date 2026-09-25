# Reading NFX files

NFX reads the NITF 2.1 layouts that its writer supports. It returns the same
value classes used to construct files, with editable metadata and deferred
native `uint8` or `uint16` pixels. This is a bounded reader, not a promise to
accept every valid NITF file from another producer.

## A single file

```matlab
[file, ok, status] = nfx.File.read('source.ntf');
if ~ok
    fprintf('%s: %s\n', status.code, status.message);
    return
end

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

Configure MATLAB's path through **Home > Set Path > Add Folder** and select
only the NFX `src` folder. Namespace subfolders resolve through that parent.
Recursively adding the repository root can expose old validation checkouts
under the ignored `artifacts/` folder.

### Read pixels when needed

The default reads complete supported headers, TREs (including overflow),
text and DES payloads. It seeks past image payloads without reading or
decoding them. Every image remains present in `file.images`, with dimensions,
comments, band metadata, TRE accessors and segment lengths available.

```matlab
% Retain every image's pixels during the initial read.
[file, ok, status] = nfx.File.read('source.ntf', readAll=true);

% Retain pixels only for image segments 1 and 2.
[file, ok, status] = nfx.File.read('source.ntf', readSegment=[1 2]);

% Load additional pixels into a new value; retain the returned object.
[file, ok, status] = file.readSegment(3);
[file, ok, status] = file.readAll();

% Load an independent image value.
[image, ok, status] = file.images(1).read();
file = file.replaceImage(1, image);

% Convenient temporary access, without retaining pixels in file.
pixels = file.images(1).data;
```

`readSegment` uses one-based **image segment** indices, regardless of text or
DES order. Indices must be distinct; their order does not reorder the file.
Use either `readAll=true` or `readSegment=...` in the initial call. File-level
methods delegate decoding to `ImageSegment.read`. Already loaded images are
reused, and a failed explicit read leaves the original value unchanged.

`image.pixelsLoaded` reports whether native pixels are retained. A `.data`
getter loads a temporary image when needed; repeated accesses can repeat
I/O and decoding. Use the explicit methods to retain pixels. Getter failures
throw `nfx:ReadPixels`; explicit methods provide `ok` and `status` instead.
Displaying an image, inspecting headers, and validating metadata do not
trigger pixel reads. `compression` remains empty until a compressed image
is loaded; its C8 header fields and J2KLRA are available immediately.

Unloaded images retain an absolute source path, offsets, source size and
modification time, and header snapshots. Moving/deleting the source or
changing its size, timestamp or headers makes a later read fail. These checks
are not a hash of the skipped payload: changes that preserve all these
attributes cannot be detected in advance. Loaded images no longer depend
on the source. Assigning `image.data` replaces that dependency and restores
ordinary uncompressed storage.

`status.pixels_complete` is false while any image is deferred. Metadata-only
success does not establish pixel precision, padding, cloud-value or JPEG2000
codestream validity. Validation reports `PixelsDeferred` warnings and
`complete=false` until pixels are loaded; `metadata_complete` still describes
the supported metadata. `write` temporarily loads remaining images, then
validates the complete file before creating output. This uses the retained
read budgets and does not populate the caller's original object. To preserve
low memory use, inspect metadata or load individual segments; writing still
requires all image pixels in memory.

Automatic `.data` loading uses the existing dependent-property getter, with
host I/O excluded by `coder.target('MATLAB')`. Generated code can use already
loaded arrays; it rejects deferred access. No handle cache, `subsref` overload,
or heterogeneous decoded collection is introduced. Compiled compatibility
remains unverified locally because no MATLAB Coder license is available.

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

The [additional TRE guide](TRE_SUPPORT.md) lists the newer concrete schemas.
SECURA retains document bytes and validates its envelope, but external
security-document validation remains incomplete. Such files expose
`SecurityDocumentUnchecked` and `metadata_complete=false`, even if every
tag is recognized. Their valid stored content can still be rewritten.

SENSRB reading and writing also accept the documented
[level-8 scanner velocity deviation](README.md#known-sensrb-velocity-deviation):
Pushbroom and Whiskbroom records may omit module 10 while retaining level 8.

`sensor = file.images(1).SENSRB` consolidates continuation chunks into one
`sensor.time_stamped_data` entry per `time_stamp_type`. Types appear in their
first-seen order; time/value pairs retain their original order, including
duplicate timestamps. Module-12 uncertainty references address the merged
groups. Separate logical SENSRB attachments remain separate, and the image's
raw physical `tre_records` are unchanged.

| Content | Reading behavior |
| --- | --- |
| Uncompressed imagery | Blocked B/F/T layouts, native unsigned samples, bands, frames, edge padding, multiple images |
| Image metadata | Comments, band fields, corners, stored ABPP/PJUST and display relationships |
| Quality/cloud imagery | Still unsigned PIXQUAL masks, CLOUD binary/percentage grids, PIXQLA associations and CSCCGA metadata |
| TREs | Concrete types and opaque unknown tags; repeated records, SENSRB continuation groups, wrappers and overflow ownership |
| Text | Supported STA text and subheaders, including text-only files |
| Generic DESs | Exact payload and supported subheader bytes; no semantic claim about arbitrary registered data |
| GLAS/GFM DESs | Typed CSATTB, CSEPHB, CSSFAB and CSCSDB layouts already supported by the writer |
| JPEG2000 | Existing lossless NPJE/EPJE C8 still-image output |
| Collections | Original-resolution uncompressed MIE collections, explicit members, manifests, quick looks and unavailable blocks |

Lengths, counts, conditional headers and source bounds are checked before
content is reconstructed. Supplied structural values must agree with the
decoded data. Known TRE payloads follow the NFX writer's canonical rules.
Imported metadata retains its original extended/user/overflow partition
until attachments change. One overflow area per owner is supported; generic
DESs precede overflow DESs in owner order. Unsupported layouts and conflicting
fields produce a diagnostic instead of silently dropping or repairing data.

TRE payloads, generic DES payloads and untouched compressed codestreams are
preserved. Native significant pixels, exact `uint64` timing, and metadata at
encoded precision survive a semantic write/read/write round trip. Whole-file
byte identity is tested in many cases but is not the public guarantee.

A recognized sensor DES name alone does not establish typed validity. Its
complete payload and association header must decode and validate before NFX
restores sensor verification. Otherwise it remains generic raw support data;
a model that requires that unverified descriptor fails full validation.

## Unknown TREs

An unrecognized tag is retained as an opaque `tre_record`: its six-character
tag, exact `uint8` payload, owner and insertion order survive reading and
writing. This also applies to unknown children of supported wrappers and to
overflow records. Opaque payloads can contain up to 99,999 bytes. Known
wrappers retain their existing size limits. Malformed envelopes, invalid
overflow pointers and malformed **known** payloads still fail reading.

`status.metadata_complete` is false when unknown TREs are present. Validation
reports also expose `complete=false` and `UnknownTRE` warnings. `valid=true`
then means the checked container and known fields pass; it does not establish
the meaning of the opaque bytes. Image model companion checks are deferred
for contexts containing unknown metadata, along with cross-image model
checks when metadata is incomplete. Ordinary writing permits this explicit
pass-through state. `SNIP_COMPLIANT=true` rejects incomplete metadata.

```matlab
image = file.images(1);
[view, found] = image.tre(1);
if found
    disp(view);                 % Shows the tag and lack of a decoder.
    raw = view.records;         % Independent homogeneous snapshots.
    payloadBytes = numel(raw(1).payload);

    % Remove an attachment while retaining the other file content.
    image = image.removeTRE(view.id);
    file = file.replaceImage(1, image);
end
```

For a deliberate format probe, copy a raw record, compare its payload length
with a known format, and change **the copy's** tag. For example, if you suspect
an RPC00B layout, `probe.tag = 'RPC00B'; disp(nfx.TRERecord(probe))` invokes
that decoder for inspection. `nfx.RPC00B.deserialize(probe.payload)` returns
an editable concrete value and success status. This never changes the original
attachment, infers an alias, or proves an undocumented format equivalent.
See [inspectTREPayload](examples/inspectTREPayload.m) for a bounded example.

## JPEG2000

When pixels are requested, NFX uses MATLAB's `imread` JPEG2000 backend
through a temporary raw codestream file. Missing codec support and detected
corruption return a diagnostic. Decoder corruption warnings count as failure;
caller warning settings are restored. Loading a selected image decodes its
complete pixel array and needs memory for those samples.

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

`File.read` accepts optional `MaxBytes` and `MaxPixels` budgets. Both default
to `flintmax`, so ordinary local files are not rejected by a small fixed cap.
Supply positive finite integer `double` values when explicit caps are needed.
These are limits, not preallocations or guarantees of available memory.

`MaxBytes` bounds retained metadata plus selected encoded image payloads in
the initial read. Skipped image payloads do not count. For later file methods,
it bounds the newly requested encoded payloads; for a segment method, that
segment's payload. Small header rechecks are additional I/O. `MaxPixels`
counts all retained image samples after a file-level read, including each
band and frame; a segment-level read counts only that segment. Initial
budgets carry forward; method options override them for that operation.

`MIECollection.read` continues to read eagerly, with defaults of `2^30`
source bytes, `2^28` decoded samples and 10,000 files. Its limits apply across
members. Use `File.read` to inspect a single member without loading pixels.

```matlab
[file, ok, status] = nfx.File.read('source.ntf', ...
    readAll=true, MaxBytes=2^30, MaxPixels=1e9);
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
| `SourceChanged` | A deferred source changed after its metadata was read |
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
