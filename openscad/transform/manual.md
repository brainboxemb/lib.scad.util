# Transform helpers

`openscad/transform.scad` is a small readability layer over native OpenSCAD
transforms. It keeps the underlying coordinate model visible while avoiding
repeated low-level `translate()`, `rotate()`, `mirror()` and axis-remapping
matrix boilerplate in consumer code.

The API uses the short `xf_` prefix because these helpers behave like language
primitives rather than domain geometry.

## Choosing the right transform

| Intent | Prefer |
| --- | --- |
| Move by an XYZ vector | `xf_move()` |
| Move on one axis | `xf_xmove()`, `xf_ymove()`, `xf_zmove()` |
| Rotate by Euler angles | `xf_rot()` |
| Rotate on one axis | `xf_xrot()`, `xf_yrot()`, `xf_zrot()` |
| Mirror geometry | `xf_flip()` or an axis-specific `xf_*flip()` |
| Store position + rotation as data | `xf_create()` + `xf_apply()` |
| Remap local coordinate axes | `xf_frame()` |
| Store an axis remap as data | `xf_frame_create()` + `xf_apply()` |
| General affine/skew transform | native `multmatrix()` |

The library does not try to replace every native OpenSCAD transform. Use the
smallest helper that makes the design intent clearer.

## Simple placement

Instead of:

```openscad
translate([10, 0, 5])
    rotate([0, 90, 0])
        part();
```

write:

```openscad
xf_move([10, 0, 5])
    xf_yrot(90)
        part();
```

When only one axis changes, use the axis-specific form:

```openscad
xf_zmove(12)
    part();
```

These helpers intentionally have the same transform ordering as their nested
native OpenSCAD equivalents.

## Transform objects

Use `xf_create()` when the transform itself is meaningful data that should be
created once and reused:

```openscad
_mount_xf =
    xf_create(
        pos_mm = [10, 0, 5],
        rot_deg = [0, 90, 0]
    );

xf_apply(_mount_xf)
    mount();
```

A pose object contains a position in millimetres and Euler rotation in degrees.
`xf_apply()` also accepts frame objects created by `xf_frame_create()`.

The object form is useful when an owning object needs to carry placement state,
or when several pieces of geometry must share exactly the same transform. For a
single obvious operation, the direct `xf_move()` / `xf_*rot()` modules are
usually easier to read.

## Coordinate frames

A coordinate frame describes where the **local axes** of child geometry should
point.

Use `xf_frame()` when the intent is axis remapping rather than an ordinary
Euler rotation. Supply any two orthogonal destination axes; the third is
derived so the result remains right-handed.

For example:

```openscad
xf_frame(
    pos_mm = [20, 0, 0],
    x_axis = [0, 1, 0],
    y_axis = [0, 0, 1]
)
    linear_extrude(height = 16)
        profile();
```

This says:

```text
local +X -> global +Y
local +Y -> global +Z
local +Z -> global +X
origin   -> [20, 0, 0]
```

The equivalent raw matrix is harder to inspect:

```openscad
multmatrix([
    [0, 0, 1, 20],
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 0, 1]
])
    linear_extrude(height = 16)
        profile();
```

The frame form communicates the CAD intent without asking the reader to decode
matrix coefficients.

### Frame rules

- at least two of `x_axis`, `y_axis`, `z_axis` must be supplied;
- supplied axes must be non-zero vectors;
- the resolved axes must be mutually orthogonal;
- the frame must be right-handed;
- axis vector length is ignored: directions are normalized;
- `pos_mm` is the destination origin.

The transform layer deliberately rejects a non-orthogonal frame rather than
silently introducing skew.

## Reflected frames

A reflection changes handedness, so it is kept separate from `xf_frame()`.

If an axis remap also needs a reflection, write that explicitly:

```openscad
xf_frame(
    x_axis = [1, 0, 0],
    y_axis = [0, 0, 1]
)
    xf_zflip()
        part();
```

That is easier to review than hiding the reflection inside a matrix.

Axis-specific mirrors are:

```openscad
xf_xflip(); // mirror across YZ
xf_yflip(); // mirror across XZ
xf_zflip(); // mirror across XY
```

Use `xf_flip(v)` when the mirror-plane normal is not aligned to a primary
axis.

## What stays native

Keep native OpenSCAD when the native operation already expresses the intent
best. In particular:

- `scale()` remains native;
- `multmatrix()` remains appropriate for a genuine general affine transform
  or skew that `xf_frame()` cannot represent;
- geometry-generating operations such as `linear_extrude()` and
  `rotate_extrude()` are not wrapped merely for naming consistency.

The goal is readable CAD, not hiding OpenSCAD.
