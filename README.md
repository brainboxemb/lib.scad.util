# lib.scad.util

Reusable OpenSCAD utility library with domain-independent geometry, inspection
and modeling helpers for shared CAD projects.

The library is intentionally small. Utilities belong here only when they are
useful across unrelated projects and do not encode product-specific geometry.

## Documentation

Start with the short examples below, then use the feature manuals for the
behavioral details and design rules:

| Area | Manual | Use it for |
| --- | --- | --- |
| Transform | [`openscad/transform/manual.md`](openscad/transform/manual.md) | moves, rotations, mirrors, transform objects and coordinate frames |
| Forge | [`openscad/forge/manual.md`](openscad/forge/manual.md) | tagged differences, Boolean overlap and reusable cutter objects |
| Inspection | [`openscad/inspection/design/design.md`](openscad/inspection/design/design.md) | section-inspection behavior and design context |

A useful rule of thumb is:

```text
xf_*    -> where/how geometry is placed
fg_*    -> how positive and negative geometry are combined
util_*  -> general utilities outside those language-like layers
```

## Transform helpers

`openscad/transform.scad` provides a deliberately small readability layer over
native OpenSCAD transforms. It uses plain OpenSCAD and does not depend on BOSL2.
It also supports reusable transform objects through `xf_create()` and
`xf_apply()`.

```openscad
use <openscad/transform.scad>

xf_zmove(10)
    xf_xrot(90)
        cylinder(d = 5, h = 20);

_part_xf =
    xf_create(
        pos_mm = [10, 0, 5],
        rot_deg = [0, 90, 0]
    );

xf_apply(_part_xf)
    cylinder(d = 5, h = 20);
```

Available helpers:

```openscad
xf_move([x, y, z]);

xf_xmove(x);
xf_ymove(y);
xf_zmove(z);

xf_flip([x, y, z]);
xf_xflip();
xf_yflip();
xf_zflip();

xf_rot([x_angle, y_angle, z_angle]);

xf_xrot(angle);
xf_yrot(angle);
xf_zrot(angle);

xf_create(pos_mm = [x, y, z], rot_deg = [x_deg, y_deg, z_deg]);
xf_apply(obj);

xf_frame(pos_mm = [x, y, z], x_axis = [...], y_axis = [...]);
xf_frame_create(pos_mm = [x, y, z], x_axis = [...], y_axis = [...]);
```

The `xf_` prefix is intentionally short because these helpers are language-like
transform primitives. General utilities continue to use the `util_` prefix.


### Coordinate frames

Use `xf_frame()` when the intent is to remap local axes rather than express
the same operation as matrix coefficients. Any two orthogonal destination axes
are enough; the third is derived as a right-handed frame.

```openscad
xf_frame(
    pos_mm = [10, 0, 0],
    x_axis = [0, 1, 0],
    y_axis = [0, 0, 1]
)
    linear_extrude(height = 20)
        square([5, 5]);
```

The object form uses the same `xf_apply()` path:

```openscad
_frame =
    xf_frame_create(
        pos_mm = [10, 0, 0],
        x_axis = [0, 1, 0],
        y_axis = [0, 0, 1]
    );

xf_apply(_frame)
    child_geometry();
```

Frames are deliberately orthogonal: the transform layer does not silently
introduce skew when axes are not perpendicular. Reflections stay explicit via
`xf_flip()` / `xf_*flip()`.

See the [Transform manual](openscad/transform/manual.md) for frame semantics,
object transforms, migration examples and the boundary with native OpenSCAD.

## Forge modeling helpers

`openscad/forge.scad` is a deliberately small modeling layer inspired by the
readability of BOSL2 tagged booleans and Relativity.scad class-based CSG, while
remaining plain OpenSCAD and compatible with this portfolio's `object()` APIs.

Forge does not implement attachments, selector expressions or replacement
primitives. Its tagged difference is intentionally explicit:

```openscad
use <openscad/forge.scad>

fg_diff() {
    fg_body()
        body();

    fg_remove()
        hole();

    fg_keep()
        rib();
}
```

The result is `(body - remove) + keep`. Every participating geometry branch
inside `fg_diff()` should use `fg_body()`, `fg_remove()` or `fg_keep()`. The
underlying `fg_tag()` is available when a role needs to be selected by name.

Forge owns a small default boolean overlap of **0.001 mm** through
`fg_overlap_mm()`. Cutter helpers apply that overlap automatically so callers
do not need to scatter tiny `+ 0.001` / `- 0.001` corrections through model
code:

```openscad
fg_remove()
    fg_cut_box(
        size_mm = [10, 20, 5],
        pos_mm = [5, 0, 0]
    );
```

For reusable specifications:

```openscad
_cut =
    fg_box_cutter_create(
        size_mm = [10, 20, 5],
        pos_mm = [5, 0, 0]
    );

fg_cutter_build(_cut);
```

Box cutters support independent negative/positive overlap per axis. Cylinder
cutters support radial, bottom and top overlap.

See the [Forge manual](openscad/forge/manual.md) for role semantics, overlap
rules, cutter-object usage, migration examples and explicit non-goals.

## Section inspection

`util_section_inspect()` retains an exact slab of child geometry along X, Y or
Z.

```openscad
use <openscad/inspection.scad>

util_section_inspect(
    axis = "Z",
    position = 0,
    depth = 0.1,
    direction = "Positive"
)
    my_model();
```

All distances are millimetres. The example retains only
`Z = 0.0 .. +0.1 mm`; `direction="Negative"` retains
`Z = -0.1 .. 0.0 mm`. `axis="None"` passes the child geometry through.

## Synchronize the interactive consumer controls

The library owns a canonical OpenSCAD Customizer block so consumers do not
quietly drift to different variable names, defaults or ranges.

After importing `inspection.scad`, synchronize the managed block into a
consumer `main.scad` with either:

```bash
bash dsg/openscad/ext/lib.scad.util/consumer/sync-section-inspection.sh \
  dsg/openscad/main.scad
```

or:

```powershell
& .\dsg\openscad\ext\lib.scad.util\consumer\sync-section-inspection.ps1 \
  dsg\openscad\main.scad
```

The command is idempotent. If the managed markers are absent it appends the
block. If they already exist it replaces that block with the current
library-owned version.

The synchronized variables are:

```openscad
section_axis = "None";          // [None,X,Y,Z]
section_position_mm = 0;        // [-100:0.5:100]
section_depth_mm = 10;          // [0.1:0.1:200]
section_direction = "Positive"; // [Positive,Negative]
```

The managed block contains only Customizer variables, so it can safely stay
with the consumer's other top-level parameters. The model is wrapped explicitly
where it is rendered:

```openscad
util_section_inspect(
    axis = section_axis,
    position = section_position_mm,
    depth = section_depth_mm,
    direction = section_direction
)
    selected_view();
```

## Scope

Good candidates for this repository are helpers that:

- are useful across unrelated OpenSCAD projects;
- do not encode project-specific dimensions or hardware semantics;
- do not require build/project-tooling behaviour;
- have a small, stable API and independent verification.

Domain geometry belongs in its owning library or project.

## Repository layout

```text
openscad/
  forge.scad
  forge/manual.md
  inspection.scad
  inspection/design/design.md
  transform.scad
  transform/manual.md

consumer/
  section-inspection.scad
  sync-section-inspection.sh
  sync-section-inspection.ps1

test/
  forge.scad
  section_inspection.scad
  transform.scad

scripts/
  run-verification.sh
```
