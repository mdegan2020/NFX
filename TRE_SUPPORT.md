# Additional TRE support

These extensions use the same snapshot, removal, display and typed lookup
API as RPC00B. Field names follow the standard's mnemonics in lowercase.
Deserializers return an independent concrete object plus `ok` and `status`.
Missing typed lookups return a newly constructed scalar object and `ok=false`.

| TRE | Direct owners | Supported behavior |
| --- | --- | --- |
| GEOPSB | File, image | Coordinate system, units and datum/grid codes, including published legacy codes |
| BNDPLC | File, image | Multiple 2-D/3-D rings, GEOPSB association, units, ring intersections and nesting |
| XMLDCA | File, image, text | Four descriptive subheader sizes, original content bytes and optional CRC-16 |
| SECURA | File, image, text | Security envelope, original document bytes, copied header fields and file-header prerequisite |
| PIXQLA | Image | Bit conditions, modifiers, display-level associations, image dimensions and wavelengths |
| CSCCGA | Image | Cloud grid fields, binary/percentage pixels, dimensions and origin |
| MSTGTA | Image | Planned target fields, distinct active target numbers and empty placeholders |
| BLOCKA | Image | Block fields, precise parent corners and radar-only fields |
| ENGRDA | File, image, text | Ordered engineering descriptors and original data bytes, with typed conversion helpers |

Legal frame/context wrappers retain their encoded children. These additions
do not use asynchronous wrappers. Repeated engineering, XML and security
records retain separate attachments; they are not concatenated.

## Engineering data

```matlab
entry = nfx.ENGRDA.entry('Temperature', single([280 281; 282 283]), 'K');
engineering = nfx.ENGRDA(resrc='Sensor A', redata=entry);
image = image + engineering;

for index = 1:image.treCount('ENGRDA')
    [engineering, found] = image.ENGRDA(index);
    if found
        [values, decoded] = nfx.ENGRDA.values( ...
            engineering.redata(1), single(0));
    end
end
```

`redata` is a homogeneous struct array. Its fields are `englbl`, `engmtxc`,
`engmtxr`, `engtyp`, `engdts`, `engdatu`, and `engdata`. Matrix sizes, label
lengths and symbol counts derive automatically. `engdata` always contains a
`uint8` row in big-endian, row-major wire order. Entries can differ in shape,
element type and byte length without storing heterogeneous decoded objects.

The conversion helpers support native integers, real single/double, complex
single and BCS character matrices (printable ASCII plus LF, FF and CR).
`values` takes a scalar prototype to fix
the return type. Unusual integer byte widths remain available as raw bytes.
The one-digit byte-width field cannot represent complex doubles.

Run `writeExtendedMetadata(folder)` from the examples path for a complete
synthetic file, a polygon, XML with a checksum, and typed engineering data.

## Quality and cloud images

Quality image support covers still masks with `icat='PIXQUAL'`,
`irep='NODISPLY'`, `imode='B'`, and native unsigned 8- or 16-bit pixels.
Temporal `PIXQUAL.M` segments remain unsupported. NFX checks the local
PIXQLA condition count when deriving
automatic ABPP, including unused high bits in an all-zero mask. The supported
precision ranges are 2–8 bits for uint8 and 9–16 bits for uint16. Explicit
ABPP must cover the conditions. For PIXQLA inherited from file context,
supply an explicit ABPP that covers those conditions.

PIXQLA associations use image display levels, not segment indices. A mask
may have full image dimensions or one compact row/column. Band counts must
match the associated images or equal one. Wavelengths follow Appendix AA's
association rules. Masks retain aligned acquisition and coordinate metadata.
Binary packed samples, signed samples, wider types and LUTs remain outside
the native reader/writer's supported image storage.

Cloud images use `icat='CLOUD'`, `irep='MONO'`, one uint8 band, and ABPP=8.
`isubcat_text='CLDPCT'` selects percentage values 0–100. Blank
`isubcat_text` selects binary values 0/255. Both support 253 for fill and
254 for unknown. The existing numeric `isubcat` wavelength API remains
available; a band cannot have both a wavelength and a literal category.
ILOC expresses `[origin_line origin_sample] - 1` in the supported display
coordinate layout. Numerically lossless NC or existing C8 storage is supported.

NFX validates local numeric cloud references, which must identify base
images (`ialvl=0`). Named references can refer to
external imagery. Source selection, actual cloud classification, motion
timestamp associations and whether a supplied grid was previously chipped
remain the data provider's responsibility. CSCCGA support does not certify
the entire CCIS product workflow.

## Polygon and document boundaries

BNDPLC validates non-touching simple rings with clockwise exteriors and
alternating nested holes. Geographic validation uses unwrapped longitude
and latitude in a local coordinate plane, with ring spans below 180 degrees.
It does not perform ellipsoidal/geodesic or polar topology. Meter-coordinate
rings require PRJPSB, which has no concrete decoder yet; an imported opaque
PRJPSB can be retained, with incomplete semantic validation. Supporting these
two GeoSDE records does not constitute a complete GeoSDE georeferencing model.

XMLDCA retains its original XML-related content encoding. NFX validates the
container, descriptive fields and supplied checksum. It does not interpret
the XML application schema. `updateCRC()` computes the STANAG 7023 CRC-16
(polynomial 0x8005, initial zero, MSB first, no reflection or final XOR).

SECURA supports the current unclassified NITF 2.1 header profile. Copied FDT
and security fields must match the owner; NFX does not silently repair them.
If an image or text segment has SECURA, the file header needs SECURA too.
The security document, including any supplied GZIP stream, is preserved as
bytes. XML/GZIP parsing and registered security-schema validation are
external. `SecurityDocumentUnchecked` therefore makes `report.complete` and
`status.metadata_complete` false, while valid envelope data can be written.
This is envelope support, not security-policy validation or certification.

SECURA's Appendix AI maximum is 99,988 payload bytes. NFX handles that
specific limit through overflow; other concrete TREs retain the common
99,985-byte maximum. Unknown five-digit payloads up to 99,999 bytes can still
be preserved without a schema claim.

FIRELA remains deferred. RSMIDC receives the ordinary unknown-TRE treatment,
with no alias, automatic reinterpretation or special code.

## References and Coder status

The implementation follows the local pinned STDI-0002-1 appendices:
E (2025-02), N, P (2024-04), AA (2022-10), AE, AI and AV (2024-06).
Tests use synthetic independent byte expectations, the published STANAG
CRC vector, malformed fields, file round trips and relationship checks.

Implementation retains applicable `%#codegen` annotations, typed accessors
and homogeneous serialized storage. The portable `engineering` probe adds
varying ENGRDA descriptor types and lengths to the [Coder kit](CODER_TESTS.md).
MATLAB execution of that probe is tested locally. Compiled compatibility
and R2023b execution remain unverified.
