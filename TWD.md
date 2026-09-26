# TWD — three window display

`twd` is a separate image-viewing namespace under `src/+twd`. It follows the
ENVI Classic arrangement: a full-resolution main window, a whole-image
overview, and a linked magnified view. It accepts arrays independently of
NITF and does not depend on `nfx`.

## Start

Use MATLAB's **Home → Set Path** dialog to add NFX's `src` folder. Add
`examples` as well to run `threeWindowExample`. Package folders beginning
with `+` do not need individual path entries.

```matlab
viewer = twd.show(pixels);
viewer = twd.show(pixels(:, :, [3 2 1]), Title='False color');
```

For a file already read by NFX:

```matlab
viewer = twd.show(file.images(1).data, Title='Image 1');
```

The `.data` access loads deferred NFX pixels before opening the viewer.
The viewer accepts one in-memory grayscale or RGB image, not a file-backed
reader or a spectral band-selection interface. Select your desired three
bands first. Logical, `single`, `double`, and signed/unsigned 8-, 16-, and
32-bit integer arrays are supported. Arrays must be dense, real, nonempty,
and on the CPU. `viewer.Data` retains the native input values and type.

## Windows and controls

| Window | Display | Navigation and resizing |
| --- | --- | --- |
| Main | 1 display pixel per source pixel; default 500 × 500 canvas | Right-drag to pan. Click or drag its red box to position the zoom view. Resize to see more or fewer pixels at 1:1. |
| Overview | Whole image; initially about 400 pixels wide | Click to center the main view, or drag the red viewport box. Resizing constrains the window proportions to the source image. No independent pan or zoom. |
| Zoom | Default 4 display pixels per source pixel; 100 × 100 canvas | Click to center on a detail. Red **−** and **+** controls change magnification by one, down to 1:1. Resize to change the area shown while retaining the factor. The red crosshair marks the center. |

All three views preserve isotropic source pixels. Small images are padded
with black in the main and zoom windows, preserving their fixed scales.
The overview may have a subpixel rounding margin when its exact proportions
cannot be represented by integer window dimensions. Extremely narrow or wide
images have larger margins when native window chrome imposes a minimum size
(the overview uses at least 120 × 80). Initial windows are kept on screen,
with the overview and zoom below the main view. Tall overviews are reduced
to fit the available space.

**Sizes refer to MATLAB's graphics pixel units.** Windows display scaling
may map one such unit to multiple physical monitor pixels. The fixed scale
and aspect guarantee applies within that coordinate system; this version
does not calibrate physical monitor pixels across different DPI settings.

Arrow keys pan the main view when either main or overview has focus; in
the zoom window they move the zoom view. Shift-arrow moves ten source
pixels. **+**/**−** also change zoom magnification from the keyboard.
Closing any window closes its entire display group. Overview resizing keeps
its title bar on screen.

Panning the main view carries the zoom view with it. The zoom viewport stays
within the visible main image when it fits; if its window covers a larger
area, it centers over that region and its box outlines the portion visible
within the main window.

## Stretch and options

The default is a fixed linear **2–98% stretch per channel**, estimated from
up to 100,000 evenly spaced samples per channel. NaN/Inf samples are excluded
from the estimate and displayed as black in their channel. A collapsed
percentile range falls back to the sampled minimum and maximum; constant
finite channels display as mid-gray. Panning does not change the stretch.

```matlab
viewer = twd.show(pixels, ...
    Title='Scene', ...
    MainSize=[500 500], ...
    OverviewWidth=400, ...
    ZoomSize=[160 120], ...
    ZoomFactor=4, ...
    Stretch='percentile');

viewer = twd.show(pixels, Stretch='minmax');
viewer = twd.show(pixels, Limits=[0 4095]);

% RGB can use one limit pair per displayed channel.
viewer = twd.show(rgb, Limits=[0 4095; 100 3000; 0 2047]);
```

`ZoomFactor` supports integers from 1 through 1024. The controls stop at
these bounds; unsupported factors are rejected before changing the view.

`Limits` overrides `Stretch`. `minmax` scans all finite source values in
bounded chunks. Only display data is converted to RGB bytes. The main and
zoom views render cropped regions with nearest-neighbor interpolation; the
overview uses bilinear resampling of display intensities into a cached
thumbnail, after mapping nonfinite samples to black. Downsampling is
intended for navigation and can alias fine periodic patterns.

## Programmatic navigation

```matlab
viewer.panTo([1200 800]);       % Source [column row], first center [1 1]
viewer.zoomTo([1250 820]);      % Clamped to the visible main image
viewer.setZoomFactor(8);

mainRegion = viewer.MainViewport;   % [left top width height]
zoomRegion = viewer.ZoomViewport;   % Coordinates at pixel edges
delete(viewer);
```

Read-only properties also expose `MainCenter`, `ZoomCenter`, `ZoomFactor`,
`Limits`, and the three figure handles. Use figure `Position` to place or
resize a window. Changing internal axes, images, or callbacks directly is
outside the supported API and can defeat the fixed-scale constraints.

Multiple calls create independent groups. Cross-group linking is a later
feature. The controller publishes `NavigationChanged` after navigation or
resizing, so future linking can build on source coordinates without coupling
the three windows' different scales.

## Compatibility and verification

This is a MATLAB desktop utility, outside the toolbox's Coder target. It
uses base MATLAB graphics without `imshow`, Java helpers, Python, or Image
Processing Toolbox. It uses APIs available in the project's R2023b+ range;
local execution and GUI gesture tests use R2026a on Windows.

`runTests` includes `TwdDisplayTest`: native-data preservation, stretches,
fixed scales, resizing, bounds, overlays, mouse gestures, keyboard controls,
independent groups, and cleanup. Gesture tests briefly display their own
windows. They do not modify existing display groups.

## Reference behavior

The [ENVI Classic tutorial](https://www.nv5geospatialsoftware.com/portals/0/pdfs/envi/ENVI_Classic_Intro.pdf)
describes the image/scroll/zoom windows, viewport boxes, zoom controls, and
display-group linking (the display-window and linking sections).
[ENVI_DISP_QUERY](https://www.nv5geospatialsoftware.com/docs/ENVI_DISP_QUERY.html)
documents the main view's fixed full-resolution scale.

MATLAB's newer viewer has the required interactive callback APIs documented
as [R2026b additions](https://www.mathworks.com/help/images/ref/images.ui.graphics.viewer-properties.html).
TWD uses lower-level axes, images, and callbacks to provide these controls
on R2026a while keeping window geometry explicit.
