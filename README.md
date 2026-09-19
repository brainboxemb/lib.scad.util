# lib.scad.util

Reusable OpenSCAD utility library with domain-independent geometry, inspection
and modeling helpers for shared CAD projects.

The library is intentionally small. Utilities belong here only when they are
useful across unrelated projects and do not encode product-specific geometry.

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

The block also defines `util_section_inspect_configured()`, so the consumer
only needs:

```openscad
util_section_inspect_configured()
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
  inspection.scad
  inspection/design/design.md

consumer/
  section-inspection.scad
  sync-section-inspection.sh
  sync-section-inspection.ps1

test/
  section_inspection.scad

scripts/
  run-verification.sh
```
